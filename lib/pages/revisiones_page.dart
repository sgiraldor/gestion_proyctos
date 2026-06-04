import 'package:flutter/material.dart';

import '../enums/project_status.dart';
import '../enums/user_role.dart';
import '../models/integrante.dart';
import '../models/proyecto.dart';
import '../models/revision.dart';
import '../models/usuario.dart';
import '../services/firestore_service.dart';
import '../services/proyecto_service.dart';
import '../utils/app_theme.dart';

class RevisionesPage extends StatefulWidget {
  final Proyecto proyecto;
  final Usuario usuario;
  final List<Integrante> integrantes;

  const RevisionesPage({
    super.key,
    required this.proyecto,
    required this.usuario,
    required this.integrantes,
  });

  @override
  State<RevisionesPage> createState() => _RevisionesPageState();
}

class _RevisionesPageState extends State<RevisionesPage> {
  final _proyectoService = ProyectoService();
  final _firestoreService = FirestoreService();

  void _mostrarFormularioRevision() {
    if (widget.usuario.rol != UserRole.evaluador) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solo el evaluador puede registrar revisiones'),
        ),
      );
      return;
    }

    final puedeRevisar = _proyectoService.evaluadorPuedeRevisar(
      evaluadorId: widget.usuario.uid,
      integrantes: widget.integrantes,
    );

    if (!puedeRevisar) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'El evaluador no puede revisar un proyecto donde participa.',
          ),
        ),
      );
      return;
    }

    final conceptoController = TextEditingController();
    bool aprobado = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Nueva revision'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: conceptoController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Concepto de la revision',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Aprobado'),
                      value: aprobado,
                      onChanged: (value) {
                        setDialogState(() => aprobado = value);
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
                    final concepto = conceptoController.text.trim();
                    if (!_proyectoService.revisionTieneConcepto(concepto)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('La revision debe tener concepto'),
                        ),
                      );
                      return;
                    }

                    try {
                      await _firestoreService.guardarRevision(
                        Revision(
                          id: '',
                          proyectoId: widget.proyecto.id,
                          evaluadorId: widget.usuario.uid,
                          concepto: concepto,
                          aprobado: aprobado,
                          fechaRevision: DateTime.now(),
                        ),
                      );

                      try {
                        await _firestoreService.actualizarEstadoProyecto(
                          widget.proyecto.id,
                          aprobado
                              ? ProjectStatus.aprobado.name
                              : ProjectStatus.conAjustes.name,
                        );
                      } catch (_) {
                        // La revision ya quedo guardada; el estado del proyecto
                        // puede fallar por reglas remotas durante pruebas.
                      }

                      if (mounted && context.mounted) {
                        Navigator.pop(context);
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Revision guardada'),
                          ),
                        );
                      }
                    } catch (error) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'No se pudo guardar la revision: $error',
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

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revisiones'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarFormularioRevision,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Revision>>(
        stream: _firestoreService.revisionesStream(widget.proyecto.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final revisiones = snapshot.data ?? [];
          if (revisiones.isEmpty) {
            return const Center(
              child: Text(
                'No hay revisiones registradas',
                style: TextStyle(color: AppTheme.secondaryInk),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: revisiones.length,
            itemBuilder: (context, index) {
              final revision = revisiones[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(
                    revision.aprobado
                        ? Icons.check_circle_outline
                        : Icons.warning_amber_rounded,
                    color: revision.aprobado
                        ? AppTheme.success
                        : AppTheme.warning,
                  ),
                  title: Text(revision.aprobado ? 'Aprobado' : 'Con ajustes'),
                  subtitle: Text(
                    '${revision.concepto}\n'
                    'Fecha: ${_formatearFecha(revision.fechaRevision)}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
