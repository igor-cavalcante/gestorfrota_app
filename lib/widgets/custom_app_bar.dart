import 'package:flutter/material.dart';
import 'package:extensao3/feature/login-screen.dart'; 
import 'package:extensao3/services/token_storage.dart'; // Importe o seu TokenStorage

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title, 
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      leading: leading,

      // Alinhando com o azul marinho policial usado no login
      backgroundColor: const Color(0xFF1A237E), 
      foregroundColor: Colors.white,
      elevation: 4.0,

      actions: [
        IconButton(
          icon: const Icon(Icons.logout_rounded),
          tooltip: 'Sair do Sistema',
          onPressed: () {
            _showLogoutConfirmation(context);
          },
        ),
      ],
    );
  }

  // Melhora de UX: Confirmação antes de sair
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Encerrar Sessão'),
          content: const Text('Deseja realmente sair do sistema de gestão de frota?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCELAR'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
                _handleLogout(context);      // Executa o logout
              },
              child: const Text('SAIR', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Função assíncrona para garantir a limpeza do token
  Future<void> _handleLogout(BuildContext context) async {
    // 1. Apaga o token e a role do armazenamento seguro
    await TokenStorage.clear();

    // 2. Redireciona para o Login limpando toda a pilha de navegação
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false, 
      );
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}