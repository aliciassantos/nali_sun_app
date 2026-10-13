// Validação de e-mail, senha e formulários

class Validators {
  // Valida o formato do e-mail.
  static String? validarEmail(String? valor) {
    final email = valor?.trim() ?? '';

    if (email.isEmpty) {
      return 'Informe seu e-mail.';
    }

    final formatoValido = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    if (!formatoValido.hasMatch(email)) {
      return 'Digite um e-mail válido.';
    }

    return null;
  }

  // No login, verificamos se a senha foi preenchida.
  // A senha real será conferida pelo serviço de autenticação.
  static String? validarSenhaLogin(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Informe sua senha.';
    }

    return null;
  }

  // Regras para o cadastro de uma nova conta.
  static String? validarSenhaCadastro(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Crie uma senha.';
    }

    if (valor.length < 8) {
      return 'A senha deve ter pelo menos 8 caracteres.';
    }

    if (!RegExp(r'[A-Z]').hasMatch(valor)) {
      return 'Inclua pelo menos uma letra maiúscula.';
    }

    if (!RegExp(r'[a-z]').hasMatch(valor)) {
      return 'Inclua pelo menos uma letra minúscula.';
    }

    if (!RegExp(r'[0-9]').hasMatch(valor)) {
      return 'Inclua pelo menos um número.';
    }

    return null;
  }

  static String? validarConfirmacaoSenha(
    String? valor,
    String senhaOriginal,
  ) {
    if (valor == null || valor.isEmpty) {
      return 'Confirme sua senha.';
    }

    if (valor != senhaOriginal) {
      return 'As senhas não coincidem.';
    }

    return null;
  }
}

