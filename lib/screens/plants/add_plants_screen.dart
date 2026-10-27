import 'package:flutter/material.dart';

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({super.key});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _especieController = TextEditingController();

  // Valores dos sliders
  double _frequenciaRega = 7; // dias
  double _luminosidadeIndex = 1; // 0: Muito pouca, 1: Pouca, 2: Média, 3: Muita

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

  // Paleta de cores oficial do Nali-Sun
  static const Color fundoBege = Color(0xFFFBE4AE);
  static const Color verdeEscuro = Color(0xFF0B3740);
  static const Color verdeBase = Color(0xFF81B380);
  static const Color verdeAviso = Color(0xFF258A60);
  static const Color verdeBorda = Color(0xFF5AA68C);
  static const Color cardAmareloVerde = Color(0xFFD6D578);
  static const Color verdeChip = Color(0xFFA7BF73);

  @override
  void dispose() {
    _nomeController.dispose();
    _especieController.dispose();
    super.dispose();
  }

  void _salvarPlanta() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      // Lógica de salvar no Supabase / Provider entra aqui
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Planta cadastrada com sucesso! 🌿'),
          backgroundColor: verdeAviso,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundoBege,
      appBar: AppBar(
        backgroundColor: verdeEscuro,
        elevation: 0,
        toolbarHeight: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: Material(
              color: verdeBase,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: verdeEscuro, size: 22),
                onPressed: () => Navigator.pop(context),
                tooltip: 'Voltar',
              ),
            ),
          ),
        ),
        title: const Text(
          'Nova Planta',
          style: TextStyle(
            color: fundoBege,
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
                foregroundColor: fundoBege,
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ==================== CARD DE SELEÇÃO DE FOTO ====================
                _buildCardUploadFoto(),
                const SizedBox(height: 20),

                // ==================== NOME DA PLANTA ====================
                _buildRotulo('Nome da Planta'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nomeController,
                  style: const TextStyle(color: verdeEscuro, fontSize: 14),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Informe o nome da planta' : null,
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
                  style: const TextStyle(color: verdeEscuro, fontSize: 14),
                  decoration: _buildInputDecoration(
                    hint: 'Busque ou digite a espécie',
                    icon: Icons.search_outlined,
                  ),
                ),
                const SizedBox(height: 10),

                // ==================== CHIPS DE SUGESTÃO ====================
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _sugestoesEspecies.map((especie) {
                    return ActionChip(
                      label: Text(
                        especie,
                        style: const TextStyle(
                          color: verdeEscuro,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor: verdeChip,
                      side: const BorderSide(color: verdeEscuro, width: 1),
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
                  subtitulo: 'A cada ${_frequenciaRega.round()} dias',
                  icone: Icons.water_drop_outlined,
                  child: SliderTheme(
                    data: _sliderThemeData(),
                    child: Slider(
                      value: _frequenciaRega,
                      min: 1,
                      max: 30,
                      divisions: 29,
                      onChanged: (val) {
                        setState(() => _frequenciaRega = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ==================== SLIDER LUMINOSIDADE ====================
                _buildCardSlider(
                  titulo: 'Luminosidade',
                  subtitulo: _niveisLuminosidade[_luminosidadeIndex.round()],
                  icone: Icons.wb_sunny_outlined,
                  child: SliderTheme(
                    data: _sliderThemeData(),
                    child: Slider(
                      value: _luminosidadeIndex,
                      min: 0,
                      max: 3,
                      divisions: 3,
                      onChanged: (val) {
                        setState(() => _luminosidadeIndex = val);
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

  // ==================== WIDGETS AUXILIARES ====================

  Widget _buildCardUploadFoto() {
    return InkWell(
      onTap: () {
        // Exibir modal para tirar foto ou escolher da galeria
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: cardAmareloVerde,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: verdeAviso, width: 1.5),
        ),
        child: Column(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: verdeAviso,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_a_photo_outlined,
                color: fundoBege,
                size: 22,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tirar foto ou escolher da galeria',
              style: TextStyle(
                color: verdeEscuro,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'JPG ou PNG · até 10 MB',
              style: TextStyle(
                color: verdeEscuro,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cardAmareloVerde, verdeChip],
        ),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icone, color: verdeEscuro, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: verdeEscuro,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                subtitulo,
                style: const TextStyle(
                  color: verdeEscuro,
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
      style: const TextStyle(
        color: verdeEscuro,
        fontSize: 13,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: verdeEscuro.withValues(alpha: 0.5),
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, color: verdeEscuro, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: verdeBorda, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: verdeBorda, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: verdeAviso, width: 1.8),
      ),
    );
  }

  SliderThemeData _sliderThemeData() {
    return SliderThemeData(
      activeTrackColor: verdeAviso,
      inactiveTrackColor: cardAmareloVerde,
      thumbColor: verdeEscuro,
      overlayColor: verdeAviso.withValues(alpha: 0.2),
      trackHeight: 6,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
    );
  }
}