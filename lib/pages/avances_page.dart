import 'package:flutter/material.dart';

import '../models/proyecto.dart';
import '../models/avance.dart';

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
  final List<Avance> avances = [];

  void mostrarFormularioAvance() {
    final descripcionController = TextEditingController();
    final porcentajeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nuevo avance'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descripcionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descripción del avance',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: porcentajeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Porcentaje de avance',
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
                final descripcion =
                    descripcionController.text.trim();

                final porcentaje =
                    double.tryParse(
                      porcentajeController.text.trim(),
                    );

                if (descripcion.isEmpty || porcentaje == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Descripción y porcentaje son obligatorios',
                      ),
                    ),
                  );
                  return;
                }

                if (porcentaje < 0 || porcentaje > 100) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'El porcentaje debe estar entre 0 y 100',
                      ),
                    ),
                  );
                  return;
                }

                setState(() {
                  avances.add(
                    Avance(
                      id: 'A${avances.length + 1}',
                      proyectoId: widget.proyecto.id,
                      descripcion: descripcion,
                      porcentaje: porcentaje,
                      fechaRegistro: DateTime.now(),
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

  String formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text('Avances'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: mostrarFormularioAvance,
        child: const Icon(Icons.add),
      ),
      body: avances.isEmpty
          ? const Center(
              child: Text(
                'No hay avances registrados',
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: avances.length,
              itemBuilder: (context, index) {
                final avance = avances[index];

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.analytics),
                    title: Text(
                      '${avance.porcentaje.toStringAsFixed(0)}%',
                    ),
                    subtitle: Text(
                      '${avance.descripcion}\n'
                      'Fecha: ${formatearFecha(avance.fechaRegistro)}',
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}