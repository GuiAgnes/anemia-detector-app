import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../constants/ml_constants.dart';
import '../exceptions/ml_exceptions.dart';

/// Resultado da classificação de anemia
class ClassificationResult {
  final String predictedClass;
  final double confidence;
  final List<double> probabilities;

  const ClassificationResult({
    required this.predictedClass,
    required this.confidence,
    required this.probabilities,
  });
}

/// Serviço para gerenciamento do modelo de classificação de coloração
class ClassificationService {
  Interpreter? _interpreter;
  bool _isLoaded = false;

  /// Verifica se o modelo está carregado
  bool get isLoaded => _isLoaded;

  /// Carrega o modelo TFLite de classificação do asset
  Future<void> loadModel() async {
    if (_isLoaded) return;

    try {
      _interpreter = await Interpreter.fromAsset(MLConstants.classificationModelPath);
      _isLoaded = true;
    } catch (e) {
      throw ModelLoadException(
        'Erro ao carregar modelo de classificação: ${e.toString()}',
        e,
      );
    }
  }

  /// Executa a inferência de classificação
  /// 
  /// Recebe um tensor Float32List normalizado [0, 1] com shape [224, 224, 3]
  /// Retorna o resultado da classificação com classe predita e confiança
  Future<ClassificationResult> runClassification(
    Float32List inputTensor,
  ) async {
    if (!_isLoaded || _interpreter == null) {
      throw const InferenceException(
        'Modelo de classificação não está carregado. Chame loadModel() primeiro.',
      );
    }

    try {
      // Verifica se o tamanho do tensor está correto
      // Esperado: 1 * 224 * 224 * 3 = 150528 elementos
      final expectedSize = MLConstants.classificationInputShape[0] *
          MLConstants.classificationInputShape[1] *
          MLConstants.classificationInputShape[2] *
          MLConstants.classificationInputShape[3];
      
      if (inputTensor.length != expectedSize) {
        throw InferenceException(
          'Tamanho do tensor incorreto. Esperado: $expectedSize, recebido: ${inputTensor.length}',
        );
      }
      
      // Prepara o tensor de entrada
      // Converte Float32List para lista aninhada [1][224][224][3]
      final inputList = _float32ListToNestedList(inputTensor);
      
      // Prepara o tensor de saída [1, 4] para classificação
      final List<List<double>> output = [
        List.generate(
          MLConstants.numAnemiaClasses,
          (i) => 0.0,
        ),
      ];

      // Executa a inferência
      _interpreter!.run(inputList, output);

      // Processa o resultado
      final probabilities = output[0];
      
      // Encontra a classe com maior probabilidade
      int maxIndex = 0;
      double maxProb = probabilities[0];
      for (int i = 1; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          maxIndex = i;
        }
      }

      final predictedClass = MLConstants.anemiaClasses[maxIndex];
      final confidence = maxProb;

      return ClassificationResult(
        predictedClass: predictedClass,
        confidence: confidence,
        probabilities: probabilities,
      );
    } catch (e) {
      throw InferenceException(
        'Erro durante a inferência de classificação: ${e.toString()}',
        e,
      );
    }
  }
  
  /// Converte Float32List para lista aninhada [1][224][224][3]
  List<List<List<List<double>>>> _float32ListToNestedList(
    Float32List flatTensor,
  ) {
    final List<List<List<List<double>>>> nested = [
      List.generate(
        MLConstants.classificationInputSize,
        (y) => List.generate(
          MLConstants.classificationInputSize,
          (x) => List.generate(
            MLConstants.rgbChannels,
            (c) {
              // Calcula o índice no array plano
              final index = (y * MLConstants.classificationInputSize * MLConstants.rgbChannels) +
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

