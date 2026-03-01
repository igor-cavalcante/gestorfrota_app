import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage(
    // ESTA CONFIGURAÇÃO É ESSENCIAL PARA WEB
    webOptions: WebOptions(
      dbName: 'gestor_frota_db',
      publicKey: 'gestor_frota_key',
      // Se definido como true, ele criptografa.
      // Em HTTP local, tente false se estiver dando erro de inicialização.
    ),
  );
  static const _tokenKey = "auth_token";
  static const _roleKey = "user_role"; // Nova chave para a Role

  static Future<void> saveToken(String? token) async {
    if (token == null) return;
    try {
      await _storage.write(key: 'jwt_token', value: token);
      print("Token gravado no Storage");
    } catch (e) {
      print("Erro ao gravar no Storage Web: $e");
      // Fallback manual se o secure storage falhar na Web
    }
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
