class Translation {
  String name;
  String short;
  String code;
  String? source;

  Translation(this.name, this.short, this.code, this.source);
}

List<Translation> bibleTranslations = [
  Translation('Bible in Basic English', 'BBE', 'bbe', 'bibleapi'),
  Translation('King James Version', 'KJV', 'kjv', 'bibleapi'),
  Translation('World English Bible', 'WEB', 'web', 'bibleapi'),
  Translation('Open English Bible, Commonwealth Edition', 'OEB-CW', 'oeb-cw',
      'bibleapi'),
  Translation('Open English Bible, US Edition', 'OEB-US', 'oeb-us', 'bibleapi'),
  Translation('New English Translation', 'NET', 'net', 'bibleorg'),
  Translation('American Standard Version', 'ASV', 'asv', 'getbible'),
  // Translation('English Standard Version', 'ESV', 'esv', 'esvapi')
];
