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
          title: 'Exemplo 1: Conjuntiva Bem Exposta',
          description: 'A pálpebra inferior é puxada levemente e revela a mucosa rosa, iluminada e em foco. A mão apenas apoia o movimento sem cobrir a área importante.',
        ),
        
        const SizedBox(height: 16),
        
        // Exemplo 2
        _buildExampleCard(
          imagePath: 'assets/images/examples/02_3.jpg',
          title: 'Exemplo 2: Close-up Nítido',
          description: 'A câmera está próxima o bastante para mostrar detalhes dos vasos, mas ainda mantém toda a mucosa visível. A iluminação uniforme realça a cor.',
        ),
        
        const SizedBox(height: 16),
        
        // Exemplo 3
        _buildExampleCard(
          imagePath: 'assets/images/examples/04_2.jpg',
          title: 'Exemplo 3: Mãos Bem Posicionadas',
          description: 'Uma mão estabiliza a cabeça e a outra expõe o olho com movimentos suaves. A conjuntiva aparece inteira e com boa luz.',
        ),
        
        const SizedBox(height: 16),
        
        // Exemplo 4
        _buildExampleCard(
          imagePath: 'assets/images/examples/07_9.jpg',
          title: 'Exemplo 4: Luz Uniforme',
          description: 'A iluminação ilumina toda a conjuntiva, realçando cor e textura. Não há sombras ou brilhos fortes que prejudiquem a leitura.',
        ),
        
        const SizedBox(height: 16),
        
        // Exemplo 5
        _buildExampleCard(
          imagePath: 'assets/images/examples/IMG-20251017-WA0012.jpg',
          title: 'Exemplo 5: Enquadramento Completo',
          description: 'A mucosa ocupa quase todo o quadro, sem cortes ou áreas escuras. O foco está cravado na região que o modelo precisa analisar.',
        ),
      ],
    );
  }

  /// Card de exemplo
  Widget _buildExampleCard({
    String? imagePath,
    required String title,
    required String description,
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
            const SizedBox(height: 4),
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

}

