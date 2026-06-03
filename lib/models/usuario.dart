import '../enums/user_role.dart';
import '../enums/account_status.dart';

class Usuario {
  final String uid;
  final String nombre;
  final String email;
  final UserRole rol;
  final AccountStatus estado;

  Usuario({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.estado,
  });
}