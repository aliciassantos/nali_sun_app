// Definição de rotas nomeadas
import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/reset_password.dart';
// import '../screens/home/home_screen.dart';
import '../screens/plants/plants_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/tips/tips_screen.dart';
import '../screens/profile/profile_screen.dart';

class AppRoutes {
  // Nomes das rotas
  static const String login = '/login';
  static const String register = '/register';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';
  static const String garden = '/garden';
  static const String calendar = '/calendar';
  static const String tips = '/tips';
  static const String profile = '/profile';

  // Mapa de rotas do aplicativo
  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      resetPassword:(context) => const ResetPasswordScreen(),
      home:(context) => const MainNavigationScreen(),
      garden:(context) => const MyGardenScreen(),
      calendar:(context) => const CalendarScreen(),
      tips:(context) => const TipsScreen(),
      profile:(context) => const ProfileScreen(),
    };
  }
}