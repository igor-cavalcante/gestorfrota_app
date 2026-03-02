import 'package:web/web.dart' as web;

class TokenStorage {
  static const _tokenKey = "auth_token";
  static const _roleKey = "user_role";

  static Future<void> saveToken(String? token) async {
    if (token != null && token.isNotEmpty) {
      web.window.localStorage.setItem(_tokenKey, token);
      print("Token salvo no localStorage");
    }
  }

  static Future<String?> getToken() async {
    final token = web.window.localStorage.getItem(_tokenKey);
    return token;
  }

  static Future<void> saveRole(String role) async {
    web.window.localStorage.setItem(_roleKey, role);
    print("Token salvo no localStorage");
  }

  static Future<String> getUserRole() async {
    return web.window.localStorage.getItem(_roleKey) ?? "REQUESTER";
    
  }

  static Future<void> clear() async {
    web.window.localStorage.removeItem(_tokenKey);
    web.window.localStorage.removeItem(_roleKey);
  }
}