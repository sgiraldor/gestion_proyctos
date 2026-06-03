import '../models/usuario.dart';
import '../enums/user_role.dart';
import '../enums/account_status.dart';

class PermissionService {

  bool puedeCrearProyecto(Usuario usuario) {
    return usuario.estado == AccountStatus.active &&
        usuario.rol == UserRole.investigador;
  }

  bool puedeEvaluarProyecto(Usuario usuario) {
    return usuario.estado == AccountStatus.active &&
        usuario.rol == UserRole.evaluador;
  }

  bool puedeGestionarUsuarios(Usuario usuario) {
    return usuario.estado == AccountStatus.active &&
        usuario.rol == UserRole.coordinador;
  }

  bool puedeIngresarSistema(Usuario usuario) {
    return usuario.estado == AccountStatus.active;
  }

  bool estaBloqueado(Usuario usuario) {
    return usuario.estado == AccountStatus.blocked;
  }

  bool estaPendienteAprobacion(Usuario usuario) {
    return usuario.estado == AccountStatus.pendingApproval;
  }
}