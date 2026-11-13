
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/plant_dao.dart';
import '../../providers/plant_provider.dart';
import '../../app/routes.dart';
import '../../utils/constants.dart';

class PlantDetailsScreen extends StatefulWidget {
  final String plantId;

  const PlantDetailsScreen({super.key, required this.plantId});

  @override
  State<PlantDetailsScreen> createState() => _PlantDetailsScreenState();
}

class _PlantDetailsScreenState extends State<PlantDetailsScreen> {
  // ==================== PALETA DE CORES ====================

  // Cores originais do tema claro
  static const Color verdeEscuro = Color(0xFF0B3740);
  static const Color verdeMedio = Color(0xFF258A60);
  static const Color verdeFolha = Color(0xFF5AA68C);
  static const Color verdeClaro = Color(0xFF81B380);
  static const Color amareloVerde = Color(0xFFA7BF73);
  static const Color amareloCreme = Color(0xFFD6D578);
  static const Color fundoAmarelado = Color(0xFFFBE4AE);

  // Identificação do tema atual
  bool get _temaEscuro =>
      Theme.of(context).brightness == Brightness.dark;

  // ==================== CORES ADAPTÁVEIS ====================

  Color get _fundo =>
      _temaEscuro ? AppColors.fundoEscuro : fundoAmarelado;

  Color get _texto =>
      _temaEscuro ? AppColors.textoClaro : verdeEscuro;

  Color get _textoSecundario =>
      _temaEscuro ? AppColors.textoSecundario : verdeEscuro;

  // Cor dos textos da AppBar
  Color get _textoAppBar =>
      _temaEscuro ? AppColors.textoClaro : fundoAmarelado;

  Color get _destaque =>
      _temaEscuro ? AppColors.verdeDestaque : verdeMedio;

  Color get _corIcone =>
      _temaEscuro ? AppColors.verdeDestaque : verdeEscuro;

  List<Color> get _gradienteVerde => _temaEscuro
      ? [
          AppColors.cardEscuro,
          AppColors.superficieEscura,
        ]
      : [
          verdeFolha,
          verdeClaro,
        ];

  List<Color> get _gradienteAmarelo => _temaEscuro
      ? [
          AppColors.cardEscuro,
          AppColors.superficieEscura,
        ]
      : [
          amareloCreme,
          amareloVerde,
        ];

  // ==================== ESTADO DA TELA ====================

  Map<String, dynamic>? planta;
  int regasDoMes = 0;

  bool carregando = true;
  bool processandoRega = false;
  bool processandoExclusao = false;

  // ==================== CICLO DE VIDA ====================

  @override
  void initState() {
    super.initState();
    _carregarPlanta();
  }

  // ==================== CARREGAR PLANTA ====================

  Future<void> _carregarPlanta() async {
    final id = int.tryParse(widget.plantId);

    if (id == null) {
      if (!mounted) return;

      setState(() {
        carregando = false;
      });

      return;
    }

    final provider = context.read<PlantProvider>();

    var resultado = provider.buscarPlanta(id);

    if (resultado == null) {
      await provider.carregarPlantas();
      resultado = provider.buscarPlanta(id);
    }

    int totalRegas = 0;

    if (resultado != null) {
      totalRegas = await PlantDAO.buscarRegasDoMes(widget.plantId);
    }

    if (!mounted) return;

    setState(() {
      planta = resultado;
      regasDoMes = totalRegas;
      carregando = false;
    });
  }

  // ==================== CÁLCULO DE ASSIDUIDADE ====================

  double _calcularAssiduidade({
    required int totalRegasRealizadas,
  }) {
    if (planta == null) return 1.0;

    final createdAtString =
        planta!['created_at']?.toString();

    final createdAt =
        DateTime.tryParse(createdAtString ?? '');

    if (createdAt == null) return 1.0;

    final frequencia =
        (planta!['watering_frequency_days'] as num?)?.toInt() ?? 1;

    final diasCultivo =
        DateTime.now().difference(createdAt).inDays;

    if (diasCultivo <= 0 || frequencia <= 0) return 1.0;

    final regasEsperadas = diasCultivo / frequencia;

    if (regasEsperadas <= 0) return 1.0;

    final percentual =
        totalRegasRealizadas / regasEsperadas;

    return percentual.clamp(0.0, 1.0);
  }

  // ==================== REGISTRAR REGA ====================

  Future<void> _regarAgora() async {
    if (processandoRega || planta == null) return;

    setState(() {
      processandoRega = true;
    });

    try {
      final id = int.parse(widget.plantId);

      await context.read<PlantProvider>().registrarRega(id);

      if (!mounted) return;

      await _carregarPlanta();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Rega registrada com sucesso! 💧',
          ),
          backgroundColor: _destaque,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível registrar a rega: $e',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          processandoRega = false;
        });
      }
    }
  }

  // ==================== DIAS DE CULTIVO ====================

  int _calcularDiasCultivo() {
    if (planta == null) return 0;

    final createdAtString =
        planta!['created_at']?.toString();

    final createdAt =
        DateTime.tryParse(createdAtString ?? '');

    if (createdAt == null) return 0;

    final diferenca =
        DateTime.now().difference(createdAt).inDays;

    return diferenca < 0 ? 0 : diferenca;
  }

  // ==================== EXCLUIR PLANTA ====================

  Future<void> _excluirPlanta() async {
    if (planta == null || processandoExclusao) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _temaEscuro
              ? AppColors.cardEscuro
              : fundoAmarelado,
          title: Text(
            'Excluir planta?',
            style: TextStyle(color: _texto),
          ),
          content: Text(
            'Deseja realmente excluir ${planta!['name']}? '
            'Essa ação não poderá ser desfeita.',
            style: TextStyle(color: _textoSecundario),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text(
                'Cancelar',
                style: TextStyle(color: _destaque),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    setState(() {
      processandoExclusao = true;
    });

    try {
      await context.read<PlantProvider>().excluirPlanta(
        int.parse(widget.plantId),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        processandoExclusao = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir planta: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ==================== CONSTRUIR TELA ====================

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return Scaffold(
        backgroundColor: _fundo,
        body: Center(
          child: CircularProgressIndicator(
            color: _destaque,
          ),
        ),
      );
    }

    if (planta == null) {
      return Scaffold(
        backgroundColor: _fundo,
        appBar: AppBar(
          backgroundColor:
              _temaEscuro ? AppColors.fundoEscuro : verdeEscuro,
          foregroundColor: _textoAppBar,
          title: const Text('Detalhes da planta'),
        ),
        body: Center(
          child: Text(
            'Planta não encontrada.',
            style: TextStyle(color: _texto),
          ),
        ),
      );
    }

    final nome =
        planta!['name']?.toString() ?? 'Planta';

    final especie =
        planta!['species']?.toString() ??
        'Espécie não informada';

    final frequencia =
        (planta!['watering_frequency_days'] as num?)?.toInt() ?? 1;

    final luminosidade =
        planta!['luminosity']?.toString() ?? 'Não informada';

    final imagem =
        planta!['image_path']?.toString() ?? '';

    final assiduidadeValor = _calcularAssiduidade(
      totalRegasRealizadas: regasDoMes,
    );

    final assiduidadePorcentagem =
        (assiduidadeValor * 100).toInt();

    return Scaffold(
      backgroundColor: _fundo,

      // ==================== APP BAR ====================

      appBar: AppBar(
        backgroundColor:
            _temaEscuro ? AppColors.fundoEscuro : verdeEscuro,
        elevation: 0,
        leadingWidth: 56,

        // Seta de voltar
        leading: Center(
          child: Container(
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              color: _temaEscuro
                  ? AppColors.cardEscuro
                  : verdeClaro,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: _temaEscuro
                    ? AppColors.textoClaro
                    : verdeEscuro,
                size: 22,
              ),
              onPressed: () => Navigator.maybePop(context),
              tooltip: 'Voltar',
            ),
          ),
        ),

        // Nome e espécie da planta
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              nome,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _textoAppBar,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              especie,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _textoAppBar.withValues(alpha: 0.85),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),

        // Ações da AppBar
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundColor: _temaEscuro
                  ? AppColors.cardEscuro
                  : amareloVerde,
              radius: 18,
              child: Icon(
                Icons.edit_outlined,
                size: 18,
                color: _temaEscuro
                    ? AppColors.verdeDestaque
                    : verdeEscuro,
              ),
            ),
            onPressed: () async {
              final atualizou = await Navigator.pushNamed(
                context,
                AppRoutes.plant,
                arguments: planta,
              );

              if (atualizou == true) {
                await _carregarPlanta();
              }
            },
          ),

          IconButton(
            icon: CircleAvatar(
              backgroundColor: _temaEscuro
                  ? AppColors.cardEscuro
                  : verdeFolha,
              radius: 18,
              child: Icon(
                Icons.delete_outline,
                size: 18,
                color: _temaEscuro
                    ? AppColors.textoClaro
                    : fundoAmarelado,
              ),
            ),
            onPressed:
                processandoExclusao ? null : _excluirPlanta,
          ),

          const SizedBox(width: 8),
        ],
      ),

      // ==================== CONTEÚDO ====================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==================== IMAGEM ====================

            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: imagem.isNotEmpty
                  ? Image.network(
                      imagem,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _imagemAlternativa();
                      },
                    )
                  : _imagemAlternativa(),
            ),

            const SizedBox(height: 16),

            // ==================== REGA E LUMINOSIDADE ====================

            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.water_drop_outlined,
                    title:
                        'A cada $frequencia '
                        '${frequencia == 1 ? 'dia' : 'dias'}',
                    subtitle: _textoProximaRega(frequencia),
                    gradientColors: _gradienteVerde,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.wb_sunny_outlined,
                    title: luminosidade,
                    subtitle: 'Luminosidade',
                    gradientColors: _gradienteAmarelo,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ==================== BOTÃO REGAR ====================

            ElevatedButton(
              onPressed:
                  processandoRega ? null : _regarAgora,
              style: ElevatedButton.styleFrom(
                backgroundColor: _destaque,
                foregroundColor: _temaEscuro
                    ? AppColors.fundoEscuro
                    : fundoAmarelado,
                disabledBackgroundColor:
                    _destaque.withValues(alpha: 0.6),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (processandoRega)
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _temaEscuro
                            ? AppColors.textoClaro
                            : fundoAmarelado,
                      ),
                    )
                  else
                    const Text(
                      '💦 ',
                      style: TextStyle(fontSize: 16),
                    ),

                  const SizedBox(width: 4),

                  Text(
                    processandoRega
                        ? 'Registrando...'
                        : 'Regar Agora',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ==================== ASSIDUIDADE ====================

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _gradienteAmarelo,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.stars_outlined,
                            size: 20,
                            color: _corIcone,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Assiduidade',
                            style: TextStyle(
                              color: _texto,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      Text(
                        '$assiduidadePorcentagem%',
                        style: TextStyle(
                          color: _texto,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: LinearProgressIndicator(
                      value: assiduidadeValor,
                      minHeight: 8,
                      backgroundColor: _temaEscuro
                          ? AppColors.superficieEscura
                          : amareloCreme,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(_destaque),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Uma rotina gentil, um jardim saudável.',
                    style: TextStyle(
                      color: _texto,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ==================== ESTATÍSTICAS ====================

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.calendar_today_outlined,
                    value: regasDoMes.toString(),
                    label: 'Total de regas no mês',
                    gradientColors: _gradienteVerde,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _buildStatCard(
                    icon: Icons.eco_outlined,
                    value: _calcularDiasCultivo().toString(),
                    label: 'Total de dias de cultivo',
                    gradientColors: _temaEscuro
                        ? _gradienteVerde
                        : [amareloVerde, verdeClaro],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== IMAGEM ALTERNATIVA ====================

  Widget _imagemAlternativa() {
    return Container(
      height: 180,
      width: double.infinity,
      color: _temaEscuro
          ? AppColors.cardEscuro
          : verdeFolha.withValues(alpha: 0.3),
      child: Icon(
        Icons.eco,
        size: 48,
        color: _corIcone,
      ),
    );
  }

  // ==================== PRÓXIMA REGA ====================

  String _textoProximaRega(int frequencia) {
    final ultimaRegaString =
        planta!['last_watered_at']?.toString();

    final cadastroString =
        planta!['created_at']?.toString();

    final referencia =
        DateTime.tryParse(ultimaRegaString ?? '') ??
        DateTime.tryParse(cadastroString ?? '');

    if (referencia == null) {
      return 'Data não disponível';
    }

    final proximaRega =
        referencia.add(Duration(days: frequencia));

    final hoje = DateTime.now();

    final hojeData =
        DateTime(hoje.year, hoje.month, hoje.day);

    final proximaData = DateTime(
      proximaRega.year,
      proximaRega.month,
      proximaRega.day,
    );

    final diferenca =
        proximaData.difference(hojeData).inDays;

    if (diferenca < 0) {
      return 'Atrasada há ${diferenca.abs()} '
          '${diferenca.abs() == 1 ? 'dia' : 'dias'}';
    }

    if (diferenca == 0) {
      return 'Próxima: hoje';
    }

    if (diferenca == 1) {
      return 'Próxima: amanhã';
    }

    return 'Próxima em $diferenca dias';
  }

  // ==================== CARD DE INFORMAÇÃO ====================

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 22,
            color: _corIcone,
          ),

          const SizedBox(height: 8),

          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _texto,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            subtitle,
            style: TextStyle(
              color: _textoSecundario,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== CARD DE ESTATÍSTICAS ====================

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required List<Color> gradientColors,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 22,
            color: _corIcone,
          ),

          const SizedBox(height: 4),

          Text(
            value,
            style: TextStyle(
              color: _texto,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            label,
            style: TextStyle(
              color: _textoSecundario,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
