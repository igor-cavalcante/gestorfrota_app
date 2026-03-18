import 'package:flutter/material.dart';
import 'package:extensao3/models/users/pessoa.dart';
import 'package:extensao3/models/users/user_role.dart';
import 'package:extensao3/services/users/user_service.dart';

class DashboardScreenUsers extends StatefulWidget {
  const DashboardScreenUsers({super.key});

  @override
  State<DashboardScreenUsers> createState() => _DashboardScreenUsersState();
}

class _DashboardScreenUsersState extends State<DashboardScreenUsers> {
  final TextEditingController _searchController = TextEditingController();
  List<Pessoa> _allUsers = [];
  bool _isLoading = true;
  String _selectedRoleFilter = 'TODOS';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  /// Busca a lista de usuários da API
  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await UserService.getAllUsers();
      setState(() {
        _allUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("Erro ao carregar usuários: $e", isError: true);
    }
  }

  /// Executa a exclusão via API
  Future<void> _deleteUser(Pessoa user) async {
    try {
      await UserService.deleteUser(user.id);
      _showSnackBar("Usuário ${user.name} removido com sucesso!");
      _fetchUsers();
    } catch (e) {
      _showSnackBar("Erro ao remover usuário", isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Gerência de Usuários",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        ElevatedButton.icon(
          onPressed: () => _showUserForm(), 
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
            Expanded(
              flex: 3,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Pesquisar por nome...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: (v) => setState(() {}),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                value: _selectedRoleFilter,
                decoration: const InputDecoration(labelText: "Filtrar por Cargo"),
                items: ['TODOS', 'ADMIN', 'FLEET_MANAGER', 'DRIVER', 'REQUESTER']
                    .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedRoleFilter = v!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTable() {
    final filteredUsers = _allUsers.where((u) {
      final matchesName = u.name.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesRole = _selectedRoleFilter == 'TODOS' || u.role.name == _selectedRoleFilter;
      return matchesName && matchesRole;
    }).toList();

    return Theme(
      data: Theme.of(context).copyWith(cardTheme: const CardThemeData(elevation: 0)),
      child: PaginatedDataTable(
        columns: const [
          DataColumn(label: Text("ID")),
          DataColumn(label: Text("NOME")),
          DataColumn(label: Text("CPF")),
          DataColumn(label: Text("CARGO PRINCIPAL")),
          DataColumn(label: Text("AÇÕES")),
        ],
        source: UserTableSource(
          users: filteredUsers, 
          context: context, 
          onDelete: _confirmDelete,
        ),
        rowsPerPage: filteredUsers.length < 10 && filteredUsers.isNotEmpty ? filteredUsers.length : 10,
        showCheckboxColumn: false,
      ),
    );
  }

  void _confirmDelete(Pessoa user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar Exclusão"),
        content: Text("Deseja realmente excluir o usuário ${user.name}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(user);
            },
            child: const Text("Excluir", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Modal para criação de novo usuário
  void _showUserForm() {
    final nameController = TextEditingController();
    final cpfController = TextEditingController();
    List<String> selectedRoles = ['REQUESTER']; // Role padrão

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          title: const Text("Novo Usuário"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: "Nome Completo")),
                TextField(controller: cpfController, decoration: const InputDecoration(labelText: "CPF")),
                const SizedBox(height: 16),
                const Text("Cargos:", style: TextStyle(fontWeight: FontWeight.bold)),
                ...UserRole.values.map((role) {
                  return CheckboxListTile(
                    title: Text(role.name),
                    value: selectedRoles.contains(role.name),
                    onChanged: (val) {
                      setModalState(() {
                        val! ? selectedRoles.add(role.name) : selectedRoles.remove(role.name);
                      });
                    },
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () async {
                try {
                  final result = await UserService.createUser(
                    nameController.text, 
                    cpfController.text, 
                    selectedRoles
                  );
                  Navigator.pop(ctx);
                  _showTokenDialog(result['firstAccessToken']);
                  _fetchUsers();
                } catch (e) {
                  _showSnackBar("Erro ao criar usuário", isError: true);
                }
              },
              child: const Text("Salvar"),
            ),
          ],
        ),
      ),
    );
  }

  void _showTokenDialog(String? token) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Usuário Criado!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Passe este código para o primeiro acesso do usuário:"),
            const SizedBox(height: 10),
            SelectableText(token ?? "---", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Ok"))],
      ),
    );
  }
}

class UserTableSource extends DataTableSource {
  final List<Pessoa> users;
  final BuildContext context;
  final Function(Pessoa) onDelete;

  UserTableSource({required this.users, required this.context, required this.onDelete});

  @override
  DataRow? getRow(int index) {
    if (index >= users.length) return null;
    final user = users[index];

    return DataRow(cells: [
      DataCell(Text(user.id.toString())),
      DataCell(Text(user.name, style: const TextStyle(fontWeight: FontWeight.w500))),
      DataCell(Text(user.cpf)),
      DataCell(Chip(label: Text(user.role.name, style: const TextStyle(fontSize: 10)))),
      DataCell(Row(
        children: [
          IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () {}),
          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => onDelete(user)),
        ],
      )),
    ]);
  }

  @override bool get isRowCountApproximate => false;
  @override int get rowCount => users.length;
  @override int get selectedRowCount => 0;
}