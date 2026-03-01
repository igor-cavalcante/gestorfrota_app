import 'dart:convert';
import 'package:http/http.dart' as http;

import 'token_storage.dart';

class ApiClient {
  static const _baseUrl = "http://200.137.87.174:30850";

  // ---------------- HEADERS PADRÃO ----------------

 static Future<Map<String, String>> _headers() async {
  final token = await TokenStorage.getToken(); // Agora busca do Local Storage

  return {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token",
  };
}

  // ---------------- GET ----------------

  static Future<http.Response> get(String path) async {
    return http.get(
      Uri.parse("$_baseUrl$path"),
      headers: await _headers(),
    );
  }

  // ---------------- POST ----------------

  static Future<http.Response> post(String path, {dynamic body, bool isPublic = false}) async {
  final headers = await _headers();

  
  if (isPublic) headers.remove("Authorization"); // Remove o "Bearer null" no login

  return http.post(
    Uri.parse("$_baseUrl$path"),
    headers: headers,
    body: body != null ? jsonEncode(body) : null,
  );
}

  // ---------------- PATCH (NOVO) ----------------

  static Future<http.Response> patch(String path, {dynamic body}) async {
    return http.patch(
      Uri.parse("$_baseUrl$path"),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
  }

  // ---------------- DELETE (opcional) ----------------

  static Future<http.Response> delete(String path) async {
    return http.delete(
      Uri.parse("$_baseUrl$path"),
      headers: await _headers(),
    );
  }
}
