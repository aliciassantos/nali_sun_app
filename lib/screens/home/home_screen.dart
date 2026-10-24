
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Paleta original Nali-Sun
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
    final usuario = context.watch<AuthProvider>().currentUser;
    final tema = Theme.of(context);
    final escuro = tema.brightness == Brightness.dark;

    final fundo = tema.scaffoldBackgroundColor;
    final texto = tema.colorScheme.onSurface;
    final destaque = escuro ? verdeBase : verdeAcao;

    return Scaffold(
      backgroundColor: fundo,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(
              nomeUsuario: usuario?.name ?? 'Usuário',
              escuro: escuro,
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProximaRegaCard(escuro),

                    const SizedBox(height: 16),

                    _buildGridAcoes(escuro),

                    const SizedBox(height: 24),

                    _buildTituloSecao(
                      'Precisa de Atenção',
                      '1 planta',
                      destaque,
                      texto,
                    ),

                    const SizedBox(height: 10),

                    _buildAvisoCard(
                      titulo: 'Regar Suculenta',
                      subtitulo: 'Atrasada · 2 dias',
                      corFundo: escuro
                          ? const Color(0xFF493334)
                          : verdeAvisoCard,
                      corBorda: const Color(0xFFE53935),
                      icone: Icons.warning_amber_rounded,
                      corIcone: const Color(0xFFFF6B6B),
                      escuro: escuro,
                    ),

                    const SizedBox(height: 20),

                    _buildTituloSecao(
                      'Regar Hoje',
                      'Às 18h',
                      destaque,
                      texto,
                    ),

                    const SizedBox(height: 10),

                    _buildAvisoCard(
                      titulo: 'Regar Samambaia',
                      subtitulo: 'Hoje · 18hrs',
                      corFundo: escuro
                          ? const Color(0xFF493F2C)
                          : amareloCard,
                      corBorda: const Color(0xFFF59E0B),
                      icone: Icons.warning_amber_rounded,
                      corIcone: const Color(0xFFFFB74D),
                      escuro: escuro,
                    ),

                    const SizedBox(height: 10),

                    _buildAvisoCard(
                      titulo: 'Tudo em Dia',
                      subtitulo: 'Monstera · próxima rega em 3 dias',
                      corFundo: escuro
                          ? const Color(0xFF24463D)
                          : verdeBase,
                      corBorda: escuro ? verdeBase : verdeBase,
                      icone: Icons.check_circle_outline,
                      corIcone: escuro ? verdeBase : verdeEscuro,
                      escuro: escuro,
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

  // ==================== CABEÇALHO ====================

  Widget _buildHeader({
    required String nomeUsuario,
    required bool escuro,
  }) {
    final fundoHeader = escuro
        ? const Color(0xFF102A2E)
        : verdeEscuro;

    final textoHeader = escuro ? Colors.white : fundoBege;
    final verdeIcone = escuro ? verdeBase : verdeBase;

    return Container(
      width: double.infinity,
      color: fundoHeader,
      padding: const EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Nali-Sun',
                      style: TextStyle(
                        color: textoHeader,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.eco, color: verdeIcone, size: 20),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Bem-vinda, $nomeUsuario!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textoHeader,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: verdeBase,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none,
              color: verdeEscuro,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: escuro ? const Color(0xFF304B4E) : amareloCard,
              shape: BoxShape.circle,
              border: Border.all(color: verdeBase, width: 2),
            ),
            child: Icon(
              Icons.person,
              color: escuro ? Colors.white : verdeEscuro,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== PRÓXIMA REGA ====================

  Widget _buildProximaRegaCard(bool escuro) {
    final corTexto = escuro ? Colors.white : verdeEscuro;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: escuro
              ? const [
                  Color(0xFF28594B),
                  Color(0xFF1B4039),
                ]
              : const [
                  verdeAvisoCard,
                  verdeBase,
                ],
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
            children: [
              Expanded(
                child: Text(
                  'Próxima Rega do Jardim',
                  style: TextStyle(
                    color: corTexto,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.water_drop_outlined,
                color: corTexto,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Hoje, às 18h',
            style: TextStyle(
              color: corTexto,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: escuro
                  ? const Color(0xFF426B58)
                  : verdeChartreuse,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              '14 set 2026 · Jiboia e Samambaia',
              style: TextStyle(
                color: escuro ? Colors.white : verdeEscuro,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ATALHOS ====================

  Widget _buildGridAcoes(bool escuro) {
    final gradientePlantas = escuro
        ? const LinearGradient(
            colors: [Color(0xFF29483E), Color(0xFF203C36)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [verdeChartreuse, verdeBase],
          );

    final gradienteCalendario = escuro
        ? const LinearGradient(
            colors: [Color(0xFF254A45), Color(0xFF1C3936)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [verdeBase, verdeAvisoCard],
          );

    final gradienteDicas = escuro
        ? const LinearGradient(
            colors: [Color(0xFF49452D), Color(0xFF353D2D)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [amareloCard, verdeChartreuse],
          );

    final gradientePerfil = escuro
        ? const LinearGradient(
            colors: [Color(0xFF344649), Color(0xFF263A3D)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [textoNavUnselected, fundoBege],
          );

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMiniCard(
                'Minhas Plantas',
                '4 plantas',
                Icons.eco_outlined,
                gradientePlantas,
                escuro,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMiniCard(
                'Calendário de Cuidados',
                '3 cuidados hoje',
                Icons.calendar_today_outlined,
                gradienteCalendario,
                escuro,
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
                gradienteDicas,
                escuro,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMiniCard(
                'Meu perfil',
                'Customize seu perfil',
                Icons.person_outline,
                gradientePerfil,
                escuro,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniCard(
    String titulo,
    String subtitulo,
    IconData icone,
    Gradient gradiente,
    bool escuro,
  ) {
    final corTexto = escuro ? Colors.white : verdeEscuro;

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
          Icon(icone, color: corTexto, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: corTexto,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: escuro
                      ? const Color(0xFFD4E1DC)
                      : verdeEscuro,
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

  // ==================== TÍTULOS DE SEÇÃO ====================

  Widget _buildTituloSecao(
    String titulo,
    String acao,
    Color corAcao,
    Color corTexto,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            titulo,
            style: TextStyle(
              color: corTexto,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
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

  // ==================== AVISOS ====================

  Widget _buildAvisoCard({
    required String titulo,
    required String subtitulo,
    required Color corFundo,
    required Color corBorda,
    required IconData icone,
    required Color corIcone,
    required bool escuro,
  }) {
    final corTexto = escuro ? Colors.white : textoCardEscuro;

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
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.local_florist,
              color: escuro ? verdeBase : verdeEscuro,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    color: corTexto,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitulo,
                  style: TextStyle(
                    color: corTexto,
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
