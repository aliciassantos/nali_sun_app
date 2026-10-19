import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Cores da Paleta Nali-Sun
  static const Color fundoBege = Color(0xFFFBE4AE);
  static const Color verdeEscuro = Color(0xFF0B3740);
  static const Color verdeBase = Color(0xFF81B380);
  static const Color verdeAcao = Color(0xFF258A60);
  static const Color amareloCard = Color(0xFFD6D578);
  static const Color verdeAvisoCard = Color(0xFF5AA68C);
  static const Color verdeChartreuse = Color(0xFFA7BF73);
  static const Color textoCardEscuro = Color(0xFF392E0E);
  static const Color textoNavUnselected = Color(0xFFDACB8A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundoBege,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER FLUIDO (100% DA LARGURA)
            _buildHeader(),

            // CORPO ROLÁVEL E ADAPTÁVEL
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // CARD PRINCIPAL COM GRADIENTE
                    _buildProximaRegaCard(),

                    const SizedBox(height: 16),

                    // GRID DE MINI CARDS COM GRADIENTES INDIVIDUAIS
                    _buildGridAcoes(),

                    const SizedBox(height: 24),

                    // SEÇÃO 1: PRECISA DE ATENÇÃO
                    _buildTituloSecao('Precisa de Atenção', '1 planta', verdeAcao),
                    const SizedBox(height: 10),
                    _buildAvisoCard(
                      titulo: 'Regar Suculenta',
                      subtitulo: 'Atrasada · 2 dias',
                      corFundo: verdeAvisoCard,
                      corBorda: const Color(0xFFE53935),
                      icone: Icons.warning_amber_rounded,
                      corIcone: const Color(0xFFE53935),
                    ),

                    const SizedBox(height: 20),

                    // SEÇÃO 2: REGAR HOJE
                    _buildTituloSecao('Regar Hoje', 'Às 18h', verdeAcao),
                    const SizedBox(height: 10),
                    _buildAvisoCard(
                      titulo: 'Regar Samambaia',
                      subtitulo: 'Hoje · 18hrs',
                      corFundo: amareloCard,
                      corBorda: const Color(0xFFF59E0B),
                      icone: Icons.warning_amber_rounded,
                      corIcone: const Color(0xFFF59E0B),
                    ),
                    const SizedBox(height: 10),
                    _buildAvisoCard(
                      titulo: 'Tudo em Dia',
                      subtitulo: 'Monstera · próxima rega em 3 dias',
                      corFundo: verdeBase,
                      corBorda: verdeBase,
                      icone: Icons.check_circle_outline,
                      corIcone: verdeEscuro,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: const [
                    Text(
                      'Nali-Sun',
                      style: TextStyle(
                        color: fundoBege,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.eco, color: verdeBase, size: 20),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Bem-vinda, Alícia!',
                  style: TextStyle(
                    color: fundoBege,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          // Botão Notificação
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: verdeBase,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none, color: verdeEscuro, size: 22),
          ),
          const SizedBox(width: 10),
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: amareloCard,
              shape: BoxShape.circle,
              border: Border.all(color: verdeBase, width: 2),
            ),
            child: const Icon(Icons.person, color: verdeEscuro, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildProximaRegaCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Gradiente exato do Figma: Color(0xFF5AA68C) -> Color(0xFF81B380)
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [verdeAvisoCard, verdeBase],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Próxima Rega do Jardim',
                style: TextStyle(
                  color: verdeEscuro,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(Icons.water_drop_outlined, color: verdeEscuro, size: 22),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Hoje, às 18h',
            style: TextStyle(
              color: verdeEscuro,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: verdeChartreuse,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text(
              '14 set 2026 · Jiboia e Samambaia',
              style: TextStyle(
                color: verdeEscuro,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridAcoes() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMiniCard(
                'Minhas Plantas',
                '4 plantas',
                Icons.eco_outlined,
                const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [verdeChartreuse, verdeBase],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMiniCard(
                'Calendário de Cuidados',
                '3 cuidados hoje',
                Icons.calendar_today_outlined,
                const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [verdeBase, verdeAvisoCard],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMiniCard(
                'Dicas de Cultivo',
                '3 artigos novos',
                Icons.menu_book_outlined,
                const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [amareloCard, verdeChartreuse],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMiniCard(
                'Meu perfil',
                'Customize seu perfil',
                Icons.person_outline,
                const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [textoNavUnselected, fundoBege],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniCard(String titulo, String subtitulo, IconData icone, Gradient gradiente) {
    return Container(
      height: 106,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: gradiente,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icone, color: verdeEscuro, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: verdeEscuro,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitulo,
                style: const TextStyle(
                  color: verdeEscuro,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTituloSecao(String titulo, String acao, Color corAcao) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            color: verdeEscuro,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          acao,
          style: TextStyle(
            color: corAcao,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAvisoCard({
    required String titulo,
    required String subtitulo,
    required Color corFundo,
    required Color corBorda,
    required IconData icone,
    required Color corIcone,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: corFundo,
        border: Border.all(color: corBorda, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_florist, color: verdeEscuro),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: textoCardEscuro,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitulo,
                  style: const TextStyle(
                    color: textoCardEscuro,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Icon(icone, color: corIcone, size: 22),
        ],
      ),
    );
  }
}