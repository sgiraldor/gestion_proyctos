import '../enums/project_status.dart';
import '../enums/sync_status.dart';

class Proyecto {
  final String id;
  final String titulo;
  final String descripcion;
  final String responsableId;
  final DateTime fechaCreacion;
  final ProjectStatus estado;
  final double porcentajeAvance;
  final SyncStatus syncStatus;

  Proyecto({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.responsableId,
    required this.fechaCreacion,
    required this.estado,
    required this.porcentajeAvance,
    this.syncStatus = SyncStatus.pendingSync,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'responsableId': responsableId,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'estado': estado.name,
      'porcentajeAvance': porcentajeAvance,
      'syncStatus': syncStatus.name,
    };
  }

  factory Proyecto.fromJson(Map<String, dynamic> json) {
    return Proyecto(
      id: json['id'] as String? ?? '',
      titulo: json['titulo'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      responsableId: json['responsableId'] as String? ?? '',
      fechaCreacion: _dateFromJson(json['fechaCreacion']) ?? DateTime.now(),
      estado: ProjectStatus.values.firstWhere(
        (e) => e.name == json['estado'],
        orElse: () => ProjectStatus.borrador,
      ),
      porcentajeAvance: (json['porcentajeAvance'] as num? ?? 0).toDouble(),
      syncStatus: SyncStatus.values.firstWhere(
        (e) => e.name == json['syncStatus'],
        orElse: () => SyncStatus.pendingSync,
      ),
    );
  }

  Proyecto copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    String? responsableId,
    DateTime? fechaCreacion,
    ProjectStatus? estado,
    double? porcentajeAvance,
    SyncStatus? syncStatus,
  }) {
    return Proyecto(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      responsableId: responsableId ?? this.responsableId,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      estado: estado ?? this.estado,
      porcentajeAvance: porcentajeAvance ?? this.porcentajeAvance,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  static DateTime? _dateFromJson(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    try {
      return value?.toDate() as DateTime?;
    } catch (_) {
      return null;
    }
  }
}
