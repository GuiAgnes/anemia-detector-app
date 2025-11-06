import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import '../constants/ml_constants.dart';
import 'image_processor.dart';

/// Classe para passar dados ao isolate
class _ImageProcessingData {
  final Uint8List imageBytes;
  
  _ImageProcessingData(this.imageBytes);
}

/// Classe para retornar dados do isolate
class _ProcessedImageData {
  final Float32List tensor;
  final img.Image? resizedImage;
  
  _ProcessedImageData(this.tensor, this.resizedImage);
}

/// Processa imagem em isolate (top-level function)
Future<_ProcessedImageData> _processImageInIsolate(
  _ImageProcessingData data,
) async {
  try {
    // Decodifica a imagem
    final img.Image? decodedImage = img.decodeImage(data.imageBytes);
    
    if (decodedImage == null) {
      throw Exception('Não foi possível decodificar a imagem');
    }

    // Redimensiona para o tamanho de entrada do modelo
    final img.Image resizedImage = img.copyResize(
      decodedImage,
      width: MLConstants.inputSize,
      height: MLConstants.inputSize,
    );

    // Converte para tensor Float32List normalizado [0-1]
    final Float32List tensor = _imageToTensorInIsolate(resizedImage);
    
    return _ProcessedImageData(tensor, resizedImage);
  } catch (e) {
    throw Exception('Erro ao processar imagem no isolate: $e');
  }
}

/// Converte a imagem para tensor Float32List normalizado [0-1]
/// Função top-level para uso em isolate
Float32List _imageToTensorInIsolate(img.Image image) {
  final int imageSize = MLConstants.inputSize *
      MLConstants.inputSize *
      MLConstants.rgbChannels;
  final Float32List tensor = Float32List(imageSize);

  int index = 0;
  for (int y = 0; y < MLConstants.inputSize; y++) {
    for (int x = 0; x < MLConstants.inputSize; x++) {
      final pixel = image.getPixel(x, y);
      
      // Extrai os valores RGB (0-255) e normaliza para [0-1]
      final r = (pixel.r.toInt() & 0xFF) / MLConstants.maxPixelValue;
      final g = (pixel.g.toInt() & 0xFF) / MLConstants.maxPixelValue;
      final b = (pixel.b.toInt() & 0xFF) / MLConstants.maxPixelValue;
      
      // Armazena no formato RGB (canal primeiro)
      tensor[index++] = r;
      tensor[index++] = g;
      tensor[index++] = b;
    }
  }

  return tensor;
}

/// Processa overlay em isolate (top-level function)
Future<Uint8List?> _processOverlayInIsolate(
  Map<String, dynamic> data,
) async {
  try {
    final Uint8List imageBytes = data['imageBytes'] as Uint8List;
    final Uint8List segmentationMask = data['segmentationMask'] as Uint8List;
    
    // Decodifica a imagem
    final img.Image? decodedImage = img.decodeImage(imageBytes);
    if (decodedImage == null) return null;

    // Cria uma cópia da imagem original
    final overlay = img.copyResize(
      decodedImage,
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

/// Extensão do ImageProcessor com suporte a isolates
extension ImageProcessorIsolate on ImageProcessor {
  /// Pré-processa uma imagem usando isolate (melhor performance)
  /// 
  /// Redimensiona para 256x256 e normaliza valores para [0-1]
  /// Processamento pesado é feito em isolate separado
  static Future<Float32List> preprocessImageWithIsolate(
    File imageFile,
  ) async {
    try {
      // Lê o arquivo como bytes
      final Uint8List imageBytes = await imageFile.readAsBytes();
      
      // Processa em isolate separado
      final result = await compute(
        _processImageInIsolate,
        _ImageProcessingData(imageBytes),
      );
      
      return result.tensor;
    } catch (e) {
      throw Exception('Erro ao pré-processar imagem com isolate: $e');
    }
  }

  /// Cria overlay usando isolate (melhor performance)
  static Future<Uint8List?> createSegmentationOverlayWithIsolate(
    Uint8List imageBytes,
    Uint8List segmentationMask,
  ) async {
    try {
      final data = {
        'imageBytes': imageBytes,
        'segmentationMask': segmentationMask,
      };
      
      return await compute(_processOverlayInIsolate, data);
    } catch (e) {
      return null;
    }
  }
}

