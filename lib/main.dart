// lib/main.dart
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'feature/login-screen.dart';
import 'screens/main_screen.dart';
import 'screens/driver/driver_activies_screen.dart';
import 'services/token_storage.dart';
import 'screens/requester/requester_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VIGIA',
      locale: const Locale('pt', 'BR'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: TokenStorage.getToken(), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Se NÃO tem token, vai para o Login
        if (snapshot.data == null || snapshot.data!.isEmpty) {
          return const LoginScreen();
        }

        // Se TEM token, verifica a lista de roles
        return FutureBuilder<List<String>>(
          future: TokenStorage.getUserRoles(), 
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final roles = roleSnapshot.data ?? ["REQUESTER"];

            // Lógica de Prioridade de Redirecionamento baseada na lista de permissões
            if (roles.contains('ADMIN') || roles.contains('FLEET_MANAGER')) {
              return const MainScreen();
            } 
            
            if (roles.contains('DRIVER')) {
              return const DriverActivitiesScreen();
            } 

            return const RequesterScreen();
          },
        );
      },
    );
  }
}