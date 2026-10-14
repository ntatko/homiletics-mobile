import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:homiletics/classes/translation.dart';
import 'package:homiletics/services/bible_text.dart';
import 'package:homiletics/services/bible_text_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'bible_text_test.dart' show sampleBibleJson;

List<int> _gz(Map<String, dynamic> json) =>
    gzip.encode(utf8.encode(jsonEncode(json)));

void main() {
  late Directory dir;
  late List<Uri> requested;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('bibles_test');
    requested = [];
  });

  tearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  BibleTextService service(
    Future<http.Response> Function(http.Request request) handler, {
    int minBytes = 10,
  }) =>
      BibleTextService(
        directory: () async => dir,
        client: () => MockClient((request) {
          requested.add(request.url);
          return handler(request);
        }),
        decoder: (bytes) async => BibleText.decodeGzip(bytes),
        minBytes: minBytes,
        maxBytes: 1024 * 1024,
      );

  test('downloads from GitHub raw into the directory, then loads', () async {
    final s =
        service((_) async => http.Response.bytes(_gz(sampleBibleJson()), 200));
    expect(await s.isDownloaded(Translation.web), isFalse);
    expect(await s.load(Translation.web), isNull);

    expect(await s.download(Translation.web), isTrue);
    expect(requested.single.toString(),
        'https://raw.githubusercontent.com/ntatko/homiletics-mobile/refs/heads/main/data/bibles/web.json.gz');
    expect(File('${dir.path}/web.json.gz').existsSync(), isTrue);
    expect(File('${dir.path}/web.json.gz.part').existsSync(), isFalse);
    expect(await s.isDownloaded(Translation.web), isTrue);
    expect(await s.downloadedSize(Translation.web), greaterThan(0));
    final text = await s.load(Translation.web);
    expect(text!.books['ROM'], isNotNull);

    // A fresh service (next app launch) finds the file on disk.
    final again = service((_) async => http.Response('nope', 500));
    expect(await again.isDownloaded(Translation.web), isTrue);
    expect((await again.load(Translation.web))!.code, 'web');
  });

  test('concurrent downloads share one request', () async {
    final s =
        service((_) async => http.Response.bytes(_gz(sampleBibleJson()), 200));
    final results = await Future.wait(
        [s.download(Translation.web), s.download(Translation.web)]);
    expect(results, [true, true]);
    expect(requested.length, 1);
  });

  test('keeps nothing when the server fails or sends junk', () async {
    for (final response in <http.Response Function()>[
      () => http.Response('Not found', 404),
      () => http.Response('<html>error</html>', 200),
      () => http.Response.bytes(gzip.encode(utf8.encode('{"format":9}')), 200),
      // A different translation's file.
      () => http.Response.bytes(_gz(sampleBibleJson(code: 'kjv')), 200),
    ]) {
      final s = service((_) async => response());
      expect(await s.download(Translation.web), isFalse);
      expect(await s.isDownloaded(Translation.web), isFalse);
      expect(dir.listSync(), isEmpty);
    }
  });

  test('refuses files that are too small or too large', () async {
    final small = service(
        (_) async => http.Response.bytes(_gz(sampleBibleJson()), 200),
        minBytes: 1024 * 1024);
    expect(await small.download(Translation.web), isFalse);

    final big = service((_) async =>
        http.Response.bytes(List<int>.filled(2 * 1024 * 1024, 0), 200));
    expect(await big.download(Translation.web), isFalse);
    expect(dir.listSync(), isEmpty);
  });

  test('network errors fail the download instead of throwing', () async {
    final s = service((_) async => throw const SocketException('offline'));
    expect(await s.download(Translation.web), isFalse);
  });

  test('translations without an offline text are never fetched', () async {
    final s = service((_) async => http.Response('x', 200));
    expect(await s.download(Translation.niv), isFalse);
    expect(await s.autoDownload(Translation.niv), isFalse);
    expect(requested, isEmpty);
  });

  test('auto-download tries once per session', () async {
    final s = service((_) async => http.Response('down', 503));
    expect(await s.autoDownload(Translation.web), isFalse);
    expect(await s.autoDownload(Translation.web), isFalse);
    expect(requested.length, 1);
    // An explicit download still retries.
    await s.download(Translation.web);
    expect(requested.length, 2);
  });

  test('delete removes the file; a corrupt file is removed on load', () async {
    final s =
        service((_) async => http.Response.bytes(_gz(sampleBibleJson()), 200));
    await s.download(Translation.web);
    await s.delete(Translation.web);
    expect(await s.isDownloaded(Translation.web), isFalse);
    expect(dir.listSync(), isEmpty);

    File('${dir.path}/web.json.gz').writeAsStringSync('garbage');
    final fresh = service((_) async => http.Response('x', 500));
    expect(await fresh.isDownloaded(Translation.web), isTrue);
    expect(await fresh.load(Translation.web), isNull);
    expect(await fresh.isDownloaded(Translation.web), isFalse);
  });

  test('notifies listeners as downloads start and finish', () async {
    final s =
        service((_) async => http.Response.bytes(_gz(sampleBibleJson()), 200));
    int changes = 0;
    s.changes.addListener(() => changes++);
    await s.download(Translation.web);
    expect(changes, greaterThanOrEqualTo(2));
    expect(s.isDownloading(Translation.web), isFalse);
  });

  test('formatBibleSize', () {
    expect(formatBibleSize(1291688), '1.2 MB');
    expect(formatBibleSize(15 * 1024 * 1024), '15 MB');
  });
}
