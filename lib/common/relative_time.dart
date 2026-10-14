import 'package:flutter/widgets.dart';
import 'package:timeago/timeago.dart' as timeago;

bool _registered = false;

/// Swahili relative times, which timeago does not ship. The "ago" word agrees
/// with the noun class of each unit (dakika/saa/siku zilizopita, mwezi
/// uliopita, miezi/miaka iliyopita), so it lives inside each message and
/// [suffixAgo] is empty. [relativeTime] never formats future dates, but the
/// from-now strings would read "baada ya dakika 5 zilizopita" if it did.
class _SwMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => 'baada ya';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'sasa hivi';
  @override
  String aboutAMinute(int minutes) => 'dakika moja iliyopita';
  @override
  String minutes(int minutes) => 'dakika $minutes zilizopita';
  @override
  String aboutAnHour(int minutes) => 'saa moja iliyopita';
  @override
  String hours(int hours) => 'saa $hours zilizopita';
  @override
  String aDay(int hours) => 'siku moja iliyopita';
  @override
  String days(int days) => 'siku $days zilizopita';
  @override
  String aboutAMonth(int days) => 'mwezi mmoja uliopita';
  @override
  String months(int months) => 'miezi $months iliyopita';
  @override
  String aboutAYear(int year) => 'mwaka mmoja uliopita';
  @override
  String years(int years) => 'miaka $years iliyopita';
  @override
  String wordSeparator() => ' ';
}

/// timeago ships English and Spanish by default; add the other interface
/// languages it has messages for, plus our own Swahili messages.
void _registerLocales() {
  if (_registered) return;
  _registered = true;
  timeago.setLocaleMessages('fr', timeago.FrMessages());
  timeago.setLocaleMessages('pt', timeago.PtBrMessages());
  timeago.setLocaleMessages('zh_Hans', timeago.ZhCnMessages());
  // timeago's plain "zh" messages use Traditional characters.
  timeago.setLocaleMessages('zh_Hant', timeago.ZhMessages());
  timeago.setLocaleMessages('sw', _SwMessages());
}

/// The timeago key for [locale], or 'en' when timeago has no messages for it.
String _timeagoLocale(Locale locale) {
  const Set<String> supported = {
    'en',
    'es',
    'fr',
    'pt',
    'sw',
    'zh_Hans',
    'zh_Hant',
  };
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
