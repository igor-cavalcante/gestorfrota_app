// lib/screens/reports_screen.dart

import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // A tela de Relatórios será uma lista.
    // Usamos ListView para garantir que ela role se tivermos
    // muitos relatórios ou filtros no futuro.
    return ListView(
      // Padding geral da tela
      padding: const EdgeInsets.all(16.0),
      children: [
        // --- 1. SEÇÃO DE FILTROS ---
        Text(
          'Filtros de Período',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16.0),

        // --- Filtro de Período Simulado ---
        // Usamos um Card para agrupar os filtros
        Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Usamos TextField (com 'enabled: false') para simular
                // um seletor de data que o usuário tocaria.
                TextField(
                  enabled: false, // Faz o campo não ser editável
                  decoration: InputDecoration(
                    labelText: 'Data Inicial',
                    hintText: '01/10/2025', // Texto de exemplo
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
                TextField(
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Data Final',
                    hintText: '31/10/2025', // Texto de exemplo
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
                // Botão de ação (simulado)
                ElevatedButton.icon(
                  onPressed: () {
                    print('Botão Aplicar Filtros pressionado');
                  },
                  icon: Icon(Icons.filter_list),
                  label: Text('Aplicar Filtros'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50), // Ocupa largura total
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),

        const SizedBox(height: 24.0),

        // --- 2. SEÇÃO DA LISTA DE RELATÓRIOS ---
        Text(
          'Relatórios Disponíveis',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16.0),

        // --- Lista de Relatórios ---
        // Usamos Cards e ListTile para uma aparência limpa e clicável

        // Relatório 1: Quilometragem
        _buildReportListItem(
          context: context,
          icon: Icons.speed,
          title: 'Relatório de Quilometragem',
          subtitle: 'KM rodados por veículo no período.',
          onTap: () {
            print('Abrindo Relatório de Quilometragem...');
            // No futuro: navegar para uma tela de detalhes do relatório
          },
        ),

        // Relatório 2: Combustível
        _buildReportListItem(
          context: context,
          icon: Icons.local_gas_station,
          title: 'Relatório de Combustível',
          subtitle: 'Custos, abastecimentos e média de consumo.',
          onTap: () {
            print('Abrindo Relatório de Combustível...');
          },
        ),

        // Relatório 3: Manutenção
        _buildReportListItem(
          context: context,
          icon: Icons.build_circle,
          title: 'Relatório de Manutenção',
          subtitle: 'Histórico de manutenções e custos associados.',
          onTap: () {
            print('Abrindo Relatório de Manutenção...');
          },
        ),

        // Relatório 4: Ociosidade
        _buildReportListItem(
          context: context,
          icon: Icons.timelapse,
          title: 'Relatório de Ociosidade',
          subtitle: 'Tempo de motor ligado com veículo parado.',
          onTap: () {
            print('Abrindo Relatório de Ociosidade...');
          },
        ),
      ],
    );
  }

  // --- WIDGET HELPER PARA OS ITENS DA LISTA ---
  // Criamos este 'helper' para não repetir o código 4x
  Widget _buildReportListItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: Icon(icon, color: Colors.blue.shade700),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16.0),
        onTap: onTap, // Ação ao clicar
      ),
    );
  }
}