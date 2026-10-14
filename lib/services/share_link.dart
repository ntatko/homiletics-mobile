import 'dart:convert';
import 'dart:io' show ZLibDecoder, ZLibEncoder;
import 'dart:typed_data';

import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/classes/word_study.dart';

/// Share links (format v1, see docs/SHARE_LINKS.md): a whole study packed
/// into the URL fragment as base64url(raw DEFLATE(UTF-8 JSON envelope)).
///
///     https://homiletics.app/view#h=<payload>   homiletic
///     https://homiletics.app/view#w=<payload>   word study
///     homiletics://view#h=<payload>             custom scheme
///
/// The website implements the same decoder, so any change here must follow
/// the spec (and its test vectors) exactly.
class ShareLink {
  ShareLink._();

  /// The newest envelope version this app reads and the one it writes.
  static const int version = 1;

  static const String webHost = 'homiletics.app';
  static const String webPath = '/view';
  static const String scheme = 'homiletics';

  /// Links longer than this may be cut off by some apps; warn before
  /// sharing (but still allow it).
  static const int recommendedMaxLength = 8000;

  /// Hard cap on the decompressed JSON, so a crafted link can't exhaust
  /// memory.
  static const int maxDecodedBytes = 256 * 1024;

  /// A payload this long can't be a legitimate link (it would decompress
  /// past [maxDecodedBytes] at any sane ratio); rejected before decoding.
  static const int _maxPayloadChars = 512 * 1024;

  static final RegExp _payloadChars = RegExp(r'^[A-Za-z0-9_-]+$');

  /// Finds a share link (either scheme) inside arbitrary pasted text.
  static final RegExp _linkInText = RegExp(
      r'(?:https?://(?:www\.)?homiletics\.app/view/?|homiletics://view/?)'
      r'#([hw])=([A-Za-z0-9_=-]*)',
      caseSensitive: false);

  // ---------------------------------------------------------------- encode

  /// The share link for a homiletic and its rows. Empty fields and rows
  /// are left out. [translation] is the sharer's Bible translation code.
  static String encodeHomiletic(
    Homiletic homiletic, {
    List<ContentSummary> summaries = const [],
    List<Division> divisions = const [],
    List<Application> applications = const [],
    String? translation,
  }) {
    return encodeStudy(SharedHomiletic(
      passage: homiletic.passage,
      contentSummaries: [
        for (final ContentSummary s in summaries)
          SharedRow(s.passage, s.summary),
      ],
      divisions: [
        for (final Division d in divisions) SharedRow(d.passage, d.title),
      ],
      subjectSentence: homiletic.subjectSentence,
      fcf: homiletic.fcf,
      aim: homiletic.aim,
      applications: [for (final Application a in applications) a.text],
      translation: translation,
      updatedAt: homiletic.updatedAt,
    ));
  }

  /// The share link for a word study.
  static String encodeWordStudy(WordStudy study, {String? translation}) {
    return encodeStudy(SharedWordStudy(
      passage: study.passage,
      word: study.word,
      definition: study.definition,
      otherUsage: study.otherUsage,
      contextualMeaning: study.contextualMeaning,
      deeperMeaning: study.deeperMeaning,
      application: study.application,
      translation: translation,
      updatedAt: study.updatedAt,
    ));
  }

  /// The https share link for [study].
  static String encodeStudy(SharedStudy study) {
    return 'https://$webHost$webPath#${study.typeCode}='
        '${encodePayload(study.toEnvelope())}';
  }

  /// base64url (no padding) of the raw-DEFLATE compressed JSON [envelope].
  static String encodePayload(Map<String, dynamic> envelope) {
    final List<int> json = utf8.encode(jsonEncode(envelope));
    final List<int> compressed = ZLibEncoder(raw: true, level: 9).convert(json);
    return base64Url.encode(compressed).replaceAll('=', '');
  }

  // ---------------------------------------------------------------- decode

  /// Whether [text] looks like it holds a share link or payload (cheap; no
  /// decoding). Used to offer "Open shared study" for pasted text.
  static bool looksLikeShareLink(String text) =>
      _linkInText.hasMatch(text.trim());

  /// Whether [uri] is addressed to the share-link viewer (either scheme),
  /// whatever its fragment holds.
  static bool isShareUri(Uri uri) {
    final String s = uri.scheme.toLowerCase();
    if (s == scheme) {
      return uri.host.toLowerCase() == 'view' ||
          uri.path == webPath ||
          uri.path == '$webPath/';
    }
    if (s == 'https' || s == 'http') {
      final String host = uri.host.toLowerCase();
      return (host == webHost || host == 'www.$webHost') &&
          (uri.path == webPath || uri.path == '$webPath/');
    }
    return false;
  }

  /// Decodes a share link (https or homiletics:// URL, possibly surrounded
  /// by other text), a bare `h=…` / `w=…` fragment, or a bare payload.
  static ShareLinkResult decode(String input) {
    final String text = input.trim();
    if (text.isEmpty) return const ShareLinkInvalid('empty');

    String? type;
    String payload;
    final RegExpMatch? match = _linkInText.firstMatch(text);
    if (match != null) {
      type = match.group(1)!.toLowerCase();
      payload = match.group(2)!;
    } else if (RegExp(r'^#?[hw]=', caseSensitive: false).hasMatch(text)) {
      final String fragment = text.startsWith('#') ? text.substring(1) : text;
      type = fragment[0].toLowerCase();
      payload = fragment.substring(2);
    } else if (text.contains('://')) {
      // Some other URL: maybe a share URI we didn't spot in the text form
      // (e.g. different casing); otherwise not ours.
      final Uri? uri = Uri.tryParse(text);
      if (uri == null || !isShareUri(uri)) {
        return const ShareLinkInvalid('not a share link');
      }
      return decodeUri(uri);
    } else {
      payload = text;
    }
    return decodePayload(payload, expectedType: type);
  }

  /// Decodes an incoming link (from the OS).
  static ShareLinkResult decodeUri(Uri uri) {
    if (!isShareUri(uri)) return const ShareLinkInvalid('not a share link');
    final String fragment = uri.fragment;
    final RegExpMatch? m =
        RegExp(r'^([hw])=(.*)$', caseSensitive: false).firstMatch(fragment);
    if (m == null) return const ShareLinkInvalid('no payload in fragment');
    return decodePayload(m.group(2)!, expectedType: m.group(1)!.toLowerCase());
  }

  /// Decodes a base64url payload. When [expectedType] ("h" / "w", from the
  /// fragment key) is given, the envelope's `t` must match it.
  static ShareLinkResult decodePayload(String payload, {String? expectedType}) {
    // Tolerate padding and stray line breaks from copy/paste.
    final String cleaned = payload.replaceAll(RegExp(r'[\s=]'), '');
    if (cleaned.isEmpty || cleaned.length > _maxPayloadChars) {
      return const ShareLinkInvalid('bad payload length');
    }
    if (!_payloadChars.hasMatch(cleaned) || cleaned.length % 4 == 1) {
      return const ShareLinkInvalid('not base64url');
    }

    final Uint8List compressed;
    try {
      compressed = base64Url.decode(base64Url.normalize(cleaned));
    } on FormatException {
      return const ShareLinkInvalid('not base64url');
    }

    final List<int>? json = _inflateCapped(compressed);
    if (json == null) return const ShareLinkInvalid('bad deflate data');

    final Object? envelope;
    try {
      envelope = jsonDecode(utf8.decode(json));
    } on FormatException {
      return const ShareLinkInvalid('not JSON');
    }
    return decodeEnvelope(envelope, expectedType: expectedType);
  }

  /// Validates a decoded JSON [envelope] and turns it into a study.
  static ShareLinkResult decodeEnvelope(Object? envelope,
      {String? expectedType}) {
    if (envelope is! Map<String, dynamic>) {
      return const ShareLinkInvalid('envelope is not an object');
    }
    final Object? v = envelope['v'];
    if (v is! num || v != v.roundToDouble() || v < 1) {
      return const ShareLinkInvalid('bad version');
    }
    if (v > version) return ShareLinkUnsupportedVersion(v.toInt());

    final Object? t = envelope['t'];
    if (t != 'h' && t != 'w') return const ShareLinkInvalid('bad type');
    if (expectedType != null && expectedType != t) {
      return const ShareLinkInvalid('type does not match link');
    }
    final Object? d = envelope['d'];
    if (d is! Map<String, dynamic>) {
      return const ShareLinkInvalid('data is not an object');
    }
    try {
      return ShareLinkSuccess(t == 'h'
          ? SharedHomiletic._fromData(d)
          : SharedWordStudy._fromData(d));
    } on _ShapeError catch (e) {
      return ShareLinkInvalid(e.message);
    }
  }

  /// Inflates raw DEFLATE [data], or returns null if it's corrupt or would
  /// grow past [maxDecodedBytes]. Input goes in small chunks so a bomb is
  /// stopped early instead of being fully expanded in memory.
  static List<int>? _inflateCapped(List<int> data) {
    final _CappedSink sink = _CappedSink(maxDecodedBytes);
    try {
      final ByteConversionSink input =
          ZLibDecoder(raw: true).startChunkedConversion(sink);
      const int chunk = 1024;
      for (int i = 0; i < data.length && !sink.overflowed; i += chunk) {
        final int end = i + chunk < data.length ? i + chunk : data.length;
        input.addSlice(data, i, end, false);
      }
      if (sink.overflowed) return null;
      input.close();
    } catch (_) {
      return null;
    }
    if (sink.overflowed || !sink.closed) return null;
    return sink.bytes.takeBytes();
  }
}

class _CappedSink implements Sink<List<int>> {
  final int limit;
  final BytesBuilder bytes = BytesBuilder(copy: false);
  bool overflowed = false;
  bool closed = false;

  _CappedSink(this.limit);

  @override
  void add(List<int> data) {
    if (overflowed) return;
    if (bytes.length + data.length > limit) {
      overflowed = true;
      bytes.clear();
      return;
    }
    bytes.add(data);
  }

  @override
  void close() => closed = true;
}

// ------------------------------------------------------------------ results

/// The outcome of decoding a share link.
sealed class ShareLinkResult {
  const ShareLinkResult();
}

class ShareLinkSuccess extends ShareLinkResult {
  final SharedStudy study;
  const ShareLinkSuccess(this.study);
}

/// The link was made by a newer app ("update Homiletics to open this").
class ShareLinkUnsupportedVersion extends ShareLinkResult {
  final int version;
  const ShareLinkUnsupportedVersion(this.version);
}

/// Not a share link, corrupt, or not the expected shape. [reason] is for
/// logs only, never shown to users.
class ShareLinkInvalid extends ShareLinkResult {
  final String reason;
  const ShareLinkInvalid(this.reason);

  @override
  String toString() => 'ShareLinkInvalid($reason)';
}

// ---------------------------------------------------------------- the data

/// A study carried by a share link (read-only; saving makes new records).
sealed class SharedStudy {
  /// Passage reference ('' when the link had none).
  final String passage;

  /// The sharer's Bible translation code, if given.
  final String? translation;

  /// When the sharer last edited it, if given.
  final DateTime? updatedAt;

  const SharedStudy({this.passage = '', this.translation, this.updatedAt});

  /// "h" or "w".
  String get typeCode;

  /// The data object (`d`), with empty fields left out.
  Map<String, dynamic> toData();

  /// The full `{"v":1,"t":…,"d":…}` envelope.
  Map<String, dynamic> toEnvelope() =>
      {'v': ShareLink.version, 't': typeCode, 'd': toData()};

  void _putCommon(Map<String, dynamic> d) {
    if (_has(translation)) d['tr'] = translation;
    if (updatedAt != null) d['u'] = _isoSeconds(updatedAt!);
  }
}

/// A verses + text row (content summary or division).
class SharedRow {
  final String verses;
  final String text;
  const SharedRow(this.verses, this.text);

  bool get isEmpty => !_has(verses) && !_has(text);

  @override
  bool operator ==(Object other) =>
      other is SharedRow && other.verses == verses && other.text == text;

  @override
  int get hashCode => Object.hash(verses, text);
}

class SharedHomiletic extends SharedStudy {
  final List<SharedRow> contentSummaries;
  final List<SharedRow> divisions;
  final String subjectSentence;
  final String fcf;

  /// The text after "Cause the audience to learn that".
  final String aim;
  final List<String> applications;

  const SharedHomiletic({
    super.passage,
    this.contentSummaries = const [],
    this.divisions = const [],
    this.subjectSentence = '',
    this.fcf = '',
    this.aim = '',
    this.applications = const [],
    super.translation,
    super.updatedAt,
  });

  @override
  String get typeCode => 'h';

  @override
  Map<String, dynamic> toData() {
    final List<SharedRow> c =
        contentSummaries.where((r) => !r.isEmpty).toList();
    final List<SharedRow> dv = divisions.where((r) => !r.isEmpty).toList();
    final List<String> ap = applications.where(_has).toList();
    final Map<String, dynamic> d = {
      if (_has(passage)) 'p': passage,
      if (c.isNotEmpty)
        'c': [
          for (final r in c) [r.verses, r.text]
        ],
      if (dv.isNotEmpty)
        'dv': [
          for (final r in dv) [r.verses, r.text]
        ],
      if (_has(subjectSentence)) 's': subjectSentence,
      if (_has(fcf)) 'f': fcf,
      if (_has(aim)) 'a': aim,
      if (ap.isNotEmpty) 'ap': ap,
    };
    _putCommon(d);
    return d;
  }

  factory SharedHomiletic._fromData(Map<String, dynamic> d) {
    return SharedHomiletic(
      passage: _string(d, 'p'),
      contentSummaries: _rows(d, 'c'),
      divisions: _rows(d, 'dv'),
      subjectSentence: _string(d, 's'),
      fcf: _string(d, 'f'),
      aim: _string(d, 'a'),
      applications: _strings(d, 'ap'),
      translation: _optionalString(d, 'tr'),
      updatedAt: _date(d, 'u'),
    );
  }

  /// Whether every field is empty.
  bool get isEmpty => toData().isEmpty;

  /// Saves this as a brand-new homiletic (never touches existing ones) and
  /// returns it. If a row fails to save, the partial copy is removed.
  Future<Homiletic> saveCopy() async {
    final Homiletic homiletic = Homiletic(
      passage: passage,
      subjectSentence: subjectSentence,
      fcf: fcf,
      aim: aim,
    );
    await homiletic.update();
    try {
      // One after another so the rows keep their order (ordered by id).
      for (final SharedRow row in contentSummaries) {
        await ContentSummary(
                homileticId: homiletic.id,
                passage: row.verses,
                summary: row.text)
            .update();
      }
      for (final SharedRow row in divisions) {
        await Division(homiletic.id, passage: row.verses, title: row.text)
            .update();
      }
      for (final String text in applications) {
        await Application(homileticsId: homiletic.id, text: text).update();
      }
    } catch (_) {
      try {
        await homiletic.delete();
      } catch (_) {}
      rethrow;
    }
    return homiletic;
  }
}

class SharedWordStudy extends SharedStudy {
  final String word;
  final String definition;

  /// Newline-separated references.
  final String otherUsage;
  final String contextualMeaning;
  final String deeperMeaning;
  final String application;

  const SharedWordStudy({
    super.passage,
    this.word = '',
    this.definition = '',
    this.otherUsage = '',
    this.contextualMeaning = '',
    this.deeperMeaning = '',
    this.application = '',
    super.translation,
    super.updatedAt,
  });

  @override
  String get typeCode => 'w';

  @override
  Map<String, dynamic> toData() {
    final Map<String, dynamic> d = {
      if (_has(passage)) 'p': passage,
      if (_has(word)) 'wd': word,
      if (_has(definition)) 'df': definition,
      if (_has(otherUsage)) 'ou': otherUsage,
      if (_has(contextualMeaning)) 'cm': contextualMeaning,
      if (_has(deeperMeaning)) 'dm': deeperMeaning,
      if (_has(application)) 'ap': application,
    };
    _putCommon(d);
    return d;
  }

  factory SharedWordStudy._fromData(Map<String, dynamic> d) {
    return SharedWordStudy(
      passage: _string(d, 'p'),
      word: _string(d, 'wd'),
      definition: _string(d, 'df'),
      otherUsage: _string(d, 'ou'),
      contextualMeaning: _string(d, 'cm'),
      deeperMeaning: _string(d, 'dm'),
      application: _string(d, 'ap'),
      translation: _optionalString(d, 'tr'),
      updatedAt: _date(d, 'u'),
    );
  }

  /// Saves this as a brand-new word study and returns it.
  Future<WordStudy> saveCopy() async {
    final WordStudy study = WordStudy(
      passage: passage,
      word: word,
      definition: definition,
      otherUsage: otherUsage,
      contextualMeaning: contextualMeaning,
      deeperMeaning: deeperMeaning,
      application: application,
    );
    await study.update();
    return study;
  }
}

// ------------------------------------------------------------------ helpers

bool _has(String? s) => s != null && s.trim().isNotEmpty;

/// ISO 8601 UTC to the second ("2026-10-14T12:00:00Z").
String _isoSeconds(DateTime time) {
  final String iso = time.toUtc().toIso8601String();
  final int dot = iso.indexOf('.');
  return dot == -1 ? iso : '${iso.substring(0, dot)}Z';
}

class _ShapeError implements Exception {
  final String message;
  const _ShapeError(this.message);
}

String _string(Map<String, dynamic> d, String key) =>
    _optionalString(d, key) ?? '';

String? _optionalString(Map<String, dynamic> d, String key) {
  final Object? value = d[key];
  if (value == null) return null;
  if (value is! String) throw _ShapeError('"$key" is not a string');
  return value;
}

List<String> _strings(Map<String, dynamic> d, String key) {
  final Object? value = d[key];
  if (value == null) return const [];
  if (value is! List || value.any((e) => e is! String)) {
    throw _ShapeError('"$key" is not a list of strings');
  }
  return List<String>.unmodifiable(value.cast<String>());
}

List<SharedRow> _rows(Map<String, dynamic> d, String key) {
  final Object? value = d[key];
  if (value == null) return const [];
  if (value is! List) throw _ShapeError('"$key" is not a list');
  return List<SharedRow>.unmodifiable([
    for (final Object? row in value)
      if (row is List &&
          row.length == 2 &&
          row[0] is String &&
          row[1] is String)
        SharedRow(row[0] as String, row[1] as String)
      else
        throw _ShapeError('"$key" has a row that is not [verses, text]'),
  ]);
}

DateTime? _date(Map<String, dynamic> d, String key) {
  final String? value = _optionalString(d, key);
  if (value == null || value.isEmpty) return null;
  // An unreadable timestamp is only a hint; don't reject the study for it.
  return DateTime.tryParse(value)?.toUtc();
}
