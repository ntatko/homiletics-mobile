import 'package:homiletics/storage/homiletic_storage.dart';
import 'package:homiletics/sync_trigger.dart';

/// Resolves [homileticId] to a stable uuid for incremental sync pushes.
Future<void> triggerSyncPushForHomileticId(int? homileticId) async {
  if (homileticId == null) {
    triggerSyncPush();
    return;
  }
  try {
    final h = await getHomileticById(homileticId);
    final u = h.uuid?.trim();
    if (u != null && u.isNotEmpty) {
      triggerSyncPush(homileticUuid: u);
    } else {
      triggerSyncPush();
    }
  } catch (_) {
    triggerSyncPush();
  }
}
