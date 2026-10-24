
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  final themeProvider = ThemeProvider();

  await Future.wait([
    authProvider.restoreSession(),
    themeProvider.loadTheme(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
        ),
        ChangeNotifierProvider<ThemeProvider>.value(
          value: themeProvider,
        ),
      ],
      child: const NaliSunApp(),
    ),
  );
}
