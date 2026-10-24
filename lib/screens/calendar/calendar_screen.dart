// Aba 3: Agenda e Tarefas

import 'package:flutter/material.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // Paleta original Nali-Sun
  static const Color fundoBege = Color(0xFFFBE4AE);
  static const Color verdeEscuro = Color(0xFF0B3740);
  static const Color verdeBase = Color(0xFF81B380);
  static const Color verdeAcao = Color(0xFF258A60);
  static const Color amareloCard = Color(0xFFD6D578);
  static const Color textoCardEscuro = Color(0xFF392E0E);
  static const Color textoDetalhe = Color(0xFF897632);

  int _diaSelecionado = 26;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final escuro = tema.brightness == Brightness.dark;
    final fundo = tema.scaffoldBackgroundColor;
    final texto = tema.colorScheme.onSurface;

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
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSeletorMes(escuro),
                    const SizedBox(height: 12),
                    _buildCardCalendario(escuro),
                    const SizedBox(height: 20),
                    _buildSecaoTarefasDoDia(escuro, texto),
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
    final corFundo =
        escuro ? const Color(0xFF102A2E) : verdeEscuro;
    final corTexto = escuro ? Colors.white : fundoBege;

    return Container(
      width: double.infinity,
      color: corFundo,
      padding: const EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tarefas do Dia',
            style: TextStyle(
              color: corTexto,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Um pouco de atenção, todos os dias.',
            style: TextStyle(
              color: corTexto,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SELETOR DE MÊS ====================

  Widget _buildSeletorMes(bool escuro) {
    final corTexto = escuro ? Colors.white : verdeEscuro;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: escuro
              ? const [
                  Color(0xFF29483F),
                  Color(0xFF203A36),
                ]
              : const [
                  fundoBege,
                  amareloCard,
                ],
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
            icon: Icon(
              Icons.chevron_left,
              color: corTexto,
              size: 22,
            ),
            onPressed: () {},
          ),
          Column(
            children: [
              Text(
                'Outubro 2026',
                style: TextStyle(
                  color: corTexto,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '31 dias · começa quinta-feira',
                style: TextStyle(
                  color: corTexto.withValues(alpha: 0.8),
                  fontSize: 10,
                ),
              ),
            ],
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              Icons.chevron_right,
              color: corTexto,
              size: 22,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // ==================== CALENDÁRIO ====================

  Widget _buildCardCalendario(bool escuro) {
    const diasDaSemana = [
      'SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB', 'DOM',
    ];

    final corCartao =
        escuro ? const Color(0xFF1B383C) : verdeBase;
    final corCelula =
        escuro ? const Color(0xFF294448) : fundoBege;
    final corTexto =
        escuro ? Colors.white : verdeEscuro;
    final corEvento =
        escuro ? const Color(0xFFA7D8A5) : verdeEscuro;
    final corSelecionado =
        escuro ? const Color(0xFF81B380) : verdeAcao;
    final corTextoSelecionado =
        escuro ? const Color(0xFF102A2E) : fundoBege;

    final Map<int, int> eventosDias = {
      2: 1,
      7: 1,
      13: 1,
      15: 1,
      20: 1,
      23: 2,
      28: 1,
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: corCartao,
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
          Row(
            children: diasDaSemana.map((dia) {
              return Expanded(
                child: Text(
                  dia,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: corTexto,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 34,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              if (index < 3) {
                return const SizedBox.shrink();
              }

              final dia = index - 2;
              final selecionado = dia == _diaSelecionado;
              final quantidadeEventos = eventosDias[dia] ?? 0;

              return GestureDetector(
                onTap: () => setState(() {
                  _diaSelecionado = dia;
                }),
                child: Container(
                  decoration: BoxDecoration(
                    color: selecionado
                        ? corSelecionado
                        : corCelula,
                    borderRadius: BorderRadius.circular(10),
                    border: selecionado
                        ? Border.all(
                            color: escuro
                                ? verdeBase
                                : verdeEscuro,
                            width: 1.2,
                          )
                        : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$dia',
                        style: TextStyle(
                          color: selecionado
                              ? corTextoSelecionado
                              : corTexto,
                          fontSize: 13,
                          fontWeight: selecionado
                              ? FontWeight.bold
                              : FontWeight.w400,
                        ),
                      ),
                      if (quantidadeEventos > 0)
                        Positioned(
                          bottom: 3,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              quantidadeEventos,
                              (_) => Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 1,
                                ),
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: selecionado
                                      ? corTextoSelecionado
                                      : corEvento,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              _buildItemLegenda('Rega', corEvento, corTexto),
              const SizedBox(width: 16),
              _buildItemLegenda(
                'Adubação',
                escuro ? amareloCard : verdeEscuro,
                corTexto,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemLegenda(
    String rotulo,
    Color cor,
    Color corTexto,
  ) {
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
          style: TextStyle(
            color: corTexto,
            fontSize: 10,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ==================== TAREFAS DO DIA ====================

  Widget _buildSecaoTarefasDoDia(
    bool escuro,
    Color corTexto,
  ) {
    final corEtiqueta =
        escuro ? const Color(0xFF29483F) : verdeBase;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Segunda, $_diaSelecionado outubro',
                style: TextStyle(
                  color: corTexto,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: corEtiqueta,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '2 tarefas',
                style: TextStyle(
                  color: escuro ? Colors.white : verdeEscuro,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        _buildItemTarefa(
          titulo: 'Regar Jiboia',
          horarioSubtitulo: '18:00 · rega semanal',
          icone: Icons.water_drop_outlined,
          concluida: false,
          escuro: escuro,
        ),

        const SizedBox(height: 8),

        _buildItemTarefa(
          titulo: 'Adubar Monstera',
          horarioSubtitulo: '09:00 · adubação mensal',
          icone: Icons.eco_outlined,
          concluida: true,
          escuro: escuro,
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: escuro ? verdeBase : textoDetalhe,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '1 cuidado concluído. Seu jardim agradece!',
                style: TextStyle(
                  color: escuro
                      ? const Color(0xFFB8CCC5)
                      : textoDetalhe,
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

  // ==================== ITEM DE TAREFA ====================

  Widget _buildItemTarefa({
    required String titulo,
    required String horarioSubtitulo,
    required IconData icone,
    required bool concluida,
    required bool escuro,
  }) {
    final corFundo =
        escuro ? const Color(0xFF1B383C) : fundoBege;
    final corTexto =
        escuro ? Colors.white : verdeEscuro;
    final corDetalhe =
        escuro ? const Color(0xFFB8CCC5) : textoDetalhe;
    final corIcone =
        escuro ? verdeBase : verdeEscuro;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: verdeBase.withValues(alpha: escuro ? 0.6 : 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icone, color: corIcone, size: 20),
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
                    decoration: concluida
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  horarioSubtitulo,
                  style: TextStyle(
                    color: corDetalhe,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            concluida
                ? Icons.check_box
                : Icons.check_box_outline_blank,
            color: concluida ? verdeBase : corIcone,
            size: 22,
          ),
        ],
      ),
    );
  }
}
