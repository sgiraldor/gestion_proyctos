import 'package:flutter/material.dart';

import '../enums/account_status.dart';
import '../enums/user_role.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import 'proyectos_page.dart';
import 'usuarios_page.dart';

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
        title: const Text('Inicio'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesion',
            onPressed: () => AuthService().logout(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, ${usuario.nombre}',
                  style: const TextStyle(
                    color: AppTheme.ink,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  usuario.rol.label,
                  style: const TextStyle(
                    color: AppTheme.secondaryInk,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _ProfileCard(usuario: usuario),
          const SizedBox(height: 18),
          const _SectionTitle('Accesos'),
          if (usuario.rol == UserRole.investigador) ...[
            _MenuTile(
              icon: Icons.folder_outlined,
              title: 'Proyectos',
              subtitle: 'Crear y administrar proyectos',
              onTap: () => _abrirProyectos(context),
            ),
            const _MenuTile(
              icon: Icons.assignment_outlined,
              title: 'Entregables',
              subtitle: 'Se gestionan dentro de cada proyecto',
            ),
            const _MenuTile(
              icon: Icons.analytics_outlined,
              title: 'Avances',
              subtitle: 'Se registran dentro de cada proyecto',
            ),
          ],
          if (usuario.rol == UserRole.evaluador) ...[
            _MenuTile(
              icon: Icons.folder_outlined,
              title: 'Proyectos para revision',
              subtitle: 'Ingresar a proyectos y registrar revisiones',
              onTap: () => _abrirProyectos(context),
            ),
            const _MenuTile(
              icon: Icons.fact_check_outlined,
              title: 'Revisiones',
              subtitle: 'Validar avances y entregables',
            ),
          ],
          if (usuario.rol == UserRole.coordinador) ...[
            _MenuTile(
              icon: Icons.folder_outlined,
              title: 'Todos los proyectos',
              subtitle: 'Supervisar proyectos registrados',
              onTap: () => _abrirProyectos(context),
            ),
            _MenuTile(
              icon: Icons.admin_panel_settings_outlined,
              title: 'Administracion de usuarios',
              subtitle: 'Gestionar roles y estados de cuenta',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UsuariosPage(),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  void _abrirProyectos(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProyectosPage(usuario: usuario),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final Usuario usuario;

  const _ProfileCard({required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.person_outline,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    usuario.email,
                    style: const TextStyle(
                      color: AppTheme.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cuenta ${usuario.estado.label.toLowerCase()}',
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
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.secondaryInk,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 21),
          ),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: onTap == null
              ? null
              : const Icon(
                  Icons.chevron_right,
                  color: AppTheme.secondaryInk,
                ),
          onTap: onTap,
        ),
      ),
    );
  }
}
