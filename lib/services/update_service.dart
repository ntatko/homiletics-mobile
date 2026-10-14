import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// The GitHub release that the update check reads. `/latest` already skips
/// drafts and pre-releases.
final Uri kLatestReleaseUri = Uri.parse(
    'https://api.github.com/repos/ntatko/homiletics-mobile/releases/latest');

/// Where portable (zip) installs send people to download a new version.
final Uri kWindowsDownloadPage =
    Uri.parse('https://homiletics.app/download#windows');

/// The installer asset name the release workflow publishes.
const String kSetupAssetName = 'Homiletics-Setup.exe';

/// Written next to Homiletics.exe by the Inno Setup installer
/// (installer/windows/homiletics.iss). Portable zip copies don't have it.
const String kInstallMarkerName = 'install.ini';

/// Parses "v3.0.0" / "3.0.0" / "3.0.0+37" into [major, minor, patch].
/// Returns null for anything else, including pre-release tags
/// ("v3.1.0-beta.1"), so a malformed tag never offers an update.
@visibleForTesting
List<int>? parseVersion(String? tag) {
  if (tag == null) return null;
  final RegExpMatch? m =
      RegExp(r'^v?(\d+)\.(\d+)\.(\d+)(?:\+\d+)?$').firstMatch(tag.trim());
  if (m == null) return null;
  return [for (int i = 1; i <= 3; i++) int.parse(m.group(i)!)];
}

/// Whether [candidate] is a newer version than [current]. False when
/// either can't be parsed.
bool isNewerVersion(String? candidate, String? current) {
  final List<int>? a = parseVersion(candidate);
  final List<int>? b = parseVersion(current);
  if (a == null || b == null) return false;
  for (int i = 0; i < 3; i++) {
    if (a[i] != b[i]) return a[i] > b[i];
  }
  return false;
}

/// A downloadable file attached to a release.
class ReleaseAsset {
  final String name;
  final Uri url;
  final int size;

  const ReleaseAsset(
      {required this.name, required this.url, required this.size});
}

/// The parts of a GitHub release the updater uses.
class ReleaseInfo {
  /// "3.1.0" (no leading v).
  final String version;
  final String notes;
  final Uri? pageUrl;

  /// The Windows installer, if the release has a trustworthy one.
  final ReleaseAsset? setup;

  const ReleaseInfo({
    required this.version,
    required this.notes,
    this.pageUrl,
    this.setup,
  });

  /// Parses a GitHub `releases/latest` response. Returns null if it isn't
  /// a usable release (draft, pre-release, or malformed tag).
  static ReleaseInfo? fromJson(Map<String, dynamic> json) {
    if (json['draft'] == true || json['prerelease'] == true) return null;
    final String? tag = json['tag_name'] as String?;
    final List<int>? v = parseVersion(tag);
    if (v == null) return null;

    ReleaseAsset? setup;
    final Object? assets = json['assets'];
    if (assets is List) {
      for (final Object? a in assets) {
        if (a is! Map) continue;
        if (a['name'] != kSetupAssetName) continue;
        final Uri? url = Uri.tryParse('${a['browser_download_url']}');
        final Object? size = a['size'];
        if (url == null ||
            !isTrustedAssetUrl(url) ||
            size is! int ||
            size <= 0) {
          continue;
        }
        setup = ReleaseAsset(name: kSetupAssetName, url: url, size: size);
        break;
      }
    }
    final Uri? page = Uri.tryParse('${json['html_url'] ?? ''}');
    return ReleaseInfo(
      version: v.join('.'),
      notes: (json['body'] as String? ?? '').trim(),
      pageUrl:
          page != null && page.scheme == 'https' && page.host == 'github.com'
              ? page
              : null,
      setup: setup,
    );
  }

  /// The release notes as plain text, shortened for the update prompt.
  String notesSnippet({int maxLength = 400}) {
    String text = notes
        .replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '')
        .replaceAll(RegExp(r'^#+\s*', multiLine: true), '')
        .replaceAll(RegExp(r'\*\*|__|`'), '')
        .replaceAll(RegExp(r'^\s*[-*]\s+', multiLine: true), '• ')
        .replaceAllMapped(RegExp(r'\[([^\]]+)\]\([^)]+\)'), (m) => m.group(1)!)
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
    if (text.length > maxLength) {
      text = '${text.substring(0, maxLength).trimRight()}…';
    }
    return text;
  }
}

/// Only installers published as this repo's release assets are downloaded.
@visibleForTesting
bool isTrustedAssetUrl(Uri url) =>
    url.scheme == 'https' &&
    url.host == 'github.com' &&
    url.path.startsWith('/ntatko/homiletics-mobile/releases/download/');

/// The result of a check: [release] is set when a newer version exists.
class UpdateCheck {
  final String currentVersion;
  final ReleaseInfo? release;

  const UpdateCheck(this.currentVersion, this.release);

  bool get hasUpdate => release != null;
}

/// Checks GitHub for a newer Windows release and installs it. Does nothing
/// (and makes no network calls) on other platforms, which update through
/// their stores.
class UpdateService {
  UpdateService._();

  static const Duration _checkInterval = Duration(hours: 24);

  static bool get isSupported => !kIsWeb && Platform.isWindows;

  /// Whether this copy was installed by Homiletics-Setup.exe, so it can
  /// update itself. Portable zip copies are updated by hand.
  static bool get isInstalledBySetup {
    if (!isSupported) return false;
    try {
      final String dir = path.dirname(Platform.resolvedExecutable);
      return File(path.join(dir, kInstallMarkerName)).existsSync() &&
          File(path.join(dir, 'unins000.exe')).existsSync();
    } catch (_) {
      return false;
    }
  }

  /// Looks for an update. Throws on network or server errors.
  static Future<UpdateCheck> check() async {
    final String current = (await PackageInfo.fromPlatform()).version;
    final http.Response response = await http.get(kLatestReleaseUri, headers: {
      'Accept': 'application/vnd.github+json',
      'User-Agent': 'Homiletics/$current',
    }).timeout(const Duration(seconds: 15));
    if (response.statusCode == 404) {
      // No published release yet.
      return UpdateCheck(current, null);
    }
    if (response.statusCode != 200) {
      throw HttpException('Update check: HTTP ${response.statusCode}');
    }
    final ReleaseInfo? release =
        ReleaseInfo.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    Preferences.lastUpdateCheck = DateTime.now();
    if (release == null || !isNewerVersion(release.version, current)) {
      return UpdateCheck(current, null);
    }
    return UpdateCheck(current, release);
  }

  /// The launch check: at most once a day, silent on errors, and quiet
  /// about a version the user chose to skip.
  static Future<UpdateCheck?> checkOnLaunch() async {
    if (!isSupported) return null;
    final DateTime? last = Preferences.lastUpdateCheck;
    if (last != null && DateTime.now().difference(last) < _checkInterval) {
      return null;
    }
    try {
      final UpdateCheck result = await check();
      final ReleaseInfo? release = result.release;
      if (release == null ||
          release.version == Preferences.skippedUpdateVersion) {
        return null;
      }
      return result;
    } catch (_) {
      return null;
    }
  }

  /// Downloads [asset] to the temp folder, reporting progress from 0 to 1,
  /// and returns the file. Throws if the download fails or is the wrong size.
  static Future<File> download(ReleaseAsset asset,
      {void Function(double progress)? onProgress}) async {
    if (!isTrustedAssetUrl(asset.url)) {
      throw StateError('Untrusted update URL');
    }
    final Directory dir = Directory(
        path.join((await getTemporaryDirectory()).path, 'homiletics-update'));
    await dir.create(recursive: true);
    final File file = File(path.join(dir.path, asset.name));
    final http.Client client = http.Client();
    try {
      final http.StreamedResponse response = await client
          .send(http.Request('GET', asset.url))
          .timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) {
        throw HttpException('Update download: HTTP ${response.statusCode}');
      }
      final IOSink sink = file.openWrite();
      int received = 0;
      try {
        await for (final List<int> chunk
            in response.stream.timeout(const Duration(seconds: 60))) {
          received += chunk.length;
          if (received > asset.size) {
            throw const FileSystemException('Update download is too large');
          }
          sink.add(chunk);
          onProgress?.call(received / asset.size);
        }
      } finally {
        await sink.close();
      }
      if (received != asset.size) {
        throw FileSystemException(
            'Update download is incomplete ($received of ${asset.size} bytes)');
      }
      return file;
    } catch (_) {
      if (await file.exists()) await file.delete();
      rethrow;
    } finally {
      client.close();
    }
  }

  /// Runs the downloaded installer silently and quits, so it can replace
  /// the app's files. The installer reuses the existing install's
  /// per-user / all-users mode (Inno's UsePreviousPrivileges) and reopens
  /// Homiletics when it's done.
  static Future<void> installAndExit(File setup) async {
    await Process.start(
      setup.path,
      [
        '/SILENT',
        '/SUPPRESSMSGBOXES',
        '/CLOSEAPPLICATIONS',
        '/NORESTART',
        '/RELAUNCH=1',
      ],
      mode: ProcessStartMode.detached,
    );
    exit(0);
  }
}
