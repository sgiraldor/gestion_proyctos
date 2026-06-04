import 'package:flutter/material.dart';

import '../enums/user_role.dart';
import '../models/entregable.dart';
import '../models/proyecto.dart';
import '../models/usuario.dart';
import '../services/firestore_service.dart';
import '../services/proyecto_service.dart';
import '../utils/app_theme.dart';
import '../validators/entregable_validator.dart';

class EntregablesPage extends StatefulWidget {
  final Proyecto proyecto;
  final Usuario usuario;

  const EntregablesPage({
    super.key,
    required this.proyecto,
    required this.usuario,
  });

  @override
  State<EntregablesPage> createState() => _EntregablesPageState();
}

class _EntregablesPageState extends State<EntregablesPage> {
  final _proyectoService = ProyectoService();
  final _firestoreService = FirestoreService();

  bool get _puedeCrearOEnviar {
    return widget.usuario.rol == UserRole.investigador ||
        widget.usuario.rol == UserRole.coordinador;
  }

  bool get _puedeAprobar {
    return widget.usuario.rol == UserRole.evaluador ||
        widget.usuario.rol == UserRole.coordinador;
  }

  Future<void> _actualizarAvanceProyecto() async {
    final entregables = await _firestoreService.cargarEntregables(
      widget.proyecto.id,
    );
    final avance = _proyectoService.calcularPorcentajeAvance(entregables);
    await _firestoreService.actualizarAvanceProyecto(
      widget.proyecto.id,
      avance,
    );
  }

  void _mostrarFormularioEntregable() {
    final nombreController = TextEditingController();
    final descripcionController = TextEditingController();
    final diasController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nuevo entregable'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                    validator: EntregableValidator.validarNombre,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descripcionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripcion',
                      border: OutlineInputBorder(),
                    ),
                    validator: EntregableValidator.validarDescripcion,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: diasController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Dias para la fecha limite',
                      border: OutlineInputBorder(),
                    ),
                    validator: EntregableValidator.validarDiasLimite,
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
                final dias = int.parse(diasController.text.trim());
                await _firestoreService.guardarEntregable(
                  Entregable(
                    id: '',
                    proyectoId: widget.proyecto.id,
                    nombre: nombreController.text.trim(),
                    descripcion: descripcionController.text.trim(),
                    fechaLimite: DateTime.now().add(Duration(days: dias)),
                    aprobado: false,
                    tardio: false,
                  ),
                );
                await _actualizarAvanceProyecto();
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

  Future<void> _enviarEntregable(Entregable entregable) async {
    final fechaEntrega = DateTime.now();
    final esTardio = _proyectoService.entregableEsTardio(
      fechaLimite: entregable.fechaLimite,
      fechaEntrega: fechaEntrega,
    );
    await _firestoreService.guardarEntregable(
      entregable.copyWith(
        fechaEntrega: fechaEntrega,
        tardio: esTardio,
      ),
    );
    await _actualizarAvanceProyecto();
  }

  Future<void> _aprobarEntregable(Entregable entregable) async {
    if (entregable.fechaEntrega == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero debes enviar el entregable')),
      );
      return;
    }
    await _firestoreService.guardarEntregable(
      entregable.copyWith(aprobado: true),
    );
    await _actualizarAvanceProyecto();
  }

  void _reemplazarEntregable(Entregable entregable) {
    if (!_proyectoService.puedeReemplazarEntregable(entregable)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Un entregable aprobado no puede reemplazarse'),
        ),
      );
      return;
    }

    final nuevaDescripcionController = TextEditingController(
      text: entregable.descripcion,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reemplazar entregable'),
          content: TextField(
            controller: nuevaDescripcionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Nueva descripcion',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nuevaDescripcion =
                    nuevaDescripcionController.text.trim();
                if (nuevaDescripcion.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('La descripcion no puede estar vacia'),
                    ),
                  );
                  return;
                }

                await _firestoreService.guardarEntregable(
                  entregable.copyWith(
                    descripcion: nuevaDescripcion,
                    clearFechaEntrega: true,
                    aprobado: false,
                    tardio: false,
                  ),
                );
                await _actualizarAvanceProyecto();
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

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entregables'),
      ),
      floatingActionButton: _puedeCrearOEnviar
          ? FloatingActionButton(
              onPressed: _mostrarFormularioEntregable,
              child: const Icon(Icons.add),
            )
          : null,
      body: StreamBuilder<List<Entregable>>(
        stream: _firestoreService.entregablesStream(widget.proyecto.id),
        builder: (context, snapshot) {
          final entregables = snapshot.data ?? [];
          final avance = _proyectoService.calcularPorcentajeAvance(entregables);

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Porcentaje de avance calculado',
                        style: TextStyle(
                          color: AppTheme.ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value:
                                    (avance / 100).clamp(0.0, 1.0).toDouble(),
                                minHeight: 8,
                                backgroundColor: AppTheme.separator,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${avance.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: AppTheme.ink,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: entregables.isEmpty
                    ? const Center(
                        child: Text('No hay entregables registrados'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: entregables.length,
                        itemBuilder: (context, index) {
                          final entregable = entregables[index];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Icon(
                                entregable.aprobado
                                    ? Icons.check_circle_outline
                                    : Icons.assignment_outlined,
                                color: entregable.aprobado
                                    ? AppTheme.success
                                    : AppTheme.primary,
                              ),
                              title: Text(entregable.nombre),
                              subtitle: Text(
                                '${entregable.descripcion}\n'
                                'Limite: ${_formatearFecha(entregable.fechaLimite)}\n'
                                'Estado: ${entregable.fechaEntrega == null ? 'Pendiente' : 'Enviado'}'
                                '${entregable.aprobado ? ' - Aprobado' : ''}'
                                '${entregable.tardio ? ' - Tardio' : ''}',
                              ),
                              isThreeLine: true,
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'enviar') {
                                    _enviarEntregable(entregable);
                                  }
                                  if (value == 'aprobar') {
                                    _aprobarEntregable(entregable);
                                  }
                                  if (value == 'reemplazar') {
                                    _reemplazarEntregable(entregable);
                                  }
                                },
                                itemBuilder: (context) => [
                                  if (_puedeCrearOEnviar &&
                                      entregable.fechaEntrega == null)
                                    const PopupMenuItem(
                                      value: 'enviar',
                                      child: Text('Enviar'),
                                    ),
                                  if (_puedeAprobar &&
                                      entregable.fechaEntrega != null &&
                                      !entregable.aprobado)
                                    const PopupMenuItem(
                                      value: 'aprobar',
                                      child: Text('Aprobar'),
                                    ),
                                  if (_puedeCrearOEnviar)
                                    const PopupMenuItem(
                                      value: 'reemplazar',
                                      child: Text('Reemplazar'),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
