/// Constantes relacionadas ao Machine Learning
class MLConstants {
  /// Tamanho da imagem de entrada do modelo
  static const int inputSize = 256;
  
  /// Threshold para binarização da máscara de segmentação
  /// 
  /// IMPORTANTE: Se o modelo não estiver detectando corretamente, tente ajustar este valor:
  /// - Valores mais baixos (0.1-0.3): Detecta mais pixels (mais sensível)
  /// - Valores mais altos (0.5-0.7): Detecta menos pixels (mais específico)
  /// 
  /// O código agora usa threshold adaptativo se os valores da máscara estiverem em escala diferente
  static const double segmentationThreshold = 0.3; // Reduzido de 0.5 para 0.3 para melhor detecção
  
  /// Caminho do modelo TFLite
  static const String modelPath = 'assets/model.tflite';
  
  /// Shape do input do modelo: [batch, height, width, channels]
  static const List<int> inputShape = [1, 256, 256, 3];
  
  /// Shape do output do modelo (segmentação): [batch, height, width, channels]
  static const List<int> outputShape = [1, 256, 256, 1];
  
  /// Número de canais RGB
  static const int rgbChannels = 3;
  
  /// Valor máximo de pixel para normalização
  static const double maxPixelValue = 255.0;
  
  /// Valor mínimo normalizado
  static const double minNormalizedValue = 0.0;
  
  /// Valor máximo normalizado
  static const double maxNormalizedValue = 1.0;
  
  /// Porcentagem mínima de cobertura para considerar segmentação válida
  /// Se a cobertura for menor que este valor, a segmentação é considerada inválida
  /// Valor reduzido para 0.1% para evitar rejeitar segmentações válidas
  static const double minCoveragePercentage = 0.1; // 0.1% de cobertura mínima
}

