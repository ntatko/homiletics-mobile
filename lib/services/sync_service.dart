import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/services/auth_storage.dart';
import 'package:homiletics/services/sync_api_client.dart';
import 'package:homiletics/storage/application_storage.dart';
import 'package:homiletics/storage/content_summary_storage.dart';
import 'package:homiletics/storage/division_storage.dart';
import 'package:homiletics/storage/homiletic_storage.dart';
import 'package:homiletics/storage/operational_sync_storage.dart';
import 'package:homiletics/sync_trigger.dart';

enum SyncStatus { synced, syncing, offline, notSignedIn }

void _syncServiceLog(String message, {Object? error, StackTrace? stackTrace}) {
  developer.log(
    message,
    name: 'homiletics.sync',
    error: error,
    stackTrace: stackTrace,
  );
  debugPrint('[homiletics.sync] $message${error != null ? ' | $error' : ''}');
}

class SyncService {
  SyncService({
    SyncApiClient? apiClient,
    Future<bool> Function()? isSignedInChecker,
    Future<List<Homiletic>> Function()? ensureAllHomileticsHaveUuidsFn,
    Future<List<Division>> Function(int?)? getDivisionsByHomileticIdFn,
    Future<List<ContentSummary>> Function(int?)? getSummariesByHomileticIdFn,
    Future<List<Application>> Function(int?)? getApplicationsByHomileticIdFn,
    Future<Homiletic?> Function(String)? getHomileticByUuidFn,
    Future<void> Function(Homiletic)? updateHomileticFn,
    Future<List<Application>> Function(int)? deleteApplicationByHomileticIdFn,
    Future<List<ContentSummary>> Function(int)? deleteSummaryByHomileticIdFn,
    Future<List<Division>> Function(int)? deleteDivisionByHomileticIdFn,
    Future<int> Function(Division)? insertDivisionFn,
    Future<int> Function(ContentSummary)? insertSummaryFn,
    Future<int> Function(Application)? insertApplicationFn,
    Future<int> Function(Homiletic)? insertHomileticFn,
    Future<void> Function(Homiletic)? deleteHomileticFn,
    Future<String> Function()? deviceIdForOpsFn,
    Duration debounceDuration = const Duration(seconds: 1),
  })  : _apiClient = apiClient ?? SyncApiClient(),
        _isSignedInChecker = isSignedInChecker ?? (() => isSignedIn),
        _ensureAllHomileticsHaveUuids =
            ensureAllHomileticsHaveUuidsFn ?? ensureAllHomileticsHaveUuids,
        _getDivisionsByHomileticId =
            getDivisionsByHomileticIdFn ?? getDivisionsByHomileticId,
        _getSummariesByHomileticId =
            getSummariesByHomileticIdFn ?? getSummariesByHomileticId,
        _getApplicationsByHomileticId =
            getApplicationsByHomileticIdFn ?? getApplicationsByHomileticId,
        _getHomileticByUuid = getHomileticByUuidFn ?? getHomileticByUuid,
        _updateHomiletic = updateHomileticFn ?? updateHomiletic,
        _deleteApplicationByHomileticId =
            deleteApplicationByHomileticIdFn ?? deleteApplicationByHomileticId,
        _deleteSummaryByHomileticId =
            deleteSummaryByHomileticIdFn ?? deleteSummaryByHomileticId,
        _deleteDivisionByHomileticId =
            deleteDivisionByHomileticIdFn ?? deleteDivisionByHomileticId,
        _insertDivision = insertDivisionFn ?? insertDivision,
        _insertSummary = insertSummaryFn ?? insertSummary,
        _insertApplication = insertApplicationFn ?? insertApplication,
        _insertHomiletic = insertHomileticFn ?? insertHomiletic,
        _deleteHomiletic = deleteHomileticFn ?? deleteHomiletic,
        _deviceIdForOpsFn = deviceIdForOpsFn,
        _debounceDuration = debounceDuration;

  final Duration _debounceDuration;

  static final SyncService instance = SyncService();

  final SyncApiClient _apiClient;
  final Future<bool> Function() _isSignedInChecker;
  final Future<List<Homiletic>> Function() _ensureAllHomileticsHaveUuids;
  final Future<List<Division>> Function(int?) _getDivisionsByHomileticId;
  final Future<List<ContentSummary>> Function(int?) _getSummariesByHomileticId;
  final Future<List<Application>> Function(int?) _getApplicationsByHomileticId;
  final Future<Homiletic?> Function(String) _getHomileticByUuid;
  final Future<void> Function(Homiletic) _updateHomiletic;
  final Future<List<Application>> Function(int) _deleteApplicationByHomileticId;
  final Future<List<ContentSummary>> Function(int) _deleteSummaryByHomileticId;
  final Future<List<Division>> Function(int) _deleteDivisionByHomileticId;
  final Future<int> Function(Division) _insertDivision;
  final Future<int> Function(ContentSummary) _insertSummary;
  final Future<int> Function(Application) _insertApplication;
  final Future<int> Function(Homiletic) _insertHomiletic;
  final Future<void> Function(Homiletic) _deleteHomiletic;
  final Future<String> Function()? _deviceIdForOpsFn;

  SyncStatus _status = SyncStatus.notSignedIn;
  SyncStatus get status => _status;
  set status(SyncStatus value) {
    if (_status != value) {
      _status = value;
      _notifyListeners();
    }
  }

  void _notifyListeners() {
    for (final cb in _listeners) {
      cb();
    }
  }

  final List<VoidCallback> _listeners = [];
  void addListener(VoidCallback cb) {
    _listeners.add(cb);
  }

  void removeListener(VoidCallback cb) {
    _listeners.remove(cb);
  }

  String get statusLabel {
    switch (_status) {
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.syncing:
        return 'Syncing…';
      case SyncStatus.offline:
        return 'Offline';
      case SyncStatus.notSignedIn:
        return 'Not signed in';
    }
  }

  Timer? _pushTimer;
  int _pendingPushTriggerCount = 0;
  bool _pullInProgress = false;
  bool _pendingPushAfterPull = false;
  bool _forceNextPushFull = false;

  static int _pullSeq = 0;
  static int _pushSeq = 0;

  Future<void> _pullQueueTail = Future<void>.value();

  Future<void> schedulePush() async {
    if (_pullInProgress) {
      _pendingPushAfterPull = true;
      return;
    }
    _pendingPushTriggerCount++;
    if (_debounceDuration <= Duration.zero) {
      final triggerCount = _pendingPushTriggerCount;
      _pendingPushTriggerCount = 0;
      await _doPush(triggerCount: triggerCount);
      return;
    }
    if (_pushTimer == null) {
      final ms = _debounceDuration.inMilliseconds;
      _syncServiceLog(
        ms >= 1000
            ? 'schedulePush: started ${ms ~/ 1000}s debounce'
            : 'schedulePush: started ${ms}ms debounce',
      );
    }
    _pushTimer?.cancel();
    _pushTimer = Timer(_debounceDuration, () {
      _pushTimer = null;
      final triggerCount = _pendingPushTriggerCount;
      _pendingPushTriggerCount = 0;
      unawaited(_doPush(triggerCount: triggerCount));
    });
  }

  void scheduleFullPush() {
    _forceNextPushFull = true;
    unawaited(schedulePush());
  }

  Future<void> _doPush({int triggerCount = 1}) async {
    final seq = ++_pushSeq;
    final signedIn = await _isSignedInChecker();
    if (!signedIn) {
      _syncServiceLog('_doPush#$seq: skip (not signed in)');
      return;
    }
    final forceFull = _forceNextPushFull;
    _forceNextPushFull = false;
    final scope = takePendingSyncScope();

    _syncServiceLog(
      '_doPush#$seq: begin (triggers=$triggerCount, full=${forceFull || scope.full}, '
      'upsert=${scope.upsert.length}, remove=${scope.remove.length})',
    );
    status = SyncStatus.syncing;
    try {
      await _ensureAllHomileticsHaveUuids();
      final full = forceFull || scope.full;
      if (full) {
        final all = await _ensureAllHomileticsHaveUuids();
        for (final h in all) {
          final u = h.uuid?.trim();
          if (u == null || u.isEmpty) continue;
          final item = await _homileticToBackupItem(h);
          await coalesceEnqueueHomileticPut(
            homileticUuid: u,
            itemPayload: item,
          );
        }
      } else {
        for (final u in scope.remove) {
          final uuid = u.trim();
          if (uuid.isEmpty) continue;
          await coalesceEnqueueHomileticDelete(uuid);
        }
        for (final u in scope.upsert) {
          final uuid = u.trim();
          if (uuid.isEmpty) continue;
          final h = await _getHomileticByUuid(uuid);
          if (h == null) continue;
          final item = await _homileticToBackupItem(h);
          await coalesceEnqueueHomileticPut(
            homileticUuid: uuid,
            itemPayload: item,
          );
        }
      }
      await _flushOutbox();
      status = SyncStatus.synced;
      _notifyListeners();
      _syncServiceLog('_doPush#$seq: ok');
    } catch (e, st) {
      status = SyncStatus.offline;
      _syncServiceLog('_doPush#$seq: failed', error: e, stackTrace: st);
    }
  }

  Future<void> _flushOutbox() async {
    final rows = await listOutboxOrdered();
    if (rows.isEmpty) return;
    final deviceId = _deviceIdForOpsFn != null
        ? await _deviceIdForOpsFn!()
        : await getSessionId();
    final ops = <Map<String, dynamic>>[];
    for (final r in rows) {
      Map<String, dynamic> payload;
      try {
        payload = jsonDecode(r.payloadJson) as Map<String, dynamic>;
      } catch (_) {
        continue;
      }
      ops.add({
        'client_mutation_id': r.clientMutationId,
        'op_type': r.opType,
        if (r.homileticUuid != null && r.homileticUuid!.isNotEmpty)
          'homiletic_uuid': r.homileticUuid,
        'payload': payload,
      });
    }
    if (ops.isEmpty) return;
    final body = jsonEncode({'device_id': deviceId, 'ops': ops});
    final response = await _apiClient.postSyncOps(body);
    final results = response['results'] as List<dynamic>? ?? [];
    final ackIds = <int>[];
    for (final res in results) {
      if (res is! Map) continue;
      final mid = res['client_mutation_id']?.toString();
      if (mid == null) continue;
      for (final row in rows) {
        if (row.clientMutationId == mid) {
          ackIds.add(row.id);
          break;
        }
      }
    }
    await deleteOutboxRowsByIds(ackIds);
  }

  Future<void> pullIfSignedIn() async {
    return _queuePull(snapshotFirst: false, pushAfterMergeIfNeeded: false);
  }

  Future<void> syncNowIfSignedIn() async {
    return _queuePull(snapshotFirst: true, pushAfterMergeIfNeeded: true);
  }

  Future<void> _queuePull({
    required bool snapshotFirst,
    required bool pushAfterMergeIfNeeded,
  }) async {
    final previous = _pullQueueTail;
    final completer = Completer<void>();
    _pullQueueTail = completer.future;
    try {
      await previous;
      await _runPullIfSignedIn(
        snapshotFirst: snapshotFirst,
        pushAfterMergeIfNeeded: pushAfterMergeIfNeeded,
      );
    } finally {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
  }

  Future<void> _runPullIfSignedIn({
    required bool snapshotFirst,
    required bool pushAfterMergeIfNeeded,
  }) async {
    final seq = ++_pullSeq;
    _pullInProgress = true;
    final signedIn = await _isSignedInChecker();
    if (!signedIn) {
      status = SyncStatus.notSignedIn;
      _syncServiceLog('pullIfSignedIn#$seq: skip (not signed in)');
      _pullInProgress = false;
      return;
    }
    _syncServiceLog('pullIfSignedIn#$seq: begin');
    status = SyncStatus.syncing;
    try {
      if (snapshotFirst) {
        final snap = await _apiClient
            .getSyncSnapshot()
            .timeout(const Duration(seconds: 30));
        final data = snap['data'] as List<dynamic>?;
        final lastSeq = (snap['last_seq'] as num?)?.toInt() ?? 0;
        if (data != null && data.isNotEmpty) {
          await runWithoutSyncPush(() => _mergePayloadIntoLocal(data));
        }
        await setLastAppliedServerSeq(lastSeq);
        await setHadInitialServerMerge();
        final localHomiletics = await _ensureAllHomileticsHaveUuids();
        final shouldPush = pushAfterMergeIfNeeded
            ? _shouldPushAfterUserTriggeredSync(
                localHomiletics: localHomiletics,
                remoteData: data,
              )
            : _shouldSeedEmptyServer(
                localHomiletics: localHomiletics,
                remoteData: data,
              );
        if (shouldPush) {
          _forceNextPushFull = true;
          await _doPush(triggerCount: 1);
        }
      } else {
        var since = await getLastAppliedServerSeq();
        if (since == 0 && !await hadInitialServerMerge()) {
          final snap = await _apiClient
              .getSyncSnapshot()
              .timeout(const Duration(seconds: 30));
          final data = snap['data'] as List<dynamic>?;
          final snapSeq = (snap['last_seq'] as num?)?.toInt() ?? 0;
          if (data != null && data.isNotEmpty) {
            await runWithoutSyncPush(() => _mergePayloadIntoLocal(data));
          }
          await setLastAppliedServerSeq(snapSeq);
          await setHadInitialServerMerge();
          since = snapSeq;
        }
        final r = await _apiClient
            .getSyncOpsSince(since)
            .timeout(const Duration(seconds: 30));
        final ops = r['ops'] as List<dynamic>? ?? [];
        final lastSeq = (r['last_seq'] as num?)?.toInt() ?? since;
        if (ops.isNotEmpty) {
          await applyRemoteOps(ops);
        }
        await setLastAppliedServerSeq(lastSeq);
      }
      status = SyncStatus.synced;
      _notifyListeners();
      _syncServiceLog('pullIfSignedIn#$seq: ok');
    } catch (e, st) {
      status = SyncStatus.offline;
      _syncServiceLog('pullIfSignedIn#$seq: failed', error: e, stackTrace: st);
    } finally {
      _pullInProgress = false;
      if (_pendingPushAfterPull) {
        _pendingPushAfterPull = false;
        _forceNextPushFull = true;
        await _doPush(triggerCount: 1);
      }
    }
  }

  /// Apply ops from WebSocket or GET /sync/ops (already-decoded JSON maps).
  Future<void> applyRemoteOps(List<dynamic> wireOps) async {
    final list = wireOps
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList()
      ..sort((a, b) => ((a['server_seq'] as num?)?.toInt() ?? 0)
          .compareTo((b['server_seq'] as num?)?.toInt() ?? 0));
    var last = await getLastAppliedServerSeq();
    for (final op in list) {
      final seq = (op['server_seq'] as num?)?.toInt() ?? 0;
      if (seq <= last) continue;
      final type = op['op_type']?.toString() ?? '';
      final payload = op['payload'];
      if (payload is! Map) continue;
      final payloadMap = Map<String, dynamic>.from(payload);
      await runWithoutSyncPush(() async {
        switch (type) {
          case 'homiletic.put':
            final itemRaw = payloadMap['item'] ?? payloadMap;
            if (itemRaw is Map) {
              await _mergeSingleItem(Map<String, dynamic>.from(itemRaw));
            }
            break;
          case 'homiletic.delete':
            final u = payloadMap['homiletic_uuid']?.toString().trim();
            if (u != null && u.isNotEmpty) {
              await _deleteLocalHomileticByUuid(u);
            }
            break;
          case 'homiletic.update_fields':
            await _applyHomileticUpdateFields(payloadMap);
            break;
          default:
            break;
        }
      });
      last = seq;
      await setLastAppliedServerSeq(seq);
    }
    _notifyListeners();
  }

  Future<void> _applyHomileticUpdateFields(Map<String, dynamic> payload) async {
    final u = payload['homiletic_uuid']?.toString().trim();
    if (u == null || u.isEmpty) return;
    final existing = await _getHomileticByUuid(u);
    if (existing == null) return;
    if (payload.containsKey('passage')) {
      existing.passage = payload['passage']?.toString() ?? '';
    }
    if (payload.containsKey('subject_sentence')) {
      existing.subjectSentence = payload['subject_sentence']?.toString() ?? '';
    }
    if (payload.containsKey('aim')) {
      existing.aim = payload['aim']?.toString() ?? '';
    }
    if (payload.containsKey('fcf')) {
      existing.fcf = payload['fcf']?.toString() ?? '';
    }
    if (payload.containsKey('updated_at')) {
      final raw = payload['updated_at'];
      if (raw != null) {
        existing.updatedAt = DateTime.tryParse(raw.toString());
      }
    }
    await _updateHomiletic(existing);
  }

  Future<void> _deleteLocalHomileticByUuid(String uuid) async {
    final h = await _getHomileticByUuid(uuid);
    if (h == null) return;
    await _deleteApplicationByHomileticId(h.id);
    await _deleteSummaryByHomileticId(h.id);
    await _deleteDivisionByHomileticId(h.id);
    await _deleteHomiletic(h);
  }

  Future<Map<String, dynamic>> _homileticToBackupItem(Homiletic h) async {
    final divisions = await _getDivisionsByHomileticId(h.id);
    final summaries = await _getSummariesByHomileticId(h.id);
    final applications = await _getApplicationsByHomileticId(h.id);
    return {
      'homiletic': h.toJson(),
      'divisions': divisions.map((d) => d.toJson()).toList(),
      'content_summaries': summaries.map((s) => s.toJson()).toList(),
      'applications': applications.map((a) => a.toJson()).toList(),
    };
  }

  bool _shouldSeedEmptyServer({
    required List<Homiletic> localHomiletics,
    required List<dynamic>? remoteData,
  }) {
    return (remoteData == null || remoteData.isEmpty) &&
        localHomiletics.isNotEmpty;
  }

  bool _shouldPushAfterUserTriggeredSync({
    required List<Homiletic> localHomiletics,
    required List<dynamic>? remoteData,
  }) {
    if (_shouldSeedEmptyServer(
      localHomiletics: localHomiletics,
      remoteData: remoteData,
    )) {
      return true;
    }
    if (remoteData == null || remoteData.isEmpty) {
      return false;
    }
    final remoteUuids = _extractRemoteUuids(remoteData);
    for (final homiletic in localHomiletics) {
      final uuid = homiletic.uuid?.trim();
      if (uuid != null && uuid.isNotEmpty && !remoteUuids.contains(uuid)) {
        return true;
      }
    }
    return false;
  }

  Set<String> _extractRemoteUuids(List<dynamic> remoteData) {
    final uuids = <String>{};
    for (final item in remoteData) {
      if (item is! Map) continue;
      final rawHomiletic = item['homiletic'];
      if (rawHomiletic is! Map) continue;
      final uuid = rawHomiletic['uuid']?.toString().trim();
      if (uuid != null && uuid.isNotEmpty) {
        uuids.add(uuid);
      }
    }
    return uuids;
  }

  Future<void> _mergePayloadIntoLocal(List<dynamic> data) async {
    for (final item in data) {
      if (item is! Map) continue;
      await _mergeSingleItem(Map<String, dynamic>.from(item));
    }
  }

  Future<void> _mergeSingleItem(Map<String, dynamic> map) async {
    final homileticJson = map['homiletic'] as Map<String, dynamic>;
    final uuid = (homileticJson['uuid'] as String?)?.trim();
    if (uuid == null || uuid.isEmpty) return;

    final existing = await _getHomileticByUuid(uuid);
    final fromServer = Homiletic.fromJson(homileticJson);

    if (existing != null) {
      existing.passage = fromServer.passage;
      existing.subjectSentence = fromServer.subjectSentence;
      existing.aim = fromServer.aim;
      existing.updatedAt = fromServer.updatedAt;
      existing.fcf = fromServer.fcf;
      await _updateHomiletic(existing);
      await _deleteApplicationByHomileticId(existing.id);
      await _deleteSummaryByHomileticId(existing.id);
      await _deleteDivisionByHomileticId(existing.id);
      final newId = existing.id;
      final divisions = map['divisions'] as List<dynamic>? ?? [];
      for (final d in divisions) {
        final divMap = Map<String, dynamic>.from(d as Map);
        divMap['homiletic_id'] = newId;
        divMap.remove('id');
        final div = Division.fromJson(divMap);
        div.id = null;
        await _insertDivision(div);
      }
      final summaries = map['content_summaries'] as List<dynamic>? ?? [];
      for (final s in summaries) {
        final sumMap = Map<String, dynamic>.from(s as Map);
        sumMap['homiletic_id'] = newId;
        sumMap.remove('id');
        await _insertSummary(ContentSummary.fromJson(sumMap));
      }
      final applications = map['applications'] as List<dynamic>? ?? [];
      for (final a in applications) {
        final appMap = Map<String, dynamic>.from(a as Map);
        appMap['homiletic_id'] = newId;
        appMap.remove('id');
        await _insertApplication(Application.fromJson(appMap));
      }
    } else {
      fromServer.id = -1;
      final newId = await _insertHomiletic(fromServer);
      final divisions = map['divisions'] as List<dynamic>? ?? [];
      for (final d in divisions) {
        final divMap = Map<String, dynamic>.from(d as Map);
        divMap['homiletic_id'] = newId;
        divMap.remove('id');
        final div = Division.fromJson(divMap);
        div.id = null;
        await _insertDivision(div);
      }
      final summaries = map['content_summaries'] as List<dynamic>? ?? [];
      for (final s in summaries) {
        final sumMap = Map<String, dynamic>.from(s as Map);
        sumMap['homiletic_id'] = newId;
        sumMap.remove('id');
        await _insertSummary(ContentSummary.fromJson(sumMap));
      }
      final applications = map['applications'] as List<dynamic>? ?? [];
      for (final a in applications) {
        final appMap = Map<String, dynamic>.from(a as Map);
        appMap['homiletic_id'] = newId;
        appMap.remove('id');
        await _insertApplication(Application.fromJson(appMap));
      }
    }
  }
}
