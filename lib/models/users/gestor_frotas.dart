// lib/models/users/gestor_frotas.dart

import 'pessoa.dart';
import 'user_role.dart';

class GestorFrotas extends Pessoa {
  // Removemos o 'department' conforme solicitado

  GestorFrotas({
    required super.id,
    required super.name,
    required super.cpf,
  }) : super(role: UserRole.FLEET_MANAGER);

  factory GestorFrotas.fromJson(Map<String, dynamic> json) {
    return GestorFrotas(
      id: json['id'],
      name: json['name'],
      cpf: json['cpf'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cpf': cpf,
      'role': 'FLEET_MANAGER',
    };
  }
}