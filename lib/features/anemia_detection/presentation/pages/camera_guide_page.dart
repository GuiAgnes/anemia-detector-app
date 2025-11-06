import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../../../core/theme/app_theme.dart';

/// Tela de câmera personalizada com guia visual para posicionamento do olho
class CameraGuidePage extends StatefulWidget {
  const CameraGuidePage({super.key});

  @override
  State<CameraGuidePage> createState() => _CameraGuidePageState();
}

class _CameraGuidePageState extends State<CameraGuidePage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  /// Inicializa a câmera
  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      
      if (_cameras == null || _cameras!.isEmpty) {
        if (!mounted) return;
        _showError('Nenhuma câmera disponível');
        return;
      }

      // Usa a câmera traseira por padrão
      final backCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      
      if (!mounted) return;
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Erro ao inicializar câmera: $e');
      if (!mounted) return;
      _showError('Erro ao inicializar câmera: $e');
    }
  }

  /// Captura uma foto
  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile photo = await _controller!.takePicture();
      
      // Move a foto para um diretório temporário
      final Directory tempDir = await getTemporaryDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = 'camera_$timestamp${path.extension(photo.path)}';
      final String filePath = path.join(tempDir.path, fileName);
      
      final File savedFile = File(photo.path);
      final File newFile = await savedFile.copy(filePath);
      
      // Deleta a foto original
      await savedFile.delete();

      if (!mounted) return;
      
      // Retorna a foto para a tela anterior
      Navigator.of(context).pop(newFile);
    } catch (e) {
      debugPrint('Erro ao capturar foto: $e');
      if (!mounted) return;
      _showError('Erro ao capturar foto: $e');
      setState(() {
        _isCapturing = false;
      });
    }
  }

  /// Mostra mensagem de erro
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Preview da câmera
            if (_isInitialized && _controller != null)
              SizedBox.expand(
                child: CameraPreview(_controller!),
              )
            else
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),

            // Overlay com guia e instruções
            _buildOverlay(),

            // Botão de captura
            _buildCaptureButton(),

            // Botão de voltar
            _buildBackButton(),
          ],
        ),
      ),
    );
  }

  /// Overlay com retângulo de guia e instruções
  Widget _buildOverlay() {
    return Positioned.fill(
      child: CustomPaint(
        painter: CameraGuidePainter(),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Instruções no topo
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.visibility,
                      color: Colors.white,
                      size: 32,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Posicione o olho do animal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'dentro do retângulo',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Instruções na parte inferior
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.white70,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Certifique-se de que a conjuntiva ocular está bem visível',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Botão de captura
  Widget _buildCaptureButton() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: _isCapturing ? null : _capturePhoto,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isCapturing
                  ? Colors.grey
                  : AppTheme.primaryColor,
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _isCapturing
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 36,
                  ),
          ),
        ),
      ),
    );
  }

  /// Botão de voltar
  Widget _buildBackButton() {
    return Positioned(
      top: 16,
      left: 16,
      child: SafeArea(
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom Painter para desenhar o retângulo de guia
class CameraGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Calcula o retângulo de guia (centrado, proporção 1:1)
    final guideSize = size.width * 0.7; // 70% da largura
    final guideLeft = (size.width - guideSize) / 2;
    final guideTop = (size.height - guideSize) / 2;
    final guideRect = Rect.fromLTWH(
      guideLeft,
      guideTop,
      guideSize,
      guideSize,
    );

    // Desenha overlay escuro ao redor do retângulo
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
        RRect.fromRectAndRadius(guideRect, const Radius.circular(12)),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(overlayPath, overlayPaint);

    // Desenha o retângulo de guia
    canvas.drawRRect(
      RRect.fromRectAndRadius(guideRect, const Radius.circular(12)),
      paint,
    );

    // Desenha cantos decorativos
    final cornerLength = 30.0;
    final cornerPaint = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    // Canto superior esquerdo
    canvas.drawLine(
      Offset(guideLeft, guideTop + cornerLength),
      Offset(guideLeft, guideTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(guideLeft, guideTop),
      Offset(guideLeft + cornerLength, guideTop),
      cornerPaint,
    );

    // Canto superior direito
    canvas.drawLine(
      Offset(guideLeft + guideSize - cornerLength, guideTop),
      Offset(guideLeft + guideSize, guideTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(guideLeft + guideSize, guideTop),
      Offset(guideLeft + guideSize, guideTop + cornerLength),
      cornerPaint,
    );

    // Canto inferior esquerdo
    canvas.drawLine(
      Offset(guideLeft, guideTop + guideSize - cornerLength),
      Offset(guideLeft, guideTop + guideSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(guideLeft, guideTop + guideSize),
      Offset(guideLeft + cornerLength, guideTop + guideSize),
      cornerPaint,
    );

    // Canto inferior direito
    canvas.drawLine(
      Offset(guideLeft + guideSize - cornerLength, guideTop + guideSize),
      Offset(guideLeft + guideSize, guideTop + guideSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(guideLeft + guideSize, guideTop + guideSize - cornerLength),
      Offset(guideLeft + guideSize, guideTop + guideSize),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

