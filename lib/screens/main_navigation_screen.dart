// Tela contendo a BottomNavigationBar e IndexedStack
// Navegação principal do footer
import 'package:flutter/material.dart';

import '../screens/home/home_screen.dart';
import '../screens/plants/plants_screen.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/tips/tips_screen.dart';
// importe as outras telas (calendar, tips, profile)...

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _indiceAtual = 0;

  // Lista de todas as telas das abas
  final List<Widget> _telas = const [
    HomeScreen(),
    MyGardenScreen(),
    CalendarScreen(),
    TipsScreen(),
    ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // O IndexedStack mantêm o estado de rolagem e dados de todas as telas
      body: IndexedStack(
        index: _indiceAtual,
        children: _telas,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      color: const Color(0xFF0B3740),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF0B3740),
          type: BottomNavigationBarType.fixed,
          currentIndex: _indiceAtual,
          selectedItemColor: const Color(0xFFFBE4AE),
          unselectedItemColor: const Color(0xFFDACB8A),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          // Apenas altera o índice local, sem usar Navigator!
          onTap: (index) => setState(() => _indiceAtual = index),
          items: [
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.home_outlined, Icons.home_filled, 0),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.eco_outlined, Icons.eco, 1),
              label: 'Plantas',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.calendar_today_outlined, Icons.calendar_today, 2),
              label: 'Agenda',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.menu_book_outlined, Icons.menu_book, 3),
              label: 'Dicas',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.person_outline, Icons.person, 4),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData iconeNormal, IconData iconeSelecionado, int index) {
    final bool selecionado = _indiceAtual == index;
    return AnimatedScale(
      scale: selecionado ? 1.12 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: selecionado ? const Color(0xFF258A60) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          selecionado ? iconeSelecionado : iconeNormal,
          color: selecionado ? const Color(0xFFFBE4AE) : const Color(0xFFDACB8A),
          size: 20,
        ),
      ),
    );
  }
}