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
      expect(t.bibleGatewayCode, isNotEmpty, reason: t.code);
      expect(getBibleGatewayVersion(t), t.bibleGatewayCode, reason: t.code);
      expect(Translation.languageNames.containsKey(t.languageCode), isTrue,
          reason: t.code);
    }
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
}
