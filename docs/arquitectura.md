# Arquitectura

La aplicacion separa responsabilidades en carpetas:

- `models/`: entidades serializables para Firestore y cache local.
- `pages/`: pantallas principales y navegacion por flujo.
- `services/`: autenticacion, permisos, Firestore, sincronizacion y reglas de negocio.
- `data/`: repositorio local basado en `SharedPreferences`.
- `validators/`: validacion de formularios.
- `widgets/`: componentes reutilizables de UI.
- `test/`: pruebas unitarias de validadores, permisos y reglas.

## Flujo

`main.dart` inicializa Firebase y muestra `AuthGate`. Si no hay sesion, se muestra `LoginPage`. Si hay sesion, se lee `users/{uid}` y se redirige a `HomePage`, `BlockedPage` o `PendingPage` segun `status`.

Las pantallas no deberian acceder a Firebase Auth directamente. Los datos de negocio pasan por `FirestoreService`, `LocalRepository` y `SyncService`.
