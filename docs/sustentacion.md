# Guia de Sustentacion

Puntos para explicar:

- Firebase Auth autentica; Firestore define rol y estado.
- `AuthGate` protege pantallas internas y redirige por estado.
- `PermissionService` concentra permisos por rol.
- `ProyectoService` contiene reglas de negocio comprobables por tests.
- `LocalRepository` guarda cache local y `SyncService` sincroniza con Firestore.
- `firestore.rules` refuerza autorizacion en servidor.
- Las pruebas cubren validadores, permisos y reglas de negocio.

Preguntas esperadas:

- Que pasa si un usuario nuevo inicia sesion: se crea perfil pendiente de aprobacion.
- Quien cambia roles: el coordinador desde `UsuariosPage`.
- Que pasa sin red al crear proyecto: queda en cache local como `pendingSync`.
- Por que no hay Crashlytics: es opcional y no reemplaza requisitos obligatorios.

Credenciales de prueba:

- `investigador@test.com / 123456`
- `evaluador@test.com / 123456`
- `samuel@gmail.com / 123456`
