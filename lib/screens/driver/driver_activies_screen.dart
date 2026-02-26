import 'package:flutter/material.dart';
import 'package:extensao3/widgets/custom_app_bar.dart';
import 'package:extensao3/screens/driver/trip_details_screen.dart';
import '../../services/driver/usage_service.dart';
import '../../models/vehicle/vehicle_usage_model.dart';
import 'package:intl/intl.dart';

class DriverActivitiesScreen extends StatefulWidget {
  const DriverActivitiesScreen({super.key});

  @override
  State<DriverActivitiesScreen> createState() => _DriverActivitiesScreenState();
}

class _DriverActivitiesScreenState extends State<DriverActivitiesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<VehicleUsage> _allActivities = [];
  bool _isLoading = true;
  
  // Estados para Filtro e Busca
  DateTime? _selectedDate;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await UsageService.getMyUsages();
      if (mounted) {
        setState(() {
          _allActivities = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Lógica de Filtragem e Ordenação
  List<VehicleUsage> _getFilteredList(bool isHistory) {
    return _allActivities.where((u) {
      final matchesTab = isHistory ? u.status == "FINISHED" : u.status != "FINISHED";
      
      // Filtro de Data
      bool matchesDate = true;
      if (_selectedDate != null) {
        matchesDate = u.usageStart.year == _selectedDate!.year &&
                      u.usageStart.month == _selectedDate!.month &&
                      u.usageStart.day == _selectedDate!.day;
      }

      // Filtro de Texto
      final query = _searchController.text.toLowerCase();
      final matchesSearch = u.vehicle.model.toLowerCase().contains(query) || 
                            u.vehicle.licensePlate.toLowerCase().contains(query);

      return matchesTab && matchesDate && matchesSearch;
    }).toList()
    ..sort((a, b) {
      // Ordenação: 1. STARTED primeiro, 2. Por data mais próxima (Urgência)
      if (a.status == "STARTED") return -1;
      if (b.status == "STARTED") return 1;
      return a.usageStart.compareTo(b.usageStart);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const CustomAppBar(title: 'Minha Jornada'),
      body: Column(
        children: [
          _buildSearchAndFilterHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildActivityList(_getFilteredList(false), isHistory: false),
                      _buildActivityList(_getFilteredList(true), isHistory: true),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Cabeçalho com Busca e Calendário
  Widget _buildSearchAndFilterHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: "Buscar veículo ou placa...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  setState(() => _selectedDate = date);
                },
                icon: Icon(Icons.calendar_month, 
                  color: _selectedDate != null ? Colors.blueAccent : Colors.grey),
              ),
              if (_selectedDate != null)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => setState(() => _selectedDate = null),
                )
            ],
          ),
          if (_selectedDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                "Filtrando dia: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
            ),
        ],
      ),
    );
  }

  // Barra de Navegação Inferior
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2), // Sombra para cima
          )
        ],
      ),
      child: SafeArea(
        child: TabBar(
          controller: _tabController,
          labelColor: Colors.blueAccent,
          unselectedLabelColor: Colors.grey,
          // Remove o tracinho (indicador) padrão
          indicator: const BoxDecoration(), 
          // Ajusta o estilo do texto para ficar mais harmônico sem a linha
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          tabs: const [
            Tab(
              text: "ATIVAS", 
              icon: Icon(Icons.directions_car),
            ),
            Tab(
              text: "HISTÓRICO", 
              icon: Icon(Icons.history),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityList(List<VehicleUsage> activities, {required bool isHistory}) {
    if (activities.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: _loadActivities,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final usage = activities[index];
          if (usage.status == "STARTED") return _buildActiveCard(usage);
          return _buildStandardCard(usage, isHistory);
        },
      ),
    );
  }

  // Reutiliza os cards corrigidos anteriormente (Active e Standard)...
  // [A lógica dos cards _buildActiveCard e _buildStandardCard segue a mesma das respostas anteriores]

  Widget _buildActiveCard(VehicleUsage usage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.orange.shade700, Colors.orange.shade400]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TripDetailsScreen(activity: usage))),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("EM ANDAMENTO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                    Icon(Icons.flash_on, color: Colors.white.withOpacity(0.8)),
                  ],
                ),
                const SizedBox(height: 10),
                Text("${usage.vehicle.make} ${usage.vehicle.model}", 
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text("Placa: ${usage.vehicle.licensePlate}", style: const TextStyle(color: Colors.white70)),
                const Divider(color: Colors.white24, height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _miniInfo(Icons.play_arrow, "Início", DateFormat('HH:mm').format(usage.usageStart), true),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.orange.shade800),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TripDetailsScreen(activity: usage))),
                      child: const Text("CONCLUIR"),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStandardCard(VehicleUsage usage, bool isHistory) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isHistory ? Colors.grey.shade100 : Colors.blue.shade50,
          child: Icon(Icons.directions_car, color: isHistory ? Colors.grey : Colors.blue),
        ),
        title: Text("${usage.vehicle.make} ${usage.vehicle.model}", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Placa: ${usage.vehicle.licensePlate}"),
            Text("Início: ${DateFormat('dd/MM HH:mm').format(usage.usageStart)}", style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TripDetailsScreen(activity: usage))),
      ),
    );
  }

  Widget _miniInfo(IconData icon, String label, String value, bool inverse) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: inverse ? Colors.white70 : Colors.grey, fontSize: 10)),
        Row(
          children: [
            Icon(icon, size: 12, color: inverse ? Colors.white : Colors.blue),
            const SizedBox(width: 4),
            Text(value, style: TextStyle(color: inverse ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("Nenhuma corrida encontrada", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}