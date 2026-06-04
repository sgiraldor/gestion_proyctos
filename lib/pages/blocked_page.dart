import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class BlockedPage extends StatelessWidget {
  const BlockedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 42,
                    color: AppTheme.danger,
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Acceso bloqueado',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.ink,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tu cuenta no tiene permiso para ingresar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.secondaryInk,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
