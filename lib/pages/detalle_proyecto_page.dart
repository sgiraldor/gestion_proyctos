import 'package:flutter/material.dart';

import '../enums/project_status.dart';
import '../models/integrante.dart';
import '../models/proyecto.dart';
import '../models/usuario.dart';
import '../services/firestore_service.dart';
import '../services/proyecto_service.dart';
import '../utils/app_theme.dart';
import 'avances_page.dart';
import 'entregables_page.dart';
import 'revisiones_page.dart';

class DetalleProyectoPage extends StatefulWidget {
  final Proyecto proyecto;
  final Usuario usuario;

  const DetalleProyectoPage({
    super.key,
    required this.proyecto,
    required this.usuario,
  });

  @override
  State<DetalleProyectoPage> createState() => _DetalleProyectoPageState();
}

class _DetalleProyectoPageState extends State<DetalleProyectoPage> {
  final _firestoreService = FirestoreService();
  final _proyectoService = ProyectoService();

  void _mostrarFormularioIntegrante() {
    final rolController = TextEditingController();
    List<Usuario> usuarios = const [];
    String? usuarioSeleccionadoUid;
    bool esResponsable = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Agregar integrante'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StreamBuilder<List<Usuario>>(
                      stream: _firestoreService.usuariosStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return const Text(
                            'No se pudieron cargar los usuarios',
                          );
                        }
                        usuarios = snapshot.data ?? [];
                        if (usuarios.isEmpty) {
                          return const Text(
                            'No hay usuarios registrados para agregar.',
                          );
                        }

                        return DropdownButtonFormField<String>(
                          value: usuarioSeleccionadoUid,
                          decoration: const InputDecoration(
                            labelText: 'Usuario',
                            border: OutlineInputBorder(),
                          ),
                          items: usuarios.map((usuario) {
                            return DropdownMenuItem(
                              value: usuario.uid,
                              child: Text(
                                '${usuario.nombre} - ${usuario.email}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (uid) {
                            setDialogState(() {
                              usuarioSeleccionadoUid = uid;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: rolController,
                      decoration: const InputDecoration(
                        labelText: 'Rol en el proyecto',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    CheckboxListTile(
                      value: esResponsable,
                      title: const Text('Responsable del proyecto'),
                      onChanged: (value) {
                        setDialogState(() => esResponsable = value ?? false);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final rol = rolController.text.trim();
                    Usuario? usuarioSeleccionado;
                    for (final usuario in usuarios) {
                      if (usuario.uid == usuarioSeleccionadoUid) {
                        usuarioSeleccionado = usuario;
                        break;
                      }
                    }

                    if (usuarioSeleccionado == null || rol.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Usuario y rol son obligatorios'),
                        ),
                      );
                      return;
                    }

                    try {
                      await _firestoreService.guardarIntegrante(
                        Integrante(
                          id: '',
                          proyectoId: widget.proyecto.id,
                          usuarioId: usuarioSeleccionado.uid,
                          nombre: usuarioSeleccionado.nombre,
                          rolEnProyecto: rol,
                          esResponsable: esResponsable,
                        ),
                      );
                      if (esResponsable) {
                        await _firestoreService.actualizarEstadoProyecto(
                          widget.proyecto.id,
                          ProjectStatus.activo.name,
                        );
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Integrante guardado'),
                          ),
                        );
                      }
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'No se pudo guardar el integrante. Verifica permisos y conexion.',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.proyecto.titulo),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarFormularioIntegrante,
        child: const Icon(Icons.person_add),
      ),
      body: StreamBuilder<Proyecto>(
        stream: _firestoreService.proyectoStream(widget.proyecto.id),
        initialData: widget.proyecto,
        builder: (context, proyectoSnapshot) {
          final proyecto = proyectoSnapshot.data ?? widget.proyecto;
          return StreamBuilder<List<Integrante>>(
            stream: _firestoreService.integrantesStream(proyecto.id),
            builder: (context, snapshot) {
              final integrantes = snapshot.data ?? [];
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            proyecto.titulo,
                            style: const TextStyle(
                              color: AppTheme.ink,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            proyecto.descripcion,
                            style: const TextStyle(
                              color: AppTheme.secondaryInk,
                              fontSize: 15,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _StatusPill(label: _textoEstado(proyecto.estado)),
                              const Spacer(),
                              Text(
                                '${proyecto.porcentajeAvance.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  color: AppTheme.ink,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              minHeight: 8,
                              value: (proyecto.porcentajeAvance / 100)
                                  .clamp(0.0, 1.0)
                                  .toDouble(),
                              backgroundColor: AppTheme.separator,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: Icon(
                        _proyectoService.tieneResponsable(integrantes)
                            ? Icons.check_circle_outline
                            : Icons.warning_amber_rounded,
                        color: _proyectoService.tieneResponsable(integrantes)
                            ? AppTheme.success
                            : AppTheme.warning,
                      ),
                      title: const Text('Regla de negocio'),
                      subtitle: Text(
                        _proyectoService.tieneResponsable(integrantes)
                            ? 'El proyecto tiene responsable.'
                            : 'El proyecto debe tener minimo un responsable.',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 8,
                            ),
                            child: Text(
                              'Integrantes',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (integrantes.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(4),
                              child: Text('No hay integrantes registrados.'),
                            )
                          else
                            ...integrantes.map((integrante) {
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  integrante.esResponsable
                                      ? Icons.star_rounded
                                      : Icons.person_outline,
                                  color: integrante.esResponsable
                                      ? AppTheme.warning
                                      : AppTheme.primary,
                                ),
                                title: Text(integrante.nombre),
                                subtitle: Text(
                                  integrante.rolEnProyecto,
                                ),
                                trailing: integrante.esResponsable
                                    ? const Chip(label: Text('Responsable'))
                                    : null,
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ActionTile(
                    icon: Icons.assignment_outlined,
                    title: 'Gestionar entregables',
                    subtitle: 'Crear, enviar y aprobar entregables',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EntregablesPage(
                            proyecto: proyecto,
                            usuario: widget.usuario,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _ActionTile(
                    icon: Icons.analytics_outlined,
                    title: 'Enviar avance',
                    subtitle: 'Registrar porcentaje y descripcion',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AvancesPage(proyecto: proyecto),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _ActionTile(
                    icon: Icons.fact_check_outlined,
                    title: 'Registrar revisiones',
                    subtitle: 'Evaluar concepto y resultado',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RevisionesPage(
                            proyecto: proyecto,
                            usuario: widget.usuario,
                            integrantes: integrantes,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _textoEstado(ProjectStatus estado) {
    switch (estado) {
      case ProjectStatus.borrador:
        return 'Borrador';
      case ProjectStatus.activo:
        return 'Activo';
      case ProjectStatus.enRevision:
        return 'En revision';
      case ProjectStatus.aprobado:
        return 'Aprobado';
      case ProjectStatus.conAjustes:
        return 'Con ajustes';
      case ProjectStatus.finalizado:
        return 'Finalizado';
    }
  }
}

class _StatusPill extends StatelessWidget {
  final String label;

  const _StatusPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.primary,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppTheme.secondaryInk,
        ),
        onTap: onTap,
      ),
    );
  }
}
