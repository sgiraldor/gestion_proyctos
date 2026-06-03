class Integrante {
  final String id;
  final String proyectoId;
  final String usuarioId;
  final String nombre;
  final String rolEnProyecto;
  final bool esResponsable;

  Integrante({
    required this.id,
    required this.proyectoId,
    required this.usuarioId,
    required this.nombre,
    required this.rolEnProyecto,
    required this.esResponsable,
  });

  factory Integrante.fromJson(Map<String, dynamic> data) {
    return Integrante(
      id: data['id'] ?? '',
      proyectoId: data['proyectoId'] ?? '',
      usuarioId: data['usuarioId'] ?? '',
      nombre: data['nombre'] ?? '',
      rolEnProyecto: data['rolEnProyecto'] ?? '',
      esResponsable: data['esResponsable'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'proyectoId': proyectoId,
      'usuarioId': usuarioId,
      'nombre': nombre,
      'rolEnProyecto': rolEnProyecto,
      'esResponsable': esResponsable,
    };
  }
}