// lib/models/users/admin.dart

import 'pessoa.dart';
import 'user_role.dart';

class Admin extends Pessoa {
  Admin({
    required super.id,
    required super.name,
    required super.cpf,
  }) : super(role: UserRole.ADMIN);

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
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
      'role': 'ADMIN',
    };
  }
}