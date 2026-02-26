class VehicleRequestCreate {
  final String description;
  final String purpose;
  final String priority;
  final String processNumber;
  final String destination;
  final DateTime startDateTime;
  final DateTime endDateTime;

  VehicleRequestCreate({
    required this.description,
    required this.purpose,
    required this.priority,
    required this.processNumber,
    required this.destination,
    required this.startDateTime,
    required this.endDateTime,
  });

  Map<String, dynamic> toJson() => {
        "description": description,
        "purpose": purpose,
        "priority": priority,
        "processNumber": processNumber,
        "destination": destination,
        "startDateTime": startDateTime.toIso8601String(),
        "endDateTime": endDateTime.toIso8601String(),
      };
}
