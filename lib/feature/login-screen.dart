import 'package:extensao3/screens/requester/requester_screen.dart';
import 'package:flutter/material.dart';
import 'package:extensao3/feature/registration-screen.dart';
import 'package:extensao3/screens/requester/new_request_screen.dart';
import 'package:extensao3/screens/main_screen.dart';
import 'package:extensao3/screens/driver/driver_activies_screen.dart';

// Integração com a API e Modelos
import 'package:extensao3/services/auth_service.dart';
import '../models/users/user_role.dart';
import '../models/users/pessoa.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  
  final _cpfController = TextEditingController(); 
  final _passwordController = TextEditingController();

  // Liberar memória ao fechar a tela
  @override
  void dispose() {
    _cpfController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final cpf = _cpfController.text.trim();
    final password = _passwordController.text.trim();

    if (cpf.isEmpty || password.isEmpty) {
      _showErrorSnackBar('Por favor, preencha todos os campos.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      // O AuthService agora lida com a injeção do CPF no modelo Pessoa
      final Pessoa? usuario = await authService.login(cpf, password);

      if (!mounted) return;

      if (usuario != null) {
        _redirectUser(usuario);
      } else {
        _showErrorSnackBar('CPF ou senha inválidos!');
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao conectar com o servidor.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _redirectUser(Pessoa user) {
    if (user.role == UserRole.DRIVER) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DriverActivitiesScreen()),
      );
    } else if (user.role == UserRole.ADMIN || user.role == UserRole.FLEET_MANAGER) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RequesterScreen()),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GESTÃO DE FROTA POLICIAL', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.2)
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1A237E), 
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 420, 
                    minHeight: constraints.maxHeight - 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.security_rounded,
                        size: 90,
                        color: Color(0xFF1A237E),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Autenticação',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.blueGrey[900],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Insira suas credenciais para acessar o sistema',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 40),

                      // Campo de CPF
                      TextField(
                        controller: _cpfController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next, // Pula para a senha
                        decoration: InputDecoration(
                          labelText: 'CPF',
                          hintText: '000.000.000-00',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.badge_outlined),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Campo de Senha
                      TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleLogin(), // Login direto pelo teclado
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.lock_person_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() => _isPasswordVisible = !_isPasswordVisible);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Botão de Acesso
                      SizedBox(
                        width: double.infinity,
                        height: 55.0,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A237E),
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('ACESSAR SISTEMA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Registro de novo operador
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                          );
                        },
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(color: Colors.grey, fontSize: 14.0),
                            children: [
                              TextSpan(text: 'Novo operador? '),
                              TextSpan(
                                text: 'Solicitar Acesso',
                                style: TextStyle(
                                  color: Color(0xFF1A237E),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}