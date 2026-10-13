// Definição de rotas nomeadas
import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';

class AppRoutes {
  // Nomes das rotas
  static const String login = '/login';
  static const String register = '/register';

  // Mapa de rotas do aplicativo
  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
    };
  }
}