import 'package:flutter/material.dart';

class BlockedPage extends StatelessWidget {
  const BlockedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF4F6FA),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Acceso bloqueado.\nTu cuenta no tiene permiso para ingresar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}