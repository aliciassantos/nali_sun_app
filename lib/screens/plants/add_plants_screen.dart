
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/plant_provider.dart';
import 'package:nali_sun_app/database/plant_dao.dart';
import 'package:nali_sun_app/services/kindwise_service.dart';
import 'package:nali_sun_app/utils/constants.dart';

class AddPlantScreen extends StatefulWidget {
  final Map<String, dynamic>? plantToEdit;

  const AddPlantScreen({super.key, this.plantToEdit});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _especieController = TextEditingController();
  String? _fotoPath;

  // ==================== ESTADO DE EDIÇÃO ====================

  Map<String, dynamic>? _plantaParaEditar;
  bool get _isEditing => _plantaParaEditar != null;

  // ---------- Busca por nome (Kindwise) ----------

  final KindwisePlantService _plantService = KindwisePlantService();
  List<PlantSuggestion> _sugestions = [];
  bool _isLoading = false;
  bool _semResultados = false;
  Timer? _debounce;

  // Espécie escolhida (por busca ou por foto).
  // O nome exibido nunca muda depois do toque.
  PlantSuggestion? _especieSelecionada;
  bool _isResolvingSelecao = false;
  String _ultimoTextoAutomatico = '';

  // ---------- Identificação por foto ----------

  final ImagePicker _picker = ImagePicker();
  Uint8List? _fotoBytes;
  bool _isIdentifying = false;
  List<PlantSuggestion> _resultadosFoto = [];
  String? _mensagemFoto;

  // Valores dos sliders

  double _frequenciaRega = 7;
  double _luminosidadeIndex = 1;

  final List<String> _niveisLuminosidade = [
    'Muito pouca',
    'Pouca',
    'Média',
    'Muita luz direta',
  ];

  final List<String> _sugestoesEspecies = [
    'Jiboia',
    'Samambaia',
    'Monstera',
    'Espada de São Jorge',
  ];

  // ==================== CORES DOS TEMAS ====================

  bool get _temaEscuro =>
      Theme.of(context).brightness == Brightness.dark;

  // Fundo
  Color get _corFundo => _temaEscuro
      ? AppColors.fundoEscuro
      : AppColors.fundoBege;

  // Texto principal
  Color get _corTexto => _temaEscuro
      ? AppColors.textoClaro
      : AppColors.verdeEscuro;

  // Texto secundário
  Color get _corTextoSecundario => _temaEscuro
      ? AppColors.textoSecundario
      : AppColors.verdeEscuro;

  // Destaques
  Color get _corDestaque => _temaEscuro
      ? AppColors.verdeDestaque
      : AppColors.verdeAcao;

  // Bordas
  Color get _corBorda => _temaEscuro
      ? AppColors.verdeBase
      : AppColors.verdeAvisoCard;

  // Card de upload e espécie selecionada
  Color get _corCard => _temaEscuro
      ? AppColors.cardEscuro
      : AppColors.amareloCard;

  // Campos e superfícies
  Color get _corSuperficie => _temaEscuro
      ? AppColors.superficieEscura
      : Colors.white;

  // Chips
  Color get _corChip => _temaEscuro
      ? AppColors.superficieEscura
      : AppColors.verdeChartreuse;

  @override
  void initState() {
    super.initState();
    _especieController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Captura os argumentos da rota quando a navegação é feita via pushNamed.
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic> && _plantaParaEditar == null) {
      _plantaParaEditar = args;
      _preencherCamposParaEdicao();
    } else if (widget.plantToEdit != null &&
        _plantaParaEditar == null) {
      _plantaParaEditar = widget.plantToEdit;
      _preencherCamposParaEdicao();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _especieController.removeListener(_onSearchChanged);
    _nomeController.dispose();
    _especieController.dispose();
    super.dispose();
  }

  void _preencherCamposParaEdicao() {
    if (_plantaParaEditar == null) return;

    final p = _plantaParaEditar!;

    // 1. Nome e Espécie
    _nomeController.text = p['name']?.toString() ?? '';

    // Preenche sem disparar uma nova busca automática.
    final especie = p['species']?.toString() ?? '';

    if (especie.isNotEmpty) {
      _setEspecieText(especie);
    }

    // 2. Frequência de Rega
    final reqDays =
        (p['watering_frequency_days'] as num?)?.toDouble() ?? 7.0;

    _frequenciaRega = reqDays.clamp(1.0, 30.0);

    // 3. Luminosidade
    final lumTexto = p['luminosity']?.toString() ?? '';
    final indexLum = _niveisLuminosidade.indexOf(lumTexto);

    if (indexLum != -1) {
      _luminosidadeIndex = indexLum.toDouble();
    }

    // 4. Imagem remota existente
    _fotoPath = p['image_path']?.toString();
  }

  // ======================================================================
  // BUSCA POR NOME
  // ======================================================================

  /// Preenche o campo de espécie sem disparar uma nova busca.
  void _setEspecieText(String text) {
    _ultimoTextoAutomatico = text;

    _especieController.removeListener(_onSearchChanged);
    _especieController.text = text;

    _especieController.selection = TextSelection.collapsed(
      offset: text.length,
    );

    _especieController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final String texto = _especieController.text;

    // Se o usuário editou o texto depois de escolher,
    // a escolha deixa de valer.
    final bool mudouEscolha =
        _especieSelecionada != null &&
        texto != _ultimoTextoAutomatico;

    if (mudouEscolha ||
        _resultadosFoto.isNotEmpty ||
        _mensagemFoto != null) {
      setState(() {
        if (mudouEscolha) {
          _especieSelecionada = null;
          _isResolvingSelecao = false;
        }

        _resultadosFoto = [];
        _mensagemFoto = null;
      });
    }

    _debounce?.cancel();

    // 700 ms: evita pesquisar a cada tecla.
    _debounce = Timer(const Duration(milliseconds: 700), () async {
      final String query = _especieController.text.trim();

      // Não pesquisa se o texto acabou de ser preenchido pelo app.
      if (_especieSelecionada != null &&
          _especieController.text == _ultimoTextoAutomatico) {
        return;
      }

      if (query.length < 3) {
        if (!mounted) return;

        setState(() {
          _sugestions = [];
          _isLoading = false;
          _semResultados = false;
        });

        return;
      }

      if (!mounted) return;

      setState(() {
        _isLoading = true;
        _semResultados = false;
      });

      List<PlantSuggestion> response = [];

      try {
        response = await _plantService.searchSpecies(query);
      } catch (e) {
        debugPrint('Erro na busca: $e');
      }

      if (!mounted) return;

      // Ignora respostas antigas.
      if (_especieController.text.trim() == query) {
        setState(() {
          _sugestions = response;
          _isLoading = false;
          _semResultados = response.isEmpty;
        });
      }
    });
  }

  /// Toque numa sugestão da busca ou da foto.
  Future<void> _selecionarSugestao(PlantSuggestion s) async {
    _debounce?.cancel();

    _setEspecieText(s.displayName);
    FocusScope.of(context).unfocus();

    final bool precisaResolver = s.accessToken.isEmpty;

    setState(() {
      _sugestions = [];
      _resultadosFoto = [];
      _mensagemFoto = null;
      _isLoading = false;
      _semResultados = false;
      _especieSelecionada = s;
      _isResolvingSelecao = precisaResolver;
    });

    if (!precisaResolver) return;

    // Resultado de foto: busca o token e os dados completos.
    final resolved = await _plantService.resolveSuggestion(s);

    if (!mounted) return;
    if (!identical(_especieSelecionada, s)) return;

    setState(() {
      _especieSelecionada = resolved;
      _isResolvingSelecao = false;
    });
  }

  void _removerEspecie() {
    _debounce?.cancel();
    _setEspecieText('');

    setState(() {
      _especieSelecionada = null;
      _isResolvingSelecao = false;
      _sugestions = [];
      _semResultados = false;
    });
  }

  // ======================================================================
  // IDENTIFICAÇÃO POR FOTO
  // ======================================================================

  Future<void> _escolherFoto() async {
    final ImageSource? origem =
        await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: _temaEscuro
          ? AppColors.cardEscuro
          : AppColors.fundoBege,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(
                Icons.photo_camera_outlined,
                color: _temaEscuro
                    ? AppColors.verdeDestaque
                    : AppColors.verdeEscuro,
              ),
              title: Text(
                'Tirar foto',
                style: TextStyle(
                  color: _temaEscuro
                      ? AppColors.textoClaro
                      : AppColors.verdeEscuro,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library_outlined,
                color: _temaEscuro
                    ? AppColors.verdeDestaque
                    : AppColors.verdeEscuro,
              ),
              title: Text(
                'Escolher da galeria',
                style: TextStyle(
                  color: _temaEscuro
                      ? AppColors.textoClaro
                      : AppColors.verdeEscuro,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (origem == null) return;

    await _identificarFoto(origem);
  }

  Future<void> _identificarFoto(ImageSource origem) async {
    XFile? arquivo;

    try {
      arquivo = await _picker.pickImage(
        source: origem,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
    } catch (e) {
      debugPrint('Erro ao abrir câmera/galeria: $e');
      _mostrarAviso('Não foi possível acessar a câmera ou a galeria.');
      return;
    }

    if (arquivo == null) return;

    final Uint8List bytes = await arquivo.readAsBytes();

    if (!mounted) return;

    FocusScope.of(context).unfocus();
    _debounce?.cancel();

    setState(() {
      _fotoBytes = bytes;
      _fotoPath = arquivo!.path;
      _isIdentifying = true;
      _resultadosFoto = [];
      _mensagemFoto = null;
      _sugestions = [];
      _isLoading = false;
      _semResultados = false;
      _especieSelecionada = null;
      _isResolvingSelecao = false;
    });

    final result = await _plantService.identifyByImage(bytes);

    if (!mounted) return;

    setState(() {
      _isIdentifying = false;

      if (result == null) {
        _mensagemFoto =
            'Não foi possível identificar a planta. '
            'Tente de novo ou busque pelo nome.';
      } else if (!result.isPlant) {
        _mensagemFoto =
            'Não parece haver uma planta nessa foto. '
            'Tente outra imagem.';
      } else if (result.suggestions.isEmpty) {
        _mensagemFoto =
            'Nenhuma espécie encontrada. '
            'Tente outra foto ou busque pelo nome.';
      } else {
        _resultadosFoto = result.suggestions;
      }
    });
  }

  void _mostrarAviso(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: AppColors.verdeEscuro,
      ),
    );
  }

  // ======================================================================
  // SALVAR
  // ======================================================================

  Future<void> _salvarPlanta() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final nome = _nomeController.text.trim();
    final especie = _especieController.text.trim();
    final frequenciaRega = _frequenciaRega.round();

    final luminosidade =
        _niveisLuminosidade[_luminosidadeIndex.round()];

    try {
      String? imageUrl = _fotoPath;

      // Se o usuário selecionou uma nova foto, faz o upload.
      if (_fotoBytes != null) {
        imageUrl = await PlantDAO.uploadFotoSupabase(_fotoBytes!);
      }

      if (_isEditing) {
        final plantId =
            int.parse(_plantaParaEditar!['id'].toString());

        await PlantDAO.updatePlant(
          plantId: plantId,
          name: nome,
          species: especie,
          wateringFrequencyDays: frequenciaRega,
          luminosity: luminosidade,
          imagePath: imageUrl,
        );
      } else {
        await PlantDAO.insertPlant(
          name: nome,
          species: especie,
          wateringFrequencyDays: frequenciaRega,
          luminosity: luminosidade,
          imagePath: imageUrl,
        );
      }

      if (!mounted) return;

      await context.read<PlantProvider>().carregarPlantas();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Planta atualizada com sucesso! 🌿'
                : 'Planta cadastrada com sucesso! 🌿',
          ),
          backgroundColor: AppColors.verdeAcao,
        ),
      );

      // Retorna true para atualizar as listas anteriores.
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Erro ao salvar planta no Supabase: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Não foi possível atualizar a planta. Tente novamente.'
                : 'Não foi possível cadastrar a planta. Tente novamente.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ======================================================================
  // BUILD
  // ======================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _corFundo,
      appBar: AppBar(
        // AppBar permanece igual nos dois temas.
        backgroundColor: AppColors.verdeEscuro,
        elevation: 0,
        toolbarHeight: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: Material(
              color: AppColors.verdeBase,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.verdeEscuro,
                  size: 22,
                ),
                onPressed: () => Navigator.pop(context),
                tooltip: 'Voltar',
              ),
            ),
          ),
        ),
        title: Text(
          _isEditing ? 'Editar Planta' : 'Nova Planta',
          style: const TextStyle(
            color: AppColors.fundoBege,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: _salvarPlanta,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.fundoBege,
              ),
              child: const Text(
                'Salvar',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ==================== FOTO ====================

                _buildCardUploadFoto(),

                if (_mensagemFoto != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _mensagemFoto!,
                    style: TextStyle(
                      color: _corTexto,
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],

                if (_resultadosFoto.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _buildRotulo(
                    'Possíveis espécies · toque para escolher',
                  ),
                  const SizedBox(height: 6),
                  _buildListaSugestoes(
                    _resultadosFoto,
                    mostrarProbabilidade: true,
                  ),
                ],

                const SizedBox(height: 20),

                // ==================== NOME DA PLANTA ====================

                _buildRotulo('Nome da Planta'),
                const SizedBox(height: 6),

                TextFormField(
                  controller: _nomeController,
                  style: TextStyle(
                    color: _corTexto,
                    fontSize: 14,
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty)
                          ? 'Informe o nome da planta'
                          : null,
                  decoration: _buildInputDecoration(
                    hint: 'Ex.: minha Jiboia',
                    icon: Icons.eco_outlined,
                  ),
                ),

                const SizedBox(height: 16),

                // ==================== ESPÉCIE / TIPO ====================

                _buildRotulo('Espécie / Tipo'),
                const SizedBox(height: 6),

                TextFormField(
                  controller: _especieController,
                  style: TextStyle(
                    color: _corTexto,
                    fontSize: 14,
                  ),
                  decoration: _buildInputDecoration(
                    hint: 'Busque ou digite a espécie',
                    icon: Icons.search_outlined,
                    suffix: _isLoading
                        ? Padding(
                            padding: const EdgeInsets.all(12),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _corDestaque,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),

                const SizedBox(height: 10),

                // Resultados da busca.
                if (_sugestions.isNotEmpty) ...[
                  _buildListaSugestoes(_sugestions),
                  const SizedBox(height: 10),
                ],

                if (_semResultados && _sugestions.isEmpty) ...[
                  Text(
                    'Nenhuma espécie encontrada. '
                    'Você pode digitar o nome mesmo assim.',
                    style: TextStyle(
                      color: _corTextoSecundario,
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Espécie escolhida.
                if (_especieSelecionada != null) ...[
                  _buildCardEspecieSelecionada(),
                  const SizedBox(height: 10),
                ],

                // ==================== CHIPS DE SUGESTÃO ====================

                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _sugestoesEspecies.map((especie) {
                    return ActionChip(
                      label: Text(
                        especie,
                        style: TextStyle(
                          color: _corTexto,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor: _corChip,
                      side: BorderSide(
                        color: _temaEscuro
                            ? AppColors.verdeDestaque
                            : AppColors.verdeEscuro,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onPressed: () {
                        setState(() {
                          _especieController.text = especie;
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // ==================== SLIDER FREQUÊNCIA DE REGA ====================

                _buildCardSlider(
                  titulo: 'Frequência de Rega',
                  subtitulo:
                      'A cada ${_frequenciaRega.round()} dias',
                  icone: Icons.water_drop_outlined,
                  child: SliderTheme(
                    data: _sliderThemeData(),
                    child: Slider(
                      value: _frequenciaRega,
                      min: 1,
                      max: 30,
                      divisions: 29,
                      onChanged: (val) {
                        setState(() {
                          _frequenciaRega = val;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ==================== SLIDER LUMINOSIDADE ====================

                _buildCardSlider(
                  titulo: 'Luminosidade',
                  subtitulo:
                      _niveisLuminosidade[_luminosidadeIndex.round()],
                  icone: Icons.wb_sunny_outlined,
                  child: SliderTheme(
                    data: _sliderThemeData(),
                    child: Slider(
                      value: _luminosidadeIndex,
                      min: 0,
                      max: 3,
                      divisions: 3,
                      onChanged: (val) {
                        setState(() {
                          _luminosidadeIndex = val;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ======================================================================
  // WIDGETS AUXILIARES
  // ======================================================================

  /// Lista de espécies com imagem, nome comum e nome científico.
  Widget _buildListaSugestoes(
    List<PlantSuggestion> itens, {
    bool mostrarProbabilidade = false,
  }) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 340),
      decoration: BoxDecoration(
        color: _corSuperficie,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _corBorda),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: itens.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: _corBorda.withValues(alpha: 0.3),
          ),
          itemBuilder: (context, index) {
            final item = itens[index];

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              leading: _PlantImage(
                url: item.imageUrl,
                size: 52,
              ),
              title: Text(
                item.displayName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _corTexto,
                ),
              ),
              subtitle: item.hasDistinctScientificName
                  ? Text(
                      item.scientificName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: _corTextoSecundario,
                      ),
                    )
                  : null,
              trailing:
                  (mostrarProbabilidade && item.probability != null)
                      ? Text(
                          '${(item.probability! * 100).round()}%',
                          style: TextStyle(
                            color: _corDestaque,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
              onTap: () => _selecionarSugestao(item),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardEspecieSelecionada() {
    final especie = _especieSelecionada!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _corCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _corDestaque,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          _PlantImage(
            url: especie.imageUrl,
            size: 72,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  especie.displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _corTexto,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (especie.hasDistinctScientificName) ...[
                  const SizedBox(height: 2),
                  Text(
                    especie.scientificName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _corTextoSecundario,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                if (_isResolvingSelecao)
                  Row(
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _corDestaque,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Carregando dados da planta…',
                        style: TextStyle(
                          color: _corTextoSecundario,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                else if (especie.details.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: _corDestaque,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Dados da espécie prontos',
                        style: TextStyle(
                          color: _corTextoSecundario,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remover espécie',
            icon: Icon(
              Icons.close,
              color: _corTexto,
              size: 20,
            ),
            onPressed: _removerEspecie,
          ),
        ],
      ),
    );
  }

  Widget _buildCardUploadFoto() {
    return Material(
      color: _corCard,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _corDestaque,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: _isIdentifying ? null : _escolherFoto,
        child: (_fotoBytes == null &&
                (_fotoPath == null || _fotoPath!.isEmpty))
            ? _conteudoUploadVazio()
            : _conteudoFotoSelecionada(),
      ),
    );
  }

  Widget _conteudoUploadVazio() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 24,
        horizontal: 16,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: _corDestaque,
            child: const Icon(
              Icons.add_a_photo_outlined,
              color: AppColors.fundoBege,
              size: 22,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tirar foto ou escolher da galeria',
            style: TextStyle(
              color: _corTexto,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Identificamos a espécie pela foto',
            style: TextStyle(
              color: _corTextoSecundario,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _conteudoFotoSelecionada() {
    Widget imagemWidget;

    if (_fotoBytes != null) {
      imagemWidget = Image.memory(
        _fotoBytes!,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      imagemWidget = Image.network(
        _fotoPath!,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _conteudoUploadVazio(),
      );
    }

    return Stack(
      children: [
        imagemWidget,
        if (_isIdentifying)
          Positioned.fill(
            child: Container(
              color: AppColors.verdeEscuro.withValues(alpha: 0.6),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.fundoBege,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Identificando a planta…',
                    style: TextStyle(
                      color: AppColors.fundoBege,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: AppColors.verdeEscuro.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh,
                    size: 14,
                    color: AppColors.fundoBege,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Trocar foto',
                    style: TextStyle(
                      color: AppColors.fundoBege,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCardSlider({
    required String titulo,
    required String subtitulo,
    required IconData icone,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        // O gradiente original do tema claro foi preservado.
        gradient: _temaEscuro
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.amareloCard,
                  AppColors.verdeChartreuse,
                ],
              ),
        color: _temaEscuro ? AppColors.cardEscuro : null,
        borderRadius: BorderRadius.circular(16),
        border: _temaEscuro
            ? Border.all(
                color: AppColors.verdeBase.withValues(alpha: 0.5),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: _temaEscuro ? 0.15 : 0.08,
            ),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    icone,
                    color: _corTexto,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    titulo,
                    style: TextStyle(
                      color: _corTexto,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                subtitulo,
                style: TextStyle(
                  color: _corTexto,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildRotulo(String texto) {
    return Text(
      texto,
      style: TextStyle(
        color: _corTexto,
        fontSize: 13,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      suffixIcon: suffix,
      hintText: hint,
      hintStyle: TextStyle(
        color: _corTextoSecundario.withValues(alpha: 0.5),
        fontSize: 13,
      ),
      prefixIcon: Icon(
        icon,
        color: _temaEscuro
            ? AppColors.verdeDestaque
            : AppColors.verdeEscuro,
        size: 20,
      ),
      filled: true,
      fillColor: _corSuperficie,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: _corBorda,
          width: 1.2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: _corBorda,
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: _corDestaque,
          width: 1.8,
        ),
      ),
    );
  }

  SliderThemeData _sliderThemeData() {
    return SliderThemeData(
      activeTrackColor: _corDestaque,
      inactiveTrackColor: _temaEscuro
          ? AppColors.superficieEscura
          : AppColors.amareloCard,
      thumbColor: _temaEscuro
          ? AppColors.textoClaro
          : AppColors.verdeEscuro,
      overlayColor: _corDestaque.withValues(alpha: 0.2),
      trackHeight: 6,
      thumbShape: const RoundSliderThumbShape(
        enabledThumbRadius: 9,
      ),
    );
  }
}

/// Imagem da planta com spinner, fallback de ícone e, na web,
/// fallback para <img> HTML quando o CDN não permite CORS.
class _PlantImage extends StatelessWidget {
  const _PlantImage({
    required this.url,
    required this.size,
  });

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final temaEscuro =
        Theme.of(context).brightness == Brightness.dark;

    final corFundo = temaEscuro
        ? AppColors.superficieEscura
        : AppColors.verdeChartreuse;

    final corIcone = temaEscuro
        ? AppColors.verdeDestaque
        : AppColors.verdeEscuro;

    final fallback = Container(
      width: size,
      height: size,
      color: corFundo.withValues(alpha: 0.35),
      child: Icon(
        Icons.eco_outlined,
        color: corIcone,
        size: size * 0.45,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: size,
        height: size,
        child: url.isEmpty
            ? fallback
            : Image.network(
                url,
                fit: BoxFit.cover,

                // Só tem efeito na web.
                webHtmlElementStrategy:
                    WebHtmlElementStrategy.fallback,

                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;

                  return Center(
                    child: SizedBox(
                      width: size * 0.35,
                      height: size * 0.35,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: corIcone,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  debugPrint(
                    'Falha ao carregar imagem ($url): $error',
                  );

                  return fallback;
                },
              ),
      ),
    );
  }
}
