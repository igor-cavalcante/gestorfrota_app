class VehicleRequest {
  final int id;
  final String requester;
  final String description;
  final String purpose;
  final String status;
  final String city;
  final String state;
  final String processNumber; // Adicionado
  final DateTime? startDateTime;
  final DateTime? endDateTime;

  VehicleRequest({
    required this.id,
    required this.requester,
    required this.description,
    required this.purpose,
    required this.status,
    required this.city,
    required this.state,
    required this.processNumber, // Adicionado
    this.startDateTime,
    this.endDateTime,
  });

  factory VehicleRequest.fromJson(Map<String, dynamic> json) {
    return VehicleRequest(
      id: json['id'] ?? 0,
      requester: json['requester']?['name'] ?? 'Desconhecido',
      description: json['description'] ?? '',
      purpose: json['purpose'] ?? '',
      status: json['status'] ?? '',
      processNumber: json['processNumber'] ?? 'N/A', // Mapeado
      city: json['city'] ?? json['destCity'] ?? '', 
      state: json['state'] ?? json['destState'] ?? '', 
      startDateTime: json['startDateTime'] != null ? DateTime.parse(json['startDateTime']) : null,
      endDateTime: json['endDateTime'] != null ? DateTime.parse(json['endDateTime']) : null,
    );
  }
}