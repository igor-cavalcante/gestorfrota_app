import 'package:flutter/material.dart';
import 'package:extensao3/widgets/custom_app_bar.dart';
import '../../../services/vehicle/vehicle_service.dart';

class VehicleRegistrationScreen extends StatefulWidget {
  const VehicleRegistrationScreen({super.key});

  @override
  State<VehicleRegistrationScreen> createState() =>
      _VehicleRegistrationScreenState();
}

class _VehicleRegistrationScreenState extends State<VehicleRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores ajustados para o padrão da sua API
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _plateController = TextEditingController();
  final _kmController = TextEditingController();

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _plateController.dispose();
    _kmController.dispose();
    super.dispose();
  }

  Future<void> _saveVehicle() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // 1. Limpa o texto da KM e converte para double (Ex: "36.980" -> 36.98)
        double kmValue =
            double.tryParse(_kmController.text.replaceAll(',', '.')) ?? 0.0;

        // 2. Monta o JSON exatamente como a sua API exige
        final Map<String, dynamic> vehicleData = {
          "make": _makeController.text,
          "model": _modelController.text,
          "licensePlate": _plateController.text.toUpperCase(), // CHAVE CORRETA
          "currentMileage": kmValue, // ENVIADO COMO NÚMERO
        };

        await VehicleService.create(vehicleData);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Viatura cadastrada!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // Helper para limpar a KM (remove pontos e transforma em int)
  int _parseKm(String text) {
    // Remove pontos de milhar se o usuário digitar "36.980"
    String cleaned = text.replaceAll('.', '').replaceAll(',', '');
    return int.tryParse(cleaned) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Nova Viatura'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Dados do Veículo",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 1. MARCA
                    TextFormField(
                      controller: _makeController,
                      decoration: _inputStyle(
                        'Marca',
                        Icons.business,
                        'Ex: Chevrolet',
                      ),
                      validator: (v) => v!.isEmpty ? 'Informe a marca' : null,
                    ),
                    const SizedBox(height: 16),

                    // 2. MODELO
                    TextFormField(
                      controller: _modelController,
                      decoration: _inputStyle(
                        'Modelo',
                        Icons.directions_car,
                        'Ex: Tracker Premier',
                      ),
                      validator: (v) => v!.isEmpty ? 'Informe o modelo' : null,
                    ),
                    const SizedBox(height: 16),

                    // 3. PLACA
                    TextFormField(
                      controller: _plateController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: _inputStyle(
                        'Placa',
                        Icons.tag,
                        'Ex: RXA4389',
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Informe a placa' : null,
                    ),
                    const SizedBox(height: 16),

                    // 4. QUILOMETRAGEM
                    TextFormField(
                      controller: _kmController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _inputStyle(
                        'Quilometragem Atual',
                        Icons.speed,
                        'Ex: 36.980',
                      ),
                      validator: (v) => v!.isEmpty ? 'Informe a KM' : null,
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: _saveVehicle,
                        icon: const Icon(Icons.save),
                        label: const Text(
                          "SALVAR VEÍCULO",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  InputDecoration _inputStyle(String label, IconData icon, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
