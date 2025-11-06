/// Exceções customizadas para operações de ML

/// Exceção base para erros de ML
abstract class MLException implements Exception {
  final String message;
  final Object? originalError;
  
  const MLException(this.message, [this.originalError]);
  
  @override
  String toString() => message;
  
  /// Retorna uma mensagem amigável para o usuário
  String getUserMessage() => message;
  
  /// Retorna detalhes técnicos para debug
  String getTechnicalDetails() {
    if (originalError != null) {
      return '$message\nErro original: $originalError';
    }
    return message;
  }
}

/// Exceção quando o modelo não pode ser carregado
class ModelLoadException extends MLException {
  const ModelLoadException(String message, [Object? error])
      : super(message, error);
}

/// Exceção durante a inferência
class InferenceException extends MLException {
  const InferenceException(String message, [Object? error])
      : super(message, error);
}

/// Exceção durante o pré-processamento de imagem
class ImageProcessingException extends MLException {
  const ImageProcessingException(String message, [Object? error])
      : super(message, error);
}

