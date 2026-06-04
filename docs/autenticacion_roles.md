# Autenticacion, Roles y Permisos

La autenticacion usa Firebase Auth con correo y contrasena. El perfil funcional esta en Firestore:

```text
users/{uid}
```

Campos principales:

- `uid`: identificador de Firebase Auth.
- `name`: nombre visible.
- `email`: correo.
- `role`: `investigador`, `evaluador` o `coordinador`.
- `status`: `active`, `inactive`, `blocked` o `pendingApproval`.
- `createdAt`: fecha de creacion.
- `lastLoginAt`: ultimo inicio de sesion.

Permisos principales:

- Investigador activo: crea proyectos, integrantes, entregables y avances.
- Evaluador activo: registra revisiones si no participa en el proyecto.
- Coordinador activo: administra usuarios y supervisa proyectos.
- Bloqueado, inactivo o pendiente: no entra al sistema interno.
