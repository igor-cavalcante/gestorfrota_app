import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  String _selectedStatus = 'SENT_TO_MANAGER';
  bool _isLoading = false;
  List<VehicleRequest> _requests = [];

  final Map<String, String> _statusLabels = {
    'SENT_TO_MANAGER': 'Pendentes',
    'APPROVED': 'Aprovadas',
    'REJECTED': 'Rejeitadas',
    'CANCELED': 'Canceladas',
  };

  // Mapa para traduzir a prioridade que vem da API
  final Map<String, String> _priorityLabels = {
    'LOW': 'Baixa',
    'NORMAL': 'Normal',
    'HIGH': 'Alta',
    'URGENT': 'Urgente',
  };

  final Map<String, String> _purposeLabels = {
    'DILLIGENCE': 'Diligência / Investigação',
    'ESCORT': 'Escolta / Apoio',
    'ON_CALL': 'Plantão',
    'OTHER': 'Outros',
  };

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoading = true);
    try {
      final data = await RequestService.getByStatus(_selectedStatus);
      setState(() => _requests = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar solicitações: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Minhas Solicitações'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NewRequestScreen()),
        ).then((_) => _fetchRequests()),
        label: const Text(
          "NOVA MISSÃO",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2, // Melhora a legibilidade
          ),
        ),
        icon: const Icon(Icons.add_location_alt_rounded),
        // Cores e Efeitos
        backgroundColor: const Color(0xFF2196F3), // Um azul mais vivo e visível
        foregroundColor:
            Colors.white, // Garante que o texto/ícone fiquem brancos

        hoverColor: const Color(
          0xFF1976D2,
        ), // Tom levemente mais escuro ao passar o mouse
        hoverElevation: 12, // Aumenta a sombra no hover para dar profundidade
        splashColor: Colors.white24,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
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
    return InkWell(
      onTap: () => _showRequestDetails(req),
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: const Icon(
            Icons.assignment_outlined,
            color: Color(0xFF1A237E),
          ),
          title: Text(
            "Destino: ${req.city}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "Processo: ${req.processNumber}\nSaída: ${req.startDateTime != null ? DateFormat('dd/MM/yy HH:mm').format(req.startDateTime!) : 'N/A'}",
          ),
          trailing: _statusBadge(req.status),
        ),
      ),
    );
  }

  // Widget de status com tradução e cores dinâmicas
  Widget _statusBadge(String status) {
    final Map<String, Color> statusColors = {
      'APPROVED': Colors.green,
      'REJECTED': Colors.red,
      'SENT_TO_MANAGER': Colors.orange,
      'CANCELED': Colors.grey,
      'COMPLETED': Colors.blue,
    };

    final Color baseColor = statusColors[status] ?? Colors.blueGrey;
    final String label = _statusLabels[status] ?? status;

    // Criando uma cor um pouco mais escura para o texto manualmente
    // .withAlpha(255) garante que a cor não tenha transparência no texto
    final Color textColor = HSLColor.fromColor(baseColor)
        .withLightness(0.35) // Ajusta a luminosidade (0.0 a 1.0)
        .toColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: baseColor.withOpacity(0.4), width: 1),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // --- MODAL DE DETALHES RESPONSIVO ---
  void _showRequestDetails(VehicleRequest req) {
    final bool isWeb = MediaQuery.of(context).size.width > 800;
    final double screenWidth = MediaQuery.of(context).size.width;
    final df = DateFormat('dd/MM/yyyy HH:mm');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWeb ? 600 : double.infinity),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildModalHeader(req),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle("Detalhes da Missão"),
                      _infoRow(
                        Icons.location_on,
                        "Destino",
                        "${req.city} - ${req.state}",
                      ),
                      _infoRow(
                        Icons.priority_high,
                        "Prioridade",
                        _priorityLabels[req.priority] ?? req.priority,
                      ),

                      // ÁREA CORRIGIDA: Layout Adaptativo para evitar Overflow
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // Se a largura do diálogo for pequena, empilha as datas
                          if (screenWidth < 450) {
                            return Column(
                              children: [
                                _infoRow(
                                  Icons.calendar_today,
                                  "Saída",
                                  req.startDateTime != null
                                      ? df.format(req.startDateTime!)
                                      : "N/A",
                                ),
                                _infoRow(
                                  Icons.keyboard_return,
                                  "Vinda",
                                  req.endDateTime != null
                                      ? df.format(req.endDateTime!)
                                      : "N/A",
                                ),
                              ],
                            );
                          }
                          // Em telas maiores, mantém lado a lado
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _infoRow(
                                  Icons.calendar_today,
                                  "Saída",
                                  req.startDateTime != null
                                      ? df.format(req.startDateTime!)
                                      : "N/A",
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _infoRow(
                                  Icons.keyboard_return,
                                  "Vinda",
                                  req.endDateTime != null
                                      ? df.format(req.endDateTime!)
                                      : "N/A",
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      _infoRow(Icons.notes, "Descrição", req.description),
                      const Divider(height: 32),
                      _sectionTitle("Histórico de Ações"),
                      if (req.history.isEmpty)
                        const Text("Sem histórico registrado.")
                      else
                        ...req.history.map((h) => _historyItem(h)).toList(),
                    ],
                  ),
                ),
                _modalCloseButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalHeader(VehicleRequest req) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A237E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  req.processNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
               Text(
                  "Finalidade: ${_purposeLabels[req.purpose] ?? req.purpose}",
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Alinha ícone ao topo do texto
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1A237E)),
          const SizedBox(width: 12),
          Expanded(
            // Garante que o texto ocupe apenas o espaço disponível
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  softWrap: true, // Permite quebra de linha
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  Widget _historyItem(Map<String, dynamic> h) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                h['action'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              Text(
                DateFormat(
                  'dd/MM HH:mm',
                ).format(DateTime.parse(h['performedAt'])),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
          Text(
            "Por: ${h['performedBy']}",
            style: const TextStyle(fontSize: 12),
          ),
          if (h['notes'] != null)
            Text(
              "Obs: ${h['notes']}",
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
        ],
      ),
    );
  }

  Widget _modalCloseButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey.shade800,
            foregroundColor: Colors.white,
          ),
          child: const Text("FECHAR"),
        ),
      ),
    );
  }
}
