import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/avance.dart';
import '../models/entregable.dart';
import '../models/integrante.dart';
import '../models/proyecto.dart';
import '../models/revision.dart';
import 'app_database.dart';

class LocalRepository {
  Future<void> guardarProyectos(List<Proyecto> proyectos) {
    return _guardarLista(
      AppDatabase.proyectosKey,
      proyectos.map((item) => item.toJson()).toList(),
    );
  }

  Future<List<Proyecto>> cargarProyectos() async {
    final items = await _cargarLista(AppDatabase.proyectosKey);
    return items.map(Proyecto.fromJson).toList();
  }

  Future<void> guardarIntegrantes(List<Integrante> integrantes) {
    return _guardarLista(
      AppDatabase.integrantesKey,
      integrantes.map((item) => item.toJson()).toList(),
    );
  }

  Future<List<Integrante>> cargarIntegrantes() async {
    final items = await _cargarLista(AppDatabase.integrantesKey);
    return items.map(Integrante.fromJson).toList();
  }

  Future<void> guardarEntregables(List<Entregable> entregables) {
    return _guardarLista(
      AppDatabase.entregablesKey,
      entregables.map((item) => item.toJson()).toList(),
    );
  }

  Future<List<Entregable>> cargarEntregables() async {
    final items = await _cargarLista(AppDatabase.entregablesKey);
    return items.map(Entregable.fromJson).toList();
  }

  Future<void> guardarAvances(List<Avance> avances) {
    return _guardarLista(
      AppDatabase.avancesKey,
      avances.map((item) => item.toJson()).toList(),
    );
  }

  Future<List<Avance>> cargarAvances() async {
    final items = await _cargarLista(AppDatabase.avancesKey);
    return items.map(Avance.fromJson).toList();
  }

  Future<void> guardarRevisiones(List<Revision> revisiones) {
    return _guardarLista(
      AppDatabase.revisionesKey,
      revisiones.map((item) => item.toJson()).toList(),
    );
  }

  Future<List<Revision>> cargarRevisiones() async {
    final items = await _cargarLista(AppDatabase.revisionesKey);
    return items.map(Revision.fromJson).toList();
  }

  Future<void> limpiarTodo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppDatabase.proyectosKey);
    await prefs.remove(AppDatabase.integrantesKey);
    await prefs.remove(AppDatabase.entregablesKey);
    await prefs.remove(AppDatabase.avancesKey);
    await prefs.remove(AppDatabase.revisionesKey);
  }

  Future<void> _guardarLista(
    String key,
    List<Map<String, dynamic>> values,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      key,
      values.map(jsonEncode).toList(),
    );
  }

  Future<List<Map<String, dynamic>>> _cargarLista(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList(key) ?? [];
    return values
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList();
  }
}
