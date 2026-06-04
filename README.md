# Proyecto Final Movil - Equipo 7

Aplicacion Flutter para la gestion de proyectos de investigacion. Implementa autenticacion con Firebase Auth, perfiles y roles en Cloud Firestore, reglas de negocio, persistencia local con `SharedPreferences`, sincronizacion local/remota y pruebas automatizadas.

## Funcionalidades

- Inicio y cierre de sesion con Firebase Auth.
- Perfil de usuario en `users/{uid}` con `role`, `status`, `createdAt` y `lastLoginAt`.
- Roles: `investigador`, `evaluador`, `coordinador`.
- Estados de cuenta: `active`, `inactive`, `blocked`, `pendingApproval`.
- Proyectos, integrantes, entregables, avances y revisiones en Firestore.
- Cache local de proyectos y sincronizacion manual desde la pantalla de proyectos.
- Reglas de negocio:
  - El proyecto debe tener minimo un responsable.
  - El evaluador no puede revisar proyectos donde participa.
  - Una revision debe tener concepto.
  - Un entregable aprobado no puede reemplazarse.
  - Entregables enviados despues de la fecha limite quedan marcados como tardios.

## Firebase

El proyecto Firebase configurado es `gestion-proyectos-invest`.

Para probar la app:

1. Crear usuarios en Firebase Authentication con correo y contrasena.
2. Crear o ajustar el documento `users/{uid}` en Firestore:

```json
{
  "uid": "UID_DEL_USUARIO",
  "name": "Ana Perez",
  "email": "ana@test.com",
  "role": "coordinador",
  "status": "active",
  "createdAt": "2026-06-03T10:30:00",
  "lastLoginAt": "2026-06-03T11:00:00"
}
```

3. Publicar reglas con `firebase deploy --only firestore:rules`.

Usuarios de prueba creados:

```text
investigador@test.com / 123456 / investigador
evaluador@test.com     / 123456 / evaluador
samuel@gmail.com       / 123456 / coordinador
```

Flujo recomendado:

```text
investigador@test.com -> crear proyecto -> agregar responsable -> crear entregable -> enviar avance
evaluador@test.com    -> registrar revision -> cambia estado a Aprobado o Con ajustes
```

## Comandos

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

El APK de release se genera en:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Crashlytics

Crashlytics no se incluye en esta version porque es opcional segun el punto 7 de la rubrica y no reemplaza los requisitos obligatorios.
