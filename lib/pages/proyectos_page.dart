import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/proyecto.dart';
import '../enums/project_status.dart';
import '../enums/sync_status.dart';
import 'detalle_proyecto_page.dart';

class ProyectosPage extends StatefulWidget {
  const ProyectosPage({super.key});

  @override
  State<ProyectosPage> createState() => _ProyectosPageState();
}

class _ProyectosPageState extends State<ProyectosPage> {
  final CollectionReference proyectosRef =
      FirebaseFirestore.instance.collection('proyectos');

  void agregarProyecto(String titulo, String descripcion) async {
    final nuevoProyecto = {
      'titulo': titulo,
      'descripcion': descripcion,
      'responsableId': 'u1',
      'fechaCreacion': Timestamp.now(),
      'estado': ProjectStatus.borrador.name,
      'porcentajeAvance': 0.0,
      'syncStatus': SyncStatus.pendingSync.name,
    };

    await proyectosRef.add(nuevoProyecto);
  }

  void mostrarFormularioProyecto() {
    final tituloController = TextEditingController();
    final descripcionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nuevo proyecto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título del proyecto',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descripcionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                final titulo = tituloController.text.trim();
                final descripcion = descripcionController.text.trim();

                if (titulo.isNotEmpty && descripcion.isNotEmpty) {
                  agregarProyecto(titulo, descripcion);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Título y descripción son obligatorios')));
                }
              },
              child: const Text('Guardar'),
            )
          ],
        );
      },
    );
  }

  String textoEstado(ProjectStatus estado) {
    switch (estado) {
      case ProjectStatus.borrador:
        return 'Borrador';
      case ProjectStatus.activo:
        return 'Activo';
      case ProjectStatus.enRevision:
        return 'En revisión';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proyectos'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: mostrarFormularioProyecto,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: proyectosRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final proyectos = snapshot.data!.docs
              .map((doc) => Proyecto(
                    id: doc.id,
                    titulo: doc['titulo'],
                    descripcion: doc['descripcion'],
                    responsableId: doc['responsableId'],
                    fechaCreacion:
                        (doc['fechaCreacion'] as Timestamp).toDate(),
                    estado: ProjectStatus.values
                        .firstWhere((e) => e.name == doc['estado']),
                    porcentajeAvance:
                        (doc['porcentajeAvance'] as num).toDouble(),
                    syncStatus: SyncStatus.values
                        .firstWhere((e) => e.name == doc['syncStatus']),
                  ))
              .toList();

          if (proyectos.isEmpty) {
            return const Center(child: Text('No hay proyectos registrados'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: proyectos.length,
            itemBuilder: (context, index) {
              final proyecto = proyectos[index];
              return Card(
                child: ListTile(
                  leading: Icon(Icons.folder),
                  title: Text(proyecto.titulo),
                  subtitle: Text(
                      'Estado: ${textoEstado(proyecto.estado)}\nAvance: ${proyecto.porcentajeAvance.toStringAsFixed(0)}%'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                DetalleProyectoPage(proyecto: proyecto)));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}