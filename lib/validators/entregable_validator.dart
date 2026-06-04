class EntregableValidator {
  static String? validarNombre(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'El nombre es obligatorio';
    }
    return null;
  }

  static String? validarDescripcion(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'La descripcion es obligatoria';
    }
    return null;
  }

  static String? validarDiasLimite(String? value) {
    final dias = int.tryParse(value?.trim() ?? '');
    if (dias == null) {
      return 'Ingresa un numero de dias valido';
    }
    if (dias < 0) {
      return 'Los dias no pueden ser negativos';
    }
    return null;
  }
}
