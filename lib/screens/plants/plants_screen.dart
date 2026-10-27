// Aba 2: Meu Jardim e Detalhes

import 'package:flutter/material.dart';
import '../../app/routes.dart';

class MyGardenScreen extends StatefulWidget {
  const MyGardenScreen({super.key});

  @override
  State<MyGardenScreen> createState() => _MyGardenScreenState();
}

class _MyGardenScreenState extends State<MyGardenScreen> {
  // Paleta original do Nali-Sun
  static const Color fundoBege = Color(0xFFFBE4AE);
  static const Color verdeEscuro = Color(0xFF0B3740);
  static const Color verdeBase = Color(0xFF81B380);
  static const Color verdeAcao = Color(0xFF258A60);
  static const Color amareloCard = Color(0xFFD6D578);
  static const Color verdeChartreuse = Color(0xFFA7BF73);

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final escuro = tema.brightness == Brightness.dark;

    final fundo = tema.scaffoldBackgroundColor;
    final texto = escuro ? Colors.white : verdeEscuro;
    final textoSecundario =
        escuro ? Colors.white70 : verdeEscuro.withValues(alpha: 0.75);

    return Scaffold(
      backgroundColor: fundo,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(escuro),
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
                    _buildGridPlantas(
                      escuro: escuro,
                      texto: texto,
                      textoSecundario: textoSecundario,
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

  Widget _buildHeader(bool escuro) {
    return Container(
      width: double.infinity,
      color: escuro ? const Color(0xFF102A2E) : verdeEscuro,
      padding: const EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Meu Jardim',
                  style: TextStyle(
                    color: fundoBege,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '6 plantas · um cantinho de natureza',
                  style: TextStyle(
                    color: fundoBege,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Botão de adicionar planta
          Material(
            color: verdeAcao,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                 Navigator.push(
                  context,
                  AppRoutes.plant as Route<Object?>, 
                );
              },
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.add,
                  color: fundoBege,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== GRID DE PLANTAS ====================

  Widget _buildGridPlantas({
    required bool escuro,
    required Color texto,
    required Color textoSecundario,
  }) {
    final List<Map<String, dynamic>> plantas = [
      {
        'nome': 'Monstera',
        'cientifico': 'Monstera deliciosa',
        'status': 'Em dia',
        'corCard': verdeChartreuse,
        'corBadge': fundoBege,
        'iconeBadge': Icons.check_circle_outline,
        'imagem': 'assets/img/plantinha1.jpg',
      },
      {
        'nome': 'Jiboia',
        'cientifico': 'Epipremnum aureum',
        'status': 'Regar hoje',
        'corCard': verdeBase,
        'corBadge': verdeBase,
        'iconeBadge': Icons.water_drop_outlined,
        'imagem': 'assets/img/plantinha1.jpg',
      },
      {
        'nome': 'Samambaia',
        'cientifico': 'Nephrolepis exaltata',
        'status': 'Regar hoje',
        'corCard': verdeChartreuse,
        'corBadge': verdeBase,
        'iconeBadge': Icons.water_drop_outlined,
        'imagem': 'assets/img/plantinha1.jpg',
      },
      {
        'nome': 'Suculenta',
        'cientifico': 'Echeveria elegans',
        'status': 'Rega atrasada',
        'corCard': verdeBase,
        'corBadge': amareloCard,
        'iconeBadge': Icons.warning_amber_rounded,
        'imagem': 'assets/img/plantinha1.jpg',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: plantas.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        final planta = plantas[index];

        return _buildCardPlanta(
          nome: planta['nome'] as String,
          cientifico: planta['cientifico'] as String,
          status: planta['status'] as String,
          corCard: planta['corCard'] as Color,
          corBadge: planta['corBadge'] as Color,
          iconeBadge: planta['iconeBadge'] as IconData,
          imagemUrl: planta['imagem'] as String,
          escuro: escuro,
          texto: texto,
          textoSecundario: textoSecundario,
        );
      },
    );
  }

  // ==================== CARD DA PLANTA ====================

  Widget _buildCardPlanta({
    required String nome,
    required String cientifico,
    required String status,
    required Color corCard,
    required Color corBadge,
    required IconData iconeBadge,
    required String imagemUrl,
    required bool escuro,
    required Color texto,
    required Color textoSecundario,
  }) {
    // No tema escuro, os cards também ficam escuros.
    // No tema claro, preservam as cores originais.
    final corFundoCard =
        escuro ? const Color(0xFF1B383C) : corCard;

    final corBadgeAtual = escuro
        ? const Color(0xFF31564C)
        : corBadge;

    final corTextoBadge = escuro
        ? const Color(0xFFE1F0D9)
        : verdeEscuro;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: corFundoCard,
        borderRadius: BorderRadius.circular(16),
        border: escuro
            ? Border.all(color: Colors.white.withValues(alpha: 0.07))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: escuro ? 0.12 : 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem da planta
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagemUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    color: escuro
                        ? const Color(0xFF294448)
                        : Colors.black12,
                    child: Icon(
                      Icons.eco,
                      color: escuro ? verdeBase : verdeEscuro,
                      size: 40,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Nome popular e menu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: texto,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 140,
                ),
                icon: Icon(
                  Icons.more_vert,
                  color: textoSecundario,
                  size: 20,
                ),
                onSelected: (opcao) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        opcao == 'detalhes'
                            ? 'Detalhes de $nome em breve.'
                            : 'Edição de $nome em breve.',
                      ),
                    ),
                  );
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'detalhes',
                    child: Text('Ver detalhes'),
                  ),
                  PopupMenuItem(
                    value: 'editar',
                    child: Text('Editar planta'),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 2),

          // Nome científico
          Text(
            cientifico,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textoSecundario,
              fontSize: 11,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 8),

          // Indicador de status
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: corBadgeAtual,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  iconeBadge,
                  color: corTextoBadge,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: corTextoBadge,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
