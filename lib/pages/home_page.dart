import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../enums/user_role.dart';
import 'proyectos_page.dart';

class HomePage extends StatelessWidget {
  final Usuario usuario;

  const HomePage({
    super.key,
    required this.usuario,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Investigación'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(usuario.nombre),
              subtitle: Text('Rol: ${usuario.rol.name}'),
            ),
          ),

          const SizedBox(height: 12),

          if (usuario.rol == UserRole.investigador) ...[
            Card(
              child: ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('Proyectos'),
                subtitle: const Text('Crear y administrar proyectos'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProyectosPage(),
                    ),
                  );
                },
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.assignment),
                title: Text('Entregables'),
                subtitle: Text('Se gestionan dentro de cada proyecto'),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.analytics),
                title: Text('Avances'),
                subtitle: Text('Se registran dentro de cada proyecto'),
              ),
            ),
          ],

          if (usuario.rol == UserRole.evaluador) ...[
            Card(
              child: ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('Proyectos para revisión'),
                subtitle: const Text('Ingresar a proyectos y registrar revisiones'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProyectosPage(),
                    ),
                  );
                },
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.fact_check),
                title: Text('Revisiones'),
                subtitle: Text('Validar avances y entregables'),
              ),
            ),
          ],

          if (usuario.rol == UserRole.coordinador) ...[
            Card(
              child: ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('Todos los proyectos'),
                subtitle: const Text('Supervisar proyectos registrados'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProyectosPage(),
                    ),
                  );
                },
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.admin_panel_settings),
                title: Text('Administración de usuarios'),
                subtitle: Text('Gestionar roles y estados de cuenta'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}