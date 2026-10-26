// Login

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _mostrarSenha = false;
  bool _carregando = false;

  // Paleta original do NaliSun.
  static const Color fundo = Color(0xFF0B3740);
  static const Color bege = Color(0xFFFBE4AE);
  static const Color verde = Color(0xFF258A60);
  static const Color borda = Color(0xFF81B380);

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _carregando = true);

    try {
      final auth = context.read<AuthProvider>();

      final sucesso = await auth.login(
        _emailController.text.trim(),
        _senhaController.text,
      );

      if (!mounted) return;

      if (sucesso) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              auth.errorMessage ?? 'E-mail ou senha incorretos.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível realizar o login.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  Future<void> _esqueciMinhaSenha() async {
    final emailController = TextEditingController();

    final dados = await showDialog<List<String>>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Recuperar senha'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                style: const TextStyle(
                  color: fundo,
                  fontSize: 14,
                ),
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail cadastrado',
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final email = emailController.text.trim();
                if (email.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Preencha o e-mail.',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext, [email]);
              },
              child: const Text('Enviar link'),
            ),
          ],
        );
      },
    );

    if (dados == null || !mounted) return;

    try {
      final auth = context.read<AuthProvider>();

      final sucesso = await auth.resetPassword(dados[0]);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sucesso
                ? 'E-mail de recuperação enviado! Verifique sua caixa de entrada.'
                : auth.errorMessage ??
                    'Não foi possível enviar o e-mail de recuperação.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao recuperar a senha.'),
        ),
      );
    }
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
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      isDense: true,
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
          width: 1.2,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 360,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // LOGO
                      Transform.translate(
                        offset: const Offset(0, 15),
                        child: SizedBox(
                          width: 300,
                          height: 120,
                          child: Image.asset(
                            'assets/img/nalisun_logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stack) {
                              return const Center(
                                child: Text(
                                  'Nali-Sun',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 38,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 0),

                      // CARTÃO DE LOGIN
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 30,
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
                            crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Login',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: fundo,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),

                              const SizedBox(height: 20),

                              _rotulo('E-mail'),
                              const SizedBox(height: 7),

                              TextFormField(
                                controller: _emailController,
                                style: const TextStyle(
                                  color: fundo,
                                  fontSize: 14,
                                ),
                                keyboardType:
                                    TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autocorrect: false,
                                validator: Validators.validarEmail,
                                decoration: _decoracaoCampo(
                                  dica: 'seu@email.com',
                                  icone: Icons.email_outlined,
                                ),
                              ),

                              const SizedBox(height: 13),

                              _rotulo('Senha'),
                              const SizedBox(height: 7),

                              TextFormField(
                                controller: _senhaController,
                                style: const TextStyle(
                                  color: fundo,
                                  fontSize: 14,
                                ),
                                obscureText: !_mostrarSenha,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _entrar(),
                                validator:
                                    Validators.validarSenhaLogin,
                                decoration: _decoracaoCampo(
                                  dica: 'Digite sua senha',
                                  icone: Icons.lock_outline,
                                  sufixo: IconButton(
                                    tooltip: _mostrarSenha
                                        ? 'Ocultar senha'
                                        : 'Mostrar senha',
                                    onPressed: () {
                                      setState(() {
                                        _mostrarSenha =
                                            !_mostrarSenha;
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

                              const SizedBox(height: 8),

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _esqueciMinhaSenha,
                                  style: TextButton.styleFrom(
                                    foregroundColor: verde,
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 24),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Esqueci minha senha',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // ENTRAR
                              SizedBox(
                                height: 41,
                                child: ElevatedButton(
                                  onPressed:
                                      _carregando ? null : _entrar,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: verde,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: verde,
                                    disabledForegroundColor:
                                        Colors.white70,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: _carregando
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child:
                                              CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'ENTRAR',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              // CRIAR CONTA
                              SizedBox(
                                height: 41,
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/register',
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: fundo,
                                    side: const BorderSide(
                                      color: verde,
                                      width: 1.2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text(
                                    'CRIAR CONTA',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
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
            );
          },
        ),
      ),
    );
  }
}
