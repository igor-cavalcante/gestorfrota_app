class VehicleRequest {
  final int id;
  final String requester;
  final String description;
  final String purpose;
  final String status;
  final String priority; // Adicionado
  final String city;
  final String state;
  final String processNumber;
  final DateTime? startDateTime;
  final DateTime? endDateTime;
  final List<dynamic> history; // Adicionado para o log de eventos

  VehicleRequest({
    required this.id,
    required this.requester,
    required this.description,
    required this.purpose,
    required this.status,
    required this.priority,
    required this.city,
    required this.state,
    required this.processNumber,
    this.startDateTime,
    this.endDateTime,
    required this.history,
  });

  factory VehicleRequest.fromJson(Map<String, dynamic> json) {
    return VehicleRequest(
      id: json['id'] ?? 0,
      requester: json['requesterName'] ?? json['requester']?['name'] ?? 'Desconhecido',
      description: json['description'] ?? '',
      purpose: json['purpose'] ?? '',
      status: json['status'] ?? '',
      priority: json['priority'] ?? 'NORMAL',
      processNumber: json['processNumber'] ?? json['process_number'] ?? 'N/A',
      city: json['city'] ?? json['destCity'] ?? '',
      state: json['state'] ?? json['destState'] ?? '',
      startDateTime: json['startDateTime'] != null ? DateTime.parse(json['startDateTime']) : null,
      endDateTime: json['endDateTime'] != null ? DateTime.parse(json['endDateTime']) : null,
      history: json['history'] ?? [],
    );
  }
}