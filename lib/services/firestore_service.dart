import 'package:cloud_firestore/cloud_firestore.dart';

import '../enums/account_status.dart';
import '../enums/sync_status.dart';
import '../enums/user_role.dart';
import '../models/avance.dart';
import '../models/entregable.dart';
import '../models/integrante.dart';
import '../models/proyecto.dart';
import '../models/revision.dart';
import '../models/usuario.dart';
import '../data/local_repository.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final LocalRepository _localRepository = LocalRepository();

  static const List<Usuario> usuariosBase = [
    Usuario(
      uid: 'usuario-base-ana-perez',
      nombre: 'Ana Perez',
      email: 'ana.perez@proyecto.local',
      rol: UserRole.investigador,
      estado: AccountStatus.active,
    ),
    Usuario(
      uid: 'usuario-base-luis-gomez',
      nombre: 'Luis Gomez',
      email: 'luis.gomez@proyecto.local',
      rol: UserRole.investigador,
      estado: AccountStatus.active,
    ),
    Usuario(
      uid: 'usuario-base-maria-rodriguez',
      nombre: 'Maria Rodriguez',
      email: 'maria.rodriguez@proyecto.local',
      rol: UserRole.investigador,
      estado: AccountStatus.active,
    ),
    Usuario(
      uid: 'usuario-base-carlos-martinez',
      nombre: 'Carlos Martinez',
      email: 'carlos.martinez@proyecto.local',
      rol: UserRole.investigador,
      estado: AccountStatus.active,
    ),
    Usuario(
      uid: 'usuario-base-laura-torres',
      nombre: 'Laura Torres',
      email: 'laura.torres@proyecto.local',
      rol: UserRole.evaluador,
      estado: AccountStatus.active,
    ),
    Usuario(
      uid: 'usuario-base-diego-ramirez',
      nombre: 'Diego Ramirez',
      email: 'diego.ramirez@proyecto.local',
      rol: UserRole.investigador,
      estado: AccountStatus.active,
    ),
    Usuario(
      uid: 'usuario-base-valentina-morales',
      nombre: 'Valentina Morales',
      email: 'valentina.morales@proyecto.local',
      rol: UserRole.investigador,
      estado: AccountStatus.active,
    ),
    Usuario(
      uid: 'usuario-base-andres-castro',
      nombre: 'Andres Castro',
      email: 'andres.castro@proyecto.local',
      rol: UserRole.investigador,
      estado: AccountStatus.active,
    ),
    Usuario(
      uid: 'usuario-base-camila-herrera',
      nombre: 'Camila Herrera',
      email: 'camila.herrera@proyecto.local',
      rol: UserRole.evaluador,
      estado: AccountStatus.active,
    ),
    Usuario(
      uid: 'usuario-base-jorge-salazar',
      nombre: 'Jorge Salazar',
      email: 'jorge.salazar@proyecto.local',
      rol: UserRole.investigador,
      estado: AccountStatus.active,
    ),
  ];

  CollectionReference<Map<String, dynamic>> get _proyectos =>
      _firestore.collection('proyectos');
  CollectionReference<Map<String, dynamic>> get _integrantes =>
      _firestore.collection('integrantes');
  CollectionReference<Map<String, dynamic>> get _entregables =>
      _firestore.collection('entregables');
  CollectionReference<Map<String, dynamic>> get _avances =>
      _firestore.collection('avances');
  CollectionReference<Map<String, dynamic>> get _revisiones =>
      _firestore.collection('revisiones');
  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Stream<List<Proyecto>> proyectosStream() {
    return _proyectos.orderBy('fechaCreacion', descending: true).snapshots().map(
          (snapshot) => snapshot.docs.map(_proyectoFromDoc).toList(),
        );
  }

  Stream<Proyecto> proyectoStream(String proyectoId) {
    return _proyectos.doc(proyectoId).snapshots().map((doc) {
      return Proyecto.fromJson({'id': doc.id, ...?doc.data()});
    });
  }

  Future<List<Proyecto>> cargarProyectos() async {
    final snapshot = await _proyectos.orderBy('fechaCreacion').get();
    return snapshot.docs.map(_proyectoFromDoc).toList();
  }

  Future<Proyecto> guardarProyecto(Proyecto proyecto) async {
    final doc =
        proyecto.id.isEmpty ? _proyectos.doc() : _proyectos.doc(proyecto.id);
    final guardado = proyecto.copyWith(
      id: doc.id,
      syncStatus: SyncStatus.synced,
    );
    await doc.set(_toFirestore(guardado.toJson()), SetOptions(merge: true));
    return guardado;
  }

  Future<void> actualizarProyecto(Proyecto proyecto) {
    return _proyectos.doc(proyecto.id).set(
          _toFirestore(proyecto.toJson()),
          SetOptions(merge: true),
        );
  }

  Future<void> actualizarEstadoProyecto(
    String proyectoId,
    String estado,
  ) {
    return _proyectos.doc(proyectoId).set(
      {'estado': estado},
      SetOptions(merge: true),
    );
  }

  Future<void> actualizarAvanceProyecto(
    String proyectoId,
    double porcentajeAvance,
  ) {
    return _proyectos.doc(proyectoId).set(
      {'porcentajeAvance': porcentajeAvance},
      SetOptions(merge: true),
    );
  }

  Stream<List<Integrante>> integrantesStream(String proyectoId) {
    return _integrantes.where('proyectoId', isEqualTo: proyectoId).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) {
            return Integrante.fromJson({'id': doc.id, ...doc.data()});
          }).toList(),
        );
  }

  Future<void> guardarIntegrante(Integrante integrante) {
    final doc =
        integrante.id.isEmpty ? _integrantes.doc() : _integrantes.doc(integrante.id);
    return doc.set(
      {...integrante.toJson(), 'id': doc.id},
      SetOptions(merge: true),
    );
  }

  Stream<List<Entregable>> entregablesStream(String proyectoId) {
    return _entregables.where('proyectoId', isEqualTo: proyectoId).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) {
            return Entregable.fromJson({'id': doc.id, ...doc.data()});
          }).toList(),
        );
  }

  Future<List<Entregable>> cargarEntregables(String proyectoId) async {
    final snapshot = await _entregables
        .where('proyectoId', isEqualTo: proyectoId)
        .get();
    return snapshot.docs.map((doc) {
      return Entregable.fromJson({'id': doc.id, ...doc.data()});
    }).toList();
  }

  Future<void> guardarEntregable(Entregable entregable) {
    final doc = entregable.id.isEmpty
        ? _entregables.doc()
        : _entregables.doc(entregable.id);
    final data = entregable.copyWith(id: doc.id, syncStatus: SyncStatus.synced);
    return doc.set(_toFirestore(data.toJson()), SetOptions(merge: true));
  }

  Stream<List<Avance>> avancesStream(String proyectoId) {
    return _avances.where('proyectoId', isEqualTo: proyectoId).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) {
            return Avance.fromJson({'id': doc.id, ...doc.data()});
          }).toList(),
        );
  }

  Future<void> guardarAvance(Avance avance) {
    final doc = avance.id.isEmpty ? _avances.doc() : _avances.doc(avance.id);
    return doc.set(
      _toFirestore({'id': doc.id, ...avance.toJson()}),
      SetOptions(merge: true),
    );
  }

  Stream<List<Revision>> revisionesStream(String proyectoId) async* {
    final locales = await _cargarRevisionesLocales(proyectoId);
    yield locales;

    try {
      await for (final snapshot
          in _revisiones.where('proyectoId', isEqualTo: proyectoId).snapshots()) {
        final remotas = snapshot.docs.map((doc) {
          return Revision.fromJson({...doc.data(), 'id': doc.id});
        }).toList();
        final localesActuales = await _cargarRevisionesLocales(proyectoId);
        yield _mergeRevisiones(localesActuales, remotas);
      }
    } catch (_) {
      yield await _cargarRevisionesLocales(proyectoId);
    }
  }

  Future<void> guardarRevision(Revision revision) async {
    final id = revision.id.isEmpty
        ? 'revision-local-${DateTime.now().microsecondsSinceEpoch}'
        : revision.id;
    final guardada = Revision(
      id: id,
      proyectoId: revision.proyectoId,
      evaluadorId: revision.evaluadorId,
      concepto: revision.concepto,
      aprobado: revision.aprobado,
      fechaRevision: revision.fechaRevision,
    );

    await _guardarRevisionLocal(guardada);

    try {
      await _revisiones.doc(id).set(
            _toFirestore(guardada.toJson()),
            SetOptions(merge: true),
          );
    } catch (_) {
      // Se conserva localmente cuando Firestore rechaza la escritura.
    }
  }

  Stream<List<Usuario>> usuariosStream() async* {
    yield usuariosBase;

    try {
      await for (final snapshot in _users.orderBy('email').snapshots()) {
        final remotos = snapshot.docs.map((doc) {
          return Usuario.fromJson({'uid': doc.id, ...doc.data()});
        }).toList();
        yield _mergeUsuarios(remotos);
      }
    } catch (_) {
      yield usuariosBase;
    }
  }

  Future<Usuario> crearUsuario(Usuario usuario) async {
    final doc = usuario.uid.isEmpty ? _users.doc() : _users.doc(usuario.uid);
    final guardado = usuario.copyWith(uid: doc.id);
    await doc.set(guardado.toJson());
    return guardado;
  }

  Future<void> actualizarUsuario(Usuario usuario) {
    return _users.doc(usuario.uid).set(
          usuario.toJson(),
          SetOptions(merge: true),
        );
  }

  Proyecto _proyectoFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return Proyecto.fromJson({'id': doc.id, ...doc.data()});
  }

  List<Usuario> _mergeUsuarios(List<Usuario> remotos) {
    final porUid = <String, Usuario>{
      for (final usuario in usuariosBase) usuario.uid: usuario,
      for (final usuario in remotos) usuario.uid: usuario,
    };
    final usuarios = porUid.values.toList();
    usuarios.sort((a, b) => a.email.compareTo(b.email));
    return usuarios;
  }

  Future<List<Revision>> _cargarRevisionesLocales(String proyectoId) async {
    final revisiones = await _localRepository.cargarRevisiones();
    final filtradas = revisiones.where((revision) {
      return revision.proyectoId == proyectoId;
    }).toList();
    filtradas.sort((a, b) => b.fechaRevision.compareTo(a.fechaRevision));
    return filtradas;
  }

  Future<void> _guardarRevisionLocal(Revision revision) async {
    final revisiones = await _localRepository.cargarRevisiones();
    final index = revisiones.indexWhere((item) => item.id == revision.id);
    if (index == -1) {
      revisiones.add(revision);
    } else {
      revisiones[index] = revision;
    }
    await _localRepository.guardarRevisiones(revisiones);
  }

  List<Revision> _mergeRevisiones(
    List<Revision> locales,
    List<Revision> remotas,
  ) {
    final porId = <String, Revision>{
      for (final revision in remotas) revision.id: revision,
      for (final revision in locales) revision.id: revision,
    };
    final revisiones = porId.values.toList();
    revisiones.sort((a, b) => b.fechaRevision.compareTo(a.fechaRevision));
    return revisiones;
  }

  Map<String, dynamic> _toFirestore(Map<String, dynamic> json) {
    return json.map((key, value) {
      if (value is String) {
        final date = DateTime.tryParse(value);
        if (key.toLowerCase().contains('fecha') ||
            key == 'createdAt' ||
            key == 'lastLoginAt') {
          return MapEntry(key, date == null ? value : Timestamp.fromDate(date));
        }
      }
      return MapEntry(key, value);
    });
  }
}
