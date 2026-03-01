// lib/services/auth_service.dart
import 'dart:convert';
import '../models/users/pessoa.dart';
import './token_storage.dart';
import './api_client.dart'; // Importe seu ApiClient

class AuthService {
  Future<Pessoa?> login(String cpf, String password) async {
    try {
      final response = await ApiClient.post(
        '/auth/login',
        body: {"cpf": cpf, "password": password},
        isPublic: true,
      );

      // DEBUG: Verifique o que a API respondeu de fato
      print("DEBUG: Status Code: ${response.statusCode}");
      print("DEBUG: Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Validação manual para evitar o "Null check operator"
        if (data['token'] == null) {
          print("DEBUG: Erro - Token não veio no JSON");
          return null;
        }

        await TokenStorage.saveToken(data['token']);

        // Adicione mapeamentos extras se necessário
        data['cpf'] = cpf;
        data['nome'] = data['name']; // Se a API manda name e o modelo quer nome

        return Pessoa.fromJson(data);
      } else {
        print(
          "DEBUG: Login falhou no servidor com status ${response.statusCode}",
        );
        return null;
      }
    } catch (e, stack) {
      // O 'stack' mostra o caminho exato do erro no código
      print("DEBUG: EXCEÇÃO CAPTURADA: $e");
      print("DEBUG: LOCAL DO ERRO: $stack");
      return null;
    }
  }
}
