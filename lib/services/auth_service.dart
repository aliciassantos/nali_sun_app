// Gerenciamento da sessão do usuário

import 'package:uuid/uuid.dart';

import '../database/user_dao.dart';
import '../models/user_model.dart';

class AuthService {
  final UserDAO _userDAO = UserDAO();

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final nome = name.trim();
    final emailLimpo = email.trim().toLowerCase();

    if (nome.length < 2) {
      throw Exception('Informe um nome válido.');
    }

    if (emailLimpo.isEmpty || password.isEmpty) {
      throw Exception(
        'Preencha todos os campos obrigatórios.',
      );
    }

    final existente =
        await _userDAO.getUserByEmail(emailLimpo);

    if (existente != null) {
      throw Exception(
        'Este e-mail já está cadastrado.',
      );
    }

    final usuario = UserModel(
      id: const Uuid().v4(),
      name: nome,
      email: emailLimpo,
      password: password,
      createdAt: DateTime.now(),
    );

    try {
      await _userDAO.insertUser(usuario);
    } on Exception {
      // A restrição UNIQUE do banco também protege
      // contra cadastros duplicados simultâneos.
      throw Exception(
        'Não foi possível cadastrar. '
        'Verifique se o e-mail já existe.',
      );
    }

    return usuario;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final emailLimpo = email.trim().toLowerCase();

    final usuario =
        await _userDAO.getUserByEmail(emailLimpo);

    if (usuario == null) {
      throw Exception(
        'E-mail não encontrado. Crie uma conta primeiro.',
      );
    }

    if (usuario.password != password) {
      throw Exception(
        'Senha incorreta. Verifique suas credenciais.',
      );
    }

    return usuario;
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final emailLimpo = email.trim().toLowerCase();

    final usuario =
        await _userDAO.getUserByEmail(emailLimpo);

    if (usuario == null) {
      throw Exception(
        'Nenhum usuário cadastrado com este e-mail.',
      );
    }

    if (newPassword.isEmpty) {
      throw Exception('Informe uma nova senha.');
    }

    final sucesso = await _userDAO.updatePassword(
      emailLimpo,
      newPassword,
    );

    if (!sucesso) {
      throw Exception(
        'Não foi possível redefinir a senha.',
      );
    }
  }
}
