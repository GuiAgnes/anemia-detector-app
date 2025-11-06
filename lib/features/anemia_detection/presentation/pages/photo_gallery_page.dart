import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/animated_card.dart';

/// Tela de galeria com exemplos de como tirar fotos corretas
class PhotoGalleryPage extends StatelessWidget {
  const PhotoGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF5F7FA),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              
              // Conteúdo com scroll
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Instruções gerais
                      _buildInstructions(),
                      
                      const SizedBox(height: 32),
                      
                      // Exemplos de fotos
                      _buildExamplesSection(),
                      
                      const SizedBox(height: 32),
                      
                      // Dicas importantes
                      _buildTipsSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Header da página
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Como Tirar a Foto',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Exemplos e dicas para capturar a imagem correta',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Instruções gerais
  Widget _buildInstructions() {
    return AnimatedCard(
      delay: const Duration(milliseconds: 100),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Instruções Gerais',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInstructionItem(
              '1',
              'Posicione o animal em local bem iluminado',
              Icons.lightbulb_outline,
            ),
            const SizedBox(height: 12),
            _buildInstructionItem(
              '2',
              'Segure suavemente a pálpebra inferior e puxe para baixo',
              Icons.touch_app,
            ),
            const SizedBox(height: 12),
            _buildInstructionItem(
              '3',
              'Mantenha o foco na área da conjuntiva exposta',
              Icons.center_focus_strong,
            ),
            const SizedBox(height: 12),
            _buildInstructionItem(
              '4',
              'A foto deve mostrar claramente a membrana mucosa rosa/vermelha',
              Icons.visibility,
            ),
          ],
        ),
      ),
    );
  }

  /// Item de instrução
  Widget _buildInstructionItem(String number, String text, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(
          icon,
          size: 20,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  /// Seção de exemplos
  Widget _buildExamplesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Exemplos de Fotos Corretas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
        ),
        const SizedBox(height: 16),
        
        // Exemplo 1
        _buildExampleCard(
          imagePath: 'assets/images/examples/01_4.jpg',
          title: 'Exemplo 1: Ovelha - Conjuntiva Exposta',
          description: 'Pálpebra inferior puxada para baixo, expondo a conjuntiva rosa saudável. Foco nítido na área da mucosa. A mão segura suavemente a pálpebra, revelando a membrana mucosa bem vascularizada.',
          tips: [
            'Segure a pálpebra suavemente com o polegar',
            'Mantenha o foco nítido na conjuntiva',
            'Boa iluminação natural sem sombras',
            'A conjuntiva deve estar claramente visível',
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Exemplo 2
        _buildExampleCard(
          imagePath: 'assets/images/examples/02_3.jpg',
          title: 'Exemplo 2: Close-up da Conjuntiva',
          description: 'Visão próxima da conjuntiva, mostrando detalhes da vascularização. Área bem iluminada e em foco. A conjuntiva aparece em tom rosa vibrante, indicando boa saúde.',
          tips: [
            'Exponha claramente a conjuntiva',
            'Evite sombras na área da mucosa',
            'Mantenha a câmera estável',
            'Use duas mãos se necessário para estabilizar',
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Exemplo 3
        _buildExampleCard(
          imagePath: 'assets/images/examples/04_2.jpg',
          title: 'Exemplo 3: Posicionamento Correto',
          description: 'Mãos posicionadas corretamente para expor a conjuntiva. A pálpebra superior e inferior são puxadas adequadamente, revelando a membrana mucosa com boa iluminação.',
          tips: [
            'Polegar na pálpebra superior (opcional)',
            'Dedo indicador na pálpebra inferior',
            'Puxe suavemente sem pressionar demais',
            'Exponha a maior área possível da conjuntiva',
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Exemplo 4
        _buildExampleCard(
          imagePath: 'assets/images/examples/07_9.jpg',
          title: 'Exemplo 4: Boa Iluminação',
          description: 'Foto com iluminação clara e uniforme, destacando a cor e textura da conjuntiva. Sem sombras que obscureçam os detalhes. A conjuntiva está bem exposta e visível.',
          tips: [
            'Use luz natural quando possível',
            'Evite sombras duras',
            'Iluminação uniforme na área',
            'A cor da conjuntiva deve ser claramente visível',
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Exemplo 5
        _buildExampleCard(
          imagePath: 'assets/images/examples/IMG-20251017-WA0012.jpg',
          title: 'Exemplo 5: Exposição Completa',
          description: 'Exemplo de como expor adequadamente a conjuntiva ocular. A pálpebra está puxada de forma que a membrana mucosa fique completamente visível, facilitando a análise pelo modelo de IA.',
          tips: [
            'Aproxime-se o suficiente para ver detalhes',
            'Mantenha o foco nítido na área',
            'Evite tremidas - use apoio se necessário',
            'A conjuntiva deve preencher a maior parte do quadro',
          ],
        ),
      ],
    );
  }

  /// Card de exemplo
  Widget _buildExampleCard({
    String? imagePath,
    required String title,
    required String description,
    required List<String> tips,
  }) {
    return AnimatedCard(
      delay: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.photo_library,
                    color: AppTheme.accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Imagem de exemplo (se disponível)
            if (imagePath != null)
              _buildExampleImage(imagePath),
            
            if (imagePath != null) const SizedBox(height: 12),
            
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: AppTheme.accentColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Pontos importantes:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...tips.map((tip) => Padding(
                    padding: const EdgeInsets.only(left: 24, top: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tip,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget para exibir imagem de exemplo
  Widget _buildExampleImage(String imagePath) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Se a imagem não existir, mostra placeholder
            return Container(
              color: Colors.grey[200],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Imagem não encontrada',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Adicione a imagem em: $imagePath',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[400],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Seção de dicas
  Widget _buildTipsSection() {
    return AnimatedCard(
      delay: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withOpacity(0.1),
              AppTheme.secondaryColor.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: AppTheme.warningColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Dicas Importantes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTipItem(
              Icons.wb_sunny,
              'Iluminação',
              'Use luz natural ou artificial clara. Evite sombras na área da conjuntiva.',
            ),
            const SizedBox(height: 12),
            _buildTipItem(
              Icons.center_focus_strong,
              'Foco',
              'Mantenha o foco nítido na área da conjuntiva. Use o retângulo de guia do app.',
            ),
            const SizedBox(height: 12),
            _buildTipItem(
              Icons.handshake,
              'Posicionamento',
              'Segure a pálpebra suavemente, sem pressionar demais. Exponha claramente a mucosa.',
            ),
            const SizedBox(height: 12),
            _buildTipItem(
              Icons.camera_alt,
              'Distância',
              'Mantenha uma distância adequada: nem muito longe (perde detalhes) nem muito perto (perde contexto).',
            ),
            const SizedBox(height: 12),
            _buildTipItem(
              Icons.visibility,
              'Área de Interesse',
              'A foto deve mostrar claramente a conjuntiva (membrana rosa/vermelha), não apenas o olho fechado.',
            ),
          ],
        ),
      ),
    );
  }

  /// Item de dica
  Widget _buildTipItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.warningColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppTheme.warningColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

