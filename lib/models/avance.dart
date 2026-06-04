class Avance {
  final String id;
  final String proyectoId;
  final String descripcion;
  final double porcentaje;
  final DateTime fechaRegistro;

  Avance({
    required this.id,
    required this.proyectoId,
    required this.descripcion,
    required this.porcentaje,
    required this.fechaRegistro,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'proyectoId': proyectoId,
      'descripcion': descripcion,
      'porcentaje': porcentaje,
      'fechaRegistro': fechaRegistro.toIso8601String(),
    };
  }

  factory Avance.fromJson(Map<String, dynamic> json) {
    return Avance(
      id: json['id'] as String? ?? '',
      proyectoId: json['proyectoId'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      porcentaje: (json['porcentaje'] as num? ?? 0).toDouble(),
      fechaRegistro: _dateFromJson(json['fechaRegistro']) ?? DateTime.now(),
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
