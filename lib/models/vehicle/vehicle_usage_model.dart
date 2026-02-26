// lib/models/vehicle/vehicle_usage_model.dart

import 'vehicle_model.dart';

class VehicleUsage {
  final int id;
  final int requestId;
  final DateTime usageStart;
  final DateTime usageEnd;
  final DateTime? checkInAt;
  final DateTime? checkOutAt;
  final String status;
  final String driverName;
  final Vehicle vehicle;

  VehicleUsage({
    required this.id,
    required this.requestId,
    required this.usageStart,
    required this.usageEnd,
    this.checkInAt,
    this.checkOutAt,
    required this.status,
    required this.driverName,
    required this.vehicle,
  });

  factory VehicleUsage.fromJson(Map<String, dynamic> json) {
    return VehicleUsage(
      id: json['id'] ?? 0,
      requestId: json['requestId'] ?? 0,
      usageStart: DateTime.parse(json['usageStart']),
      usageEnd: DateTime.parse(json['usageEnd']),
      checkInAt: json['checkInAt'] != null ? DateTime.parse(json['checkInAt']) : null,
      checkOutAt: json['checkOutAt'] != null ? DateTime.parse(json['checkOutAt']) : null,
      status: json['status'] ?? 'NOT_STARTED',
      driverName: json['driverName'] ?? 'Desconhecido',
      vehicle: Vehicle.fromJson(json['vehicle']),
    );
  }

  // Helpers para facilitar a UI
  bool get isStarted => status == 'STARTED';
  bool get isNotStarted => status == 'NOT_STARTED';
  bool get isFinished => status == 'FINISHED';
}