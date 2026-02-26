// lib/screens/main_screen.dart
import 'package:flutter/material.dart';

// Importa as 3 telas que vamos navegar
import 'dashboard_screen.dart';
import 'fleet_manager/approvals_screen.dart';
import 'reports_screen.dart';

// Importa a AppBar e a tela de Login (para o Logout)
import '../widgets/custom_app_bar.dart';
import 'package:extensao3/feature/login-screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Variável de estado para controlar qual aba está selecionada
  int _selectedIndex = 0; // Começa na aba 0 (Gerência)

  // Lista dos *títulos* que aparecerão na AppBar
  static const List<String> _pageTitles = [
    'Gerência de Frota',
    'Aprovações Pendentes',
    'Relatórios',
  ];

  // Lista das *telas* (Widgets) que serão exibidas no corpo
  static const List<Widget> _pages = <Widget>[
    DashboardScreen(),   // Nossa tela de dashboard (refatorada)
    ApprovalsScreen(),   // Tela placeholder
    ReportsScreen(),     // Tela placeholder
  ];

  // Função chamada quando o usuário toca numa aba
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Atualiza o estado com o novo índice
    });
  }

  @override
  Widget build(BuildContext context) {
    // O Scaffold principal da aplicação pós-login
    return Scaffold(
      // 1. A NOSSA APPBAR PERSONALIZADA
      appBar: CustomAppBar(
        // O título é dinâmico, baseado na aba selecionada
        title: _pageTitles[_selectedIndex],
      ),

      // 2. O CORPO DA TELA
      // Exibe o widget da lista '_pages' correspondente ao índice selecionado
      body: _pages[_selectedIndex],

      // 3. A BARRA DE NAVEGAÇÃO INFERIOR
      bottomNavigationBar: BottomNavigationBar(
        // Os itens da barra
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_customize),
            label: 'Gerência',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box_outlined),
            label: 'Aprovações',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Relatórios',
          ),
        ],

        // Configurações
        currentIndex: _selectedIndex, // Diz qual aba está ativa
        selectedItemColor: Colors.blueAccent, // Cor da aba ativa
        onTap: _onItemTapped, // Função a ser chamada ao tocar
        type: BottomNavigationBarType.fixed, // Garante que todos apareçam
      ),
    );
  }
}