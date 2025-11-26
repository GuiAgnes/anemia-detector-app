import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import '../constants/ml_constants.dart';
import '../exceptions/ml_exceptions.dart';

/// Exceção quando a segmentação não encontra área suficiente
class InsufficientSegmentationException extends MLException {
  const InsufficientSegmentationException(
    String message, [
    Object? originalError,
  ]) : super(message, originalError);
}

/// Serviço para processamento de imagens para ML
class ImageProcessor {
  /// Pré-processa uma imagem para o modelo TFLite
  /// 
  /// Redimensiona para 256x256 e normaliza valores para [-1, 1] (CORRIGIDO)
  static Future<Float32List> preprocessImage(File imageFile) async {
    try {
      // Lê o arquivo como bytes
      final Uint8List imageBytes = await imageFile.readAsBytes();
      
      // Decodifica a imagem
      final img.Image? decodedImage = img.decodeImage(imageBytes);
      
      if (decodedImage == null) {
        throw const ImageProcessingException(
          'Não foi possível decodificar a imagem',
        );
      }

      // Redimensiona para o tamanho de entrada do modelo
      final img.Image resizedImage = img.copyResize(
        decodedImage,
        width: MLConstants.inputSize,
        height: MLConstants.inputSize,
      );

      // Converte para tensor Float32List normalizado [-1, 1]
      return _imageToTensor(resizedImage);
    } catch (e) {
      if (e is MLException) rethrow;
      throw ImageProcessingException(
        'Erro ao pré-processar imagem: $e',
        e,
      );
    }
  }

  /// Converte a imagem para tensor Float32List normalizado [-1, 1] (CORRIGIDO)
  /// Shape: [1, 256, 256, 3]
  static Float32List _imageToTensor(img.Image image) {
    final int imageSize = MLConstants.inputSize *
        MLConstants.inputSize *
        MLConstants.rgbChannels;
    final Float32List tensor = Float32List(imageSize);

    int index = 0;
    for (int y = 0; y < MLConstants.inputSize; y++) {
      for (int x = 0; x < MLConstants.inputSize; x++) {
        final pixel = image.getPixel(x, y);
        
        // --- CORREÇÃO CRÍTICA AQUI ---
        // Extrai os valores RGB e normaliza para [-1, 1]
        // (pixel_valor / 127.5) - 1.0
        // Conforme tf.keras.applications.mobilenet_v2.preprocess_input
        final r = (pixel.r / 127.5) - 1.0;
        final g = (pixel.g / 127.5) - 1.0;
        final b = (pixel.b / 127.5) - 1.0;
        
        // Armazena no formato RGB
        tensor[index++] = r;
        tensor[index++] = g;
        tensor[index++] = b;
      }
    }

    return tensor;
  }

  /// Cria uma imagem visual da máscara de segmentação sobreposta
  /// 
  /// Versão síncrona (processa na thread principal)
  /// Para melhor performance, use createSegmentationOverlayWithIsolate
  static Future<Uint8List?> createSegmentationOverlay(
    img.Image originalImage,
    Uint8List segmentationMask,
  ) async {
    try {
      // Cria uma cópia da imagem original
      final overlay = img.copyResize(
        originalImage,
        width: MLConstants.inputSize,
        height: MLConstants.inputSize,
      );
      
      // Aplica a máscara como overlay colorido
      for (int y = 0; y < MLConstants.inputSize; y++) {
        for (int x = 0; x < MLConstants.inputSize; x++) {
          final index = y * MLConstants.inputSize + x;
          final maskValue = segmentationMask[index];
          
          if (maskValue > 0) {
            // Aplica overlay verde semi-transparente na região segmentada
            final pixel = overlay.getPixel(x, y);
            final r = (pixel.r.toInt() * 0.6 + 0 * 0.4).toInt();
            final g = (pixel.g.toInt() * 0.6 + 255 * 0.4).toInt();
            final b = (pixel.b.toInt() * 0.6 + 0 * 0.4).toInt();
            
            overlay.setPixelRgba(x, y, r, g, b, 255);
          }
        }
      }
      
      // Converte para PNG
      return Uint8List.fromList(img.encodePng(overlay));
    } catch (e) {
      return null;
    }
  }

  /// Processa a máscara de segmentação e calcula estatísticas
  /// 
  /// Lança [InsufficientSegmentationException] se a cobertura for menor que o mínimo
  static SegmentationStatistics processSegmentationMask(
    List<List<List<double>>> mask,
  ) {
    // Converte a máscara para valores binários (threshold)
    final maskBytes = Uint8List(MLConstants.inputSize * MLConstants.inputSize);
    int pixelCount = 0;
    
    // Estatísticas para diagnóstico
    double minValue = double.infinity;
    double maxValue = double.negativeInfinity;
    double sumValues = 0.0;
    int totalPixels = MLConstants.inputSize * MLConstants.inputSize;
    
    // Primeira passagem: coleta estatísticas
    for (int y = 0; y < MLConstants.inputSize; y++) {
      for (int x = 0; x < MLConstants.inputSize; x++) {
        final value = mask[y][x][0];
        if (value < minValue) minValue = value;
        if (value > maxValue) maxValue = value;
        sumValues += value;
      }
    }
    
    final meanValue = sumValues / totalPixels;
    
    // Log detalhado para diagnóstico
    debugPrint('[ImageProcessor] Estatísticas da máscara:');
    debugPrint('   Min: ${minValue.toStringAsFixed(6)}');
    debugPrint('   Max: ${maxValue.toStringAsFixed(6)}');
    debugPrint('   Média: ${meanValue.toStringAsFixed(6)}');
    debugPrint('   Threshold usado: ${MLConstants.segmentationThreshold}');
    
    // Segunda passagem: aplica threshold adaptativo se necessário
    double effectiveThreshold = MLConstants.segmentationThreshold;
    
    // (A lógica de threshold adaptativo foi removida pois, com a normalização
    // correta da entrada, o threshold fixo deve funcionar de forma confiável)
    // if (meanValue < 0.3 && maxValue < 0.5) {
    //   effectiveThreshold = (meanValue + (maxValue - meanValue) * 0.5).clamp(0.0, 1.0);
    //   debugPrint('   [AVISO] Threshold adaptativo aplicado: ${effectiveThreshold.toStringAsFixed(4)}');
    //   debugPrint('   [AVISO] Valores da máscara parecem estar em escala diferente do esperado');
    // }
    
    // Aplica threshold e binariza
    for (int y = 0; y < MLConstants.inputSize; y++) {
      for (int x = 0; x < MLConstants.inputSize; x++) {
        final value = mask[y][x][0];
        // Aplica threshold para binarizar
        final binaryValue = value > effectiveThreshold ? 255 : 0;
        maskBytes[y * MLConstants.inputSize + x] = binaryValue;
        
        if (binaryValue == 255) {
          pixelCount++;
        }
      }
    }
    
    // Calcula porcentagem de cobertura
    final coverage = (pixelCount / totalPixels) * 100.0;
    
    // Log para debug
    debugPrint('[ImageProcessor] Cobertura detectada: ${coverage.toStringAsFixed(2)}%');
    debugPrint('[ImageProcessor] Pixels segmentados: $pixelCount / $totalPixels');
    debugPrint('[ImageProcessor] Threshold efetivo usado: ${effectiveThreshold.toStringAsFixed(4)}');
    
    // Valida se a cobertura é suficiente
    if (coverage == 0.0 || (coverage < MLConstants.minCoveragePercentage && pixelCount < 100)) {
      debugPrint('[ImageProcessor] Segmentação rejeitada: cobertura muito baixa ou nenhuma área detectada');
      debugPrint('[ImageProcessor] Dica: Verifique se o threshold (${MLConstants.segmentationThreshold}) está adequado');
      debugPrint('[ImageProcessor] Dica: Valores da máscara: min=$minValue, max=$maxValue, média=$meanValue');
      throw InsufficientSegmentationException(
        'Não foi possível identificar a mucosa. '
        'A área detectada é muito pequena (${coverage.toStringAsFixed(2)}%). '
        'Tente novamente com uma imagem mais clara e bem posicionada.',
      );
    }
    
    debugPrint('[ImageProcessor] Segmentação válida: ${coverage.toStringAsFixed(2)}%');
    
    return SegmentationStatistics(
      mask: maskBytes,
      coveragePercentage: coverage,
      segmentedPixels: pixelCount,
      totalPixels: totalPixels,
    );
  }

  /// Extrai a região segmentada da imagem usando a máscara
  /// 
  /// Retorna uma nova imagem contendo apenas os pixels onde a máscara é > 0
  /// A imagem de entrada deve ter o mesmo tamanho da máscara (256x256)
  static img.Image extractSegmentedRegion(
    img.Image image,
    Uint8List segmentationMask,
  ) {
    // Garante que a imagem tem o tamanho correto
    final resizedImage = img.copyResize(
      image,
      width: MLConstants.inputSize,
      height: MLConstants.inputSize,
    );

    // Cria uma nova imagem para a região segmentada
    final segmentedImage = img.Image(
      width: MLConstants.inputSize,
      height: MLConstants.inputSize,
    );

    // Copia apenas os pixels onde a máscara é > 0
    for (int y = 0; y < MLConstants.inputSize; y++) {
      for (int x = 0; x < MLConstants.inputSize; x++) {
        final index = y * MLConstants.inputSize + x;
        final maskValue = segmentationMask[index];
        
        if (maskValue > 0) {
          // Copia o pixel da imagem original
          final pixel = resizedImage.getPixel(x, y);
          segmentedImage.setPixel(x, y, pixel);
        } else {
          // Define como preto (ou transparente) para pixels não segmentados
          segmentedImage.setPixelRgba(x, y, 0, 0, 0, 0);
        }
      }
    }

    return segmentedImage;
  }

  /// Pré-processa uma imagem para classificação
  /// 
  /// Redimensiona para 224x224 e normaliza valores para [0, 1]
  /// Retorna um tensor Float32List com shape [224, 224, 3]
  static Float32List preprocessForClassification(img.Image image) {
    // Redimensiona para o tamanho de entrada da classificação
    final resizedImage = img.copyResize(
      image,
      width: MLConstants.classificationInputSize,
      height: MLConstants.classificationInputSize,
    );

    // Converte para tensor normalizado [0, 1]
    final int imageSize = MLConstants.classificationInputSize *
        MLConstants.classificationInputSize *
        MLConstants.rgbChannels;
    final Float32List tensor = Float32List(imageSize);

    int index = 0;
    for (int y = 0; y < MLConstants.classificationInputSize; y++) {
      for (int x = 0; x < MLConstants.classificationInputSize; x++) {
        final pixel = resizedImage.getPixel(x, y);
        
        // Normaliza para [0, 1] dividindo por 255.0
        // Conforme o treinamento usa rescale=1./255.
        final r = pixel.r / 255.0;
        final g = pixel.g / 255.0;
        final b = pixel.b / 255.0;
        
        // Armazena no formato RGB
        tensor[index++] = r;
        tensor[index++] = g;
        tensor[index++] = b;
      }
    }

    return tensor;
  }
}

/// Estatísticas da segmentação
class SegmentationStatistics {
  final Uint8List mask;
  final double coveragePercentage;
  final int segmentedPixels;
  final int totalPixels;

  const SegmentationStatistics({
    required this.mask,
    required this.coveragePercentage,
    required this.segmentedPixels,
    required this.totalPixels,
  });
}