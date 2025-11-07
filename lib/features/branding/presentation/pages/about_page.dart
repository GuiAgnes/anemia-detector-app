import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<PackageInfo> _loadPackageInfo() {
    return PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre o Aplicativo'),
      ),
      body: FutureBuilder<PackageInfo>(
        future: _loadPackageInfo(),
        builder: (context, snapshot) {
          final packageInfo = snapshot.data;
          final versionLabel = packageInfo != null
              ? 'Versão ${packageInfo.version}+${packageInfo.buildNumber}'
              : 'Versão indisponível';

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/logo_unisc.jpg',
                          height: 90,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Desenvolvido por Guilherme Agnes',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Projeto de Conclusão de Curso (TCC)\nUniversidade de Santa Cruz do Sul (UNISC)',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Chip(
                          avatar: const Icon(Icons.school_outlined),
                          label: Text(versionLabel),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Sobre o Projeto',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Aplicativo desenvolvido para auxiliar o monitoramento da saúde do rebanho ovino, '
                  'automatizando a análise de anemia através de visão computacional e aprendizado de máquina. '
                  'O objetivo é oferecer uma ferramenta acessível ao produtor rural para decisões rápidas e precisas.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
