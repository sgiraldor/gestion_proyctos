class Revision {
  final String id;
  final String proyectoId;
  final String evaluadorId;
  final String concepto;
  final bool aprobado;
  final DateTime fechaRevision;

  Revision({
    required this.id,
    required this.proyectoId,
    required this.evaluadorId,
    required this.concepto,
    required this.aprobado,
    required this.fechaRevision,
  });
}