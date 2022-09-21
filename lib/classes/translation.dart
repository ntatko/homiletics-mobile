class Translation {
  String name;
  String short;
  String code;
  String? source;

  Translation(this.name, this.short, this.code, this.source);

  static Translation bbe =
      Translation('Bible in Basic English', 'BBE', 'bbe', 'bibleapi');
  static Translation kjv =
      Translation('King James Version', 'KJV', 'kjv', 'bibleapi');
  static Translation web =
      Translation('World English Bible', 'WEB', 'web', 'bibleapi');
  static Translation oebCw = Translation(
      'Open English Bible, Commonwealth Edition',
      'OEB-CW',
      'oeb-cw',
      'bibleapi');
  static Translation oebUs = Translation(
      'Open English Bible, US Edition', 'OEB-US', 'oeb-us', 'bibleapi');
  static Translation net =
      Translation('New English Translation', 'NET', 'net', 'bibleorg');
  static Translation asv =
      Translation('American Standard Version', 'ASV', 'asv', 'getbible');
  static Translation esv =
      Translation('English Standard Version', 'ESV', 'esv', 'esvapi');

  /// Returns a list of all translations
  static List<Translation> get all => [
        bbe,
        kjv,
        web,
        oebCw,
        oebUs,
        // net,
        // asv,
        // esv,
      ];
}
