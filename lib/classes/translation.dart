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
      ];
}
