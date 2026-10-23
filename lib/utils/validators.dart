// Validação de e-mail, senha e formulários
class Validators {
  static String? validarNome(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Informe seu nome.';
    }
    if (valor.trim().length < 2) {
      return 'Digite um nome válido.';
    }
    return null;
  }

  static String? validarEmail(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Informe seu e-mail.';
    }
    final emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
    if (!emailRegExp.hasMatch(valor.trim())) {
      return 'Digite um e-mail válido.';
    }
    return null;
  }

  static String? validarSenhaLogin(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Digite sua senha.';
    }
    return null;
  }

  static String? validarSenhaCadastro(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
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

  static String? validarConfirmacaoSenha(String? valor, String senhaOriginal) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Confirme sua senha.';
    }
    if (valor != senhaOriginal) {
      return 'As senhas não coincidem.';
    }
    return null;
  }
}