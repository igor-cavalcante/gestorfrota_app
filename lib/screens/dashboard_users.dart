import 'package:flutter/material.dart';
import '../services/token_storage.dart'; // Para verificar se é admin

class DashboardScreenUsers extends StatefulWidget {
  const DashboardScreenUsers({super.key});

  @override
  State<DashboardScreenUsers> createState() => _DashboardScreenUsersState();
}

class _DashboardScreenUsersState extends State<DashboardScreenUsers> {
  // Controles de Filtro
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'TODOS';
  String _selectedRole = 'TODOS';

  // Mock de dados baseado no seu banco (users + user_roles)
  // No seu sistema, você substituirá pelo retorno do seu UserService.getAll()
  final List<Map<String, dynamic>> _allUsers = [
    {
      "id": 1,
      "name": "Igor Oliveira",
      "cpf": "000.000.000-00",
      "role": "ADMIN",
      "status": "ACTIVE"
    },
    {
      "id": 2,
      "name": "João Silva",
      "cpf": "111.111.111-11",
      "role": "DRIVER",
      "status": "ACTIVE"
    },
    {
      "id": 3,
      "name": "Maria Souza",
      "cpf": "222.222.222-22",
      "role": "FLEET_MANAGER",
      "status": "INACTIVE"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildFilterBar(),
                const SizedBox(height: 16),
                _buildUserTable(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 1. Cabeçalho (Seguindo o padrão da página de frota)
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Gerência de Usuários",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        ElevatedButton.icon(
          onPressed: () => _showUserForm(), // Modal de novo usuário
          icon: const Icon(Icons.person_add),
          label: const Text("Novo Usuário"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  // 2. Barra de Filtros
  Widget _buildFilterBar() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Busca por Nome
            Expanded(
              flex: 3,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Pesquisar por nome ou CPF...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                onChanged: (v) => setState(() {}),
              ),
            ),
            const SizedBox(width: 16),
            // Filtro de Role
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: "Cargo"),
                items: ['TODOS', 'ADMIN', 'FLEET_MANAGER', 'DRIVER', 'REQUESTER']
                    .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedRole = v!),
              ),
            ),
            const SizedBox(width: 16),
            // Filtro de Status
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: "Status"),
                items: ['TODOS', 'ACTIVE', 'INACTIVE', 'FIRST_ACCESS']
                    .map((st) => DropdownMenuItem(value: st, child: Text(st)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedStatus = v!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. Tabela de Dados (PaginatedDataTable para performance e layout)
  Widget _buildUserTable() {
    final filteredUsers = _allUsers.where((u) {
      final matchesName = u['name'].toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesRole = _selectedRole == 'TODOS' || u['role'] == _selectedRole;
      final matchesStatus = _selectedStatus == 'TODOS' || u['status'] == _selectedStatus;
      return matchesName && matchesRole && matchesStatus;
    }).toList();

    return Theme(
      data: Theme.of(context).copyWith(cardTheme: const CardThemeData(elevation: 0)),
      child: PaginatedDataTable(
        columns: const [
          DataColumn(label: Text("NOME")),
          DataColumn(label: Text("CPF")),
          DataColumn(label: Text("CARGO")),
          DataColumn(label: Text("STATUS")),
          DataColumn(label: Text("AÇÕES")),
        ],
        source: UserTableSource(filteredUsers, context, onDelete: _confirmDelete, onView: _showUserDetails),
        rowsPerPage: 10,
        columnSpacing: 20,
        horizontalMargin: 20,
        showCheckboxColumn: false,
      ),
    );
  }

  // --- FUNÇÕES DE AÇÃO ---

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Detalhes do Usuário"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nome: ${user['name']}"),
            Text("CPF: ${user['cpf']}"),
            Text("Cargo: ${user['role']}"),
            Text("Status: ${user['status']}"),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Fechar"))],
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar Exclusão"),
        content: Text("Deseja realmente excluir o usuário ${user['name']}? Esta ação não pode ser desfeita."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // Lógica de delete via service aqui
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Usuário removido")));
            },
            child: const Text("Excluir", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showUserForm() {
    // Aqui você abriria sua tela de cadastro/edição
  }
}

// Classe auxiliar para preencher a tabela
class UserTableSource extends DataTableSource {
  final List<Map<String, dynamic>> users;
  final BuildContext context;
  final Function(Map<String, dynamic>) onDelete;
  final Function(Map<String, dynamic>) onView;

  UserTableSource(this.users, this.context, {required this.onDelete, required this.onView});

  @override
  DataRow? getRow(int index) {
    if (index >= users.length) return null;
    final user = users[index];

    return DataRow(cells: [
      DataCell(Text(user['name'], style: const TextStyle(fontWeight: FontWeight.w500))),
      DataCell(Text(user['cpf'])),
      DataCell(Chip(label: Text(user['role'], style: const TextStyle(fontSize: 10)))),
      DataCell(Icon(Icons.circle, color: user['status'] == 'ACTIVE' ? Colors.green : Colors.red, size: 12)),
      DataCell(Row(
        children: [
          IconButton(icon: const Icon(Icons.visibility, color: Colors.blue), onPressed: () => onView(user)),
          IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () {}),
          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => onDelete(user)),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => users.length;
  @override
  int get selectedRowCount => 0;
}