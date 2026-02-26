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
      title: 'Gestão de Frotas',
      locale: const Locale('pt', 'BR'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      // Agora chamamos o verificador de sessão
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
      future: TokenStorage.getToken(), // Verifica se existe token salvo
      builder: (context, snapshot) {
        // Enquanto verifica o storage, mostra uma tela de carregamento
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Se NÃO tem token, vai para o Login
        if (snapshot.data == null || snapshot.data!.isEmpty) {
          return const LoginScreen();
        }

        // Se TEM token, precisamos saber qual é a Role para mandar para a tela certa
        return FutureBuilder<String>(
          future: TokenStorage.getUserRole(), //
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final role = roleSnapshot.data;

            // Lógica de redirecionamento idêntica à do seu LoginScreen
            if (role == 'DRIVER') {
              return const DriverActivitiesScreen();
            } else if (role == 'ADMIN' || role == 'FLEET_MANAGER') {
              return const MainScreen();
            } else {
              return const RequesterScreen();
            }
          },
        );
      },
    );
  }
}