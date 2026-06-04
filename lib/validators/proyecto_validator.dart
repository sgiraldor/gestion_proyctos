class ProyectoValidator {
  static String? validarTitulo(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'El titulo es obligatorio';
    }
    if (text.length < 4) {
      return 'El titulo debe tener minimo 4 caracteres';
    }
    return null;
  }

  static String? validarDescripcion(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'La descripcion es obligatoria';
    }
    if (text.length < 10) {
      return 'La descripcion debe tener minimo 10 caracteres';
    }
    return null;
  }

  static String? validarPorcentaje(String? value) {
    final porcentaje = double.tryParse(value?.trim() ?? '');
    if (porcentaje == null) {
      return 'Ingresa un porcentaje valido';
    }
    if (porcentaje < 0 || porcentaje > 100) {
      return 'El porcentaje debe estar entre 0 y 100';
    }
    return null;
  }
}
