import 'package:flutter/material.dart';
import 'package:extensao3/widgets/custom_app_bar.dart';
import '../../../services/vehicle/request_service.dart';

class NewRequestScreen extends StatefulWidget {
  const NewRequestScreen({super.key});

  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _cityController = TextEditingController();
  final _reasonController = TextEditingController();
  final _processController = TextEditingController();

  DateTime? _startDateTime;
  DateTime? _endDateTime;

  String _selectedPriority = 'NORMAL';
  final List<String> _priorities = ['LOW', 'NORMAL', 'HIGH', 'URGENT'];

  String _selectedPurposeUI = 'Diligência / Investigação';
  final Map<String, String> _purposeMap = {
    'Diligência / Investigação': 'DILLIGENCE',
    'Escolta / Apoio': 'ESCORT',
    'Plantão': 'ON_CALL',
    'Outros': 'OTHER',
  };

  @override
  void dispose() {
    _cityController.dispose();
    _reasonController.dispose();
    _processController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    
    // Breakpoints de responsividade
    final bool isMobile = screenWidth < 600;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;
    
    // Define a largura máxima baseada no dispositivo
    double formMaxWidth = 800; // Largura confortável para Desktop
    if (isMobile) formMaxWidth = screenWidth * 0.95;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const CustomAppBar(title: 'Solicitar Viatura'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A237E)))
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    // CORREÇÃO: minHeight garante que o fundo ocupe a tela toda e permita o scroll
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    width: double.infinity,
                    alignment: Alignment.topCenter,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 8 : 24,
                      vertical: isMobile ? 16 : 40,
                    ),
                    child: ConstrainedBox(
                      // Aumentamos a largura máxima para telas grandes
                      constraints: BoxConstraints(maxWidth: formMaxWidth), 
                      child: Form(
                        key: _formKey,
                        child: Card(
                          elevation: 6,
                          shadowColor: Colors.black26,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          child: Padding(
                            padding: EdgeInsets.all(isMobile ? 20.0 : 40.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeader(isMobile),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Divider(),
                                ),
                                
                                _buildSectionTitle("Dados da Identificação"),
                                _buildTextField(
                                  controller: _processController,
                                  label: "Número do Processo / Protocolo",
                                  icon: Icons.assignment_rounded,
                                  hint: "Ex: 2024/001-PMTO",
                                ),

                                const SizedBox(height: 24),
                                
                                // Em telas maiores, Priority e Purpose sempre ficam lado a lado
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _buildDropdown(
                                      label: "Prioridade",
                                      value: _selectedPriority,
                                      items: _priorities,
                                      onChanged: (v) => setState(() => _selectedPriority = v!),
                                    )),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildDropdown(
                                      label: "Finalidade",
                                      value: _selectedPurposeUI,
                                      items: _purposeMap.keys.toList(),
                                      onChanged: (v) => setState(() => _selectedPurposeUI = v!),
                                    )),
                                  ],
                                ),

                                const SizedBox(height: 24),
                                _buildSectionTitle("Logística e Destino"),
                                
                                // Datas: Empilham apenas em celulares muito pequenos
                                (screenWidth < 500) 
                                ? Column(
                                    children: [
                                      _buildDateSelector("Saída", _startDateTime, () => _pickDateTime(isStart: true), true),
                                      const SizedBox(height: 16),
                                      _buildDateSelector("Retorno", _endDateTime, () => _pickDateTime(isStart: false), true),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Expanded(child: _buildDateSelector("Data Saída", _startDateTime, () => _pickDateTime(isStart: true), isMobile)),
                                      const SizedBox(width: 16),
                                      Expanded(child: _buildDateSelector("Data Retorno", _endDateTime, () => _pickDateTime(isStart: false), isMobile)),
                                    ],
                                  ),

                                const SizedBox(height: 24),
                                
                                _buildTextField(
                                  controller: _cityController,
                                  label: "Cidade de Destino (Tocantins)",
                                  icon: Icons.location_on_rounded,
                                  hint: "Digite o nome da cidade",
                                ),

                                const SizedBox(height: 24),
                                _buildSectionTitle("Justificativa da Missão"),
                                
                                _buildTextField(
                                  controller: _reasonController,
                                  label: "Descrição Detalhada",
                                  icon: Icons.description_rounded,
                                  hint: "Descreva o objetivo da missão...",
                                  maxLines: 4,
                                ),

                                const SizedBox(height: 48),
                                
                                _buildSubmitButton(isMobile),
                              ],
                            ),
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

  // --- WIDGETS AUXILIARES ---

  Widget _buildHeader(bool isMobile) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A237E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.edit_document, size: isMobile ? 30 : 40, color: const Color(0xFF1A237E)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Nova Solicitação",
                style: TextStyle(
                  fontSize: isMobile ? 20 : 26, 
                  fontWeight: FontWeight.bold, 
                  color: const Color(0xFF1A237E),
                ),
              ),
              Text(
                "Complete os campos para enviar à gerência.",
                style: TextStyle(color: Colors.grey[600], fontSize: isMobile ? 12 : 14),
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

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, String? hint, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF1A237E)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) => (value == null || value.isEmpty) ? 'Obrigatório' : null,
    );
  }

  Widget _buildDropdown({required String label, required String value, required List<String> items, required Function(String?) onChanged}) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: items.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateSelector(String label, DateTime? date, VoidCallback onTap, bool isMobile) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.calendar_today_rounded, color: Color(0xFF1A237E)),
        ),
        child: Text(
          date == null ? "Selecionar Data/Hora" : "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isMobile) {
    return Center( // Centraliza o botão em telas grandes para melhor estética
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 400),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: _submitRequest,
            icon: const Icon(Icons.send_rounded),
            label: const Text("ENVIAR SOLICITAÇÃO", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
          ),
        ),
      ),
    );
  }

  // --- MÉTODOS DE LÓGICA MANTIDOS ---
  Future<void> _pickDateTime({required bool isStart}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date == null) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;
    setState(() {
      final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      isStart ? _startDateTime = dt : _endDateTime = dt;
    });
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDateTime == null || _endDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione as datas.')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await RequestService.create({
        "priority": _selectedPriority,
        "startDateTime": _startDateTime!.toIso8601String(),
        "endDateTime": _endDateTime!.toIso8601String(),
        "purpose": _purposeMap[_selectedPurposeUI],
        "processNumber": _processController.text,
        "city": _cityController.text,
        "state": "TO",
        "description": _reasonController.text,
      });
      _showSuccess();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Sucesso"),
        content: const Text("Sua solicitação foi enviada."),
        actions: [TextButton(onPressed: () => Navigator.of(ctx).popUntil((r) => r.isFirst), child: const Text("OK"))],
      ),
    );
  }
}