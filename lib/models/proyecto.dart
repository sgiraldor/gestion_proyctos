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
      id: json['id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      responsableId: json['responsableId'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      estado: ProjectStatus.values.firstWhere(
        (e) => e.name == json['estado'],
      ),
      porcentajeAvance: (json['porcentajeAvance'] as num).toDouble(),
      syncStatus: SyncStatus.values.firstWhere(
        (e) => e.name == json['syncStatus'],
      ),
    );
  }
}