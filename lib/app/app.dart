// MaterialApp, rotas e observadores

import 'package:flutter/material.dart';

import 'routes.dart';
import 'theme.theme.dart';

class NaliSunApp extends StatelessWidget {
  const NaliSunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NaliSun',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}
