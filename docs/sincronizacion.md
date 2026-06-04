# Persistencia Local y Sincronizacion

La app usa `SharedPreferences` como cache local. `LocalRepository` guarda listas JSON de proyectos, integrantes, entregables, avances y revisiones.

`SyncStatus` permite identificar datos:

- `pendingSync`: creado localmente y pendiente de subir.
- `synced`: confirmado en Firestore.
- `failedSync`: reservado para errores de sincronizacion.

La pantalla de proyectos tiene un boton de sincronizacion. `SyncService` sube proyectos pendientes y despues refresca el cache local desde Firestore.

Este enfoque permite demostrar offline-first sin introducir una base de datos adicional.
