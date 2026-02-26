import 'dart:convert';
import 'package:http/http.dart';

import '../../models/vehicle/vehicle_request.dart';
import '../api_client.dart';

class RequestService {

  /// 🔹 Cria uma nova solicitação de veículo
  static Future<void> create(Map<String, dynamic> data) async {
    final response = await ApiClient.post("/requests", body: data);

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception("Erro ao enviar solicitação: ${response.body}");
    }
  }

  /// 🔹 Lista solicitações filtradas por status (SENT_TO_MANAGER, APPROVED, etc.)
  /// Utiliza o endpoint /requests?status=... conforme as roles do sistema [cite: 23, 39]
  static Future<List<VehicleRequest>> getByStatus(String status) async {
    // Removida a barra extra para evitar erro 403 de segurança
    final Response response = await ApiClient.get("/requests?status=$status");

    if (response.statusCode == 200) {
      final Map<String, dynamic> page = jsonDecode(response.body);
      final List content = page["content"]; // Mapeia o 'content' do Spring Page

      return content
          .map((e) => VehicleRequest.fromJson(e))
          .toList();
    }

    throw Exception("Erro ao buscar solicitações ($status): ${response.statusCode}");
  }

  /// 🔹 Aprova uma solicitação designando motorista e veículo
  /// Endpoint: PATCH /requests/{id}/approve 
  static Future<void> approve(int id,
      {required int driverId, required int vehicleId, String notes = ""}) async {

    final response = await ApiClient.patch(
      "/requests/$id/approve",
      body: {
        "driverId": driverId,
        "vehicleId": vehicleId,
        "notes": notes 
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Erro ao aprovar: ${response.body}");
    }
  }

  /// 🔹 Rejeita uma solicitação (PATCH) 
  static Future<void> reject(int id, {String notes = ""}) async {
    final response = await ApiClient.patch(
      "/requests/$id/reject",
      body: {
        "notes": notes
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Erro ao rejeitar: ${response.body}");
    }
  }

  /// 🔹 Busca motoristas disponíveis no período específico da missão
  /// Baseado nos parâmetros usageStart e usageEnd 
  static Future<List<dynamic>> getAvailableDrivers(String start, String end) async {
    final response = await ApiClient.get(
      "/requests/available-drivers?usageStart=$start&usageEnd=$end",
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception("Erro ao buscar motoristas disponíveis");
  }

  /// 🔹 Busca veículos disponíveis no período específico da missão
  /// Verifica o status ACTIVE e a ausência de conflitos de horário [cite: 14, 22]
  static Future<List<dynamic>> getAvailableVehicles(String start, String end) async {
    final response = await ApiClient.get(
      "/requests/available-vehicles?usageStart=$start&usageEnd=$end",
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception("Erro ao buscar veículos disponíveis");
  }
}