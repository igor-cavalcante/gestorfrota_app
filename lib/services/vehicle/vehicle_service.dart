import 'dart:convert';
import 'package:http/http.dart';
import '../../models/vehicle/vehicle_model.dart';
import '../api_client.dart';

class VehicleService {
  static Future<List<Vehicle>> getAll() async {
    final Response response = await ApiClient.get("/vehicles");
    if (response.statusCode == 200) {
      final Map<String, dynamic> page = jsonDecode(response.body);
      final List content = page["content"];
      return content.map((e) => Vehicle.fromJson(e)).toList();
    }
    throw Exception("Erro ao buscar veículos: ${response.statusCode}");
  }

  static Future<void> create(Map<String, dynamic> data) async {
    final response = await ApiClient.post("/vehicles", body: data);
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception("Falha no cadastro. Erro: ${response.body}");
    }
  }
}
