import '../data/local_repository.dart';
import '../enums/sync_status.dart';
import 'firestore_service.dart';

class SyncService {
  SyncService({
    LocalRepository? localRepository,
    FirestoreService? firestoreService,
  })  : _localRepository = localRepository ?? LocalRepository(),
        _firestoreService = firestoreService ?? FirestoreService();

  final LocalRepository _localRepository;
  final FirestoreService _firestoreService;

  Future<void> sincronizarProyectos() async {
    final locales = await _localRepository.cargarProyectos();
    final pendientes = locales.where(
      (proyecto) => proyecto.syncStatus != SyncStatus.synced,
    );

    for (final proyecto in pendientes) {
      await _firestoreService.guardarProyecto(proyecto);
    }

    final remotos = await _firestoreService.cargarProyectos();
    await _localRepository.guardarProyectos(remotos);
  }
}
