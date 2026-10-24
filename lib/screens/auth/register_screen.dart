// Registro

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool _mostrarSenha = false;
  bool _mostrarConfirmacao = false;
  bool _carregando = false;

  // Paleta original do NaliSun.
  static const Color fundo = Color(0xFF0B3740);
  static const Color bege = Color(0xFFFBE4AE);
  static const Color verde = Color(0xFF258A60);
  static const Color borda = Color(0xFF81B380);

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  String? _validarNome(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Informe seu nome.';
    }

    if (valor.trim().length < 2) {
      return 'Digite um nome válido.';
    }

    return null;
  }

  InputDecoration _decoracaoCampo({
    required String dica,
    required IconData icone,
    Widget? sufixo,
  }) {
    return InputDecoration(
      hintText: dica,
      hintStyle: const TextStyle(
        color: Color(0x990B3740),
        fontSize: 12,
      ),
      prefixIcon: Icon(
        icone,
        size: 19,
        color: fundo,
      ),
      suffixIcon: sufixo,
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(
          color: borda,
          width: 1.2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(
          color: borda,
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(
          color: verde,
          width: 1.8,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _rotulo(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        color: fundo,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Future<void> _criarConta() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _carregando = true);

    try {
      final auth = context.read<AuthProvider>();

      final sucesso = await auth.register(
        _nomeController.text.trim(),
        _emailController.text.trim(),
        _senhaController.text,
      );

      if (!mounted) return;

      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Conta criada com sucesso! Faça seu login.',
            ),
          ),
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              auth.errorMessage ??
                  'Não foi possível criar sua conta.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ocorreu um erro ao criar sua conta.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // LOGO
                  SizedBox(
                    width: 250,
                    height: 85,
                    child: Image.asset(
                      'assets/img/nalisun_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stack) {
                        return const Center(
                          child: Text(
                            'Nali-Sun',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  // CARTÃO DE CADASTRO
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: bege,
                      borderRadius: BorderRadius.circular(21),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x190B3740),
                          blurRadius: 30,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Criar conta',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: fundo,
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Comece a cuidar do seu jardim!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: fundo,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 22),

                          // NOME
                          _rotulo('Nome completo'),
                          const SizedBox(height: 7),

                          TextFormField(
                            controller: _nomeController,
                            style: const TextStyle(
                              color: fundo,
                              fontSize: 14,
                            ),
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            validator: _validarNome,
                            decoration: _decoracaoCampo(
                              dica: 'Digite seu nome',
                              icone: Icons.person_outline,
                            ),
                          ),

                          const SizedBox(height: 15),

                          // E-MAIL
                          _rotulo('E-mail'),
                          const SizedBox(height: 7),

                          TextFormField(
                            controller: _emailController,
                            style: const TextStyle(
                              color: fundo,
                              fontSize: 14,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            validator: Validators.validarEmail,
                            decoration: _decoracaoCampo(
                              dica: 'seu@email.com',
                              icone: Icons.email_outlined,
                            ),
                          ),

                          const SizedBox(height: 15),

                          // SENHA
                          _rotulo('Senha'),
                          const SizedBox(height: 7),

                          TextFormField(
                            controller: _senhaController,
                            style: const TextStyle(
                              color: fundo,
                              fontSize: 14,
                            ),
                            obscureText: !_mostrarSenha,
                            textInputAction: TextInputAction.next,
                            validator: Validators.validarSenhaCadastro,
                            decoration: _decoracaoCampo(
                              dica: 'Crie uma senha',
                              icone: Icons.lock_outline,
                              sufixo: IconButton(
                                tooltip: _mostrarSenha
                                    ? 'Ocultar senha'
                                    : 'Mostrar senha',
                                onPressed: () {
                                  setState(() {
                                    _mostrarSenha = !_mostrarSenha;
                                  });
                                },
                                icon: Icon(
                                  _mostrarSenha
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 19,
                                  color: const Color(0xFF66858A),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 6),

                          const Text(
                            'Use pelo menos 8 caracteres, '
                            'com maiúscula, minúscula e número.',
                            style: TextStyle(
                              color: fundo,
                              fontSize: 10,
                            ),
                          ),

                          const SizedBox(height: 15),

                          // CONFIRMAR SENHA
                          _rotulo('Confirmar senha'),
                          const SizedBox(height: 7),

                          TextFormField(
                            controller: _confirmarSenhaController,
                            style: const TextStyle(
                              color: fundo,
                              fontSize: 14,
                            ),
                            obscureText: !_mostrarConfirmacao,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _criarConta(),
                            validator: (valor) =>
                                Validators.validarConfirmacaoSenha(
                                  valor,
                                  _senhaController.text,
                                ),
                            decoration: _decoracaoCampo(
                              dica: 'Digite a senha novamente',
                              icone: Icons.lock_outline,
                              sufixo: IconButton(
                                tooltip: _mostrarConfirmacao
                                    ? 'Ocultar senha'
                                    : 'Mostrar senha',
                                onPressed: () {
                                  setState(() {
                                    _mostrarConfirmacao =
                                        !_mostrarConfirmacao;
                                  });
                                },
                                icon: Icon(
                                  _mostrarConfirmacao
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 19,
                                  color: const Color(0xFF66858A),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // BOTÃO CADASTRAR
                          SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              onPressed:
                                  _carregando ? null : _criarConta,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: verde,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: verde,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _carregando
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'CRIAR CONTA',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // VOLTAR AO LOGIN
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login',
                                (route) => false,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: fundo,
                              side: const BorderSide(
                                color: verde,
                                width: 1.2,
                              ),
                              minimumSize: const Size(
                                double.infinity,
                                44,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'JÁ TENHO UMA CONTA',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
