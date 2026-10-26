// Gerenciamento da sessão do usuário
import '../database/user_dao.dart';
import '../models/user_model.dart';

class AuthService {
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
        await UserDAO.getUserByEmail(emailLimpo);

    if (existente != null) {
      throw Exception(
        'Este e-mail já está cadastrado.',
      );
    }

    try {
      final usuario = await UserDAO.insertUser(name: nome, email: emailLimpo, password: password);
      if (usuario == null) {
        throw Exception(
          'Não foi possível realizar o cadastro.'
        );  
      }
      return usuario;
    } on Exception {
      // A restrição UNIQUE do banco também protege
      // contra cadastros duplicados simultâneos.
      throw Exception(
        'Não foi possível cadastrar. '
        'Verifique se o e-mail já existe.',
      );
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final emailLimpo = email.trim().toLowerCase();

    final response = await supabase.auth.signInWithPassword(
      email: emailLimpo,
       password: password
    );
    
    final userId = response.user?.id;
    if (userId == null) {
      throw Exception('Usuário não encontrado.');
    }

    final user = await UserDAO.getUserById(userId);
    if (user == null) {
      throw Exception('Usuário não encontrado.');
    }
    return user;
  }

  Future<void> resetPassword({
    required String email,
  }) async {
    final emailLimpo = email.trim().toLowerCase();

    if (emailLimpo.isEmpty) {
      throw Exception('Informe um e-mail válido.');
    }
    
    await supabase.auth.resetPasswordForEmail(
      emailLimpo, 
      redirectTo: 'http://localhost:3000/#/reset-password'
    );
  }
}
