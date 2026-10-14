import 'package:flutter/foundation.dart';

/// Runs an object's database writes one at a time, in call order.
///
/// Without this, two overlapping `update()` calls on a not-yet-saved object
/// would both see an empty id and insert two rows. Chaining each write onto
/// the previous one means the second call only starts once the first has
/// finished, so it sees the id the first one assigned.
///
/// Also tracks whether the object has been deleted, so writes queued after a
/// delete don't re-insert it.
mixin SerializedSave {
  Future<void> _lastSave = Future<void>.value();
  bool _deleted = false;

  /// Whether [markDeleted] has been called (via the object's `delete()`).
  /// Saves become no-ops once this is true.
  bool get isDeleted => _deleted;

  /// Queues [save] behind any write already in flight. Skipped if the object
  /// has been deleted by the time it runs.
  Future<void> serializeSave(Future<void> Function() save) {
    return serialize(() async {
      if (_deleted) return;
      await save();
    });
  }

  /// Queues [action] behind any write already in flight, regardless of the
  /// deleted flag.
  Future<T> serialize<T>(Future<T> Function() action) {
    final Future<T> run = _lastSave.then((_) => action());
    // A failed write shouldn't block the ones after it; the error still
    // reaches whoever awaited [run].
    _lastSave = run.then((_) {}, onError: (Object _) {});
    return run;
  }

  /// Marks the object deleted so later saves are skipped. Call this before
  /// queueing the delete itself so saves queued in the meantime are dropped.
  void markDeleted() => _deleted = true;

  /// Undoes [markDeleted] when the delete failed and the row still exists.
  void unmarkDeleted() => _deleted = false;

  Map<String, dynamic>? _savedState;

  /// Records [state] as what's currently in the database.
  void rememberSaved(Map<String, dynamic> state) =>
      _savedState = Map<String, dynamic>.of(state);

  /// Whether [state] is identical to the last state passed to
  /// [rememberSaved], i.e. a write would change nothing.
  bool matchesSaved(Map<String, dynamic> state) =>
      _savedState != null && mapEquals(_savedState, state);
}
