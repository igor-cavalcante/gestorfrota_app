import 'package:flutter/material.dart';
import '../../../models/vehicle/vehicle_request.dart';
import '../../../services/vehicle/request_service.dart';
import 'package:intl/intl.dart';

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

      final drivers = await RequestService.getAvailableDrivers(start, end);
      final vehicles = await RequestService.getAvailableVehicles(start, end);

      setState(() {
        _availableDrivers = drivers;
        _availableVehicles = vehicles;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao carregar recursos: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmApproval() async {
    if (_selectedDriverId == null || _selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Selecione o motorista e o veículo!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await RequestService.approve(
        widget.request.id,
        driverId: _selectedDriverId!,
        vehicleId: _selectedVehicleId!,
        notes: _notesController.text,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro na aprovação: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    final Color primaryColor = const Color(
      0xFF1A237E,
    ); // Azul escuro padrão do sistema

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Análise de Solicitação"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 24,
                    vertical: isMobile ? 16 : 40,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isMobile ? 20 : 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(isMobile, primaryColor),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Divider(),
                              ),

                              _buildSectionTitle("Resumo da Missão"),
                              _buildInfoSummary(isMobile),

                              const SizedBox(height: 32),
                              _buildSectionTitle("Alocação de Recursos"),

                              // Responsividade para Dropdowns: Lado a lado no Desktop, Empilhado no Mobile
                              isMobile
                                  ? Column(
                                      children: [
                                        _buildResourceDropdown(
                                          "Motorista",
                                          Icons.person_search,
                                          _availableDrivers,
                                          _selectedDriverId,
                                          (val) => setState(
                                            () => _selectedDriverId = val,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        _buildResourceDropdown(
                                          "Veículo / Placa",
                                          Icons.directions_car_filled,
                                          _availableVehicles,
                                          _selectedVehicleId,
                                          (val) => setState(
                                            () => _selectedVehicleId = val,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: _buildResourceDropdown(
                                            "Motorista",
                                            Icons.person_search,
                                            _availableDrivers,
                                            _selectedDriverId,
                                            (val) => setState(
                                              () => _selectedDriverId = val,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: _buildResourceDropdown(
                                            "Veículo / Placa",
                                            Icons.directions_car_filled,
                                            _availableVehicles,
                                            _selectedVehicleId,
                                            (val) => setState(
                                              () => _selectedVehicleId = val,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                              const SizedBox(height: 24),
                              _buildSectionTitle("Instruções Técnicas"),
                              TextField(
                                controller: _notesController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  labelText: "Observações Adicionais",
                                  hintText:
                                      "Orientações sobre combustível, rota ou segurança...",
                                  prefixIcon: Icon(
                                    Icons.note_alt_rounded,
                                    color: primaryColor,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                              ),

                              const SizedBox(height: 40),
                              _buildSubmitButton(isMobile),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildHeader(bool isMobile, Color color) {
    return Row(
      children: [
        CircleAvatar(
          radius: isMobile ? 24 : 30,
          backgroundColor: Colors.green[50],
          child: Icon(
            Icons.fact_check_rounded,
            size: isMobile ? 28 : 34,
            color: Colors.green[700],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Aprovação de Frota",
                style: TextStyle(
                  fontSize: isMobile ? 18 : 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                "Nº Processo: ${widget.request.processNumber}",
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: Colors.blueGrey[300],
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildInfoSummary(bool isMobile) {
    final df = DateFormat('dd/MM/yy HH:mm');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Exibe a cidade e estado do destino [cite: 21, 22]
          _summaryRow(
            Icons.map,
            "Destino",
            "${widget.request.city} - ${widget.request.state}",
          ),
          const Divider(height: 24),
          // Exibe o intervalo entre saída e retorno [cite: 22, 39]
          _summaryRow(
            Icons.schedule,
            "Período",
            "${df.format(widget.request.startDateTime!)} até ${df.format(widget.request.endDateTime!)}",
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blueGrey),
        const SizedBox(width: 8),
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildResourceDropdown(
    String label,
    IconData icon,
    List<dynamic> items,
    int? value,
    Function(int?) onChanged,
  ) {
    return DropdownButtonFormField<int>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: items.map((i) {
        String title = i['name'] ?? i['model'] ?? 'N/A';
        String subtitle = i['value'] != null ? "(${i['value']})" : ""; // Placa
        return DropdownMenuItem<int>(
          value: i['id'],
          child: Text("$title $subtitle", style: const TextStyle(fontSize: 14)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSubmitButton(bool isMobile) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: _confirmApproval,
        icon: const Icon(Icons.check_circle_outline_rounded),
        label: const Text(
          "CONFIRMAR E APROVAR",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
      ),
    );
  }
}
