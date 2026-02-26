// lib/models/users/pessoa.dart

import 'user_role.dart';
import 'admin.dart';
import 'gestor_frotas.dart';
import 'motorista.dart';
import 'solicitante.dart';

abstract class Pessoa {
  final int id;
  final String name;
  final String cpf;
  final UserRole role;

  Pessoa({
    required this.id,
    required this.name,
    required this.cpf,
    required this.role,
  });

  // Helpers para facilitar verificações no código
  bool get isAdmin => role == UserRole.ADMIN;
  bool get isManager => role == UserRole.FLEET_MANAGER;
  bool get isDriver => role == UserRole.DRIVER;
  bool get isSolicitante => role == UserRole.REQUESTER;

  factory Pessoa.fromJson(Map<String, dynamic> json) {
    // 1. Tratamento da lista de roles vinda da API
    // A API retorna "roles": ["DRIVER"]
    final List<dynamic> rolesList = json['roles'] ?? [];
    
    // Define a prioridade caso o usuário tenha mais de um papel no banco
    String roleString = 'REQUESTER'; 
    if (rolesList.contains('ADMIN')) {
      roleString = 'ADMIN';
    } else if (rolesList.contains('FLEET_MANAGER')) {
      roleString = 'FLEET_MANAGER';
    } else if (rolesList.contains('DRIVER')) {
      roleString = 'DRIVER';
    }

    // 2. Mapeamento dos campos obrigatórios conforme seu banco de dados
    // Se a API não enviar o 'id' ou 'cpf', usamos valores vazios/zero para não quebrar
    final int id = json['id'] ?? 0;
    final String name = json['name'] ?? 'Usuário';
    final String cpf = json['cpf'] ?? '';

    // Criamos um novo mapa para passar para os construtores das subclasses
    // garantindo que o campo 'role' (singular) exista para elas
    final mapParaSubclasse = {
      ...json,
      'role': roleString,
      'id': id,
      'name': name,
      'cpf': cpf,
    };

    // 3. Redirecionamento para a classe correta
    switch (roleString) {
      case 'ADMIN':
        return Admin.fromJson(mapParaSubclasse);
      case 'FLEET_MANAGER':
        return GestorFrotas.fromJson(mapParaSubclasse);
      case 'DRIVER':
        return Motorista.fromJson(mapParaSubclasse);
      case 'REQUESTER':
      default:
        return Solicitante.fromJson(mapParaSubclasse);
    }
  }

  Map<String, dynamic> toJson();
}