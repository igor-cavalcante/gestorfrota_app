import 'package:flutter/material.dart';
import '../../services/vehicle/request_service.dart';
import '../../models/vehicle/vehicle_request.dart';
import '../../widgets/custom_app_bar.dart';
import 'new_request_screen.dart';

class RequesterScreen extends StatefulWidget {
  const RequesterScreen({super.key});

  @override
  State<RequesterScreen> createState() => _RequesterScreenState();
}

class _RequesterScreenState extends State<RequesterScreen> {
  String _selectedStatus = 'SENT_TO_MANAGER'; // Status inicial [cite: 23, 31]
  bool _isLoading = false;
  List<VehicleRequest> _requests = [];

  // Mapeamento de Labels para os Status do Banco
  final Map<String, String> _statusLabels = {
    'SENT_TO_MANAGER': 'Pendentes',
    'APPROVED': 'Aprovadas',
    'REJECTED': 'Rejeitadas',
    'CANCELED': 'Canceladas',
  };

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoading = true);
    try {
      final data = await RequestService.getByStatus(_selectedStatus); //
      setState(() => _requests = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar solicitações: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Minhas Solicitações'), //
      // Botão para criar nova solicitação
      // No Scaffold da RequesterScreen.dart
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NewRequestScreen()),
        ).then((_) => _fetchRequests()),
        label: const Text(
          "NOVA MISSÃO",
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
        icon: const Icon(Icons.add_location_alt_rounded),
        backgroundColor: const Color(0xFF1A237E), //
        foregroundColor: Colors.white,
        elevation: 10, // Sombra profunda para "flutuar" sobre a lista
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Formato mais orgânico
        ),
      ),
      body: Column(
        children: [
          // Filtros por Status
          _buildFilterBar(),

          // Listagem
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _requests.isEmpty
                ? const Center(child: Text("Nenhuma solicitação encontrada."))
                : RefreshIndicator(
                    onRefresh: _fetchRequests,
                    child: ListView.builder(
                      itemCount: _requests.length,
                      padding: const EdgeInsets.all(12),
                      itemBuilder: (context, index) =>
                          _buildRequestCard(_requests[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      color: Colors.grey[100],
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _statusLabels.entries.map((entry) {
            final isSelected = _selectedStatus == entry.key;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(entry.value),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedStatus = entry.key);
                    _fetchRequests();
                  }
                },
                selectedColor: const Color(0xFF1A237E),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRequestCard(VehicleRequest req) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          "Destino: ${req.city}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ), //
        subtitle: Text(
          "Processo: ${req.processNumber}\nSaída: ${req.startDateTime}",
        ), // [cite: 22, 23]
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      ),
    );
  }
}
