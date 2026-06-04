class LoginValidator {
  static String? validarEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'El correo es obligatorio';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Ingresa un correo valido';
    }
    return null;
  }

  static String? validarPassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'La contrasena es obligatoria';
    }
    if (password.length < 6) {
      return 'La contrasena debe tener minimo 6 caracteres';
    }
    return null;
  }
}
