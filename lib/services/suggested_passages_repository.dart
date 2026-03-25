import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:homiletics/classes/passage_schedule.dart';
import 'package:homiletics/config/suggested_passages_config.dart';
import 'package:http/http.dart' as http;

class SuggestedPassagesRepository {
  static const String _boxName = 'suggested_passages';
  static const String _payloadKey = 'json';

  static Future<void> init() => Hive.openBox<dynamic>(_boxName);

  static Future<Box<dynamic>> _box() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<dynamic>(_boxName);
    }
    return Hive.openBox<dynamic>(_boxName);
  }

  static List<PassageSchedule>? _parseBody(String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final data = decoded['data'] as List<dynamic>?;
      if (data == null) return null;
      final list = data
          .map((e) =>
              PassageSchedule.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      list.sort((a, b) => a.rollout.compareTo(b.rollout));
      return list;
    } catch (_) {
      return null;
    }
  }

  /// Last successful response body, or null.
  static Future<String?> readCachedRaw() async {
    final box = await _box();
    final raw = box.get(_payloadKey);
    if (raw is! String || raw.isEmpty) return null;
    return raw;
  }

  static Future<List<PassageSchedule>?> readCachedSchedules() async {
    final raw = await readCachedRaw();
    if (raw == null) return null;
    return _parseBody(raw);
  }

  static Future<void> writeCacheRaw(String body) async {
    final box = await _box();
    await box.put(_payloadKey, body);
  }

  /// Cache-first: returns cached list immediately when possible, then refreshes from GitHub.
  /// On network failure, keeps showing [initial] if non-null.
  static Future<void> loadWithCallback({
    required void Function(List<PassageSchedule> schedules) onData,
    void Function(Object error, StackTrace stack)? onError,
  }) async {
    final cached = await readCachedSchedules();
    if (cached != null && cached.isNotEmpty) {
      onData(cached);
    }

    try {
      final response =
          await http.get(Uri.parse(kSuggestedPassagesUrl)).timeout(
                const Duration(seconds: 30),
              );
      if (response.statusCode != 200) {
        throw Exception(
            'Suggested passages HTTP ${response.statusCode}');
      }
      final parsed = _parseBody(response.body);
      if (parsed == null) {
        throw const FormatException('Invalid suggested passages JSON');
      }
      await writeCacheRaw(response.body);
      onData(parsed);
    } catch (e, st) {
      onError?.call(e, st);
    }
  }
}
