import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _novaSenhaController = TextEditingController();
  bool _carregando = false;

  Future<void> _salvarNovaSenha() async {
    final novaSenha = _novaSenhaController.text;
    if (novaSenha.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A senha deve ter pelo menos 8 caracteres.')),
      );
      return;
    }

    setState(() => _carregando = true);

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: novaSenha),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha atualizada com sucesso!')),
      );

      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      if (!mounted) return;
      final mensagemReal = e.toString().replaceAll(RegExp(r'^[a-zA-Z]+Exception: '), '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $mensagemReal')),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Redefinir Senha')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _novaSenhaController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Nova Senha'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _carregando ? null : _salvarNovaSenha,
              child: const Text('Salvar Nova Senha'),
            ),
          ],
        ),
      ),
    );
  }
}