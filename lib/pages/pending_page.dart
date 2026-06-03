import 'package:flutter/material.dart';

class PendingPage extends StatelessWidget {
  const PendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF4F6FA),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Cuenta pendiente de aprobación.\nEspera a que el coordinador active tu cuenta.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ),
      ),
    );
  }
}