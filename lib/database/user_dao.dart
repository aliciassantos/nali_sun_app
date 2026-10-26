import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

final supabase = Supabase.instance.client;

class UserDAO {

  static Future<UserModel?> insertUser({
    required String name,
    required String email,
    required String password
  }) async {

    final response = await supabase.auth.signUp(
      email: email, 
      password: password
    );

    final userId = response.user?.id;

    if (userId != null) {
      await supabase.from('users').insert({
        'id' : userId,
        'name': name,
        'email' : email
      }).select();

      return UserModel(id: userId, name: name, email: email, createdAt: DateTime.now());
    }
    return null;
  }

  static Future<UserModel?> getUserByEmail(String email) async {
    final response = await supabase
    .from('users')
    .select()
    .eq('email', email.trim().toLowerCase())
    .maybeSingle();

    if (response == null) return null;
    return UserModel.fromMap(response);
  }

  static Future<void> updatePassword(String newPassword) async {
    await supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  static Future<UserModel?> getUserById(String id) async {
    final response = await supabase
    .from('users')
    .select()
    .eq('id', id)
    .maybeSingle();

    if (response == null) return null;

    return UserModel.fromMap(response);
  }
}
