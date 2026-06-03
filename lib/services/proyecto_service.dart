import '../models/integrante.dart';
import '../models/entregable.dart';

class ProyectoService {
  bool tieneResponsable(List<Integrante> integrantes) {
    return integrantes.any((integrante) => integrante.esResponsable);
  }

  bool evaluadorPuedeRevisar({
    required String evaluadorId,
    required List<Integrante> integrantes,
  }) {
    final participaEnProyecto = integrantes.any(
      (integrante) => integrante.usuarioId == evaluadorId,
    );

    return !participaEnProyecto;
  }

  bool revisionTieneConcepto(String concepto) {
    return concepto.trim().isNotEmpty;
  }

  bool entregableEsTardio({
    required DateTime fechaLimite,
    required DateTime fechaEntrega,
  }) {
    return fechaEntrega.isAfter(fechaLimite);
  }

  bool puedeReemplazarEntregable(Entregable entregable) {
    return entregable.aprobado == false;
  }

  double calcularPorcentajeAvance(List<Entregable> entregables) {
    if (entregables.isEmpty) {
      return 0;
    }

    final aprobados = entregables.where((entregable) {
      return entregable.aprobado;
    }).length;

    return (aprobados / entregables.length) * 100;
  }
} 