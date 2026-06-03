import 'package:flutter/material.dart';

import '../models/proyecto.dart';
import '../models/revision.dart';
import '../models/integrante.dart';
import '../services/proyecto_service.dart';

class RevisionesPage extends StatefulWidget {
  final Proyecto proyecto;
  final List<Integrante> integrantes;

  const RevisionesPage({
    super.key,
    required this.proyecto,
    required this.integrantes,
  });

  @override
  State<RevisionesPage> createState() => _RevisionesPageState();
}

class _RevisionesPageState extends State<RevisionesPage> {
  final List<Revision> revisiones = [];
  final ProyectoService proyectoService = ProyectoService();

  final String evaluadorId = 'u2';

  void mostrarFormularioRevision() {
    final puedeRevisar = proyectoService.evaluadorPuedeRevisar(
      evaluadorId: evaluadorId,
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
              title: const Text('Nueva revisión'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: conceptoController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Concepto de la revisión',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('¿Aprobado?'),
                      value: aprobado,
                      onChanged: (value) {
                        setDialogState(() {
                          aprobado = value;
                        });
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
                  onPressed: () {
                    final concepto = conceptoController.text.trim();

                    if (!proyectoService.revisionTieneConcepto(concepto)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('La revisión debe tener concepto'),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      revisiones.add(
                        Revision(
                          id: 'R${revisiones.length + 1}',
                          proyectoId: widget.proyecto.id,
                          evaluadorId: evaluadorId,
                          concepto: concepto,
                          aprobado: aprobado,
                          fechaRevision: DateTime.now(),
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
        title: const Text('Revisiones'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: mostrarFormularioRevision,
        child: const Icon(Icons.add),
      ),
      body: revisiones.isEmpty
          ? const Center(
              child: Text('No hay revisiones registradas'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: revisiones.length,
              itemBuilder: (context, index) {
                final revision = revisiones[index];

                return Card(
                  child: ListTile(
                    leading: Icon(
                      revision.aprobado
                          ? Icons.check_circle
                          : Icons.warning,
                      color: revision.aprobado ? Colors.green : Colors.orange,
                    ),
                    title: Text(
                      revision.aprobado ? 'Aprobado' : 'Con ajustes',
                    ),
                    subtitle: Text(
                      '${revision.concepto}\n'
                      'Fecha: ${formatearFecha(revision.fechaRevision)}',
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}