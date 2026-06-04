import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../enums/account_status.dart';
import '../enums/user_role.dart';
import '../firebase_options.dart';
import '../models/usuario.dart';

class AuthService {
  AuthService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  Stream<firebase_auth.User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();

  firebase_auth.User? get currentUser => _firebaseAuth.currentUser;

  Future<Usuario> login(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw const AuthException('No se pudo iniciar sesion');
    }

    final usuario = await cargarPerfil(user.uid);
    if (usuario == null) {
      final now = DateTime.now();
      final nuevoPerfil = Usuario(
        uid: user.uid,
        nombre: user.displayName ?? user.email ?? 'Usuario',
        email: user.email ?? email.trim(),
        rol: UserRole.investigador,
        estado: AccountStatus.pendingApproval,
        createdAt: now,
        lastLoginAt: now,
      );
      await guardarPerfil(nuevoPerfil);
      return nuevoPerfil;
    }

    final actualizado = usuario.copyWith(lastLoginAt: DateTime.now());
    await guardarPerfil(actualizado);
    return actualizado;
  }

  Future<void> logout() {
    return _firebaseAuth.signOut();
  }

  Future<Usuario> crearUsuario({
    required String nombre,
    required String email,
    required String password,
    required UserRole rol,
    required AccountStatus estado,
  }) async {
    final secondaryAuth = await _secondaryAuth();
    firebase_auth.User? user;
    try {
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      user = credential.user;
      if (user == null) {
        throw const AuthException('No se pudo crear el usuario');
      }

      await user.updateDisplayName(nombre.trim());
    } finally {
      await secondaryAuth.signOut();
    }

    final createdUser = user;
    if (createdUser == null) {
      throw const AuthException('No se pudo crear el usuario');
    }

    final now = DateTime.now();
    final usuario = Usuario(
      uid: createdUser.uid,
      nombre: nombre.trim(),
      email: createdUser.email ?? email.trim(),
      rol: rol,
      estado: estado,
      createdAt: now,
      lastLoginAt: null,
    );
    await guardarPerfil(usuario);
    return usuario;
  }

  Future<Usuario?> cargarPerfil(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return Usuario.fromJson({
      'uid': uid,
      ...doc.data()!,
    });
  }

  Future<void> guardarPerfil(Usuario usuario) async {
    await _firestore.collection('users').doc(usuario.uid).set(
          usuario.toJson(),
          SetOptions(merge: true),
        );
  }

  Future<firebase_auth.FirebaseAuth> _secondaryAuth() async {
    const appName = 'user-admin';
    FirebaseApp app;
    try {
      app = Firebase.app(appName);
    } catch (_) {
      app = await Firebase.initializeApp(
        name: appName,
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    return firebase_auth.FirebaseAuth.instanceFor(app: app);
  }

  String mensajeError(Object error) {
    if (error is firebase_auth.FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'Ese correo ya esta registrado';
        case 'invalid-email':
          return 'El correo no es valido';
        case 'weak-password':
          return 'La contrasena es muy debil';
        case 'operation-not-allowed':
          return 'El registro por correo y contrasena no esta habilitado';
        case 'admin-restricted-operation':
          return 'Firebase no permite crear usuarios desde la app con esta configuracion';
        case 'too-many-requests':
          return 'Firebase bloqueo temporalmente los intentos. Espera un momento e intenta de nuevo';
        case 'user-disabled':
          return 'La cuenta esta deshabilitada';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Correo o contrasena incorrectos';
        case 'network-request-failed':
          return 'No hay conexion para autenticar';
        default:
          return error.message ?? 'Error de autenticacion';
      }
    }
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Firebase Auth creo la cuenta, pero Firestore bloqueo el perfil. Publica las reglas o verifica que tu usuario sea coordinador activo.';
        case 'unavailable':
          return 'Firestore no esta disponible en este momento';
        default:
          return error.message ?? 'Error de Firebase';
      }
    }
    if (error is AuthException) {
      return error.message;
    }
    return 'No se pudo iniciar sesion';
  }
}

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);
}
