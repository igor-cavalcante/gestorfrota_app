// lib/screens/main_screen.dart
import 'package:flutter/material.dart';

// Importa as 3 telas que vamos navegar
import 'dashboard_fleet.dart';
import 'dashboard_users.dart';
import 'fleet_manager/approvals_screen.dart';
import 'reports_screen.dart';
import 'package:extensao3/services/token_storage.dart';

// Importa a AppBar e a tela de Login (para o Logout)
import '../widgets/custom_app_bar.dart';
import 'package:extensao3/feature/login-screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final roles = await TokenStorage.getUserRoles();
    setState(() {
      isAdmin = roles.contains("ADMIN");
    });
  }

  // Lista dinâmica baseada na role
  List<Widget> get _pages => [
    const DashboardScreenFleet(),
    if (isAdmin) const DashboardScreenUsers(), // 2. Filtro de Admin
    const ApprovalsScreen(),
    const ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 760;

    return Scaffold(
      appBar: CustomAppBar(title: 'Gestão de Frota'),
      body: Row(
        children: [
          if (isDesktop)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) => setState(() => _selectedIndex = i),
              labelType: NavigationRailLabelType.all,
              destinations: [
                const NavigationRailDestination(icon: Icon(Icons.directions_car), label: Text('Frota')),
                if (isAdmin) const NavigationRailDestination(icon: Icon(Icons.people), label: Text('Usuários')),
                const NavigationRailDestination(icon: Icon(Icons.check_circle), label: Text('Aprovações')),
                const NavigationRailDestination(icon: Icon(Icons.bar_chart), label: Text('Relatórios')),
              ],
            ),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Frota'),
          if (isAdmin) const BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Usuários'),
          const BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'Aprovações'),
          const BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Relatórios'),
        ],
      ),
    );
  }
}