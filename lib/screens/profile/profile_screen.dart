// profile_screen.dart
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Paleta de Cores do Nali-Sun
  static const Color fundoBege = Color(0xFFFBE4AE);
  static const Color verdeEscuro = Color(0xFF0B3740);
  static const Color verdeBase = Color(0xFF81B380);
  static const Color verdeAvisoCard = Color(0xFF5AA68C);
  // static const Color amareloCard = Color(0xFFD6D578);
  static const Color cardOpcoesFundo = Color(0xFFDACB8A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundoBege,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER FLUIDO
            _buildHeader(),

            // CONTEÚDO ROLÁVEL
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // CARD DE PERFIL COM GRADIENTE
                    _buildCardUsuario(),

                    const SizedBox(height: 24),

                    // TÍTULO DA SEÇÃO
                    const Text(
                      'Conta e preferências',
                      style: TextStyle(
                        color: verdeEscuro,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // LISTA DE CONFIGURAÇÕES / OPÇÕES
                    _buildContainerOpcoes(),
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
            'Meu cantinho',
            style: TextStyle(
              color: fundoBege,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Uma rotina de cuidado, do seu jeito.',
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

  Widget _buildCardUsuario() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [verdeAvisoCard, verdeBase],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // AVATAR
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fundoBege,
              border: Border.all(color: verdeEscuro, width: 2),
            ),
            child: const ClipOval(
              child: Icon(Icons.person, size: 48, color: verdeEscuro),
            ),
          ),
          const SizedBox(width: 16),

          // INFORMAÇÕES DO USUÁRIO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Alícia Santos',
                  style: TextStyle(
                    color: verdeEscuro,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Cultivando desde agosto de 2026',
                  style: TextStyle(
                    color: verdeEscuro,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '🌿 4 plantas, muitas histórias',
                  style: TextStyle(
                    color: verdeEscuro,
                    fontSize: 12,
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

  Widget _buildContainerOpcoes() {
    return Container(
      decoration: BoxDecoration(
        color: cardOpcoesFundo,
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
          _buildItemOpcao(
            icone: Icons.person_outline,
            titulo: 'Conta',
            subtitulo: 'Alícia · alicia.santos@email.com',
            mostrarDivisor: true,
          ),
          _buildItemOpcao(
            icone: Icons.tune,
            titulo: 'Preferências',
            subtitulo: 'Português · horários de cuidado',
            mostrarDivisor: true,
          ),
          _buildItemOpcao(
            icone: Icons.notifications_none,
            titulo: 'Notificações',
            subtitulo: 'Lembretes de rega ativados',
            mostrarDivisor: true,
          ),
          _buildItemOpcao(
            icone: Icons.palette_outlined,
            titulo: 'Aparência',
            subtitulo: 'Natural · claro e acolhedor',
            mostrarDivisor: true,
          ),
          _buildItemOpcao(
            icone: Icons.info_outline,
            titulo: 'Sobre Minha Estufa',
            subtitulo: 'Versão 1.0 · cuidado que aproxima',
            mostrarDivisor: false,
          ),
        ],
      ),
    );
  }

  Widget _buildItemOpcao({
    required IconData icone,
    required String titulo,
    required String subtitulo,
    required bool mostrarDivisor,
  }) {
    return Container(
      decoration: mostrarDivisor
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: verdeBase.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
            )
          : null,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(icone, color: verdeEscuro, size: 22),
        title: Text(
          titulo,
          style: const TextStyle(
            color: verdeEscuro,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitulo,
          style: const TextStyle(
            color: verdeEscuro,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: verdeEscuro,
          size: 20,
        ),
        onTap: () {},
      ),
    );
  }
}