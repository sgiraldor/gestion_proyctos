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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'proyectoId': proyectoId,
      'evaluadorId': evaluadorId,
      'concepto': concepto,
      'aprobado': aprobado,
      'fechaRevision': fechaRevision.toIso8601String(),
    };
  }

  factory Revision.fromJson(Map<String, dynamic> json) {
    return Revision(
      id: json['id'] as String? ?? '',
      proyectoId: json['proyectoId'] as String? ?? '',
      evaluadorId: json['evaluadorId'] as String? ?? '',
      concepto: json['concepto'] as String? ?? '',
      aprobado: json['aprobado'] as bool? ?? false,
      fechaRevision: _dateFromJson(json['fechaRevision']) ?? DateTime.now(),
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
