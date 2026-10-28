// Artigo da aba de dicas
class ArticleModel {
  final int? id;
  final String titulo;
  final String categoria;
  final String resumo;
  final String conteudo;
  final String? imagem;
  final DateTime? dataPublicacao;

  const ArticleModel({
    this.id,
    required this.titulo,
    required this.categoria,
    required this.resumo,
    required this.conteudo,
    this.imagem,
    this.dataPublicacao,
  });

  /// Calcula o tempo estimado de leitura com base no conteúdo completo.
  /// Considera uma média de 200 palavras por minuto.
  int get tempoLeitura {
    final texto = conteudo.trim();

    if (texto.isEmpty) {
      return 0;
    }

    final palavras = texto
        .split(RegExp(r'\s+'))
        .where((palavra) => palavra.isNotEmpty)
        .length;

    return (palavras / 200).ceil().clamp(1, 999);
  }

  /// Retorna o tempo de leitura formatado para exibição na interface.
  String get tempoLeituraFormatado {
    final minutos = tempoLeitura;

    if (minutos == 0) {
      return 'Sem conteúdo';
    }

    return '$minutos min de leitura';
  }

  /// Converte o artigo em um mapa, útil para persistência em banco de dados.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'categoria': categoria,
      'resumo': resumo,
      'conteudo': conteudo,
      'imagem': imagem,
      'data_publicacao': dataPublicacao?.toIso8601String(),
    };
  }

  /// Cria um artigo a partir de um mapa.
  factory ArticleModel.fromMap(Map<String, dynamic> map) {
    return ArticleModel(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      categoria: map['categoria'] as String,
      resumo: map['resumo'] as String,
      conteudo: map['conteudo'] as String,
      imagem: map['imagem'] as String?,
      dataPublicacao: map['data_publicacao'] != null
          ? DateTime.tryParse(map['data_publicacao'] as String)
          : null,
    );
  }
}