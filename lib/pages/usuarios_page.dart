import 'package:flutter/material.dart';

import '../enums/account_status.dart';
import '../enums/user_role.dart';
import '../models/usuario.dart';
import '../services/firestore_service.dart';
import '../utils/app_theme.dart';
import '../validators/login_validator.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  static final _firestoreService = FirestoreService();

  void _mostrarFormularioUsuario() {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController();
    final emailController = TextEditingController();
    var rol = UserRole.investigador;
    var estado = AccountStatus.active;
    var guardando = false;
    String? errorFormulario;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Agregar usuario'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return 'El nombre es obligatorio';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Correo',
                          border: OutlineInputBorder(),
                        ),
                        validator: LoginValidator.validarEmail,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<UserRole>(
                        value: rol,
                        decoration: const InputDecoration(
                          labelText: 'Rol',
                          border: OutlineInputBorder(),
                        ),
                        items: UserRole.values
                            .map(
                              (role) => DropdownMenuItem(
                                value: role,
                                child: Text(role.label),
                              ),
                            )
                            .toList(),
                        onChanged: guardando
                            ? null
                            : (value) {
                                if (value != null) {
                                  setDialogState(() => rol = value);
                                }
                              },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<AccountStatus>(
                        value: estado,
                        decoration: const InputDecoration(
                          labelText: 'Estado',
                          border: OutlineInputBorder(),
                        ),
                        items: AccountStatus.values
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status.label),
                              ),
                            )
                            .toList(),
                        onChanged: guardando
                            ? null
                            : (value) {
                                if (value != null) {
                                  setDialogState(() => estado = value);
                                }
                              },
                      ),
                      if (errorFormulario != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          errorFormulario!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: guardando ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton.icon(
                  onPressed: guardando
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          setDialogState(() {
                            guardando = true;
                            errorFormulario = null;
                          });
                          try {
                            await _firestoreService.crearUsuario(
                              Usuario(
                                uid: '',
                                nombre: nombreController.text.trim(),
                                email: emailController.text.trim(),
                                rol: rol,
                                estado: estado,
                                createdAt: DateTime.now(),
                                lastLoginAt: null,
                              ),
                            );

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Usuario agregado'),
                                ),
                              );
                            }
                          } catch (error) {
                            final mensaje = _mensajeError(error);
                            setDialogState(() => errorFormulario = mensaje);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(mensaje)),
                              );
                            }
                          } finally {
                            if (context.mounted) {
                              setDialogState(() => guardando = false);
                            }
                          }
                        },
                  icon: guardando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.person_add),
                  label: const Text('Agregar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _mensajeError(Object error) {
    final texto = error.toString();
    if (texto.contains('permission-denied')) {
      return 'Firestore rechazo la escritura. Si las reglas ya estan abiertas, revisa que estes en el proyecto gestion-proyectos-invest y que App Check no este forzando Firestore. Detalle: $texto';
    }
    if (texto.contains('unavailable')) {
      return 'Firestore no esta disponible en este momento.';
    }
    return 'No se pudo agregar el usuario';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios'),
      ),
      body: StreamBuilder<List<Usuario>>(
        stream: _firestoreService.usuariosStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('No se pudieron cargar usuarios'));
          }
          final usuarios = snapshot.data ?? [];
          if (usuarios.isEmpty) {
            return const Center(child: Text('No hay usuarios registrados'));
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              final usuario = usuarios[index];
              final esUsuarioBase = usuario.uid.startsWith('usuario-base-');
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.person_outline),
                        ),
                        title: Text(usuario.nombre),
                        subtitle: Text(
                          esUsuarioBase
                              ? '${usuario.email}\nUsuario base de la app'
                              : '${usuario.email}\n${usuario.uid}',
                        ),
                        isThreeLine: true,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<UserRole>(
                              value: usuario.rol,
                              decoration: const InputDecoration(
                                labelText: 'Rol',
                                border: OutlineInputBorder(),
                              ),
                              items: UserRole.values
                                  .map(
                                    (role) => DropdownMenuItem(
                                      value: role,
                                      child: Text(role.label),
                                    ),
                                  )
                                  .toList(),
                              onChanged: esUsuarioBase
                                  ? null
                                  : (role) {
                                      if (role != null) {
                                        _firestoreService.actualizarUsuario(
                                          usuario.copyWith(rol: role),
                                        );
                                      }
                                    },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<AccountStatus>(
                              value: usuario.estado,
                              decoration: const InputDecoration(
                                labelText: 'Estado',
                                border: OutlineInputBorder(),
                              ),
                              items: AccountStatus.values
                                  .map(
                                    (status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(status.label),
                                    ),
                                  )
                                  .toList(),
                              onChanged: esUsuarioBase
                                  ? null
                                  : (status) {
                                      if (status != null) {
                                        _firestoreService.actualizarUsuario(
                                          usuario.copyWith(estado: status),
                                        );
                                      }
                                    },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
