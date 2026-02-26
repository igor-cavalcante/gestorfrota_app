import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/vehicle/vehicle_request.dart';
import '../../../services/vehicle/request_service.dart';
import 'ApprovalFormScreen.dart';

class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  List<VehicleRequest> _displayList = [];
  bool _loading = true;
  String _selectedStatus = "SENT_TO_MANAGER";
  DateTime? _selectedDate;

  // 1. Adicionado o filtro "Canceladas"
  final Map<String, String> _filters = {
    "Pendentes": "SENT_TO_MANAGER",
    "Aprovadas": "APPROVED",
    "Negadas": "REJECTED",
    "Canceladas": "CANCELED",
  };

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final requests = await RequestService.getByStatus(_selectedStatus);
      setState(() {
        _displayList = requests;
        if (_selectedDate != null) {
          _displayList = _displayList.where((r) => 
            r.startDateTime != null && 
            r.startDateTime!.day == _selectedDate!.day &&
            r.startDateTime!.month == _selectedDate!.month &&
            r.startDateTime!.year == _selectedDate!.year
          ).toList();
        }
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao carregar: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definindo breakpoints para melhor responsividade
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;
    final bool isTablet = width >= 600 && width < 1100;
    final bool isWeb = width >= 1100;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(isMobile, isTablet, isWeb),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _displayList.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadRequests,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                              horizontal: isWeb ? 40 : 16,
                              vertical: 20,
                            ),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 1400),
                                child: isMobile ? _buildMobileCards() : _buildResponsiveTable(width),
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // --- CABEÇALHO RESPONSIVO ---
  Widget _buildTopHeader(bool isMobile, bool isTablet, bool isWeb) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Solicitações de Veículos", 
            style: TextStyle(
              fontSize: isMobile ? 20 : 24, 
              fontWeight: FontWeight.bold, 
              color: Colors.blueGrey.shade800
            )
          ),
          const SizedBox(height: 16),
          // Wrap permite que os filtros quebrem linha se não couberem
          Wrap(
            spacing: 8,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ..._filters.entries.map((entry) {
                bool isSelected = _selectedStatus == entry.value;
                return ChoiceChip(
                  label: Text(entry.key),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) {
                      setState(() => _selectedStatus = entry.value);
                      _loadRequests();
                    }
                  },
                  selectedColor: Colors.blue.shade700,
                  backgroundColor: Colors.grey.shade100,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87, 
                    fontSize: isMobile ? 12 : 13
                  ),
                );
              }).toList(),
              const SizedBox(width: 4),
              _buildDateFilter(isMobile),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter(bool isMobile) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ActionChip(
          avatar: Icon(Icons.calendar_today, size: 16, color: _selectedDate != null ? Colors.blue.shade800 : Colors.grey.shade700),
          label: Text(
            _selectedDate == null ? "Data" : DateFormat('dd/MM/yy').format(_selectedDate!),
            style: TextStyle(color: _selectedDate != null ? Colors.blue.shade800 : Colors.grey.shade700),
          ),
          onPressed: _pickDate,
          backgroundColor: _selectedDate != null ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: _selectedDate != null ? Colors.blue : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        if (_selectedDate != null)
          IconButton(
            onPressed: () { setState(() => _selectedDate = null); _loadRequests(); },
            icon: const Icon(Icons.close, color: Colors.red, size: 18),
          ),
      ],
    );
  }

  // --- TABELA COM SCROLL HORIZONTAL (EVITA QUEBRA EM TELAS MÉDIAS) ---
  Widget _buildResponsiveTable(double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: screenWidth < 1000 ? 1000 : screenWidth - 80),
          child: DataTable(
            horizontalMargin: 20,
            columnSpacing: 20,
            headingRowColor: WidgetStateProperty.all(Colors.blueGrey.shade50),
            columns: const [
              DataColumn(label: Text('PROCESSO')),
              DataColumn(label: Text('SOLICITANTE')),
              DataColumn(label: Text('DESTINO')),
              DataColumn(label: Text('SAÍDA')),
              DataColumn(label: Text('STATUS')),
              DataColumn(label: Text('AÇÕES')),
            ],
            rows: _displayList.map((item) => DataRow(
              cells: [
                DataCell(Text(item.processNumber)),
                DataCell(Text(item.requester, style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text("${item.city}-${item.state}")),
                DataCell(Text(item.startDateTime != null ? DateFormat('dd/MM/yy HH:mm').format(item.startDateTime!) : "-")),
                DataCell(_statusBadge(item.status)),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.visibility, color: Colors.blue), onPressed: () => _showDetailsDialog(item)),
                    if (item.status == "SENT_TO_MANAGER")
                      IconButton(icon: const Icon(Icons.check_circle, color: Colors.green), onPressed: () => _approveRequest(item)),
                  ],
                )),
              ],
            )).toList(),
          ),
        ),
      ),
    );
  }

  // --- CARDS MOBILE OTIMIZADOS ---
  Widget _buildMobileCards() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _displayList.length,
      itemBuilder: (context, index) {
        final item = _displayList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.processNumber, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                    _statusBadge(item.status),
                  ],
                ),
                const Divider(height: 24),
                Text(item.requester, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text("${item.city}-${item.state}", style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showDetailsDialog(item),
                      icon: const Icon(Icons.info_outline),
                      label: const Text("Detalhes"),
                    ),
                    if (item.status == "SENT_TO_MANAGER")
                      ElevatedButton(
                        onPressed: () => _approveRequest(item),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        child: const Text("Analisar"),
                      ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // --- MODAL DE DETALHES ---
  void _showDetailsDialog(VehicleRequest item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              const Text("Detalhes da Solicitação", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Divider(height: 32),
              _detailItem("Status Atual", item.status),
              _detailItem("Solicitante", item.requester),
              _detailItem("Número Processo", item.processNumber),
              _detailItem("Destino", "${item.city} - ${item.state}"),
              _detailItem("Data Saída", item.startDateTime != null ? DateFormat('dd/MM/yyyy HH:mm').format(item.startDateTime!) : "N/A"),
              _detailItem("Motivo", item.purpose),
              _detailItem("Descrição", item.description),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
          Text(value, style: const TextStyle(fontSize: 16, height: 1.5)),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case "APPROVED":
        color = Colors.green;
        label = "APROVADA";
        break;
      case "REJECTED":
        color = Colors.red;
        label = "NEGADA";
        break;
      case "CANCELED":
        color = Colors.grey;
        label = "CANCELADA";
        break;
      default:
        color = Colors.orange;
        label = "PENDENTE";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2027),
    );
    if (picked != null) { setState(() => _selectedDate = picked); _loadRequests(); }
  }

  void _approveRequest(VehicleRequest item) async {
    final bool? approved = await Navigator.push(context, MaterialPageRoute(builder: (context) => ApprovalFormScreen(request: item)));
    if (approved == true) _loadRequests();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text("Nenhum registro encontrado", style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}