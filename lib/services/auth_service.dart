// lib/services/auth_service.dart
import 'dart:convert';
import '../models/users/pessoa.dart';
import './token_storage.dart';
import './api_client.dart';

class AuthService {
  Future<Pessoa?> login(String cpf, String password) async {
    try {
      final response = await ApiClient.post(
        '/auth/login',
        body: {"cpf": cpf, "password": password},
        isPublic: true,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['token'] == null) return null;
        await TokenStorage.saveToken(data['token']);

        // ✅ Salva a lista completa de roles vinda da API
        if (data['roles'] != null && data['roles'] is List) {
          final List<String> roles = (data['roles'] as List).map((e) => e.toString()).toList();
          await TokenStorage.saveRoles(roles);
        } else {
          await TokenStorage.saveRoles(["REQUESTER"]);
        }

        data['cpf'] = cpf;
        data['nome'] = data['name']; 

        return Pessoa.fromJson(data);
      }
      return null;
    } catch (e) {
      print("DEBUG: EXCEÇÃO NO LOGIN: $e");
      return null;
    } 
  }
}