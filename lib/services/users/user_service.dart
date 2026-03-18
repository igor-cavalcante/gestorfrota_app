// lib/services/user_service.dart
import 'dart:convert';
import 'package:extensao3/models/users/pessoa.dart';
import '../api_client.dart';

class UserService {
  // GET ALL com suporte a paginação
  static Future<List<Pessoa>> getAllUsers() async {
    final response = await ApiClient.get('/users');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      final List<dynamic> content = data['content'];
      return content.map((json) => Pessoa.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar usuários');
    }
  }

  // CREATE USER
  static Future<Map<String, dynamic>> createUser(String name, String cpf, List<String> roles) async {
    final body = {
      "name": name,
      "cpf": cpf,
      "roles": roles,
    };
    
    final response = await ApiClient.post('/users', body: body);
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Erro ao criar usuário: ${response.body}');
    }
  }

  // DELETE USER (Endpoint de Admin)
  static Future<void> deleteUser(int id) async {
    final response = await ApiClient.delete('/admin/user/$id');
    
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Falha ao deletar usuário');
    }
  }
}