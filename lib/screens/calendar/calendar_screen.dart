// Aba 3: Agenda e Tarefas
import 'package:flutter/material.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // Paleta de Cores do Nali-Sun
  static const Color fundoBege = Color(0xFFFBE4AE);
  static const Color verdeEscuro = Color(0xFF0B3740);
  static const Color verdeBase = Color(0xFF81B380);
  static const Color verdeAcao = Color(0xFF258A60);
  static const Color amareloCard = Color(0xFFD6D578);
  static const Color textoCardEscuro = Color(0xFF392E0E);
  static const Color textoDetalhe = Color(0xFF897632);

  // Dia selecionado no calendário
  int _diaSelecionado = 26;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundoBege,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER FLUIDO
            _buildHeader(),

            // CONTEÚDO ROLÁVEL (CALENDÁRIO + TAREFAS)
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // NAVEGADOR DE MÊS
                    _buildSeletorMes(),

                    const SizedBox(height: 12),

                    // CARD DO CALENDÁRIO COMPLETO
                    _buildCardCalendario(),

                    const SizedBox(height: 20),

                    // LISTA DE TAREFAS DO DIA
                    _buildSecaoTarefasDoDia(),
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
            'Tarefas do Dia',
            style: TextStyle(
              color: fundoBege,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Um pouco de atenção, todos os dias.',
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

  Widget _buildSeletorMes() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [fundoBege, amareloCard],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.chevron_left, color: verdeEscuro, size: 22),
            onPressed: () {},
          ),
          Column(
            children: const [
              Text(
                'Outubro 2026',
                style: TextStyle(
                  color: verdeEscuro,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '31 dias · começa quinta-feira',
                style: TextStyle(
                  color: verdeEscuro,
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.chevron_right, color: verdeEscuro, size: 22),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCardCalendario() {
    final List<String> diasDaSemana = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB', 'DOM'];

    // Mapeamento de dias que possuem eventos (rega ou adubação)
    final Map<int, List<Color>> eventosDias = {
      2: [verdeEscuro],
      7: [verdeEscuro],
      13: [verdeEscuro],
      15: [verdeEscuro],
      20: [verdeEscuro],
      23: [verdeEscuro, verdeEscuro],
      26: [fundoBege, fundoBege], // Dia selecionado
      28: [verdeEscuro],
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: verdeBase,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // CABEÇALHO DOS DIAS DA SEMANA
          Row(
            children: diasDaSemana
                .map(
                  (dia) => Expanded(
                    child: Text(
                      dia,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: textoCardEscuro,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),

          // GRID DOS DIAS DO MÊS (Outubro 2026 começa na Quinta-feira -> 3 células vazias)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 31 + 3, // 3 offset inicial + 31 dias
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              if (index < 3) {
                return const SizedBox.shrink(); // Células vazias do início do mês
              }

              final int dia = index - 2;
              final bool selecionado = dia == _diaSelecionado;
              final List<Color>? pontosEvento = eventosDias[dia];

              return GestureDetector(
                onTap: () => setState(() => _diaSelecionado = dia),
                child: Container(
                  decoration: BoxDecoration(
                    color: selecionado ? verdeAcao : fundoBege,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Número do Dia
                      Text(
                        '$dia',
                        style: TextStyle(
                          color: selecionado ? fundoBege : verdeEscuro,
                          fontSize: 13,
                          fontWeight: selecionado ? FontWeight.bold : FontWeight.w400,
                        ),
                      ),

                      // Indicadores de Eventos (Pontinhos de Rega/Adubação)
                      if (pontosEvento != null)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: pontosEvento
                                .map(
                                  (cor) => Container(
                                    margin: const EdgeInsets.only(left: 1),
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: cor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          // LEGENDA
          Row(
            children: [
              _buildItemLegenda('Rega', verdeEscuro),
              const SizedBox(width: 16),
              _buildItemLegenda('Adubação', verdeEscuro),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemLegenda(String rotulo, Color cor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: cor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          rotulo,
          style: const TextStyle(
            color: textoDetalhe,
            fontSize: 10,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildSecaoTarefasDoDia() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CABEÇALHO DO DIA SELECIONADO
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Segunda, $_diaSelecionado outubro',
              style: const TextStyle(
                color: verdeEscuro,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: verdeBase,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '2 tarefas',
                style: TextStyle(
                  color: verdeEscuro,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // ITEM DE TAREFA 1
        _buildItemTarefa(
          titulo: 'Regar Jiboia',
          horarioSubtitulo: '18:00 · rega semanal',
          icone: Icons.water_drop_outlined,
          concluida: false,
        ),

        const SizedBox(height: 8),

        // ITEM DE TAREFA 2
        _buildItemTarefa(
          titulo: 'Adubar Monstera',
          horarioSubtitulo: '09:00 · adubação mensal',
          icone: Icons.eco_outlined,
          concluida: true,
        ),

        const SizedBox(height: 16),

        // MENSAGEM DE CUIDADO CONCLUÍDO
        Row(
          children: const [
            Icon(Icons.check_circle_outline, color: textoDetalhe, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                '1 cuidado concluído. Seu jardim agradece!',
                style: TextStyle(
                  color: textoDetalhe,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemTarefa({
    required String titulo,
    required String horarioSubtitulo,
    required IconData icone,
    required bool concluida,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: fundoBege,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: verdeBase.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icone,
            color: verdeEscuro,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    color: verdeEscuro,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: concluida ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  horarioSubtitulo,
                  style: const TextStyle(
                    color: textoDetalhe,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            concluida ? Icons.check_box : Icons.check_box_outline_blank,
            color: concluida ? verdeAcao : verdeEscuro,
            size: 22,
          ),
        ],
      ),
    );
  }
}