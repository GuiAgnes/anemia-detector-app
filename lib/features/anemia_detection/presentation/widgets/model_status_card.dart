import 'package:flutter/material.dart';

/// Widget que exibe o status do modelo ML
class ModelStatusCard extends StatelessWidget {
  final bool isLoaded;

  const ModelStatusCard({
    super.key,
    required this.isLoaded,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              isLoaded ? Icons.check_circle : Icons.error,
              color: isLoaded ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(
              isLoaded ? 'Modelo carregado' : 'Modelo não carregado',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

