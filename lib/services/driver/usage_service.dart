// lib/services/driver/usage_service.dart

import 'dart:convert';
import 'package:http/http.dart';
import '../../models/vehicle/vehicle_usage_model.dart';
import '../api_client.dart';

class UsageService {
  /// 🔹 Busca as missões do motorista e retorna objetos tipados
  static Future<List<VehicleUsage>> getMyUsages() async {
    final Response response = await ApiClient.get("/usages/my-usages");

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List content = data['content'] ?? [];

      // Mapeia cada item do JSON para o modelo VehicleUsage
      return content.map((json) => VehicleUsage.fromJson(json)).toList();
    }
    throw Exception("Erro ao buscar missões: ${response.statusCode}");
  }

  /// 🔹 Realiza o Check-in (Retirada) usando o ID do usage
  static Future<void> checkIn(int usageId, int mileage) async {
    final response = await ApiClient.patch(
      "/usages/$usageId/check-in",
      body: {"currentMileage": mileage},
    );

    if (response.statusCode != 200) {
      throw Exception("Erro no check-in: ${response.body}");
    }
  }

  /// 🔹 Realiza o Check-out (Devolução) usando o ID do usage
  static Future<void> checkOut(
    int usageId,
    int endMileage,
    String notes,
  ) async {
    final response = await ApiClient.patch(
      "/usages/$usageId/check-out",
      body: {"endMileage": endMileage, "notes": notes},
    );

    if (response.statusCode != 200) {
      throw Exception("Erro no check-out: ${response.body}");
    }
  }
}
