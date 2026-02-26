// lib/models/users/motorista.dart

import 'pessoa.dart';
import 'user_role.dart';

class Motorista extends Pessoa {
  final String cnhNumber;
  final String cnhCategory; // Ex: B, C, D

  // Removemos 'cnhExpiration' conforme solicitado

  Motorista({
    required super.id,
    required super.name,
    required super.cpf,
    required this.cnhNumber,
    required this.cnhCategory,
  }) : super(role: UserRole.DRIVER);

  factory Motorista.fromJson(Map<String, dynamic> json) {
    return Motorista(
      id: json['id'],
      name: json['name'],
      cpf: json['cpf'],
      cnhNumber: json['cnhNumber'] ?? '',
      cnhCategory: json['cnhCategory'] ?? 'B',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cpf': cpf,
      'role': 'DRIVER',
      'cnhNumber': cnhNumber,
      'cnhCategory': cnhCategory,
    };
  }
}