import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Uma espécie sugerida (vinda da busca por nome ou da identificação por foto).
///
/// REGRA: o nome que aparece na lista (displayName) é o mesmo que fica no
/// campo e no banco. Ele nunca é trocado depois do toque.
class PlantSuggestion {
  const PlantSuggestion({
    required this.accessToken,
    required this.commonName,
    required this.scientificName,
    this.imageUrl = '',
    this.probability,
    this.details = const {},
  });

  /// Token da base de conhecimento do Kindwise ('' enquanto não resolvido,
  /// o que acontece com resultados vindos de foto).
  final String accessToken;

  /// Nome comum em pt-BR ('' se a API não tiver).
  final String commonName;
  final String scientificName;
  final String imageUrl;

  /// Só preenchido nos resultados de identificação por foto (0 a 1).
  final double? probability;

  /// Resposta completa da API (descrição, rega, luz, taxonomia...).
  final Map<String, dynamic> details;

  /// Nome comum; se não existir, o científico.
  String get displayName =>
      commonName.isNotEmpty ? commonName : scientificName;

  bool get hasDistinctScientificName =>
      scientificName.isNotEmpty &&
      scientificName.toLowerCase() != displayName.toLowerCase();

  PlantSuggestion copyWith({
    String? accessToken,
    String? commonName,
    String? scientificName,
    String? imageUrl,
    double? probability,
    Map<String, dynamic>? details,
  }) {
    return PlantSuggestion(
      accessToken: accessToken ?? this.accessToken,
      commonName: commonName ?? this.commonName,
      scientificName: scientificName ?? this.scientificName,
      imageUrl: imageUrl ?? this.imageUrl,
      probability: probability ?? this.probability,
      details: details ?? this.details,
    );
  }

  /// Dados prontos para gravar no banco (ajuste os nomes às suas colunas).
  Map<String, dynamic> toDbMap() {
    final description = details['description'];
    final watering = details['watering'];
    return {
      'kindwise_token': accessToken.isNotEmpty ? accessToken : null,
      'common_name': commonName.isNotEmpty ? commonName : null,
      'scientific_name': scientificName,
      'image_url': imageUrl.isNotEmpty ? imageUrl : null,
      'description': description is Map ? description['value'] : description,
      'watering_min': watering is Map ? watering['min'] : null,
      'watering_max': watering is Map ? watering['max'] : null,
      'best_watering': details['best_watering'],
      'best_light_condition': details['best_light_condition'],
      'wiki_url': details['url'],
    };
  }
}

/// Resultado da identificação por foto.
class PlantIdentificationResult {
  const PlantIdentificationResult({
    required this.isPlant,
    required this.suggestions,
  });

  final bool isPlant;
  final List<PlantSuggestion> suggestions;
}

class KindwisePlantService {
  static const String _host = 'plant.id';
  static const String _kbPath = '/api/v3/kb/plants';

  /// A documentação lista "Brazilian Portuguese - pt-BR" nos idiomas de
  /// common_names, mas também diz que usa códigos ISO de 2 letras.
  /// Se os nomes vierem em inglês, teste 'pt'.
  static const String _language = 'pt-BR';

  static const int _searchLimit = 5;
  static const Duration _timeout = Duration(seconds: 12);

  /// Tudo que queremos guardar da planta. O custo é por CHAMADA (0,5 crédito),
  /// não por detalhe, então pedimos tudo de uma vez.
  static const String _kbDetails =
      'common_names,url,description,taxonomy,image,watering,'
      'best_watering,best_light_condition';

  // Caches: cada espécie só é cobrada uma vez por sessão do app.
  final Map<String, Map<String, dynamic>> _detailsCache = {};
  final Map<String, List<PlantSuggestion>> _searchCache = {};

  Map<String, String> get _headers => {
        'Api-Key': dotenv.env['KINDWISE_KEY'] ?? '',
        'Accept': 'application/json',
      };

  // ======================================================================
  // 1) BUSCA POR NOME (lista dinâmica com imagem)
  // ======================================================================

  /// name_search (grátis) para achar as espécies + detalhes de cada uma
  /// (0,5 crédito por espécie, com cache) para ter nome comum e imagem.
  ///
  /// Só retorna depois de ter tudo, então a lista aparece completa e os
  /// nomes não mudam depois.
  Future<List<PlantSuggestion>> searchSpecies(String query) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    final cacheKey = q.toLowerCase();
    final cached = _searchCache[cacheKey];
    if (cached != null) return cached;

    final entities = await _nameSearch(q, limit: _searchLimit);
    if (entities.isEmpty) return [];

    // Busca os detalhes de todas em paralelo
    final suggestions = await Future.wait(
      entities.map((entity) async {
        final details = await getPlantDetails(entity.token);
        return _fromKb(entity.token, entity.scientificName, details);
      }),
    );

    _searchCache[cacheKey] = suggestions;
    return suggestions;
  }

  Future<List<({String token, String scientificName})>> _nameSearch(
    String q, {
    int limit = _searchLimit,
  }) async {
    final url = Uri.https(_host, '$_kbPath/name_search', {
      'q': q,
      'limit': '$limit',
      'language': _language,
    });

    try {
      final response =
          await http.get(url, headers: _headers).timeout(_timeout);

      if (response.statusCode != 200) {
        debugPrint('name_search falhou: ${response.statusCode} ${response.body}');
        return [];
      }

      // utf8.decode evita acentos quebrados se o servidor não mandar charset
      final body = utf8.decode(response.bodyBytes);
      if (kDebugMode) debugPrint('name_search [$q]: $body');

      final data = json.decode(body);
      final List entities = (data is Map ? data['entities'] : null) is List
          ? data['entities'] as List
          : [];

      final seen = <String>{};
      final out = <({String token, String scientificName})>[];
      for (final e in entities) {
        if (e is! Map) continue;
        final token = (e['access_token'] ?? '').toString();
        if (token.isEmpty || !seen.add(token)) continue;
        out.add((
          token: token,
          scientificName: (e['entity_name'] ?? e['matched_in'] ?? '').toString(),
        ));
      }
      return out;
    } catch (e) {
      debugPrint('Erro no name_search: $e');
    }
    return [];
  }

  // ======================================================================
  // 2) DETALHES DA ESPÉCIE (para exibir e guardar no banco)
  // ======================================================================

  /// Dados completos de uma espécie. CUSTA 0,5 crédito (cache em memória).
  Future<Map<String, dynamic>?> getPlantDetails(String accessToken) async {
    if (accessToken.isEmpty) return null;

    final cached = _detailsCache[accessToken];
    if (cached != null) return cached;

    final url = Uri.https(_host, '$_kbPath/$accessToken', {
      'details': _kbDetails,
      'language': _language,
    });

    try {
      final response =
          await http.get(url, headers: _headers).timeout(_timeout);

      if (response.statusCode != 200) {
        debugPrint('detalhes falhou: ${response.statusCode} ${response.body}');
        return null;
      }

      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data is! Map) return null;

      final map = Map<String, dynamic>.from(data);
      _detailsCache[accessToken] = map;
      return map;
    } catch (e) {
      debugPrint('Erro ao buscar detalhes da planta: $e');
    }
    return null;
  }

  // ======================================================================
  // 3) IDENTIFICAÇÃO POR FOTO
  // ======================================================================

  /// Envia a foto e devolve as 3 espécies mais prováveis.
  /// Consome crédito de identificação (confira o custo no painel do Kindwise).
  Future<PlantIdentificationResult?> identifyByImage(Uint8List bytes) async {
    final url = Uri.https(_host, '/api/v3/identification', {
      'details': 'common_names,url,description,image,watering',
      'language': _language,
    });

    try {
      final response = await http
          .post(
            url,
            headers: {..._headers, 'Content-Type': 'application/json'},
            body: json.encode({
              'images': [base64Encode(bytes)],
            }),
          )
          .timeout(const Duration(seconds: 40));

      // A criação da identificação pode responder 200 ou 201
      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint(
          'identificação falhou: ${response.statusCode} ${response.body}',
        );
        return null;
      }

      final data = json.decode(utf8.decode(response.bodyBytes));
      final result = data is Map ? data['result'] : null;
      if (result is! Map) return null;

      final isPlantRaw =
          result['is_plant'] is Map ? result['is_plant']['binary'] : null;
      final isPlant = isPlantRaw is bool ? isPlantRaw : true;

      final classification = result['classification'];
      final rawSuggestions =
          classification is Map && classification['suggestions'] is List
              ? classification['suggestions'] as List
              : [];

      final suggestions = rawSuggestions.whereType<Map>().take(3).map((s) {
        final details = s['details'] is Map
            ? Map<String, dynamic>.from(s['details'] as Map)
            : <String, dynamic>{};
        return PlantSuggestion(
          accessToken: '', // resolvido depois, ao selecionar
          commonName: _firstCommonName(details['common_names']),
          scientificName: (s['name'] ?? '').toString(),
          imageUrl: _imageUrl(details['image']),
          probability: (s['probability'] as num?)?.toDouble(),
          details: details,
        );
      }).toList();

      return PlantIdentificationResult(
        isPlant: isPlant,
        suggestions: suggestions,
      );
    } catch (e) {
      debugPrint('Erro na identificação por foto: $e');
    }
    return null;
  }

  /// Completa uma sugestão vinda de foto: acha o access_token pelo nome
  /// científico (name_search é grátis) e busca os detalhes da base de
  /// conhecimento. O nome e a imagem já exibidos NÃO mudam.
  Future<PlantSuggestion> resolveSuggestion(PlantSuggestion s) async {
    if (s.accessToken.isNotEmpty) return s;

    final results = await _nameSearch(s.scientificName, limit: 3);
    if (results.isEmpty) return s;

    final match = results.firstWhere(
      (r) => r.scientificName.toLowerCase() == s.scientificName.toLowerCase(),
      orElse: () => results.first,
    );

    final details = await getPlantDetails(match.token);
    if (details == null) return s.copyWith(accessToken: match.token);

    final kb = _fromKb(match.token, s.scientificName, details);
    return s.copyWith(
      accessToken: match.token,
      commonName: s.commonName.isNotEmpty ? s.commonName : kb.commonName,
      imageUrl: s.imageUrl.isNotEmpty ? s.imageUrl : kb.imageUrl,
      details: {...s.details, ...details},
    );
  }

  // ======================================================================
  // Helpers de parse
  // ======================================================================

  PlantSuggestion _fromKb(
    String token,
    String scientificFallback,
    Map<String, dynamic>? details,
  ) {
    final d = details ?? const <String, dynamic>{};
    final scientific = scientificFallback.isNotEmpty
        ? scientificFallback
        : (d['name'] ?? d['entity_name'] ?? '').toString();

    return PlantSuggestion(
      accessToken: token,
      commonName: _firstCommonName(d['common_names']),
      scientificName: scientific,
      imageUrl: _imageUrl(d['image']),
      details: d,
    );
  }

  /// common_names pode vir como lista (1 idioma) ou mapa {idioma: [nomes]}.
  static String _firstCommonName(dynamic raw) {
    if (raw is List) {
      for (final n in raw) {
        final s = n.toString().trim();
        if (s.isNotEmpty) return s;
      }
    } else if (raw is Map) {
      for (final v in raw.values) {
        final s = _firstCommonName(v);
        if (s.isNotEmpty) return s;
      }
    }
    return '';
  }

  /// Na v3, `image` é um objeto {value, citation, license_name, ...}.
  static String _imageUrl(dynamic raw) {
    if (raw is Map) return (raw['value'] ?? '').toString();
    if (raw is String) return raw;
    return '';
  }
}