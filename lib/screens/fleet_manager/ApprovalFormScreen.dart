import 'package:flutter/material.dart';
import '../../../models/vehicle/vehicle_request.dart';
import '../../../services/vehicle/request_service.dart';

class ApprovalFormScreen extends StatefulWidget {
  final VehicleRequest request;

  const ApprovalFormScreen({super.key, required this.request});

  @override
  State<ApprovalFormScreen> createState() => _ApprovalFormScreenState();
}

class _ApprovalFormScreenState extends State<ApprovalFormScreen> {
  final _notesController = TextEditingController();
  int? _selectedDriverId;
  int? _selectedVehicleId;
  
  List<dynamic> _availableDrivers = [];
  List<dynamic> _availableVehicles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchResources();
  }

  Future<void> _fetchResources() async {
    try {
      String start = widget.request.startDateTime!.toIso8601String();
      String end = widget.request.endDateTime!.toIso8601String();

      // Busca recursos disponíveis no IP e porta configurados no ApiClient
      final drivers = await RequestService.getAvailableDrivers(start, end);
      final vehicles = await RequestService.getAvailableVehicles(start, end);

      setState(() {
        _availableDrivers = drivers;
        _availableVehicles = vehicles;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao carregar recursos: $e")),
        );
      }
    }
  }

  Future<void> _confirmApproval() async {
    if (_selectedDriverId == null || _selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione o motorista e o veículo!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Chama o endpoint PATCH /requests/{id}/approve
      await RequestService.approve(
        widget.request.id,
        driverId: _selectedDriverId!,
        vehicleId: _selectedVehicleId!,
        notes: _notesController.text,
      );

      if (mounted) {
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro na aprovação: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dados de Aprovação")),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Missão: ${widget.request.purpose}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text("Destino: ${widget.request.city}"),
                  const Divider(height: 32),
                  
                  const Text("Selecione o Motorista:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: _selectedDriverId,
                    hint: const Text("Motoristas disponíveis"),
                    isExpanded: true,
                    items: _availableDrivers.map((d) => DropdownMenuItem<int>(
                      value: d['id'],
                      child: Text(d['name'] ?? 'Motorista sem nome'),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedDriverId = val),
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  const Text("Selecione o Veículo:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: _selectedVehicleId,
                    hint: const Text("Veículos disponíveis"),
                    isExpanded: true,
                    items: _availableVehicles.map((v) => DropdownMenuItem<int>(
                      value: v['id'],
                      // v['value'] é a placa conforme definido no seu SQL [cite: 14, 36]
                      child: Text("${v['model']} - ${v['value']}"), 
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedVehicleId = val),
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),

                  const SizedBox(height: 24),

                  const Text("Observações Técnicas:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      hintText: "Adicione recomendações para o motorista...",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _confirmApproval,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("CONFIRMAR E APROVAR", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
    );
  }
}