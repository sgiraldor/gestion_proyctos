import '../enums/user_role.dart';
import '../enums/account_status.dart';

class Usuario {
  final String uid;
  final String nombre;
  final String email;
  final UserRole rol;
  final AccountStatus estado;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  const Usuario({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.estado,
    this.createdAt,
    this.lastLoginAt,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      uid: json['uid'] as String? ?? '',
      nombre: (json['name'] ?? json['nombre'] ?? '') as String,
      email: json['email'] as String? ?? '',
      rol: UserRole.values.firstWhere(
        (role) => role.name == (json['role'] ?? json['rol']),
        orElse: () => UserRole.investigador,
      ),
      estado: AccountStatus.values.firstWhere(
        (status) => status.name == (json['status'] ?? json['estado']),
        orElse: () => AccountStatus.pendingApproval,
      ),
      createdAt: _dateFromJson(json['createdAt']),
      lastLoginAt: _dateFromJson(json['lastLoginAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': nombre,
      'email': email,
      'role': rol.name,
      'status': estado.name,
      'createdAt': createdAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  Usuario copyWith({
    String? uid,
    String? nombre,
    String? email,
    UserRole? rol,
    AccountStatus? estado,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return Usuario(
      uid: uid ?? this.uid,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      rol: rol ?? this.rol,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  static DateTime? _dateFromJson(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    try {
      return value.toDate() as DateTime;
    } catch (_) {
      return null;
    }
  }
}
