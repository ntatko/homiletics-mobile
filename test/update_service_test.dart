import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:homiletics/services/update_service.dart';

Map<String, dynamic> _release({
  String tag = 'v3.1.0',
  bool draft = false,
  bool prerelease = false,
  String body = '',
  List<Map<String, dynamic>>? assets,
}) =>
    {
      'tag_name': tag,
      'draft': draft,
      'prerelease': prerelease,
      'body': body,
      'html_url':
          'https://github.com/ntatko/homiletics-mobile/releases/tag/$tag',
      'assets': assets ??
          [
            {
              'name': 'Homiletics-Windows.zip',
              'size': 90000000,
              'browser_download_url':
                  'https://github.com/ntatko/homiletics-mobile/releases/download/$tag/Homiletics-Windows.zip',
            },
            {
              'name': 'Homiletics-Setup.exe',
              'size': 70000000,
              'browser_download_url':
                  'https://github.com/ntatko/homiletics-mobile/releases/download/$tag/Homiletics-Setup.exe',
            },
          ],
    };

void main() {
  group('parseVersion', () {
    test('accepts v-prefixed, bare and build-numbered versions', () {
      expect(parseVersion('v3.0.0'), [3, 0, 0]);
      expect(parseVersion('3.10.2'), [3, 10, 2]);
      expect(parseVersion('3.0.0+37'), [3, 0, 0]);
      expect(parseVersion(' v4.0.1 '), [4, 0, 1]);
    });

    test('rejects malformed and pre-release tags', () {
      for (final String? tag in [
        null,
        '',
        'v3',
        'v3.0',
        'latest',
        'v3.1.0-beta.1',
        'v3.0.0.1',
        'version 3.0.0',
      ]) {
        expect(parseVersion(tag), isNull, reason: '$tag');
      }
    });
  });

  group('isNewerVersion', () {
    test('compares numerically, not as text', () {
      expect(isNewerVersion('v3.10.0', '3.9.9'), isTrue);
      expect(isNewerVersion('v3.0.1', '3.0.0'), isTrue);
      expect(isNewerVersion('v4.0.0', '3.99.99'), isTrue);
      expect(isNewerVersion('v3.9.0', '3.10.0'), isFalse);
    });

    test('same or older is not newer, whatever the build number', () {
      expect(isNewerVersion('v3.0.0', '3.0.0'), isFalse);
      expect(isNewerVersion('v3.0.0', '3.0.0+37'), isFalse);
      expect(isNewerVersion('v2.9.0', '3.0.0'), isFalse);
    });

    test('malformed versions never offer an update', () {
      expect(isNewerVersion('v9.0.0-beta', '3.0.0'), isFalse);
      expect(isNewerVersion('nightly', '3.0.0'), isFalse);
      expect(isNewerVersion('v9.0.0', 'unknown'), isFalse);
    });
  });

  group('ReleaseInfo.fromJson', () {
    test('picks the installer asset', () {
      final ReleaseInfo r = ReleaseInfo.fromJson(_release())!;
      expect(r.version, '3.1.0');
      expect(r.setup, isNotNull);
      expect(r.setup!.name, 'Homiletics-Setup.exe');
      expect(r.setup!.size, 70000000);
      expect(r.setup!.url.path,
          '/ntatko/homiletics-mobile/releases/download/v3.1.0/Homiletics-Setup.exe');
      expect(r.pageUrl!.host, 'github.com');
    });

    test('no installer asset: still a release, without self-update', () {
      final ReleaseInfo r = ReleaseInfo.fromJson(_release(assets: []))!;
      expect(r.version, '3.1.0');
      expect(r.setup, isNull);
    });

    test('ignores installers hosted anywhere else', () {
      for (final String url in [
        'https://evil.example/Homiletics-Setup.exe',
        'http://github.com/ntatko/homiletics-mobile/releases/download/v3.1.0/Homiletics-Setup.exe',
        'https://github.com/someone-else/homiletics-mobile/releases/download/v3.1.0/Homiletics-Setup.exe',
        'https://github.com.evil.example/ntatko/homiletics-mobile/releases/download/v3.1.0/Homiletics-Setup.exe',
      ]) {
        final ReleaseInfo r = ReleaseInfo.fromJson(_release(assets: [
          {
            'name': 'Homiletics-Setup.exe',
            'size': 10,
            'browser_download_url': url
          }
        ]))!;
        expect(r.setup, isNull, reason: url);
      }
    });

    test('ignores an installer with a missing or bad size', () {
      for (final Object? size in [null, 0, -1, '70000000']) {
        final ReleaseInfo r = ReleaseInfo.fromJson(_release(assets: [
          {
            'name': 'Homiletics-Setup.exe',
            'size': size,
            'browser_download_url':
                'https://github.com/ntatko/homiletics-mobile/releases/download/v3.1.0/Homiletics-Setup.exe',
          }
        ]))!;
        expect(r.setup, isNull, reason: '$size');
      }
    });

    test('drafts, pre-releases and malformed tags are not releases', () {
      expect(ReleaseInfo.fromJson(_release(draft: true)), isNull);
      expect(ReleaseInfo.fromJson(_release(prerelease: true)), isNull);
      expect(ReleaseInfo.fromJson(_release(tag: 'v3.1.0-rc.1')), isNull);
      expect(ReleaseInfo.fromJson(_release(tag: 'nightly')), isNull);
      expect(ReleaseInfo.fromJson({}), isNull);
    });
  });

  group('notesSnippet', () {
    test('turns GitHub markdown into short plain text', () {
      final ReleaseInfo r = ReleaseInfo.fromJson(_release(
          body: "<!-- generated -->\n## What's Changed\n"
              '* **Backups** in Settings by @ntatko in [#70](https://github.com/x/pull/70)\n'
              '* Faster `search`\n'))!;
      expect(r.notesSnippet(),
          "What's Changed\n• Backups in Settings by @ntatko in #70\n• Faster search");
    });

    test('is capped', () {
      final ReleaseInfo r = ReleaseInfo.fromJson(_release(body: 'a' * 1000))!;
      expect(r.notesSnippet(maxLength: 50).length, 51);
      expect(r.notesSnippet(maxLength: 50), endsWith('…'));
    });
  });

  test('isTrustedAssetUrl only allows this repo on github.com', () {
    expect(
        isTrustedAssetUrl(Uri.parse(
            'https://github.com/ntatko/homiletics-mobile/releases/download/v3.1.0/Homiletics-Setup.exe')),
        isTrue);
    expect(
        isTrustedAssetUrl(Uri.parse(
            'https://objects.githubusercontent.com/whatever/Homiletics-Setup.exe')),
        isFalse);
  });

  test('UpdateService does nothing off Windows', () {
    expect(UpdateService.isSupported, isFalse);
    expect(UpdateService.isInstalledBySetup, isFalse);
  }, skip: Platform.isWindows);
}
