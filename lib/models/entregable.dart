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
}