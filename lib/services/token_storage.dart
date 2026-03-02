import 'dart:html' as html;

class TokenStorage {
  static const _tokenKey = "auth_token";
  static const _roleKey = "user_role";

  static Future<void> saveToken(String? token) async {
    if (token != null) {
      html.window.localStorage[_tokenKey] = token;
    }
  }

  static Future<String?> getToken() async {
    return html.window.localStorage[_tokenKey];
  }

  static Future<void> saveRole(String role) async {
    html.window.localStorage[_roleKey] = role;
  }

  static Future<String> getUserRole() async {
    return html.window.localStorage[_roleKey] ?? "REQUESTER";
  }

  static Future<void> clear() async {
    html.window.localStorage.remove(_tokenKey);
    html.window.localStorage.remove(_roleKey);
  }
}