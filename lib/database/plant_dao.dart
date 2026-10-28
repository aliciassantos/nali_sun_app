// Operações CRUD da tabela 'plants'
import 'package:supabase_flutter/supabase_flutter.dart';

class PlantDAO {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static const String _table = 'plants';

  /// Obtém o ID do usuário autenticado.
  static String _getUserId() {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception(
        'Você precisa estar autenticado para cadastrar uma planta.',
      );
    }

    return user.id;
  }

  /// Cadastra uma planta.
  static Future<Map<String, dynamic>> insertPlant({
    required String name,
    required String species,
    required int wateringFrequencyDays,
    required String luminosity,
    DateTime? lastWateredAt,
    String? imagePath,
  }) async {
    final userId = _getUserId();

    final plantData = <String, dynamic>{
      'user_id': userId,
      'name': name.trim(),
      'species': species.trim(),
      'watering_frequency_days': wateringFrequencyDays,
      'last_watered_at':
          (lastWateredAt ?? DateTime.now()).toUtc().toIso8601String(),
      'luminosity': luminosity,
      'image_path': imagePath,
    };

    final response = await _supabase
        .from(_table)
        .insert(plantData)
        .select()
        .single();

    return response;
  }

  /// Lista as plantas do usuário autenticado.
  static Future<List<Map<String, dynamic>>> getPlantsByUser() async {
    final userId = _getUserId();

    final response = await _supabase
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Busca uma planta pelo ID.
  static Future<Map<String, dynamic>?> getPlantById(
    int plantId,
  ) async {
    final userId = _getUserId();

    final response = await _supabase
        .from(_table)
        .select()
        .eq('id', plantId)
        .eq('user_id', userId)
        .maybeSingle();

    return response;
  }

  /// Atualiza uma planta.
  static Future<Map<String, dynamic>> updatePlant({
    required int plantId,
    required String name,
    required String species,
    required int wateringFrequencyDays,
    required String luminosity,
    DateTime? lastWateredAt,
    String? imagePath,
  }) async {
    final userId = _getUserId();

    final plantData = <String, dynamic>{
      'name': name.trim(),
      'species': species.trim(),
      'watering_frequency_days': wateringFrequencyDays,
      'luminosity': luminosity,
      'last_watered_at':
          lastWateredAt?.toUtc().toIso8601String(),
      'image_path': imagePath,
    };

    final response = await _supabase
        .from(_table)
        .update(plantData)
        .eq('id', plantId)
        .eq('user_id', userId)
        .select()
        .single();

    return response;
  }

  /// Exclui uma planta.
  static Future<void> deletePlant(int plantId) async {
    final userId = _getUserId();

    await _supabase
        .from(_table)
        .delete()
        .eq('id', plantId)
        .eq('user_id', userId);
  }
}