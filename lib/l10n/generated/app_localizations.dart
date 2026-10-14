import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// App name shown in the header and task switcher.
  ///
  /// In en, this message translates to:
  /// **'Homiletics'**
  String get appTitle;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get commonOk;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again soon.'**
  String get commonSomethingWentWrong;

  /// Option in the app-language picker meaning 'follow the phone's language setting'.
  ///
  /// In en, this message translates to:
  /// **'Phone language'**
  String get languageSystemDefault;

  /// Homiletic step 1: verse-by-verse content summaries of the passage.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get stepContent;

  /// Homiletic step 2: grouping the content into 2-4 major sections.
  ///
  /// In en, this message translates to:
  /// **'Divisions'**
  String get stepDivisions;

  /// Homiletic step 3: the whole passage summarized in 10 words or fewer.
  ///
  /// In en, this message translates to:
  /// **'Summary sentence'**
  String get stepSummary;

  /// Homiletic step 4: 'Fallen Condition Focus', the human need the passage addresses. Keep the abbreviation if no common equivalent exists.
  ///
  /// In en, this message translates to:
  /// **'FCF'**
  String get stepFcf;

  /// Homiletic step 5: the main takeaway the teacher wants the audience to learn.
  ///
  /// In en, this message translates to:
  /// **'Aim'**
  String get stepAim;

  /// Homiletic step 6: application questions for personal response.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get stepApplication;

  /// Very short (1 word, ~8 chars) label under a progress bar segment for step 1.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get stepShortContent;

  /// Very short (1 word, ~8 chars) progress label for step 2.
  ///
  /// In en, this message translates to:
  /// **'Divide'**
  String get stepShortDivisions;

  /// Very short progress label for step 3.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get stepShortSummary;

  /// Very short progress label for step 4.
  ///
  /// In en, this message translates to:
  /// **'FCF'**
  String get stepShortFcf;

  /// Very short progress label for step 5.
  ///
  /// In en, this message translates to:
  /// **'Aim'**
  String get stepShortAim;

  /// Very short progress label for step 6.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get stepShortApplication;

  /// No description provided for @commonShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get commonShare;

  /// No description provided for @commonPrint.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get commonPrint;

  /// No description provided for @commonPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get commonPreferences;

  /// No description provided for @commonUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get commonUntitled;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
