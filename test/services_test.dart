import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_final_movil/enums/account_status.dart';
import 'package:proyecto_final_movil/enums/user_role.dart';
import 'package:proyecto_final_movil/models/entregable.dart';
import 'package:proyecto_final_movil/models/integrante.dart';
import 'package:proyecto_final_movil/models/usuario.dart';
import 'package:proyecto_final_movil/services/permission_service.dart';
import 'package:proyecto_final_movil/services/proyecto_service.dart';

void main() {
  group('PermissionService', () {
    final service = PermissionService();

    test('autoriza acciones por rol activo', () {
      final investigador = Usuario(
        uid: 'u1',
        nombre: 'Ana',
        email: 'ana@test.com',
        rol: UserRole.investigador,
        estado: AccountStatus.active,
      );

      expect(service.puedeCrearProyecto(investigador), isTrue);
      expect(service.puedeEvaluarProyecto(investigador), isFalse);
    });

    test('bloquea cuentas no activas', () {
      final usuario = Usuario(
        uid: 'u2',
        nombre: 'Luis',
        email: 'luis@test.com',
        rol: UserRole.evaluador,
        estado: AccountStatus.blocked,
      );

      expect(service.puedeIngresarSistema(usuario), isFalse);
      expect(service.estaBloqueado(usuario), isTrue);
    });
  });

  group('ProyectoService', () {
    final service = ProyectoService();

    test('exige responsable en integrantes', () {
      expect(
        service.tieneResponsable([
          Integrante(
            id: 'i1',
            proyectoId: 'p1',
            usuarioId: 'u1',
            nombre: 'Ana',
            rolEnProyecto: 'Responsable',
            esResponsable: true,
          ),
        ]),
        isTrue,
      );
    });

    test('impide que evaluador revise proyecto donde participa', () {
      final integrantes = [
        Integrante(
          id: 'i1',
          proyectoId: 'p1',
          usuarioId: 'u2',
          nombre: 'Evaluador',
          rolEnProyecto: 'Asesor',
          esResponsable: false,
        ),
      ];

      expect(
        service.evaluadorPuedeRevisar(
          evaluadorId: 'u2',
          integrantes: integrantes,
        ),
        isFalse,
      );
    });

    test('calcula avance por entregables aprobados', () {
      final entregables = [
        Entregable(
          id: 'e1',
          proyectoId: 'p1',
          nombre: 'Informe',
          descripcion: 'Doc',
          fechaLimite: DateTime(2026),
          aprobado: true,
          tardio: false,
        ),
        Entregable(
          id: 'e2',
          proyectoId: 'p1',
          nombre: 'Poster',
          descripcion: 'Doc',
          fechaLimite: DateTime(2026),
          aprobado: false,
          tardio: false,
        ),
      ];

      expect(service.calcularPorcentajeAvance(entregables), 50);
    });
  });
}
