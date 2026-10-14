import 'package:flutter_test/flutter_test.dart';
import 'package:homiletics/classes/language.dart';
import 'package:homiletics/classes/translation.dart';
import 'package:homiletics/common/verse_container.dart';

void main() {
  test('translation codes are unique', () {
    final codes = Translation.all.map((t) => t.code).toList();
    expect(codes.toSet().length, codes.length);
  });

  test('existing persisted codes are unchanged', () {
    for (final code in [
      'niv', 'esv', 'nasb', 'nlt', 'nkjv', 'csb', 'nrsv', 'kjv', 'web', //
      'bbe', 'oeb-cw', 'oeb-us', 'msg', 'amp', 'cev', 'ncv',
    ]) {
      expect(Translation.all.any((t) => t.code == code), isTrue, reason: code);
    }
  });

  test('every translation maps to a Bible Gateway code and a named language',
      () {
    for (final t in Translation.all) {
      if (t.offlineOnly) continue;
      expect(t.bibleGatewayCode, isNotEmpty, reason: t.code);
      expect(getBibleGatewayVersion(t), t.bibleGatewayCode, reason: t.code);
      expect(Translation.languageNames.containsKey(t.languageCode), isTrue,
          reason: t.code);
    }
  });

  test('offline-only translations have offline data and an attribution', () {
    final offlineOnly = Translation.all.where((t) => t.offlineOnly).toList();
    expect(offlineOnly, isNotEmpty);
    for (final t in offlineOnly) {
      expect(t.offlineAvailable, isTrue, reason: t.code);
      expect(t.webAvailable, isFalse, reason: t.code);
      expect(t.attribution, isNotNull, reason: t.code);
      expect(t.attribution, isNotEmpty, reason: t.code);
      // Other Bible Gateway features (e.g. Other usage search) get the
      // language's default there, never an empty code.
      final String fallback = getBibleGatewayVersion(t);
      expect(fallback, isNotEmpty, reason: t.code);
      expect(
          Translation.all.any((o) =>
              o.bibleGatewayCode == fallback &&
              o.languageCode == t.languageCode),
          isTrue,
          reason: t.code);
    }
    expect(getBibleGatewayVersion(Translation.blivre), 'NVI-PT');
  });

  test('offline translations keep their codes and note any licence', () {
    for (final code in [
      'web', 'kjv', 'bbe', 'rv1909', 'lsg', 'cuvmps', 'cuvmpt', 'ccb', //
      'ccbt', 'blivre', 'snt',
    ]) {
      final t = Translation.all.firstWhere((t) => t.code == code);
      expect(t.offlineAvailable, isTrue, reason: code);
    }
    for (final code in ['ccb', 'ccbt', 'blivre', 'snt']) {
      final t = Translation.all.firstWhere((t) => t.code == code);
      expect(t.attribution, contains('CC BY'), reason: code);
    }
    expect(getBibleGatewayVersion(Translation.rv1909), 'RVA');
  });

  test('Chinese translations declare a script', () {
    for (final t in Translation.all.where((t) => t.languageCode == 'zh')) {
      expect(['Hans', 'Hant'], contains(t.scriptCode), reason: t.code);
    }
  });

  test('getBibleGatewayVersion for old and new entries', () {
    expect(getBibleGatewayVersion(Translation.niv), 'NIV');
    expect(getBibleGatewayVersion(Translation.web), 'WEB');
    expect(getBibleGatewayVersion(Translation.oebCw), 'OEB');
    expect(getBibleGatewayVersion(Translation.oebUs), 'OEB');
    expect(getBibleGatewayVersion(Translation.rvr1960), 'RVR1960');
    expect(getBibleGatewayVersion(Translation.nviPt), 'NVI-PT');
    expect(getBibleGatewayVersion(Translation.naTwi), 'NA-TWI');
    expect(getBibleGatewayVersion(Translation.cuv), 'CUV');
    expect(Translation.nviPt.code, 'nvi-pt');
    expect(Translation.rvr1960.code, 'rvr1960');
  });

  test('defaults per app language', () {
    expect(Translation.defaultFor(Language.english), Translation.web);
    expect(Translation.defaultFor(Language.spanish), Translation.rvr1960);
    expect(
        Translation.defaultFor(Language.chineseSimplified), Translation.cuvs);
    expect(
        Translation.defaultFor(Language.chineseTraditional), Translation.cuv);
    expect(Translation.defaultFor(Language.french), Translation.lsg);
    expect(Translation.defaultFor(Language.portuguese), Translation.nviPt);
    expect(Translation.defaultFor(Language.swahili), Translation.snt);
    for (final language in Language.all) {
      expect(Translation.all, contains(Translation.defaultFor(language)));
    }
  });

  test('resolve keeps an explicit choice and falls back sensibly', () {
    expect(Translation.resolve('kjv', Language.spanish), Translation.kjv);
    expect(Translation.resolve(null, Language.spanish), Translation.rvr1960);
    expect(Translation.resolve(null, Language.english), Translation.web);
    expect(Translation.resolve('no-such-version', Language.french),
        Translation.lsg);
  });

  test('picker groups put the app language first, then English', () {
    final es = Translation.groupedFor(Language.spanish);
    expect(es[0].key, 'es');
    expect(es[1].key, 'en');
    final en = Translation.groupedFor(Language.english);
    expect(en[0].key, 'en');
    final hant = Translation.groupedFor(Language.chineseTraditional);
    expect(hant[0].key, 'zh');
    expect(hant[0].value.first.scriptCode, 'Hant');
    // Every translation appears exactly once.
    expect(es.expand((g) => g.value).length, Translation.all.length);
  });

  test('offline fallback (Windows) stays in the language and script', () {
    expect(Translation.offlineFallbackFor(Translation.niv), Translation.web);
    expect(Translation.offlineFallbackFor(Translation.nvi), Translation.rv1909);
    expect(
        Translation.offlineFallbackFor(Translation.cuvs), Translation.cuvmps);
    expect(Translation.offlineFallbackFor(Translation.cuv), Translation.cuvmpt);
    expect(
        Translation.offlineFallbackFor(Translation.nviPt), Translation.blivre);
    // No offline text in the language: World English Bible.
    expect(Translation.offlineFallbackFor(Translation.nav), Translation.web);
    for (final Translation t in Translation.all) {
      expect(Translation.offlineFallbackFor(t).offlineAvailable, isTrue,
          reason: t.code);
    }
  });
}
