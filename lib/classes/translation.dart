import 'package:homiletics/classes/language.dart';

/// A Bible translation the passage view can show: from Bible Gateway in a
/// web view, or natively from a downloaded offline text (see
/// [offlineBytes] and data/bibles/SOURCES.md).
///
/// [code] is what gets persisted in Preferences, so existing codes must
/// never be renamed.
class Translation {
  String name;
  String short;
  String code;
  String? source;

  /// ISO 639-1 code of the translation's language ('en', 'es', 'zh', ...).
  final String languageCode;

  /// ISO 15924 script, where it matters: 'Hans' / 'Hant' for Chinese.
  final String? scriptCode;

  /// The version code Bible Gateway uses in its URLs (e.g. 'RVR1960').
  final String bibleGatewayCode;

  /// True when only the New Testament is available.
  final bool newTestamentOnly;

  /// Approximate download size of the offline text
  /// (data/bibles/<code>.json.gz), or null when there is none. Printed by
  /// tool/build_bibles.py.
  final int? offlineBytes;

  /// True when the text exists only offline (Bible Gateway doesn't host
  /// it); [bibleGatewayCode] is empty and the web view is never used.
  final bool offlineOnly;

  /// Copyright / licence line that must be shown with the text (CC BY and
  /// CC BY-SA texts); null when none is needed.
  final String? attribution;

  Translation(
    this.name,
    this.short,
    this.code,
    this.source, {
    this.languageCode = 'en',
    this.scriptCode,
    String? bibleGatewayCode,
    this.newTestamentOnly = false,
    this.offlineBytes,
    this.offlineOnly = false,
    this.attribution,
  }) : bibleGatewayCode = offlineOnly ? '' : (bibleGatewayCode ?? short);

  /// Whether a text can be downloaded for offline, native reading.
  bool get offlineAvailable => offlineBytes != null;

  /// Whether Bible Gateway hosts this translation.
  bool get webAvailable => bibleGatewayCode.isNotEmpty;

  /// A Bible Gateway translation; the app code is the lowercased BG code.
  Translation._bg(
    String name,
    String bgCode,
    String languageCode, {
    String? scriptCode,
    bool newTestamentOnly = false,
    int? offlineBytes,
    String? attribution,
  }) : this(
          name,
          bgCode,
          bgCode.toLowerCase(),
          'biblegateway',
          languageCode: languageCode,
          scriptCode: scriptCode,
          bibleGatewayCode: bgCode,
          newTestamentOnly: newTestamentOnly,
          offlineBytes: offlineBytes,
          attribution: attribution,
        );

  // ---- English ----
  static Translation bbe = Translation(
      'Bible in Basic English', 'BBE', 'bbe', 'bibleapi',
      offlineBytes: 1242399);
  static Translation kjv = Translation(
      'King James Version', 'KJV', 'kjv', 'bibleapi',
      offlineBytes: 1293980);
  static Translation web = Translation(
      'World English Bible', 'WEB', 'web', 'bibleapi',
      offlineBytes: 1291688);
  static Translation oebCw = Translation(
      'Open English Bible, Commonwealth Edition',
      'OEB-CW',
      'oeb-cw',
      'bibleapi',
      bibleGatewayCode: 'OEB');
  static Translation oebUs = Translation(
      'Open English Bible, US Edition', 'OEB-US', 'oeb-us', 'bibleapi',
      bibleGatewayCode: 'OEB');
  static Translation net =
      Translation('New English Translation', 'NET', 'net', 'bibleorg');
  static Translation asv =
      Translation('American Standard Version', 'ASV', 'asv', 'getbible');
  static Translation esv =
      Translation('English Standard Version', 'ESV', 'esv', 'esvapi');

  // Popular modern translations
  static Translation niv =
      Translation('New International Version', 'NIV', 'niv', 'biblegateway');
  static Translation nasb = Translation(
      'New American Standard Bible', 'NASB', 'nasb', 'biblegateway');
  static Translation nlt =
      Translation('New Living Translation', 'NLT', 'nlt', 'biblegateway');
  static Translation nkjv =
      Translation('New King James Version', 'NKJV', 'nkjv', 'biblegateway');
  static Translation nrsv = Translation(
      'New Revised Standard Version', 'NRSV', 'nrsv', 'biblegateway');
  static Translation msg =
      Translation('The Message', 'MSG', 'msg', 'biblegateway');
  static Translation amp =
      Translation('Amplified Bible', 'AMP', 'amp', 'biblegateway');
  static Translation csb =
      Translation('Christian Standard Bible', 'CSB', 'csb', 'biblegateway');
  static Translation cev =
      Translation('Contemporary English Version', 'CEV', 'cev', 'biblegateway');
  static Translation ncv =
      Translation('New Century Version', 'NCV', 'ncv', 'biblegateway');

  // ---- Español ----
  static Translation rvr1960 =
      Translation._bg('Reina-Valera 1960', 'RVR1960', 'es');
  static Translation nvi =
      Translation._bg('Nueva Versión Internacional', 'NVI', 'es');
  static Translation ntv =
      Translation._bg('Nueva Traducción Viviente', 'NTV', 'es');
  static Translation lbla =
      Translation._bg('La Biblia de las Américas', 'LBLA', 'es');
  static Translation nbla =
      Translation._bg('Nueva Biblia de las Américas', 'NBLA', 'es');
  static Translation dhh = Translation._bg('Dios Habla Hoy', 'DHH', 'es');
  static Translation rvc =
      Translation._bg('Reina Valera Contemporánea', 'RVC', 'es');
  static Translation pdt =
      Translation._bg('Palabra de Dios para Todos', 'PDT', 'es');
  static Translation tla =
      Translation._bg('Traducción en lenguaje actual', 'TLA', 'es');
  // Bible Gateway calls the 1909 text "Reina-Valera Antigua" (RVA).
  static Translation rv1909 = Translation(
      'Reina-Valera 1909', 'RV1909', 'rv1909', 'ebible',
      languageCode: 'es', bibleGatewayCode: 'RVA', offlineBytes: 1303438);

  // ---- 中文 (简体) ----
  static Translation cuvs =
      Translation._bg('和合本（简体）', 'CUVS', 'zh', scriptCode: 'Hans');
  static Translation cuvmps = Translation._bg('新标点和合本（简体）', 'CUVMPS', 'zh',
      scriptCode: 'Hans', offlineBytes: 1253426);
  static Translation cnvs =
      Translation._bg('新译本（简体）', 'CNVS', 'zh', scriptCode: 'Hans');
  static Translation ccb = Translation._bg('当代译本（简体）', 'CCB', 'zh',
      scriptCode: 'Hans',
      offlineBytes: 1259030,
      attribution: 'Biblica® 圣经当代译本™开放资源 © 1979–2022 Biblica, Inc. · '
          'CC BY-SA 4.0');
  static Translation rcu17ss =
      Translation._bg('和合本修订版（简体，神版）', 'RCU17SS', 'zh', scriptCode: 'Hans');

  // ---- 中文 (繁體) ----
  static Translation cuv =
      Translation._bg('和合本（繁體）', 'CUV', 'zh', scriptCode: 'Hant');
  static Translation cuvmpt = Translation._bg('新標點和合本（繁體）', 'CUVMPT', 'zh',
      scriptCode: 'Hant', offlineBytes: 1256221);
  static Translation cnvt =
      Translation._bg('新譯本（繁體）', 'CNVT', 'zh', scriptCode: 'Hant');
  static Translation ccbt = Translation._bg('當代譯本（繁體）', 'CCBT', 'zh',
      scriptCode: 'Hant',
      offlineBytes: 1262131,
      attribution: 'Biblica® 聖經，當代譯本™開放資源 © 1979–2023 Biblica, Inc. · '
          'CC BY-SA 4.0');
  static Translation rcu17ts =
      Translation._bg('和合本修訂版（繁體，神版）', 'RCU17TS', 'zh', scriptCode: 'Hant');

  // ---- Français ----
  static Translation lsg =
      Translation._bg('Louis Segond', 'LSG', 'fr', offlineBytes: 1409428);
  static Translation sg21 = Translation._bg('Segond 21', 'SG21', 'fr');
  static Translation bds = Translation._bg('La Bible du Semeur', 'BDS', 'fr');
  static Translation neg1979 =
      Translation._bg('Nouvelle Edition de Genève – NEG1979', 'NEG1979', 'fr');

  // ---- Português ----
  static Translation nviPt =
      Translation._bg('Nova Versão Internacional', 'NVI-PT', 'pt');
  static Translation arc =
      Translation._bg('Almeida Revista e Corrigida 2009', 'ARC', 'pt');
  static Translation nvt =
      Translation._bg('Nova Versão Transformadora', 'NVT', 'pt');
  static Translation ntlh =
      Translation._bg('Nova Tradução na Linguagem de Hoje 2000', 'NTLH', 'pt');
  static Translation ol = Translation._bg('O Livro', 'OL', 'pt');
  // Almeida-based and freely licensed; not on Bible Gateway.
  static Translation blivre =
      Translation('Bíblia Livre', 'BLIVRE', 'blivre', 'ebible',
          languageCode: 'pt',
          offlineOnly: true,
          offlineBytes: 1296131,
          attribution: 'Bíblia Livre © 2018 Diego Santos, Mario Sérgio e '
              'Marco Teles · CC BY 4.0 BR');

  // ---- Kiswahili ----
  static Translation snt =
      Translation._bg('Neno: Bibilia Takatifu', 'SNT', 'sw',
          offlineBytes: 1365550,
          attribution: 'Biblica® Toleo Wazi Neno: Bibilia Takatifu™ '
              '© 1984–2015 Biblica, Inc. · CC BY-SA 4.0');
  static Translation tku = Translation._bg(
      'Agano Jipya: Tafsiri ya Kusoma-Kwa-Urahisi', 'TKU', 'sw',
      newTestamentOnly: true);

  // ---- Other languages ----
  static Translation byo =
      Translation._bg('Bíbélì Mímọ́ Yorùbá Òde Òn', 'BYO', 'yo');
  static Translation ccl =
      Translation._bg('Mawu a Mulungu mu Chichewa Chalero', 'CCL', 'ny');
  static Translation lcb =
      Translation._bg('Endagaano Enkadde nʼEndagaano Empya', 'LCB', 'lg');
  static Translation som = Translation._bg('Somali Bible', 'SOM', 'so');
  static Translation naTwi =
      Translation._bg('Nkwa Asem', 'NA-TWI', 'tw', newTestamentOnly: true);
  static Translation nav = Translation._bg('كتاب الحياة', 'NAV', 'ar');
  static Translation ervAr =
      Translation._bg('Arabic Bible: Easy-to-Read Version', 'ERV-AR', 'ar');

  /// Returns a list of all translations
  static List<Translation> get all => [
        // Popular modern translations first
        niv,
        esv,
        nasb,
        nlt,
        nkjv,
        csb,
        nrsv,
        kjv,
        // Other translations
        web,
        bbe,
        oebCw,
        oebUs,
        msg,
        amp,
        cev,
        ncv,
        // Commented out ones
        // net,
        // asv,
        // Spanish
        rvr1960, nvi, ntv, lbla, nbla, dhh, rvc, pdt, tla, rv1909,
        // Chinese
        cuvs, cuvmps, cnvs, ccb, rcu17ss,
        cuv, cuvmpt, cnvt, ccbt, rcu17ts,
        // French
        lsg, sg21, bds, neg1979,
        // Portuguese
        nviPt, arc, nvt, ntlh, ol, blivre,
        // Swahili
        snt, tku,
        // Yoruba, Chichewa, Luganda, Somali, Twi, Arabic
        byo, ccl, lcb, som, naTwi, nav, ervAr,
      ];

  /// Each Bible language's own name, in the picker's default order.
  static const Map<String, String> languageNames = {
    'en': 'English',
    'es': 'Español',
    'zh': '中文',
    'fr': 'Français',
    'pt': 'Português',
    'sw': 'Kiswahili',
    'yo': 'Yorùbá',
    'ny': 'Chichewa',
    'lg': 'Luganda',
    'so': 'Soomaali',
    'tw': 'Twi',
    'ar': 'العربية',
  };

  /// The translation to use for [language] when the user hasn't chosen one.
  static Translation defaultFor(Language language) {
    switch (language.locale.languageCode) {
      case 'es':
        return rvr1960;
      case 'zh':
        return language.locale.scriptCode == 'Hant' ? cuv : cuvs;
      case 'fr':
        return lsg;
      case 'pt':
        return nviPt;
      case 'sw':
        return snt;
      default:
        return web;
    }
  }

  /// The Bible Gateway translation to use for a [languageCode] (and
  /// [scriptCode]) when a translation has no Bible Gateway code of its own.
  static Translation webFallbackFor(String languageCode, {String? scriptCode}) {
    switch (languageCode) {
      case 'es':
        return rvr1960;
      case 'zh':
        return scriptCode == 'Hant' ? cuv : cuvs;
      case 'fr':
        return lsg;
      case 'pt':
        return nviPt;
      case 'sw':
        return snt;
      default:
        return niv;
    }
  }

  /// The translation for a stored [code]: the matching one, or the default
  /// for [language] when nothing (or an unknown code) is stored.
  static Translation resolve(String? code, Language language) {
    if (code != null) {
      for (final Translation t in all) {
        if (t.code == code) return t;
      }
    }
    return defaultFor(language);
  }

  /// [all] grouped by language code for the picker: [language]'s group
  /// first, then English, then the rest. In the Chinese group,
  /// [language]'s script (Simplified when unspecified) comes first.
  static List<MapEntry<String, List<Translation>>> groupedFor(
      Language language) {
    final String first = language.locale.languageCode;
    final List<String> order = [
      first,
      if (first != 'en') 'en',
      ...languageNames.keys.where((k) => k != first && k != 'en'),
    ];
    final String script =
        first == 'zh' ? (language.locale.scriptCode ?? 'Hans') : 'Hans';
    final List<MapEntry<String, List<Translation>>> groups = [];
    for (final String lang in order) {
      final Iterable<Translation> inLang =
          all.where((t) => t.languageCode == lang);
      if (inLang.isEmpty) continue;
      groups.add(MapEntry(
          lang,
          lang == 'zh'
              ? [
                  ...inLang.where((t) => t.scriptCode == script),
                  ...inLang.where((t) => t.scriptCode != script),
                ]
              : inLang.toList()));
    }
    return groups;
  }
}
