import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/proyecto.dart';

class StorageService {
  static const String proyectosKey = 'proyectos';

  Future<void> guardarProyectos(List<Proyecto> proyectos) async {
    final prefs = await SharedPreferences.getInstance();

    final proyectosJson = proyectos.map((proyecto) {
      return jsonEncode(proyecto.toJson());
    }).toList();

    await prefs.setStringList(proyectosKey, proyectosJson);
  }

  Future<List<Proyecto>> cargarProyectos() async {
    final prefs = await SharedPreferences.getInstance();

    final proyectosGuardados = prefs.getStringList(proyectosKey) ?? [];

    final List<Proyecto> proyectos = [];

    for (final item in proyectosGuardados) {
      try {
        final mapa = jsonDecode(item);
        proyectos.add(Proyecto.fromJson(mapa));
      } catch (e) {
        // Ignora datos viejos que no estaban guardados como JSON
      }
    }

    return proyectos;
  }

  Future<void> limpiarProyectos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(proyectosKey);
  }
}