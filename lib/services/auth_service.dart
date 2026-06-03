import '../models/usuario.dart';
import '../enums/user_role.dart';
import '../enums/account_status.dart';

class AuthService {
  Usuario? login(String email, String password) {
    if (password != '123456') {
      return null;
    }

    if (email == 'investigador@test.com') {
      return Usuario(
        uid: 'u1',
        nombre: 'Investigador Prueba',
        email: email,
        rol: UserRole.investigador,
        estado: AccountStatus.active,
      );
    }

    if (email == 'evaluador@test.com') {
      return Usuario(
        uid: 'u2',
        nombre: 'Evaluador Prueba',
        email: email,
        rol: UserRole.evaluador,
        estado: AccountStatus.active,
      );
    }

    if (email == 'coordinador@test.com') {
      return Usuario(
        uid: 'u3',
        nombre: 'Coordinador Prueba',
        email: email,
        rol: UserRole.coordinador,
        estado: AccountStatus.active,
      );
    }

    if (email == 'bloqueado@test.com') {
      return Usuario(
        uid: 'u4',
        nombre: 'Usuario Bloqueado',
        email: email,
        rol: UserRole.investigador,
        estado: AccountStatus.blocked,
      );
    }

    if (email == 'pendiente@test.com') {
      return Usuario(
        uid: 'u5',
        nombre: 'Usuario Pendiente',
        email: email,
        rol: UserRole.investigador,
        estado: AccountStatus.pendingApproval,
      );
    }

    return null;
  }
}