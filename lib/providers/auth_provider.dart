// Estado da autenticação do usuário

import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get errorMessage => _errorMessage;

  Future<bool> login(
    String email,
    String password,
  ) async {
    _setLoading(true);

    try {
      _currentUser = await _authService.login(
        email: email,
        password: password,
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

  Future<bool> register(
    String name,
    String email,
    String password,
  ) async {
    _setLoading(true);

    try {
      _currentUser = await _authService.register(
        name: name,
        email: email,
        password: password,
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

  void logout() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _mensagemErro(Object erro) {
    return erro.toString().replaceFirst(
      'Exception: ',
      '',
    );
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
