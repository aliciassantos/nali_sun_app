// Estado da autenticação do usuário

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../database/user_dao.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserDAO _userDAO = UserDAO();

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _sessionChecked = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get sessionChecked => _sessionChecked;
  String? get errorMessage => _errorMessage;

  Future<void> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('logged_user_id');

      if (userId != null) {
        _currentUser = await _userDAO.getUserById(userId);

        // Se o usuário não existir mais no banco, limpa a sessão.
        if (_currentUser == null) {
          await prefs.remove('logged_user_id');
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
      final user = await _authService.login(
        email: email,
        password: password,
      );

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

  Future<bool> register(
    String name,
    String email,
    String password,
  ) async {
    _setLoading(true);

    try {
      final user = await _authService.register(
        name: name,
        email: email,
        password: password,
      );

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

  Future<bool> resetPassword(
    String email,
    String newPassword,
  ) async {
    _setLoading(true);

    try {
      await _authService.resetPassword(
        email: email,
        newPassword: newPassword,
      );

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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_user_id');

    _currentUser = null;
    _errorMessage = null;
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
