import 'package:flutter/widgets.dart';
import 'package:timeago/timeago.dart' as timeago;

bool _registered = false;

/// timeago ships English and Spanish by default; add the other interface
/// languages it has messages for. Swahili has none, so it falls back to
/// English.
void _registerLocales() {
  if (_registered) return;
  _registered = true;
  timeago.setLocaleMessages('fr', timeago.FrMessages());
  timeago.setLocaleMessages('pt', timeago.PtBrMessages());
  timeago.setLocaleMessages('zh_Hans', timeago.ZhCnMessages());
  // timeago's plain "zh" messages use Traditional characters.
  timeago.setLocaleMessages('zh_Hant', timeago.ZhMessages());
}

/// The timeago key for [locale], or 'en' when timeago has no messages for it.
String _timeagoLocale(Locale locale) {
  const Set<String> supported = {'en', 'es', 'fr', 'pt', 'zh_Hans', 'zh_Hant'};
  String key = locale.languageCode;
  if (key == 'zh') {
    key = locale.scriptCode == 'Hant' ? 'zh_Hant' : 'zh_Hans';
  }
  return supported.contains(key) ? key : 'en';
}

/// "3 days ago" in the interface language of [context].
String relativeTime(BuildContext context, DateTime time) {
  _registerLocales();
  return timeago.format(time,
      locale: _timeagoLocale(Localizations.localeOf(context)));
}
