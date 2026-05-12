import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'package:extensao3/screens/users/dashboard_users.dart';
import 'fleet_manager/approvals_screen.dart';
import 'reports_screen.dart';
import '../widgets/custom_app_bar.dart';
import '../services/token_storage.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isAdmin = false;
  bool _isRailExtended = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final isAdmin = await TokenStorage.hasRole('ADMIN');
    setState(() {
      _isAdmin = isAdmin;
    });
  }

  List<Map<String, dynamic>> _getMenuOptions() {
    final List<Map<String, dynamic>> options = [
      {
        'title': 'Gerência de Frota',
        'icon': Icons.dashboard_customize_outlined,
        'selectedIcon': Icons.dashboard_customize,
        'screen': const DashboardScreen(),
      },
      {
        'title': 'Aprovações',
        'icon': Icons.check_box_outlined,
        'selectedIcon': Icons.check_box,
        'screen': const ApprovalsScreen(),
      },
    ];

    if (_isAdmin) {
      options.add({
        'title': 'Usuários',
        'icon': Icons.group_outlined,
        'selectedIcon': Icons.group,
        'screen': const DashboardScreenUsers(),
      });
    }

    options.add({
      'title': 'Relatórios',
      'icon': Icons.bar_chart_outlined,
      'selectedIcon': Icons.bar_chart,
      'screen': const ReportsScreen(),
    });

    return options;
  }

  @override
  Widget build(BuildContext context) {
    final menuOptions = _getMenuOptions();
    final bool isWideScreen = MediaQuery.of(context).size.width >= 760;

    if (_selectedIndex >= menuOptions.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      appBar: CustomAppBar(title: menuOptions[_selectedIndex]['title']),
      // Mudança de Row para Stack para a Navbar não empurrar o conteúdo
      body: Stack(
        children: [
          // 1. CONTEÚDO PRINCIPAL FIXO
          // O Padding garante que o conteúdo respeite o espaço da navbar FECHADA (aprox 72px).
          // Quando a navbar abre, o conteúdo não encolhe, ele permanece intacto.
          Padding(
            padding: EdgeInsets.only(left: isWideScreen ? 72.0 : 0.0),
            child: Container(
              color: Colors.grey[50],
              width: double.infinity,
              height: double.infinity,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: menuOptions[_selectedIndex]['screen'],
              ),
            ),
          ),

          // 2. NAVBAR SOBREPOSTA (OVERLAY)
          if (isWideScreen)
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              child: Material(
                // Adiciona uma sombra elegante quando a navbar abre por cima da tabela
                elevation: _isRailExtended ? 16.0 : 0.0,
                color: const Color(0xFF1A237E),
                child: NavigationRail(
                  extended: _isRailExtended,
                  minExtendedWidth: 200,
                  backgroundColor: const Color(0xFF1A237E),
                  unselectedIconTheme: const IconThemeData(
                    color: Colors.white70,
                  ),
                  selectedIconTheme: const IconThemeData(color: Colors.white),
                  unselectedLabelTextStyle: const TextStyle(
                    color: Colors.white70,
                  ),
                  selectedLabelTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  destinations: menuOptions.map((option) {
                    return NavigationRailDestination(
                      icon: Icon(option['icon']),
                      selectedIcon: Icon(
                        option['selectedIcon'] ?? option['icon'],
                      ),
                      label: Text(option['title']),
                    );
                  }).toList(),
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) =>
                      setState(() => _selectedIndex = index),
                  leading: IconButton(
                    icon: Icon(
                      _isRailExtended ? Icons.menu_open : Icons.menu,
                      color: Colors.white,
                    ),
                    onPressed: () =>
                        setState(() => _isRailExtended = !_isRailExtended),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: isWideScreen
          ? null
          : BottomNavigationBar(
              currentIndex: _selectedIndex,
              selectedItemColor: const Color(0xFF1A237E),
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
              onTap: (index) => setState(() => _selectedIndex = index),
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
