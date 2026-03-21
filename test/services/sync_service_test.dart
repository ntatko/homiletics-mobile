import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/services/sync_api_client.dart';
import 'package:homiletics/services/sync_service.dart';
import 'package:homiletics/storage/operational_sync_storage.dart';
import 'package:homiletics/sync_trigger.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('SyncService', () {
    setUp(() async {
      await resetReplicationMeta();
    });

    tearDown(() {
      onSyncDataChanged = null;
    });

    test('syncNowIfSignedIn merges snapshot and pushes local-only homiletics', () async {
      final localHomiletics = <Homiletic>[
        _homiletic(id: 1, uuid: 'local-1'),
      ];
      final apiClient = _FakeSyncApiClient(
        snapshotResult: {
          'data': [
            _remoteHomileticPayload(uuid: 'remote-1', id: 21),
          ],
          'last_seq': 0,
        },
      );
      final service = _buildService(
        apiClient: apiClient,
        currentHomiletics: localHomiletics,
      );

      await service.syncNowIfSignedIn();
      await Future<void>.delayed(Duration.zero);

      expect(apiClient.postOpsBodies, isNotEmpty);
      final body = jsonDecode(apiClient.postOpsBodies.first) as Map<String, dynamic>;
      expect(body['device_id'], isNotEmpty);
      final ops = body['ops'] as List<dynamic>?;
      expect(ops, isNotEmpty);
      expect(ops!.first['op_type'], 'homiletic.put');
    });

    test('pullIfSignedIn stays pull-only for passive sync triggers', () async {
      final localHomiletics = <Homiletic>[
        _homiletic(id: 1, uuid: 'local-1'),
      ];
      final apiClient = _FakeSyncApiClient(
        snapshotResult: {
          'data': [
            _remoteHomileticPayload(uuid: 'remote-1', id: 21),
          ],
          'last_seq': 0,
        },
      );
      final service = _buildService(
        apiClient: apiClient,
        currentHomiletics: localHomiletics,
      );

      await service.pullIfSignedIn();
      await Future<void>.delayed(Duration.zero);

      expect(apiClient.postOpsBodies, isEmpty);
    });

    test('schedulePush enqueues homiletic.put via outbox', () async {
      final localHomiletics = <Homiletic>[
        _homiletic(id: 1, uuid: 'local-1'),
      ];
      final apiClient = _FakeSyncApiClient(
        snapshotResult: {'data': [], 'last_seq': 0},
      );
      final service = _buildService(
        apiClient: apiClient,
        currentHomiletics: localHomiletics,
      );
      triggerSyncPush(homileticUuid: 'local-1');
      await service.schedulePush();

      expect(apiClient.postOpsBodies, hasLength(1));
    });
  });
}

SyncService _buildService({
  required _FakeSyncApiClient apiClient,
  required List<Homiletic> currentHomiletics,
}) {
  return SyncService(
    apiClient: apiClient,
    deviceIdForOpsFn: () async => 'test-device',
    isSignedInChecker: () async => true,
    ensureAllHomileticsHaveUuidsFn: () async {
      for (var i = 0; i < currentHomiletics.length; i++) {
        final homiletic = currentHomiletics[i];
        if (homiletic.uuid != null && homiletic.uuid!.isNotEmpty) continue;
        homiletic.uuid = 'generated-${homiletic.id}';
      }
      return List<Homiletic>.from(currentHomiletics);
    },
    getDivisionsByHomileticIdFn: (_) async => <Division>[],
    getSummariesByHomileticIdFn: (_) async => <ContentSummary>[],
    getApplicationsByHomileticIdFn: (_) async => <Application>[],
    getHomileticByUuidFn: (uuid) async {
      for (final homiletic in currentHomiletics) {
        if (homiletic.uuid == uuid) return homiletic;
      }
      return null;
    },
    updateHomileticFn: (_) async {},
    deleteApplicationByHomileticIdFn: (_) async => <Application>[],
    deleteSummaryByHomileticIdFn: (_) async => <ContentSummary>[],
    deleteDivisionByHomileticIdFn: (_) async => <Division>[],
    insertDivisionFn: (_) async => 1,
    insertSummaryFn: (_) async => 1,
    insertApplicationFn: (_) async => 1,
    insertHomileticFn: (homiletic) async {
      homiletic.id = currentHomiletics.length + 1;
      currentHomiletics.add(homiletic);
      return homiletic.id;
    },
    deleteHomileticFn: (_) async {},
    debounceDuration: Duration.zero,
  );
}

Homiletic _homiletic({
  required int id,
  required String uuid,
}) {
  return Homiletic(
    id: id,
    uuid: uuid,
    passage: 'John 3:16',
    subjectSentence: 'God loves the world',
    aim: 'Trust Christ',
    fcf: 'We doubt grace',
    updatedAt: DateTime.utc(2026, 3, 19, 12),
  );
}

Map<String, dynamic> _remoteHomileticPayload({
  required String uuid,
  required int id,
}) {
  return {
    'homiletic': {
      'id': id,
      'uuid': uuid,
      'passage': 'Romans 8:1',
      'subject_sentence': 'No condemnation remains',
      'aim': 'Rest in Christ',
      'updated_at': DateTime.utc(2026, 3, 19, 13).toIso8601String(),
      'fcf': 'We fear judgment',
    },
    'divisions': <Map<String, dynamic>>[],
    'content_summaries': <Map<String, dynamic>>[],
    'applications': <Map<String, dynamic>>[],
  };
}

class _FakeSyncApiClient implements SyncApiClient {
  _FakeSyncApiClient({
    required this.snapshotResult,
    Map<String, dynamic>? opsResult,
  }) : opsResult = opsResult ?? const {'ops': <dynamic>[], 'last_seq': 0};

  final Map<String, dynamic> snapshotResult;
  final Map<String, dynamic> opsResult;
  final List<String> postOpsBodies = <String>[];

  @override
  Future<Map<String, dynamic>> postSyncOps(String bodyJson) async {
    postOpsBodies.add(bodyJson);
    final decoded = jsonDecode(bodyJson) as Map<String, dynamic>;
    final ops = decoded['ops'] as List<dynamic>? ?? [];
    final results = <Map<String, dynamic>>[];
    var seq = 0;
    for (final o in ops) {
      if (o is! Map) continue;
      seq++;
      results.add({
        'client_mutation_id': o['client_mutation_id'],
        'server_seq': seq,
        'duplicate': false,
      });
    }
    return {'last_seq': seq, 'results': results};
  }

  @override
  Future<Map<String, dynamic>> getSyncSnapshot() async => snapshotResult;

  @override
  Future<Map<String, dynamic>> getSyncOpsSince(int sinceSeq) async => opsResult;

  @override
  Future<int> requestCode(String email) async => 600;

  @override
  Future<Map<String, dynamic>> verifyCode(String email, String code) async =>
      <String, dynamic>{};

  @override
  Future<bool> tryRefreshTokens() async => false;

  @override
  Future<void> logoutOnServer() async {}
}
