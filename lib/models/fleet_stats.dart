class FleetStats {
  final int total;
  final int available;
  final int inUse;
  final int maintenance;

  FleetStats({
    required this.total,
    required this.available,
    required this.inUse,
    required this.maintenance,
  });

  factory FleetStats.fromJson(Map<String, dynamic> json) {
    return FleetStats(
      // Tentei adivinhar os nomes das chaves (keys) do seu JSON.
      // Se na API vier diferente (ex: "veiculos_total"), altere aqui.
      total: json['total'] ?? 0,
      available: json['disponivel'] ?? 0,
      inUse: json['em_uso'] ?? 0,
      maintenance: json['manutencao'] ?? 0,
    );
  }
}