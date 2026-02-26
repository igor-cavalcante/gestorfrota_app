import 'package:flutter/material.dart';
import 'package:extensao3/widgets/custom_app_bar.dart';
import '../../models/vehicle/vehicle_usage_model.dart';
import 'check_in_screen.dart';

class TripDetailsScreen extends StatelessWidget {
  final VehicleUsage activity;

  const TripDetailsScreen({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final bool isStarted = activity.isStarted;
    // Verifica se a missão já foi concluída
    final bool isFinished = activity.status.toUpperCase() == 'FINALIZADA' || 
                           activity.status.toUpperCase() == 'FINISHED';

    return Scaffold(
      appBar: const CustomAppBar(title: 'Detalhes da Missão'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 180, 
              color: const Color(0xFF1A237E), // Azul Marinho Policial
              child: const Center(child: Icon(Icons.map, size: 50, color: Colors.white))
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Missão #${activity.id}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _infoTile(Icons.person, "Motorista", activity.driverName),
                  _infoTile(
                    Icons.timer, 
                    "Status", 
                    activity.status.replaceAll('_', ' '),
                    color: isFinished ? Colors.red : Colors.green,
                  ),
                  const Divider(height: 40),
                  const Text("Viatura", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.directions_car, color: Color(0xFF1A237E)),
                      title: Text("${activity.vehicle.make} ${activity.vehicle.model}"),
                      subtitle: Text("Placa: ${activity.vehicle.licensePlate}\nKM Atual: ${activity.vehicle.currentMileage}"),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Botão de Ação com Trava de Segurança
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isStarted ? Colors.orange.shade800 : Colors.green.shade700,
                        disabledBackgroundColor: Colors.grey.shade400, // Cor quando desativado
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      // Se estiver finalizada, onPressed é nulo (botão desativado)
                      onPressed: isFinished 
                        ? null 
                        : () => Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (_) => CheckInScreen(activity: activity))
                          ),
                      child: Text(
                        isFinished 
                          ? "MISSÃO FINALIZADA" 
                          : (isStarted ? "REALIZAR CHECK-OUT (DEVOLUÇÃO)" : "REALIZAR CHECK-IN (RETIRADA)"),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (isFinished)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Center(
                        child: Text(
                          "Este registro não pode mais ser alterado.",
                          style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey), 
          const SizedBox(width: 12), 
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)), 
          Text(value, style: TextStyle(color: color, fontWeight: color != null ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}