// Estado da autenticação do usuário

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../database/user_dao.dart';

SupabaseClient get supabase => Supabase.instance.client;

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  StreamSubscription<AuthState>? _authSubscription;

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _sessionChecked = false;
  bool _isRecoveringPassword = false; // Estado para redefinição
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get sessionChecked => _sessionChecked;
  bool get isRecoveringPassword => _isRecoveringPassword; // Getter
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _startAuthListen();
  }

  void _startAuthListen() {
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;

      if (event == AuthChangeEvent.passwordRecovery) {
        _isRecoveringPassword = true;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> restoreSession() async {
    try {
      final userId = supabase.auth.currentUser?.id;

      if (userId != null) {
        _currentUser = await UserDAO.getUserById(userId);

        // Se o usuário não existir mais no banco, limpa a sessão.
        if (_currentUser == null) {
          await supabase.auth.signOut();
        }
      }
    } catch (_) {
      _currentUser = null;
    } finally {
      _sessionChecked = true;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);

    try {
      final user = await _authService.login(email: email, password: password);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('logged_user_id', user.id);

      _currentUser = user;
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = _mensagemErro(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);

    try {
      // 👈 Chamada corrigida para usar o _authService
      final user = await _authService.register(
        name: name,
        email: email,
        password: password,
      );

      _currentUser = user;
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = _mensagemErro(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);

    try {
      await _authService.resetPassword(email: email);

      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = _mensagemErro(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();

    _currentUser = null;
    _errorMessage = null;
    _isRecoveringPassword = false;
    notifyListeners();
  }

  void clearPasswordRecoveryFlag() {
    _isRecoveringPassword = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _mensagemErro(Object erro) {
    return erro.toString().replaceFirst('Exception: ', '');
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}