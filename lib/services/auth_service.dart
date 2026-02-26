// lib/services/auth_service.dart
import 'dart:convert';
import '../models/users/pessoa.dart';
import './token_storage.dart';
import './api_client.dart'; // Importe seu ApiClient

class AuthService {
  Future<Pessoa?> login(String cpf, String password) async {
    try {
      // Usando o ApiClient para manter o padrão do projeto
      // O endpoint aqui é '/auth/login' pois a baseUrl do ApiClient não tem o '/auth'
      final response = await ApiClient.post(
        '/auth/login', 
        body: {"cpf": cpf, "password": password},
        isPublic: true,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        // 1. Salva o Token
        await TokenStorage.saveToken(data['token']);

        // 2. Extrai a role principal para o Storage (se necessário no seu app)
        if (data['roles'] != null && (data['roles'] as List).isNotEmpty) {
          await TokenStorage.saveRole(data['roles'][0]);
        }

        // 3. Injeta o CPF no mapa (necessário pois seus modelos exigem CPF)
        data['cpf'] = cpf;

        // 4. Deixa o Pessoa.fromJson decidir quem é o usuário baseado na lista de roles
        return Pessoa.fromJson(data);
      }
      return null;
    } catch (e) {
      print("Erro no login: $e");
      return null;
    }
  }
}