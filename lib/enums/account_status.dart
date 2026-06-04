enum AccountStatus {
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
