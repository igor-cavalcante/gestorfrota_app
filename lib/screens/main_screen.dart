// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'package:extensao3/screens/users/dashboard_users.dart'; // Importe sua nova tela de usuários
import 'fleet_manager/approvals_screen.dart';
import 'reports_screen.dart';
import '../widgets/custom_app_bar.dart';
import '../services/token_storage.dart';
import '../models/users/pessoa.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isAdmin = false;
  bool _isRailExtended = true; // Controle do toggle da barra lateral

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  /// Verifica as permissões de admin usando o seu TokenStorage
  Future<void> _checkPermissions() async {
    final isAdmin = await TokenStorage.hasRole('ADMIN'); //
    setState(() {
      _isAdmin = isAdmin;
    });
  }

  /// Constrói a lista de abas baseada no status de admin
  List<Map<String, dynamic>> _getMenuOptions() {
    final List<Map<String, dynamic>> options = [
      {
        'title': 'Gerência de Frota',
        'icon': Icons.dashboard_customize,
        'screen': const DashboardScreen(),
      },
      {
        'title': 'Aprovações',
        'icon': Icons.check_box_outlined,
        'screen': const ApprovalsScreen(),
      },
    ];

    // Adiciona o Dashboard de Usuários apenas se for Admin
    if (_isAdmin) {
      options.add({
        'title': 'Usuários',
        'icon': Icons.group,
        'screen': const DashboardScreenUsers(),
      });
    }

    options.add({
      'title': 'Relatórios',
      'icon': Icons.bar_chart,
      'screen': const ReportsScreen(),
    });

    return options;
  }

  @override
  Widget build(BuildContext context) {
    final menuOptions = _getMenuOptions();
    final bool isWideScreen = MediaQuery.of(context).size.width >= 760;

    // Garante que o índice selecionado não cause erro se a lista de abas mudar
    if (_selectedIndex >= menuOptions.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: menuOptions[_selectedIndex]['title'],
      ),
      body: Row(
        children: [
          // 1. BARRA LATERAL (NavigationRail) - Somente para Telas >= 760px
          if (isWideScreen)
            NavigationRail(
              extended: _isRailExtended, // Controle do Toggle
              backgroundColor: Colors.white,
              selectedIconTheme: const IconThemeData(color: Colors.blueAccent),
              selectedLabelTextStyle: const TextStyle(
                color: Colors.blueAccent, 
                fontWeight: FontWeight.bold
              ),
              unselectedIconTheme: const IconThemeData(color: Colors.grey),
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              // Botão de Toggle (Menu Hambúrguer) no topo da Rail
              leading: IconButton(
                icon: Icon(_isRailExtended ? Icons.menu_open : Icons.menu),
                onPressed: () {
                  setState(() => _isRailExtended = !_isRailExtended);
                },
              ),
              destinations: menuOptions.map((opt) {
                return NavigationRailDestination(
                  icon: Icon(opt['icon']),
                  label: Text(opt['title']),
                );
              }).toList(),
            ),

          // 2. CONTEÚDO PRINCIPAL (A tela selecionada)
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: menuOptions[_selectedIndex]['screen'],
            ),
          ),
        ],
      ),

      // 3. BARRA INFERIOR (BottomNavigationBar) - Somente para Telas < 760px
      bottomNavigationBar: isWideScreen
          ? null
          : BottomNavigationBar(
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.blueAccent,
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                setState(() => _selectedIndex = index);
              },
              items: menuOptions.map((opt) {
                return BottomNavigationBarItem(
                  icon: Icon(opt['icon']),
                  label: opt['title'],
                );
              }).toList(),
            ),
    );
  }
}