import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = "auth_token";
  static const _roleKey = "user_role"; // Nova chave para a Role

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Novo método para guardar a Role
  static Future<void> saveRole(String role) async {
    await _storage.write(key: _roleKey, value: role);
  }

  // Novo método para ler a Role
  static Future<String> getUserRole() async {
    String? role = await _storage.read(key: _roleKey);
    return role ?? 'REQUESTER'; // Retorna REQUESTER por padrão se estiver vazio
  }

  static Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _roleKey);
  }
}