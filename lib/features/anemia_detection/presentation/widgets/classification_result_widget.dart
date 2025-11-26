import 'package:flutter/material.dart';
import '../../../../core/constants/ml_constants.dart';
import '../../../../core/ml/classification_service.dart';

/// Widget para exibir o resultado da classificação de anemia
class ClassificationResultWidget extends StatelessWidget {
  final ClassificationResult result;

  const ClassificationResultWidget({
    super.key,
    required this.result,
  });

  /// Retorna a cor associada a cada classe de anemia
  Color _getColorForClass(String className) {
    switch (className) {
      case 'Normal':
        return const Color(0xFF10B981); // Verde
      case 'Leve':
        return const Color(0xFFF59E0B); // Amarelo/Laranja
      case 'Moderada':
        return const Color(0xFFEF4444); // Vermelho
      case 'Grave':
        return const Color(0xFFDC2626); // Vermelho escuro
      default:
        return Colors.grey;
    }
  }

  /// Retorna o ícone associado a cada classe
  IconData _getIconForClass(String className) {
    switch (className) {
      case 'Normal':
        return Icons.check_circle;
      case 'Leve':
        return Icons.warning;
      case 'Moderada':
        return Icons.error;
      case 'Grave':
        return Icons.dangerous;
      default:
        return Icons.help;
    }
  }

  /// Retorna uma descrição para cada classe
  String _getDescriptionForClass(String className) {
    switch (className) {
      case 'Normal':
        return 'A coloração da mucosa está normal. O animal não apresenta sinais de anemia.';
      case 'Leve':
        return 'A coloração indica anemia leve. Recomenda-se monitoramento.';
      case 'Moderada':
        return 'A coloração indica anemia moderada. Tratamento recomendado.';
      case 'Grave':
        return 'A coloração indica anemia grave. Tratamento urgente necessário.';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForClass(result.predictedClass);
    final icon = _getIconForClass(result.predictedClass);
    final description = _getDescriptionForClass(result.predictedClass);
    final confidencePercent = (result.confidence * 100).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'DIAGNÓSTICO DE ANEMIA',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Card principal com resultado
        Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Classe predita
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.predictedClass.toUpperCase(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: color,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Confiança: $confidencePercent%',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Descrição
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Probabilidades detalhadas
              Text(
                'Probabilidades por classe:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(
                result.probabilities.length,
                (index) {
                  final className = MLConstants.anemiaClasses[index];
                  final probability = result.probabilities[index];
                  final isPredicted = className == result.predictedClass;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            className,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isPredicted ? FontWeight.bold : FontWeight.normal,
                              color: isPredicted ? color : Colors.grey[700],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: LinearProgressIndicator(
                            value: probability,
                            backgroundColor: Colors.grey[200]!,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isPredicted ? color : Colors.grey[400]!,
                            ),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 50,
                          child: Text(
                            '${(probability * 100).toStringAsFixed(1)}%',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isPredicted ? FontWeight.bold : FontWeight.normal,
                              color: isPredicted ? color : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

