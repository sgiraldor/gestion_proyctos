import '../enums/sync_status.dart';

class Entregable {
  final String id;
  final String proyectoId;
  final String nombre;
  final String descripcion;
  final DateTime fechaLimite;
  final DateTime? fechaEntrega;
  final bool aprobado;
  final bool tardio;
  final SyncStatus syncStatus;

  Entregable({
    required this.id,
    required this.proyectoId,
    required this.nombre,
    required this.descripcion,
    required this.fechaLimite,
    this.fechaEntrega,
    required this.aprobado,
    required this.tardio,
    this.syncStatus = SyncStatus.pendingSync,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'proyectoId': proyectoId,
      'nombre': nombre,
      'descripcion': descripcion,
      'fechaLimite': fechaLimite.toIso8601String(),
      'fechaEntrega': fechaEntrega?.toIso8601String(),
      'aprobado': aprobado,
      'tardio': tardio,
      'syncStatus': syncStatus.name,
    };
  }

  factory Entregable.fromJson(Map<String, dynamic> json) {
    return Entregable(
      id: json['id'] as String? ?? '',
      proyectoId: json['proyectoId'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      fechaLimite: _dateFromJson(json['fechaLimite']) ?? DateTime.now(),
      fechaEntrega: _dateFromJson(json['fechaEntrega']),
      aprobado: json['aprobado'] as bool? ?? false,
      tardio: json['tardio'] as bool? ?? false,
      syncStatus: SyncStatus.values.firstWhere(
        (status) => status.name == json['syncStatus'],
        orElse: () => SyncStatus.pendingSync,
      ),
    );
  }

  Entregable copyWith({
    String? id,
    String? proyectoId,
    String? nombre,
    String? descripcion,
    DateTime? fechaLimite,
    DateTime? fechaEntrega,
    bool clearFechaEntrega = false,
    bool? aprobado,
    bool? tardio,
    SyncStatus? syncStatus,
  }) {
    return Entregable(
      id: id ?? this.id,
      proyectoId: proyectoId ?? this.proyectoId,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      fechaLimite: fechaLimite ?? this.fechaLimite,
      fechaEntrega: clearFechaEntrega ? null : fechaEntrega ?? this.fechaEntrega,
      aprobado: aprobado ?? this.aprobado,
      tardio: tardio ?? this.tardio,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  static DateTime? _dateFromJson(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    try {
      return value.toDate() as DateTime;
    } catch (_) {
      return null;
    }
  }
}
