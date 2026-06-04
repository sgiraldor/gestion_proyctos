import 'package:flutter/material.dart';

import '../enums/project_status.dart';
import '../models/avance.dart';
import '../models/proyecto.dart';
import '../services/firestore_service.dart';
import '../utils/app_theme.dart';
import '../validators/proyecto_validator.dart';

class AvancesPage extends StatefulWidget {
  final Proyecto proyecto;

  const AvancesPage({
    super.key,
    required this.proyecto,
  });

  @override
  State<AvancesPage> createState() => _AvancesPageState();
}

class _AvancesPageState extends State<AvancesPage> {
  final _firestoreService = FirestoreService();

  void _mostrarFormularioAvance() {
    final descripcionController = TextEditingController();
    final porcentajeController = TextEditingController(
      text: widget.proyecto.porcentajeAvance.toStringAsFixed(0),
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nuevo avance'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: descripcionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Descripcion del avance',
                      border: OutlineInputBorder(),
                    ),
                    validator: ProyectoValidator.validarDescripcion,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: porcentajeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Porcentaje de avance',
                      helperText: 'Puedes escribir un valor manual, por ejemplo 30',
                      border: OutlineInputBorder(),
                    ),
                    validator: _validarPorcentaje,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }
                final porcentaje = double.parse(
                  porcentajeController.text.trim().replaceAll(',', '.'),
                );
                await _firestoreService.guardarAvance(
                  Avance(
                    id: '',
                    proyectoId: widget.proyecto.id,
                    descripcion: descripcionController.text.trim(),
                    porcentaje: porcentaje,
                    fechaRegistro: DateTime.now(),
                  ),
                );
                await _firestoreService.actualizarAvanceProyecto(
                  widget.proyecto.id,
                  porcentaje,
                );
                await _firestoreService.actualizarEstadoProyecto(
                  widget.proyecto.id,
                  ProjectStatus.enRevision.name,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  String? _validarPorcentaje(String? value) {
    final text = (value ?? '').trim().replaceAll(',', '.');
    if (text.isEmpty) {
      return 'El porcentaje es obligatorio';
    }
    final porcentaje = double.tryParse(text);
    if (porcentaje == null) {
      return 'Ingresa un numero valido';
    }
    if (porcentaje < 0 || porcentaje > 100) {
      return 'El porcentaje debe estar entre 0 y 100';
    }
    return null;
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avances'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarFormularioAvance,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Avance>>(
        stream: _firestoreService.avancesStream(widget.proyecto.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final avances = snapshot.data ?? [];
          if (avances.isEmpty) {
            return const _EmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: avances.length,
            itemBuilder: (context, index) {
              final avance = avances[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${avance.porcentaje.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              avance.descripcion,
                              style: const TextStyle(
                                color: AppTheme.ink,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Fecha: ${_formatearFecha(avance.fechaRegistro)}',
                              style: const TextStyle(
                                color: AppTheme.secondaryInk,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.analytics_outlined, size: 42, color: AppTheme.secondaryInk),
            SizedBox(height: 12),
            Text(
              'No hay avances registrados',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.ink,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
