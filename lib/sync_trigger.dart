/// Callback for "data changed, consider syncing". Set from main to SyncService.schedulePush.
void Function()? onSyncDataChanged;
bool _suppressSyncPush = false;

bool _fullPushRequested = false;
final Set<String> _dirtyUpsertUuids = {};
final Set<String> _dirtyRemoveUuids = {};

Future<T> runWithoutSyncPush<T>(Future<T> Function() action) async {
  final previous = _suppressSyncPush;
  _suppressSyncPush = true;
  try {
    return await action();
  } finally {
    _suppressSyncPush = previous;
  }
}

/// [homileticUuid]: scope the next push to this homiletic (smaller payload).
/// Omit or pass null/empty to request a full backup on the next push.
/// [removed]: server should drop this uuid from the snapshot (still respects locks).
void triggerSyncPush({String? homileticUuid, bool removed = false}) {
  if (_suppressSyncPush) {
    return;
  }
  if (homileticUuid == null || homileticUuid.trim().isEmpty) {
    _fullPushRequested = true;
    _dirtyUpsertUuids.clear();
    _dirtyRemoveUuids.clear();
  } else {
    final u = homileticUuid.trim();
    if (removed) {
      _dirtyRemoveUuids.add(u);
      _dirtyUpsertUuids.remove(u);
    } else {
      if (!_fullPushRequested) {
        _dirtyUpsertUuids.add(u);
      }
      _dirtyRemoveUuids.remove(u);
    }
  }
  onSyncDataChanged?.call();
}

/// Snapshot of pending incremental sync hints (see [takePendingSyncScope]).
class PendingSyncScope {
  PendingSyncScope({
    required this.full,
    required Set<String> upsert,
    required Set<String> remove,
  })  : upsert = Set<String>.from(upsert),
        remove = Set<String>.from(remove);

  final bool full;
  final Set<String> upsert;
  final Set<String> remove;
}

/// Consumes pending incremental sync hints. Call once when executing a push.
PendingSyncScope takePendingSyncScope() {
  final full = _fullPushRequested;
  final upsert = Set<String>.from(_dirtyUpsertUuids);
  final remove = Set<String>.from(_dirtyRemoveUuids);
  _fullPushRequested = false;
  _dirtyUpsertUuids.clear();
  _dirtyRemoveUuids.clear();
  return PendingSyncScope(full: full, upsert: upsert, remove: remove);
}

/// Re-queue scope after a failed push (does not schedule a timer by itself).
void restorePendingSyncScope({
  required bool full,
  required Set<String> upsert,
  required Set<String> remove,
}) {
  if (_suppressSyncPush) return;
  if (full) {
    _fullPushRequested = true;
    _dirtyUpsertUuids.clear();
    _dirtyRemoveUuids.clear();
  } else {
    _dirtyUpsertUuids.addAll(upsert);
    _dirtyRemoveUuids.addAll(remove);
  }
}
