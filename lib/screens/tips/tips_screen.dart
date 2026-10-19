import 'package:flutter/material.dart';

class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  // Paleta de Cores do Nali-Sun
  static const Color fundoBege = Color(0xFFFBE4AE);
  static const Color verdeEscuro = Color(0xFF0B3740);
  static const Color verdeAcao = Color(0xFF258A60);
  static const Color textoCardEscuro = Color(0xFF392E0E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundoBege,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER FLUIDO
            _buildHeader(),

            // LISTA DE DICAS ROLÁVEL
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCardDica(
                      categoria: 'SUBSTRATO',
                      tempoLeitura: '5 min de leitura',
                      corBadge: verdeAcao,
                      titulo: 'O segredo está embaixo: substrato ideal para cada planta',
                      subtitulo: 'Mistura certa de terra, areia e perlita faz toda a diferença no crescimento.',
                      imagemUrl: 'assets/img/plantinha1.jpg',
                    ),
                    const SizedBox(height: 16),
                    _buildCardDica(
                      categoria: 'PODA',
                      tempoLeitura: '8 min de leitura',
                      corBadge: textoCardEscuro,
                      titulo: 'Poda consciente: quando e como cortar sem estressar a planta',
                      subtitulo: 'Tesoura limpa, corte certeiro. A planta agradece com folhas novas.',
                      imagemUrl: 'assets/img/plantinha1.jpg',
                    ),
                    const SizedBox(height: 16),
                    _buildCardDica(
                      categoria: 'ILUMINAÇÃO',
                      tempoLeitura: '4 min de leitura',
                      corBadge: verdeAcao,
                      titulo: 'Luz direta vs. Indireta: como identificar o local perfeito em casa',
                      subtitulo: 'Entenda os sinais das folhas e posicione suas plantas no lugar certo.',
                      imagemUrl: 'assets/img/plantinha1.jpg',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== COMPONENTES DO LAYOUT ====================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: verdeEscuro,
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            'Dicas para Florescer',
            style: TextStyle(
              color: fundoBege,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Pequenos saberes, plantas mais felizes.',
            style: TextStyle(
              color: fundoBege,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardDica({
    required String categoria,
    required String tempoLeitura,
    required Color corBadge,
    required String titulo,
    required String subtitulo,
    required String imagemUrl,
  }) {
    return Container(
      height: 190,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // IMAGEM DE FUNDO
            Positioned.fill(
              child: Image.network(
                imagemUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: verdeEscuro,
                  child: const Icon(Icons.menu_book, color: fundoBege, size: 48),
                ),
              ),
            ),

            // OVERLAY DE GRADIENTE ESCURO PARA LEITURA DO TEXTO
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      verdeEscuro.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
            ),

            // CONTEÚDO DO CARD
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // BADGE CATEGORIA + TEMPO DE LEITURA
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: corBadge,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          categoria,
                          style: const TextStyle(
                            color: fundoBege,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: 1,
                          height: 10,
                          color: fundoBege,
                        ),
                        Text(
                          tempoLeitura,
                          style: const TextStyle(
                            color: fundoBege,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // TÍTULO DA DICA
                  Text(
                    titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // SUBTÍTULO
                  Text(
                    subtitulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}