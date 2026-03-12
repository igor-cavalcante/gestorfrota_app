// lib/services/token_storage.dart
import 'dart:convert';
import 'package:web/web.dart' as web;

class TokenStorage {
  static const _tokenKey = "auth_token";
  static const _rolesKey = "user_roles"; // Alterado para plural

  static Future<void> saveToken(String? token) async {
    if (token != null && token.isNotEmpty) {
      web.window.localStorage.setItem(_tokenKey, token);
    }
  }

  static Future<String?> getToken() async {
    return web.window.localStorage.getItem(_tokenKey);
  }

  // Novo método para salvar a lista completa de roles
  static Future<void> saveRoles(List<String> roles) async {
    web.window.localStorage.setItem(_rolesKey, jsonEncode(roles));
    print("Roles salvas no localStorage: $roles");
  }

  // Recupera a lista de roles ou retorna uma lista com REQUESTER por padrão
  static Future<List<String>> getUserRoles() async {
    final rolesJson = web.window.localStorage.getItem(_rolesKey);
    if (rolesJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(rolesJson);
        return decoded.map((e) => e.toString()).toList();
      } catch (e) {
        return ["REQUESTER"];
      }
    }
    return ["REQUESTER"];
  }

  // Helper para verificar se o usuário possui uma role específica
  static Future<bool> hasRole(String role) async {
    final roles = await getUserRoles();
    return roles.contains(role);
  }

  static Future<void> clear() async {
    web.window.localStorage.removeItem(_tokenKey);
    web.window.localStorage.removeItem(_rolesKey);
  }
}