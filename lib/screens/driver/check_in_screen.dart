import 'package:flutter/material.dart';
import 'package:extensao3/widgets/custom_app_bar.dart';
import '../../services/driver/usage_service.dart';
import '../../models/vehicle/vehicle_usage_model.dart';
import 'driver_activies_screen.dart';

class CheckInScreen extends StatefulWidget {
  final VehicleUsage activity;
  const CheckInScreen({super.key, required this.activity});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _kmController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleSubmission() async {
    if (_kmController.text.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      int km = int.parse(_kmController.text.replaceAll('.', '').replaceAll(',', ''));
      
      if (widget.activity.isStarted) {
        // Envio para Check-out (Finalização)
        await UsageService.checkOut(widget.activity.id, km, _notesController.text);
      } else {
        // Envio para Check-in (Início)
        await UsageService.checkIn(widget.activity.id, km);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sucesso!"), backgroundColor: Colors.green));
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const DriverActivitiesScreen()), (r) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isCheckout = widget.activity.isStarted;

    return Scaffold(
      appBar: CustomAppBar(title: isCheckout ? 'Check-out' : 'Check-in'),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text("Viatura: ${widget.activity.vehicle.licensePlate}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 30),
                TextField(
                  controller: _kmController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: isCheckout ? "Quilometragem Final" : "Quilometragem Inicial",
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.speed),
                  ),
                ),
                if (isCheckout) ...[
                  const SizedBox(height: 20),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: "Notas/Observações", border: OutlineInputBorder(), prefixIcon: Icon(Icons.note)),
                  ),
                ],
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity, height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: isCheckout ? Colors.orange : Colors.green),
                    onPressed: _handleSubmission,
                    child: Text(isCheckout ? "FINALIZAR MISSÃO" : "CONFIRMAR RETIRADA", style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}