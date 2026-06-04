import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class PendingPage extends StatelessWidget {
  const PendingPage({super.key});

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
                    Icons.hourglass_empty_rounded,
                    size: 42,
                    color: AppTheme.warning,
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Cuenta pendiente',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.ink,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Espera a que el coordinador active tu cuenta.',
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
