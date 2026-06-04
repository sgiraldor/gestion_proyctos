enum UserRole {
  investigador,
  evaluador,
  coordinador,
}

extension UserRoleLabel on UserRole {
  String get label {
    switch (this) {
      case UserRole.investigador:
        return 'Investigador';
      case UserRole.evaluador:
        return 'Evaluador';
      case UserRole.coordinador:
        return 'Coordinador';
    }
  }
}
