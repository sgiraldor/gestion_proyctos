import 'package:flutter/material.dart';

import '../data/local_repository.dart';
import '../enums/project_status.dart';
import '../enums/sync_status.dart';
import '../models/proyecto.dart';
import '../models/usuario.dart';
import '../services/firestore_service.dart';
import '../services/permission_service.dart';
import '../services/sync_service.dart';
import '../utils/app_theme.dart';
import '../validators/proyecto_validator.dart';
import 'detalle_proyecto_page.dart';

class ProyectosPage extends StatefulWidget {
  final Usuario usuario;

  const ProyectosPage({
    super.key,
    required this.usuario,
  });

  @override
  State<ProyectosPage> createState() => _ProyectosPageState();
}

class _ProyectosPageState extends State<ProyectosPage> {
  final _firestoreService = FirestoreService();
  final _localRepository = LocalRepository();
  final _syncService = SyncService();
  final _permissionService = PermissionService();
  List<Proyecto> _cacheLocal = [];
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _cargarCacheLocal();
  }

  Future<void> _cargarCacheLocal() async {
    final proyectos = await _localRepository.cargarProyectos();
    if (mounted) {
      setState(() => _cacheLocal = proyectos);
    }
  }

  Future<void> _agregarProyecto(String titulo, String descripcion) async {
    final proyecto = Proyecto(
      id: '',
      titulo: titulo,
      descripcion: descripcion,
      responsableId: widget.usuario.uid,
      fechaCreacion: DateTime.now(),
      estado: ProjectStatus.borrador,
      porcentajeAvance: 0,
      syncStatus: SyncStatus.pendingSync,
    );

    try {
      final guardado = await _firestoreService.guardarProyecto(proyecto);
      final nuevos = [guardado, ..._cacheLocal.where((p) => p.id != guardado.id)];
      await _localRepository.guardarProyectos(nuevos);
      if (mounted) {
        setState(() => _cacheLocal = nuevos);
      }
    } catch (_) {
      final temporal = proyecto.copyWith(
        id: 'local-${DateTime.now().microsecondsSinceEpoch}',
        syncStatus: SyncStatus.pendingSync,
      );
      final nuevos = [temporal, ..._cacheLocal];
      await _localRepository.guardarProyectos(nuevos);
      if (mounted) {
        setState(() => _cacheLocal = nuevos);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sin conexion: el proyecto queda pendiente'),
          ),
        );
      }
    }
  }

  Future<void> _sincronizar() async {
    setState(() => _syncing = true);
    try {
      await _syncService.sincronizarProyectos();
      await _cargarCacheLocal();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sincronizacion completada')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo sincronizar')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _syncing = false);
      }
    }
  }

  void _mostrarFormularioProyecto() {
    final tituloController = TextEditingController();
    final descripcionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nuevo proyecto'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: tituloController,
                  decoration: const InputDecoration(
                    labelText: 'Titulo del proyecto',
                    border: OutlineInputBorder(),
                  ),
                  validator: ProyectoValidator.validarTitulo,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descripcionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descripcion',
                    border: OutlineInputBorder(),
                  ),
                  validator: ProyectoValidator.validarDescripcion,
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
              onPressed: () {
                if (!formKey.currentState!.validate()) {
                  return;
                }
                _agregarProyecto(
                  tituloController.text.trim(),
                  descripcionController.text.trim(),
                );
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
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

  @override
  Widget build(BuildContext context) {
    final puedeCrear = _permissionService.puedeCrearProyecto(widget.usuario);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proyectos'),
        actions: [
          IconButton(
            tooltip: 'Sincronizar',
            onPressed: _syncing ? null : _sincronizar,
            icon: _syncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
          ),
        ],
      ),
      floatingActionButton: puedeCrear
          ? FloatingActionButton(
              onPressed: _mostrarFormularioProyecto,
              child: const Icon(Icons.add),
            )
          : null,
      body: StreamBuilder<List<Proyecto>>(
        stream: _firestoreService.proyectosStream(),
        builder: (context, snapshot) {
          final proyectos = snapshot.hasData ? snapshot.data! : _cacheLocal;
          if (snapshot.hasData) {
            _localRepository.guardarProyectos(snapshot.data!);
          }
          if (snapshot.connectionState == ConnectionState.waiting &&
              proyectos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError && proyectos.isEmpty) {
            return const _StateMessage(
              icon: Icons.cloud_off_outlined,
              title: 'No se pudieron cargar los proyectos',
              subtitle: 'Revisa la conexion o vuelve a sincronizar.',
            );
          }
          if (proyectos.isEmpty) {
            return const _StateMessage(
              icon: Icons.folder_open_outlined,
              title: 'No hay proyectos registrados',
              subtitle: 'Crea un proyecto para empezar el seguimiento.',
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text(
                puedeCrear
                    ? 'Administra tus proyectos de investigacion'
                    : 'Consulta proyectos disponibles para revision',
                style: const TextStyle(
                  color: AppTheme.secondaryInk,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ...proyectos.map((proyecto) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ProjectCard(
                    proyecto: proyecto,
                    estado: _textoEstado(proyecto.estado),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetalleProyectoPage(
                            proyecto: proyecto,
                            usuario: widget.usuario,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Proyecto proyecto;
  final String estado;
  final VoidCallback onTap;

  const _ProjectCard({
    required this.proyecto,
    required this.estado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progreso =
        (proyecto.porcentajeAvance / 100).clamp(0.0, 1.0).toDouble();

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      proyecto.syncStatus == SyncStatus.synced
                          ? Icons.folder_outlined
                          : Icons.cloud_upload_outlined,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          proyecto.titulo,
                          style: const TextStyle(
                            color: AppTheme.ink,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          estado,
                          style: const TextStyle(
                            color: AppTheme.secondaryInk,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppTheme.secondaryInk,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        minHeight: 7,
                        value: progreso,
                        backgroundColor: AppTheme.separator,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${proyecto.porcentajeAvance.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: AppTheme.ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _StateMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: AppTheme.secondaryInk),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.ink,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.secondaryInk,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
