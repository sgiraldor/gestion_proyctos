import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_final_movil/validators/entregable_validator.dart';
import 'package:proyecto_final_movil/validators/login_validator.dart';
import 'package:proyecto_final_movil/validators/proyecto_validator.dart';

void main() {
  group('LoginValidator', () {
    test('acepta credenciales con formato valido', () {
      expect(LoginValidator.validarEmail('ana@test.com'), isNull);
      expect(LoginValidator.validarPassword('123456'), isNull);
    });

    test('rechaza campos vacios o invalidos', () {
      expect(LoginValidator.validarEmail('ana'), isNotNull);
      expect(LoginValidator.validarPassword('123'), isNotNull);
    });
  });

  group('ProyectoValidator', () {
    test('valida titulo, descripcion y porcentaje', () {
      expect(ProyectoValidator.validarTitulo('Proyecto final'), isNull);
      expect(
        ProyectoValidator.validarDescripcion('Descripcion suficiente'),
        isNull,
      );
      expect(ProyectoValidator.validarPorcentaje('50'), isNull);
    });

    test('rechaza porcentajes fuera de rango', () {
      expect(ProyectoValidator.validarPorcentaje('-1'), isNotNull);
      expect(ProyectoValidator.validarPorcentaje('101'), isNotNull);
    });
  });

  group('EntregableValidator', () {
    test('valida datos de entregable', () {
      expect(EntregableValidator.validarNombre('Informe'), isNull);
      expect(EntregableValidator.validarDescripcion('Documento'), isNull);
      expect(EntregableValidator.validarDiasLimite('3'), isNull);
    });
  });
}
