import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../../../core/exceptions/ml_exceptions.dart';
import '../../../../core/ml/classification_service.dart';
import '../../../../core/ml/image_processor.dart';
import '../../../../core/ml/image_processor_isolate.dart';
import '../../../../core/ml/tflite_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/animated_card.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../herd_management/data/models/analysis_model.dart';
import '../../../herd_management/data/models/animal_model.dart';
import '../../../herd_management/data/repositories/analysis_repository.dart';
import '../../../herd_management/presentation/controllers/herd_notifier.dart';
import '../../../herd_management/presentation/widgets/save_analysis_bottom_sheet.dart';
import '../widgets/classification_result_widget.dart';
import '../widgets/segmentation_results_widget.dart';
import '../widgets/stats_card.dart';
import 'camera_guide_page.dart';
import 'photo_gallery_page.dart';

class AnalysisCapturePage extends StatefulWidget {
  const AnalysisCapturePage({super.key, this.preselectedAnimal});

  final AnimalModel? preselectedAnimal;

  @override
  State<AnalysisCapturePage> createState() => _AnalysisCapturePageState();
}

class _AnalysisCapturePageState extends State<AnalysisCapturePage> {
  final TFLiteService _mlService = TFLiteService();
  final ClassificationService _classificationService = ClassificationService();
  bool _isProcessing = false;
  bool _isSaving = false;

  File? _analyzedImage;
  Uint8List? _segmentationMask;
  double? _coveragePercentage;
  ClassificationResult? _classificationResult;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      // Carrega ambos os modelos
      await Future.wait([
        _mlService.loadModel(),
        _classificationService.loadModel(),
      ]);
      if (!mounted) return;
      setState(() {
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            e is MLException ? e.message : 'Erro ao carregar modelo: $e';
      });
    }
  }

  Future<void> pickImage() async {
    if (!_mlService.isLoaded || !_classificationService.isLoaded) {
      _showError('Modelos ainda não foram carregados. Aguarde...');
      return;
    }

    try {
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Selecionar Imagem'),
            content: const Text('Escolha a origem da imagem:'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, ImageSource.camera),
                child: const Text('Câmera'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, ImageSource.gallery),
                child: const Text('Galeria'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          );
        },
      );

      if (source == null) return;

      File? imageFile;

      if (source == ImageSource.camera) {
        try {
          final result = await Navigator.push<File>(
            context,
            MaterialPageRoute(
              builder: (context) => const CameraGuidePage(),
            ),
          );

          if (!context.mounted) return;
          if (result == null) return;
          imageFile = result;
        } catch (e) {
          if (!context.mounted) return;
          debugPrint('Erro ao abrir câmera personalizada: $e');
          _showError('Erro ao abrir câmera. Verifique as permissões.');
          return;
        }
      } else {
        final ImagePicker picker = ImagePicker();
        XFile? pickedFile;

        try {
          pickedFile = await picker.pickImage(
            source: source,
            imageQuality: 85,
          );
        } catch (e) {
          if (!context.mounted) return;
          debugPrint('Erro ao pegar imagem: $e');
          _showError('Erro ao acessar galeria. Verifique as permissões.');
          return;
        }

        if (pickedFile == null) return;
        imageFile = File(pickedFile.path);
      }

      if (!await imageFile.exists()) {
        _showError('Arquivo de imagem não encontrado.');
        return;
      }

      File finalImageFile = imageFile;

      try {
        final CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: imageFile.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Recortar Imagem',
              toolbarColor: Colors.deepPurple,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
              hideBottomControls: false,
              showCropGrid: true,
            ),
            IOSUiSettings(
              title: 'Recortar Imagem',
              aspectRatioLockEnabled: true,
            ),
          ],
        );

        if (croppedFile != null) {
          final croppedFileCheck = File(croppedFile.path);
          if (await croppedFileCheck.exists()) {
            finalImageFile = croppedFileCheck;
          }
        }
      } catch (e, stackTrace) {
        debugPrint('Erro ao recortar imagem (usando original): $e');
        debugPrint('Stack trace: $stackTrace');
      }

      if (!await finalImageFile.exists()) {
        _showError('Não foi possível acessar a imagem selecionada.');
        return;
      }

      await _processImage(finalImageFile);
    } catch (e, stackTrace) {
      debugPrint('Erro ao selecionar imagem: $e');
      debugPrint('Stack trace: $stackTrace');
      _showError('Erro ao selecionar imagem: ${e.toString()}');
    }
  }

  Future<void> _processImage(File imageFile) async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _analyzedImage = imageFile;
      _segmentationMask = null;
      _coveragePercentage = null;
      _classificationResult = null;
    });

    try {
      if (!await imageFile.exists()) {
        throw Exception('Arquivo de imagem não existe mais.');
      }

      final Float32List inputTensor =
          await ImageProcessorIsolate.preprocessImageWithIsolate(imageFile);

      final statistics = await _mlService.runSegmentation(inputTensor);

      if (!mounted) return;

      // Executa classificação após segmentação bem-sucedida
      ClassificationResult? classificationResult;
      try {
        // Lê a imagem original
        final imageBytes = await imageFile.readAsBytes();
        final decodedImage = img.decodeImage(imageBytes);
        
        if (decodedImage != null) {
          // Extrai a região segmentada
          final segmentedRegion = ImageProcessor.extractSegmentedRegion(
            decodedImage,
            statistics.mask,
          );
          
          // Pré-processa para classificação
          final classificationTensor = ImageProcessor.preprocessForClassification(
            segmentedRegion,
          );
          
          // Executa classificação
          classificationResult = await _classificationService.runClassification(
            classificationTensor,
          );
        }
      } catch (e) {
        debugPrint('Erro ao executar classificação: $e');
        // Não falha o processo se a classificação falhar
      }

      if (!mounted) return;

      setState(() {
        _segmentationMask = statistics.mask;
        _coveragePercentage = statistics.coveragePercentage;
        _classificationResult = classificationResult;
        _isProcessing = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Erro ao processar imagem: $e');
      debugPrint('Stack trace: $stackTrace');

      if (!mounted) return;

      final errorMessage = e is MLException
          ? e.message
          : 'Erro ao processar imagem: ${e.toString()}';

      setState(() {
        _errorMessage = errorMessage;
        _isProcessing = false;
        _segmentationMask = null;
        _coveragePercentage = null;
        _classificationResult = null;
      });

      _showError(errorMessage);
    }
  }

  Future<Uint8List?> _createSegmentationOverlay(
    img.Image originalImage,
    Uint8List segmentationMask,
  ) async {
    final imageBytes = Uint8List.fromList(img.encodePng(originalImage));

    return ImageProcessorIsolate.createSegmentationOverlayWithIsolate(
      imageBytes,
      segmentationMask,
    );
  }

  Future<void> _onSaveAnalysis() async {
    if (_analyzedImage == null ||
        _segmentationMask == null ||
        _coveragePercentage == null) {
      return;
    }

    final request = await SaveAnalysisBottomSheet.show(
      context,
      preselectedAnimalId: widget.preselectedAnimal?.id,
      defaultRecordedAt: DateTime.now(),
    );

    if (request == null) {
      return;
    }

    if (!context.mounted) return;
    setState(() {
      _isSaving = true;
    });

    try {
      final overlayBytes = await _generateOverlayBytes();
      final savedPaths = await _persistImages(
        animalId: request.animalId,
        overlayBytes: overlayBytes,
      );

      final analysis = AnalysisModel(
        animalId: request.animalId,
        recordedAt: request.recordedAt.toUtc(),
        score: _coveragePercentage!,
        originalImagePath: savedPaths.original,
        segmentedImagePath: savedPaths.segmented,
        actionTaken: request.actionTaken,
        notes: request.notes,
        anemiaClassification: _classificationResult?.predictedClass,
        classificationConfidence: _classificationResult?.confidence,
      );

      if (!context.mounted) return;

      final analysisRepository = context.read<AnalysisRepository>();
      final herdNotifier = context.read<HerdNotifier>();

      await analysisRepository.addAnalysis(analysis);
      await herdNotifier.refresh();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Análise salva com sucesso.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Erro ao salvar análise: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<_SavedAnalysisPaths> _persistImages({
    required int animalId,
    required Uint8List? overlayBytes,
  }) async {
    final baseDir = await getApplicationDocumentsDirectory();
    final analysesDir = Directory(
      p.join(baseDir.path, 'analyses', animalId.toString()),
    );

    if (!await analysesDir.exists()) {
      await analysesDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final originalPath = p.join(analysesDir.path, '${timestamp}_original.jpg');
    await _analyzedImage!.copy(originalPath);

    String segmentedPath = originalPath;
    if (overlayBytes != null) {
      segmentedPath = p.join(analysesDir.path, '${timestamp}_segmentada.png');
      await File(segmentedPath).writeAsBytes(overlayBytes, flush: true);
    }

    return _SavedAnalysisPaths(
      original: originalPath,
      segmented: segmentedPath,
    );
  }

  Future<Uint8List?> _generateOverlayBytes() async {
    if (_analyzedImage == null || _segmentationMask == null) {
      return null;
    }

    final bytes = await _analyzedImage!.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;
    return _createSegmentationOverlay(decoded, _segmentationMask!);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        elevation: 6,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _mlService.dispose();
    _classificationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _isProcessing || _isSaving;
    final busyMessage = _isProcessing
        ? 'Processando imagem...'
        : 'Salvando análise...';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova análise'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF5F7FA),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    AnimatedCard(
                      delay: const Duration(milliseconds: 100),
                      child: _buildModelStatus(),
                    ),
                    const SizedBox(height: 24),
                    AnimatedCard(
                      delay: const Duration(milliseconds: 200),
                      child: GradientButton(
                        text: 'Tirar Foto / Selecionar',
                        icon: Icons.camera_alt,
                        onPressed:
                            isBusy || !_mlService.isLoaded ? null : pickImage,
                        isLoading: false,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedCard(
                      delay: const Duration(milliseconds: 250),
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PhotoGalleryPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Ver Exemplos de Fotos'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(
                            color: AppTheme.primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_errorMessage != null)
                      AnimatedCard(
                        delay: const Duration(milliseconds: 300),
                        backgroundColor: AppTheme.errorColor.withOpacity(0.1),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: AppTheme.errorColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: AppTheme.errorColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_analyzedImage != null && !_isProcessing)
                      AnimatedCard(
                        delay: const Duration(milliseconds: 300),
                        child: _buildImageCard(),
                      ),
                    if (_segmentationMask != null && !_isProcessing)
                      AnimatedCard(
                        delay: const Duration(milliseconds: 400),
                        child: Column(
                          children: [
                            _buildSegmentationResults(),
                            if (_classificationResult != null) ...[
                              const SizedBox(height: 24),
                              _buildClassificationResults(),
                            ],
                            const SizedBox(height: 16),
                            GradientButton(
                              text: 'Salvar análise',
                              icon: Icons.save_alt,
                              onPressed: _isSaving ? null : _onSaveAnalysis,
                              isLoading: _isSaving,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (isBusy)
                LoadingOverlay(
                  message: busyMessage,
                  isVisible: true,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Anemia Detector',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Diagnóstico de anemia em ovinos usando IA',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildModelStatus() {
    final bothLoaded = _mlService.isLoaded && _classificationService.isLoaded;
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bothLoaded
                ? AppTheme.accentColor.withOpacity(0.1)
                : AppTheme.errorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            bothLoaded ? Icons.check_circle : Icons.error,
            color:
                bothLoaded ? AppTheme.accentColor : AppTheme.errorColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bothLoaded
                    ? 'Modelos Carregados'
                    : 'Modelos Não Carregados',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                bothLoaded
                    ? 'Pronto para análise'
                    : 'Aguardando carregamento...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageCard() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'IMAGEM ORIGINAL',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              _analyzedImage!,
              height: 300,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentationResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StatsCard(
          title: 'Cobertura da Região',
          value: '${_coveragePercentage!.toStringAsFixed(1)}%',
          icon: Icons.analytics,
          gradient: AppTheme.primaryGradient,
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SegmentationResultsWidget(
              analyzedImage: _analyzedImage!,
              segmentationMask: _segmentationMask!,
              coveragePercentage: _coveragePercentage!,
              onCreateOverlay: _createSegmentationOverlay,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassificationResults() {
    if (_classificationResult == null) {
      return const SizedBox.shrink();
    }

    return ClassificationResultWidget(
      result: _classificationResult!,
    );
  }
}

class _SavedAnalysisPaths {
  const _SavedAnalysisPaths({
    required this.original,
    required this.segmented,
  });

  final String original;
  final String segmented;
}

