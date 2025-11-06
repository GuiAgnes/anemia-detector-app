import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../constants/ml_constants.dart';
import '../exceptions/ml_exceptions.dart';
import 'image_processor.dart';

/// Serviço para gerenciamento do modelo TFLite
class TFLiteService {
  Interpreter? _interpreter;
  bool _isLoaded = false;

  /// Verifica se o modelo está carregado
  bool get isLoaded => _isLoaded;

  /// Carrega o modelo TFLite do asset
  Future<void> loadModel() async {
    if (_isLoaded) return;

    try {
      _interpreter = await Interpreter.fromAsset(MLConstants.modelPath);
      _isLoaded = true;
    } catch (e) {
      throw ModelLoadException(
        'Erro ao carregar modelo: ${e.toString()}',
        e,
      );
    }
  }

  /// Executa a inferência de segmentação
  /// 
  /// Retorna a máscara de segmentação processada
  Future<SegmentationStatistics> runSegmentation(
    Float32List inputTensor,
  ) async {
    if (!_isLoaded || _interpreter == null) {
      throw const InferenceException(
        'Modelo não está carregado. Chame loadModel() primeiro.',
      );
    }

    try {
      // Verifica se o tamanho do tensor está correto
      // Esperado: 1 * 256 * 256 * 3 = 196608 elementos
      final expectedSize = MLConstants.inputShape[0] *
          MLConstants.inputShape[1] *
          MLConstants.inputShape[2] *
          MLConstants.inputShape[3];
      
      if (inputTensor.length != expectedSize) {
        throw InferenceException(
          'Tamanho do tensor incorreto. Esperado: $expectedSize, recebido: ${inputTensor.length}',
        );
      }
      
      // Prepara o tensor de entrada
      // Converte Float32List para lista aninhada [1][256][256][3]
      final inputList = _float32ListToNestedList(inputTensor);
      
      // Prepara o tensor de saída [1, 256, 256, 1] para segmentação
      final List<List<List<List<double>>>> output = [
        List.generate(
          MLConstants.inputSize, // height
          (y) => List.generate(
            MLConstants.inputSize, // width
            (x) => List.generate(
              1, // channels
              (c) => 0.0,
            ),
          ),
        ),
      ];

      // Executa a inferência usando run() com lista aninhada
      // O TFLite Flutter espera lista aninhada para entrada e saída
      _interpreter!.run(inputList, output);

      // Pós-processa a máscara de segmentação
      // output[0] remove a dimensão de batch, resultando em [256][256][1]
      return ImageProcessor.processSegmentationMask(output[0]);
    } catch (e) {
      throw InferenceException(
        'Erro durante a inferência: ${e.toString()}',
        e,
      );
    }
  }
  
  /// Converte Float32List para lista aninhada [1][256][256][3]
  List<List<List<List<double>>>> _float32ListToNestedList(
    Float32List flatTensor,
  ) {
    final List<List<List<List<double>>>> nested = [
      List.generate(
        MLConstants.inputSize,
        (y) => List.generate(
          MLConstants.inputSize,
          (x) => List.generate(
            MLConstants.rgbChannels,
            (c) {
              // Calcula o índice no array plano
              final index = (y * MLConstants.inputSize * MLConstants.rgbChannels) +
                           (x * MLConstants.rgbChannels) +
                           c;
              return flatTensor[index].toDouble();
            },
          ),
        ),
      ),
    ];
    return nested;
  }

  /// Libera os recursos do modelo
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isLoaded = false;
  }
}

