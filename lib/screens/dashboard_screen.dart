import 'package:flutter/material.dart';
import '../models/vehicle/vehicle_model.dart';
import '../models/fleet_stats.dart';
import '../services/vehicle/vehicle_service.dart';
import 'vehicle/vehicle_registration_screen.dart';
import '../services/token_storage.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _userRole = "";
  late Future<List<Vehicle>> futureVehicles;
  late Future<FleetStats> futureStats;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      // Iniciamos a busca dos veículos
      futureVehicles = VehicleService.getAll();
      // Processamos as estatísticas a partir do resultado da busca de veículos
      futureStats = _buildStatsFromVehicles();
    });
  }

  Future<void> _loadPermissions() async {
    final role = await TokenStorage.getUserRole();
    if (mounted) {
      setState(() {
        _userRole = role;
      });
    }
  }

  Future<FleetStats> _buildStatsFromVehicles() async {
    // Aguarda o Future de veículos para evitar chamadas duplicadas à API
    final vehicles = await futureVehicles;
    int available = 0, inUse = 0, maintenance = 0;

    for (var v in vehicles) {
      final s = v.status.toUpperCase();
      // Mapeamento baseado nos status comuns de frota policial/gestão
      if (s.contains('DISPONIVEL') || s == 'ACTIVE') {
        available++;
      } else if (s.contains('USO') || s.contains('EM_USO')) {
        inUse++;
      } else if (s.contains('MANUTENCAO')) {
        maintenance++;
      }
    }

    return FleetStats(
      total: vehicles.length,
      available: available,
      inUse: inUse,
      maintenance: maintenance,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobileSmall = screenWidth < 400;
    final bool isWeb = screenWidth > 900;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: RefreshIndicator(
        onRefresh: () async => _refreshData(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Resumo Operacional', null),
                  const SizedBox(height: 16),

                  _buildKpiGrid(isWeb, isMobileSmall),

                  const SizedBox(height: 24),

                  _buildChartsSection(isWeb),

                  const SizedBox(height: 32),

                  _buildSectionHeader('Veículos na Base', () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VehicleRegistrationScreen(),
                      ),
                    );
                    if (result == true) {
                      _refreshData();
                    }
                  }),
                  const SizedBox(height: 16),

                  _buildVehicleGrid(isWeb),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- LÓGICA DE LAYOUT ---

  Widget _buildKpiGrid(bool isWeb, bool isMobileSmall) {
    return FutureBuilder<FleetStats>(
      future: futureStats,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();
        final stats = snapshot.data!;

        int crossAxisCount = isWeb ? 4 : (isMobileSmall ? 1 : 2);

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: isWeb ? 2.2 : (isMobileSmall ? 3.8 : 1.6),
          children: [
            _statCard("Total", stats.total, Icons.directions_car, Colors.blue),
            _statCard("Disponíveis", stats.available, Icons.check_circle, Colors.green),
            _statCard("Em Uso", stats.inUse, Icons.local_shipping, Colors.orange),
            _statCard("Manutenção", stats.maintenance, Icons.build, Colors.red),
          ],
        );
      },
    );
  }

  Widget _buildChartsSection(bool isWeb) {
    return FutureBuilder<FleetStats>(
      future: futureStats,
      builder: (context, snapshot) {
        final stats = snapshot.data ?? FleetStats(total: 0, available: 0, inUse: 0, maintenance: 0);
        
        if (isWeb) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildChartCard("Status da Frota (%)", _buildPieChart(stats))),
              const SizedBox(width: 16),
              Expanded(child: _buildChartCard("Uso Semanal (km rodados)", _buildBarChart())),
            ],
          );
        } else {
          return Column(
            children: [
              _buildChartCard("Status da Frota (%)", _buildPieChart(stats)),
              const SizedBox(height: 16),
              _buildChartCard("Uso Semanal (km rodados)", _buildBarChart()),
            ],
          );
        }
      },
    );
  }

  Widget _buildVehicleGrid(bool isWeb) {
    return FutureBuilder<List<Vehicle>>(
      future: futureVehicles,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final vehicles = snapshot.data ?? [];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: vehicles.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWeb ? 3 : 1,
            mainAxisExtent: 85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (_, index) => _vehicleCard(vehicles[index]),
        );
      },
    );
  }

  // --- COMPONENTES VISUAIS ---

  Widget _statCard(String label, int value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$value", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 20),
            SizedBox(height: 160, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(FleetStats stats) {
    // Cálculo de porcentagem seguro para evitar divisão por zero
    double total = stats.total == 0 ? 1 : stats.total.toDouble();
    double percDisponivel = (stats.available / total);

    return Row(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 90,
              height: 90,
              child: CircularProgressIndicator(
                value: percDisponivel,
                strokeWidth: 12,
                color: Colors.green,
                backgroundColor: Colors.orange.shade300,
              ),
            ),
            Text("${(percDisponivel * 100).toStringAsFixed(0)}%", 
                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _chartLegend(Colors.green, "Disponível", "${stats.available}"),
              const SizedBox(height: 8),
              _chartLegend(Colors.orange, "Em uso", "${stats.inUse}"),
              const SizedBox(height: 8),
              _chartLegend(Colors.red, "Manutenção", "${stats.maintenance}"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chartLegend(Color color, String label, String value) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54))),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBarChart() {
    // Dados simulados de KM rodados por dia
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _bar(40, "S", "120"),
        _bar(75, "T", "215"),
        _bar(95, "Q", "310"),
        _bar(60, "Q", "180"),
        _bar(85, "S", "260"),
        _bar(35, "S", "95"),
        _bar(20, "D", "40"),
      ],
    );
  }

  Widget _bar(double height, String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(value, style: const TextStyle(fontSize: 8, color: Colors.blueGrey)),
        const SizedBox(height: 4),
        Container(
          width: 16,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              colors: [Colors.blue.shade700, Colors.blue.shade300],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _vehicleCard(Vehicle v) {
    Color statusColor = v.status.toUpperCase().contains('ACTIVE') || v.status.toUpperCase().contains('DISPONIVEL') 
        ? Colors.green 
        : (v.status.toUpperCase().contains('MANUTENCAO') ? Colors.red : Colors.orange);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        dense: true,
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
          child: const Icon(Icons.directions_car, color: Colors.blueGrey, size: 20),
        ),
        title: Text(v.licensePlate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text("${v.make} ${v.model}", style: const TextStyle(fontSize: 11)),
        trailing: Icon(Icons.circle, color: statusColor, size: 10),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback? onAdd) {
    bool isAdmin = _userRole == "ADMIN";
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (onAdd != null && isAdmin)
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 16),
            label: const Text("Novo Veículo"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
      ],
    );
  }
}