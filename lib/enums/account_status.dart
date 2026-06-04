enum AccountStatus {
<<<<<<< HEAD
  active,
  inactive,
  blocked,
  pendingApproval,
}

extension AccountStatusLabel on AccountStatus {
  String get label {
    switch (this) {
      case AccountStatus.active:
        return 'Activa';
      case AccountStatus.inactive:
        return 'Inactiva';
      case AccountStatus.blocked:
        return 'Bloqueada';
      case AccountStatus.pendingApproval:
        return 'Pendiente';
    }
  }
}
=======
  activo,
  inactivo,
  bloqueado,
  pendienteAprobacion,
}
>>>>>>> 70233f51266470e69ae422e749a14accd5b9113f
