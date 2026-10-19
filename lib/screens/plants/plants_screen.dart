// Aba 2: Meu Jardim e Detalhes
import 'package:flutter/material.dart';

class MyGardenScreen extends StatefulWidget {
  const MyGardenScreen({super.key});

  @override
  State<MyGardenScreen> createState() => _MyGardenScreenState();
}

class _MyGardenScreenState extends State<MyGardenScreen> {
  // Paleta de Cores Exata do Nali-Sun
  static const Color fundoBege = Color(0xFFFBE4AE);
  static const Color verdeEscuro = Color(0xFF0B3740);
  static const Color verdeBase = Color(0xFF81B380);
  static const Color verdeAcao = Color(0xFF258A60);
  static const Color amareloCard = Color(0xFFD6D578);
  static const Color verdeChartreuse = Color(0xFFA7BF73);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundoBege,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER 
            _buildHeader(),

            // GRID DE PLANTAS 
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildGridPlantas(),
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
              children: const [
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
          // Botão de Adicionar Nova Planta
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: verdeAcao,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: fundoBege, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildGridPlantas() {
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
        final p = plantas[index];
        return _buildCardPlanta(
          nome: p['nome'],
          cientifico: p['cientifico'],
          status: p['status'],
          corCard: p['corCard'],
          corBadge: p['corBadge'],
          iconeBadge: p['iconeBadge'],
          imagemUrl: p['imagem'],
        );
      },
    );
  }

  Widget _buildCardPlanta({
    required String nome,
    required String cientifico,
    required String status,
    required Color corCard,
    required Color corBadge,
    required IconData iconeBadge,
    required String imagemUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: corCard,
        borderRadius: BorderRadius.circular(16),
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
        children: [
          // Imagem da Planta (Carregando asset local)
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagemUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.black12,
                  child: const Icon(Icons.eco, color: verdeEscuro, size: 40),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Nome Popular + Ícone de Ação
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: verdeEscuro,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.more_vert, color: verdeEscuro, size: 18),
            ],
          ),
          const SizedBox(height: 2),

          // Nome Científico
          Text(
            cientifico,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: verdeEscuro,
              fontSize: 11,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),

          // Emblema de Status (Badge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: corBadge,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(iconeBadge, color: verdeEscuro, size: 12),
                const SizedBox(width: 4),
                Text(
                  status,
                  style: const TextStyle(
                    color: verdeEscuro,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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