import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/proyecto.dart';
import '../models/integrante.dart';
import 'entregables_page.dart';
import 'avances_page.dart';
import 'revisiones_page.dart';

class DetalleProyectoPage extends StatefulWidget {
  final Proyecto proyecto;

  const DetalleProyectoPage({super.key, required this.proyecto});

  @override
  State<DetalleProyectoPage> createState() => _DetalleProyectoPageState();
}

class _DetalleProyectoPageState extends State<DetalleProyectoPage> {
  final CollectionReference proyectosRef =
      FirebaseFirestore.instance.collection('proyectos');
  final CollectionReference integrantesRef =
      FirebaseFirestore.instance.collection('integrantes');

  late Stream<List<Integrante>> streamIntegrantes;

  @override
  void initState() {
    super.initState();
    streamIntegrantes = integrantesRef
        .where('proyectoId', isEqualTo: widget.proyecto.id)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Integrante.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  void mostrarFormularioIntegrante() {
    final nombreController = TextEditingController();
    final rolController = TextEditingController();
    bool esResponsable = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Agregar integrante'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del integrante',
                    border: OutlineInputBorder(),
                  ),
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
                    setDialogState(() {
                      esResponsable = value ?? false;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () async {
                  final nombre = nombreController.text.trim();
                  final rol = rolController.text.trim();
                  if (nombre.isEmpty || rol.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nombre y rol obligatorios')));
                    return;
                  }

                  await integrantesRef.add({
                    'proyectoId': widget.proyecto.id,
                    'nombre': nombre,
                    'rolEnProyecto': rol,
                    'esResponsable': esResponsable,
                  });

                  Navigator.pop(context);
                },
                child: const Text('Guardar'),
              )
            ],
          );
        });
      },
    );
  }

  bool tieneResponsable(List<Integrante> integrantes) {
    return integrantes.any((i) => i.esResponsable);
  }

  @override
  Widget build(BuildContext context) {
    final proyecto = widget.proyecto;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: Text(proyecto.titulo),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: mostrarFormularioIntegrante,
        child: const Icon(Icons.person_add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(proyecto.titulo,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(proyecto.descripcion),
                    const SizedBox(height: 16),
                    Text(
                        'Avance: ${proyecto.porcentajeAvance.toStringAsFixed(0)}%'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<Integrante>>(
              stream: streamIntegrantes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                final integrantes = snapshot.data ?? [];

                return Card(
                  child: ListTile(
                    leading: Icon(
                      tieneResponsable(integrantes)
                          ? Icons.check_circle
                          : Icons.warning,
                      color:
                          tieneResponsable(integrantes) ? Colors.green : Colors.orange,
                    ),
                    title: const Text('Regla de negocio'),
                    subtitle: Text(
                      tieneResponsable(integrantes)
                          ? 'El proyecto tiene responsable.'
                          : 'El proyecto debe tener mínimo un responsable.',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EntregablesPage(proyecto: proyecto)),
                );
              },
              icon: const Icon(Icons.assignment),
              label: const Text('Gestionar entregables'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AvancesPage(proyecto: proyecto)),
                );
              },
              icon: const Icon(Icons.analytics),
              label: const Text('Registrar avances'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          RevisionesPage(proyecto: proyecto, integrantes: [])),
                );
              },
              icon: const Icon(Icons.fact_check),
              label: const Text('Registrar revisiones'),
            ),
          ],
        ),
      ),
    );
  }
}