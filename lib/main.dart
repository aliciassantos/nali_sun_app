import 'package:flutter/material.dart';
import 'package:nali_sun_app/screens/auth/login_screen.dart';

void main() {
  runApp(const FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B3740) /* color-cyan-15 */,
      ),
      home: const Scaffold(body: SafeArea(child: Login())),
    );
  }
}
