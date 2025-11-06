import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as img;

// Core
import 'core/ml/tflite_service.dart';
import 'core/ml/image_processor_isolate.dart';
import 'core/exceptions/ml_exceptions.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/animated_card.dart';
import 'core/widgets/gradient_button.dart';
import 'core/widgets/loading_overlay.dart';

// Features
import 'features/anemia_detection/presentation/widgets/segmentation_results_widget.dart';
import 'features/anemia_detection/presentation/widgets/stats_card.dart';
import 'features/anemia_detection/presentation/pages/camera_guide_page.dart';
import 'features/anemia_detection/presentation/pages/photo_gallery_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anemia Detector',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final TFLiteService _mlService = TFLiteService();
  bool _isProcessing = false;

  // Resultados da análise (segmentação)
  File? _analyzedImage;
  Uint8List? _segmentationMask;
  double? _coveragePercentage;

  // Mensagens de erro
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  /// Carrega o modelo TFLite
  Future<void> _loadModel() async {
    try {
      await _mlService.loadModel();
      if (!mounted) return;
      setState(() {
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e is MLException
            ? e.message
            : 'Erro ao carregar modelo: $e';
      });
    }
  }

  /// Seleciona uma imagem da câmera ou galeria
  Future<void> pickImage() async {
    if (!_mlService.isLoaded) {
      _showError('Modelo ainda não foi carregado. Aguarde...');
      return;
    }

    try {
      // Mostra diálogo para escolher entre câmera ou galeria
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

      // Se for câmera, usa a tela personalizada com guia
      if (source == ImageSource.camera) {
        try {
          final result = await Navigator.push<File>(
            context,
            MaterialPageRoute(
              builder: (context) => const CameraGuidePage(),
            ),
          );

          if (result == null) return;
          imageFile = result;
        } catch (e) {
          debugPrint('Erro ao abrir câmera personalizada: $e');
          _showError('Erro ao abrir câmera. Verifique as permissões.');
          return;
        }
      } else {
        // Se for galeria, usa o image_picker normalmente
        final ImagePicker picker = ImagePicker();
        XFile? pickedFile;
        
        try {
          pickedFile = await picker.pickImage(
            source: source,
            imageQuality: 85,
          );
        } catch (e) {
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

      // Tenta recortar a imagem (opcional - se falhar, usa a original)
      File finalImageFile = imageFile;
      
        // Tenta abrir o cropper, mas se falhar, usa a imagem original
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
          } else {
            debugPrint('Arquivo recortado não existe, usando original');
          }
        }
        // Se croppedFile é null, o usuário cancelou - usa a original (já definida)
      } catch (e, stackTrace) {
        debugPrint('Erro ao recortar imagem (usando original): $e');
        debugPrint('Stack trace: $stackTrace');
        // Se falhar o recorte, usa a imagem original (já definida)
      }

      if (!await finalImageFile.exists()) {
        _showError('Não foi possível acessar a imagem selecionada.');
        return;
      }

      // Processa a imagem e executa a inferência
      await _processImage(finalImageFile);
    } catch (e, stackTrace) {
      debugPrint('Erro ao selecionar imagem: $e');
      debugPrint('Stack trace: $stackTrace');
      _showError('Erro ao selecionar imagem: ${e.toString()}');
    }
  }

  /// Pré-processa a imagem e executa a inferência
  Future<void> _processImage(File imageFile) async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _analyzedImage = imageFile;
      _segmentationMask = null;
      _coveragePercentage = null;
    });

    try {
      // Verifica se o arquivo existe
      if (!await imageFile.exists()) {
        throw Exception('Arquivo de imagem não existe mais.');
      }

      // Pré-processa a imagem usando isolate (melhor performance)
      final Float32List inputTensor =
          await ImageProcessorIsolate.preprocessImageWithIsolate(imageFile);

      // Executa a inferência
      final statistics = await _mlService.runSegmentation(inputTensor);

      // A validação da segmentação já é feita dentro do processSegmentationMask
      // Se a cobertura for muito pequena, uma exceção será lançada

      // Verifica se ainda está montado antes de atualizar o estado
      if (!mounted) return;

      setState(() {
        _segmentationMask = statistics.mask;
        _coveragePercentage = statistics.coveragePercentage;
        _isProcessing = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Erro ao processar imagem: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Verifica se ainda está montado antes de atualizar o estado
      if (!mounted) return;

      // Mensagem de erro específica para segmentação insuficiente
      String errorMessage;
      if (e is MLException) {
        errorMessage = e.message;
      } else {
        errorMessage = 'Erro ao processar imagem: ${e.toString()}';
      }

      setState(() {
        _errorMessage = errorMessage;
        _isProcessing = false;
        // Limpa resultados anteriores se houver erro
        _segmentationMask = null;
        _coveragePercentage = null;
      });

      // Mostra mensagem de erro ao usuário
      _showError(errorMessage);
    }
  }

  /// Cria uma imagem visual da máscara de segmentação sobreposta
  Future<Uint8List?> _createSegmentationOverlay(
    img.Image originalImage,
    Uint8List segmentationMask,
  ) async {
    // Converte a imagem para bytes para usar no isolate
    final imageBytes = Uint8List.fromList(img.encodePng(originalImage));
    
    // Usa isolate para melhor performance
    return ImageProcessorIsolate.createSegmentationOverlayWithIsolate(
      imageBytes,
      segmentationMask,
    );
  }

  /// Mostra mensagem de erro moderna
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    // Header moderno
                    _buildHeader(),
                    
                    const SizedBox(height: 24),

                    // Status do modelo com animação
                    AnimatedCard(
                      delay: const Duration(milliseconds: 100),
                      child: _buildModelStatus(),
                    ),

                    const SizedBox(height: 24),

                    // Botão principal com gradiente
                    AnimatedCard(
                      delay: const Duration(milliseconds: 200),
                      child: GradientButton(
                        text: 'Tirar Foto / Selecionar',
                        icon: Icons.camera_alt,
                        onPressed: _isProcessing || !_mlService.isLoaded
                            ? null
                            : pickImage,
                        isLoading: false,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Botão para ver exemplos
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

                    // Mensagem de erro moderna
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

                    // Imagem analisada moderna
                    if (_analyzedImage != null && !_isProcessing)
                      AnimatedCard(
                        delay: const Duration(milliseconds: 300),
                        child: _buildImageCard(),
                      ),

                    // Resultados da Segmentação modernos
                    if (_segmentationMask != null && !_isProcessing)
                      AnimatedCard(
                        delay: const Duration(milliseconds: 400),
                        child: _buildSegmentationResults(),
                      ),
                  ],
                ),
              ),
              
              // Loading overlay moderno
              if (_isProcessing)
                LoadingOverlay(
                  message: 'Processando imagem...',
                  isVisible: _isProcessing,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Header moderno do aplicativo
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

  /// Status do modelo moderno
  Widget _buildModelStatus() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _mlService.isLoaded
                ? AppTheme.accentColor.withOpacity(0.1)
                : AppTheme.errorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _mlService.isLoaded ? Icons.check_circle : Icons.error,
            color: _mlService.isLoaded
                ? AppTheme.accentColor
                : AppTheme.errorColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _mlService.isLoaded ? 'Modelo Carregado' : 'Modelo Não Carregado',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _mlService.isLoaded
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

  /// Card de imagem moderno
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

  /// Resultados de segmentação modernos
  Widget _buildSegmentationResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card de estatísticas moderno
        StatsCard(
          title: 'Cobertura da Região',
          value: '${_coveragePercentage!.toStringAsFixed(1)}%',
          icon: Icons.analytics,
          gradient: AppTheme.primaryGradient,
        ),
        
        const SizedBox(height: 24),
        
        // Imagem com overlay
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
}
