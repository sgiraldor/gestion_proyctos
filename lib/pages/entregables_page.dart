import 'package:flutter/material.dart';

import '../models/proyecto.dart';
import '../models/entregable.dart';
import '../services/proyecto_service.dart';

class EntregablesPage extends StatefulWidget {
  final Proyecto proyecto;

  const EntregablesPage({
    super.key,
    required this.proyecto,
  });

  @override
  State<EntregablesPage> createState() => _EntregablesPageState();
}

class _EntregablesPageState extends State<EntregablesPage> {
  final List<Entregable> entregables = [];
  final ProyectoService proyectoService = ProyectoService();

  void mostrarFormularioEntregable() {
    final nombreController = TextEditingController();
    final descripcionController = TextEditingController();
    final diasController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nuevo entregable'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descripcionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: diasController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Días para la fecha límite',
                    border: OutlineInputBorder(),
                  ),
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
                final nombre = nombreController.text.trim();
                final descripcion = descripcionController.text.trim();
                final dias = int.tryParse(diasController.text.trim());

                if (nombre.isEmpty || descripcion.isEmpty || dias == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Todos los campos son obligatorios'),
                    ),
                  );
                  return;
                }

                setState(() {
                  entregables.add(
                    Entregable(
                      id: 'E${entregables.length + 1}',
                      proyectoId: widget.proyecto.id,
                      nombre: nombre,
                      descripcion: descripcion,
                      fechaLimite: DateTime.now().add(Duration(days: dias)),
                      aprobado: false,
                      tardio: false,
                    ),
                  );
                });

                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void enviarEntregable(int index) {
    final entregable = entregables[index];
    final fechaEntrega = DateTime.now();

    final esTardio = proyectoService.entregableEsTardio(
      fechaLimite: entregable.fechaLimite,
      fechaEntrega: fechaEntrega,
    );

    setState(() {
      entregables[index] = Entregable(
        id: entregable.id,
        proyectoId: entregable.proyectoId,
        nombre: entregable.nombre,
        descripcion: entregable.descripcion,
        fechaLimite: entregable.fechaLimite,
        fechaEntrega: fechaEntrega,
        aprobado: entregable.aprobado,
        tardio: esTardio,
      );
    });
  }

  void aprobarEntregable(int index) {
    final entregable = entregables[index];

    if (entregable.fechaEntrega == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero debes enviar el entregable'),
        ),
      );
      return;
    }

    setState(() {
      entregables[index] = Entregable(
        id: entregable.id,
        proyectoId: entregable.proyectoId,
        nombre: entregable.nombre,
        descripcion: entregable.descripcion,
        fechaLimite: entregable.fechaLimite,
        fechaEntrega: entregable.fechaEntrega,
        aprobado: true,
        tardio: entregable.tardio,
      );
    });
  }

  void reemplazarEntregable(int index) {
    final entregable = entregables[index];

    if (!proyectoService.puedeReemplazarEntregable(entregable)) {
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
              labelText: 'Nueva descripción',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final nuevaDescripcion =
                    nuevaDescripcionController.text.trim();

                if (nuevaDescripcion.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('La descripción no puede estar vacía'),
                    ),
                  );
                  return;
                }

                setState(() {
                  entregables[index] = Entregable(
                    id: entregable.id,
                    proyectoId: entregable.proyectoId,
                    nombre: entregable.nombre,
                    descripcion: nuevaDescripcion,
                    fechaLimite: entregable.fechaLimite,
                    fechaEntrega: null,
                    aprobado: false,
                    tardio: false,
                  );
                });

                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  double calcularAvance() {
    return proyectoService.calcularPorcentajeAvance(entregables);
  }

  String formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    final avance = calcularAvance();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text('Entregables'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: mostrarFormularioEntregable,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: ListTile(
              leading: const Icon(Icons.percent),
              title: const Text('Porcentaje de avance calculado'),
              subtitle: Text('${avance.toStringAsFixed(0)}%'),
            ),
          ),
          Expanded(
            child: entregables.isEmpty
                ? const Center(
                    child: Text('No hay entregables registrados'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: entregables.length,
                    itemBuilder: (context, index) {
                      final entregable = entregables[index];

                      return Card(
                        child: ListTile(
                          leading: Icon(
                            entregable.aprobado
                                ? Icons.check_circle
                                : Icons.assignment,
                            color: entregable.aprobado
                                ? Colors.green
                                : Colors.indigo,
                          ),
                          title: Text(entregable.nombre),
                          subtitle: Text(
                            '${entregable.descripcion}\n'
                            'Límite: ${formatearFecha(entregable.fechaLimite)}\n'
                            'Estado: ${entregable.fechaEntrega == null ? 'Pendiente' : 'Enviado'}'
                            '${entregable.aprobado ? ' - Aprobado' : ''}'
                            '${entregable.tardio ? ' - Tardío' : ''}',
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'enviar') {
                                enviarEntregable(index);
                              }

                              if (value == 'aprobar') {
                                aprobarEntregable(index);
                              }

                              if (value == 'reemplazar') {
                                reemplazarEntregable(index);
                              }
                            },
                            itemBuilder: (context) => [
                              if (entregable.fechaEntrega == null)
                                const PopupMenuItem(
                                  value: 'enviar',
                                  child: Text('Enviar'),
                                ),
                              if (entregable.fechaEntrega != null &&
                                  !entregable.aprobado)
                                const PopupMenuItem(
                                  value: 'aprobar',
                                  child: Text('Aprobar'),
                                ),
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
      ),
    );
  }
}