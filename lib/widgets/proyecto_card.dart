import 'package:flutter/material.dart';

import '../models/proyecto.dart';

class ProyectoCard extends StatelessWidget {
  final Proyecto proyecto;
  final VoidCallback? onTap;

  const ProyectoCard({
    super.key,
    required this.proyecto,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.folder),
        title: Text(proyecto.titulo),
        subtitle: Text(
          '${proyecto.descripcion}\nAvance: ${proyecto.porcentajeAvance.toStringAsFixed(0)}%',
        ),
        isThreeLine: true,
        trailing: onTap == null ? null : const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
