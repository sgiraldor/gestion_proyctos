import 'package:firebase_core/firebase_core.dart';
<<<<<<< HEAD
import 'package:flutter/material.dart';

import 'enums/account_status.dart';
import 'firebase_options.dart';
import 'models/usuario.dart';
import 'pages/blocked_page.dart';
import 'pages/home_page.dart';
=======
import 'firebase_options.dart';
>>>>>>> 70233f51266470e69ae422e749a14accd5b9113f
import 'pages/login_page.dart';
import 'pages/pending_page.dart';
import 'services/auth_service.dart';
import 'services/permission_service.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestion de Investigacion',
      theme: AppTheme.light(),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  static final AuthService _authService = AuthService();
  static final PermissionService _permissionService = PermissionService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final firebaseUser = snapshot.data;
        if (firebaseUser == null) {
          return LoginPage(authService: _authService);
        }

        return FutureBuilder<Usuario?>(
          future: _authService.cargarPerfil(firebaseUser.uid),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (profileSnapshot.hasError || profileSnapshot.data == null) {
              return LoginPage(authService: _authService);
            }

            final usuario = profileSnapshot.data!;
            if (_permissionService.estaBloqueado(usuario)) {
              return const BlockedPage();
            }
            if (_permissionService.estaPendienteAprobacion(usuario)) {
              return const PendingPage();
            }
            if (usuario.estado == AccountStatus.inactive ||
                !_permissionService.puedeIngresarSistema(usuario)) {
              return const BlockedPage();
            }
            return HomePage(usuario: usuario);
          },
        );
      },
    );
  }
}
