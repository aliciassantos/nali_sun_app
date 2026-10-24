// MaterialApp, rotas e observadores
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/auth/login_screen.dart';
import 'routes.dart';
import 'theme.theme.dart';

class NaliSunApp extends StatelessWidget {
  const NaliSunApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = context.watch<ThemeProvider>();

    if (!auth.sessionChecked || !theme.isLoaded) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: theme.themeMode,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'NaliSun',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: theme.themeMode,
      initialRoute: auth.isAuthenticated ? AppRoutes.home : AppRoutes.login,
      onGenerateRoute: (settings) {
        final name = settings.name ?? AppRoutes.login;
        final builder = AppRoutes.routes[name];

        if (builder == null) {
          return MaterialPageRoute<void>(builder: (_) => const LoginScreen());
        }

        const rotasPublicas = {AppRoutes.login, AppRoutes.register};

        if (!rotasPublicas.contains(name) && !auth.isAuthenticated) {
          return MaterialPageRoute<void>(
            builder: (_) => const LoginScreen(),
            settings: const RouteSettings(name: AppRoutes.login),
          );
        }

        return MaterialPageRoute<void>(settings: settings, builder: builder);
      },
    );
  }
}
