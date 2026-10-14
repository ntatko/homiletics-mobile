import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_sw.dart';
import 'app_localizations_zh.dart';

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pt'),
    Locale('sw'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// Heading of the preferences dialog.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get prefsTitle;

  /// Preferences row / sheet title for choosing the app's interface language.
  ///
  /// In en, this message translates to:
  /// **'Preferred language'**
  String get prefsAppLanguage;

  /// Preferences row / sheet title for choosing the Bible translation shown in the passage view.
  ///
  /// In en, this message translates to:
  /// **'Preferred Bible version'**
  String get prefsBibleVersion;

  /// Note under a Bible translation that only contains the New Testament.
  ///
  /// In en, this message translates to:
  /// **'New Testament only'**
  String get bibleNewTestamentOnly;

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

  /// Hint shown on the home screen while the search field is open but empty.
  ///
  /// In en, this message translates to:
  /// **'Search your homiletics, divisions, applications, lecture notes and word studies.'**
  String get homeSearchIntro;

  /// Placeholder inside the home screen's search field. Keep short (~35 chars).
  ///
  /// In en, this message translates to:
  /// **'Search lessons, passages, notes…'**
  String get homeSearchFieldHint;

  /// Tooltip / accessibility label of the search icon button in the home header.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get homeSearchTooltip;

  /// Tooltip of the X button that closes the home search field.
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get homeCloseSearch;

  /// Filter pill / menu option on the weekly passage card meaning 'show passages from every study'. Short (~16 chars).
  ///
  /// In en, this message translates to:
  /// **'All studies'**
  String get homeAllStudies;

  /// Tooltip of the study filter pill on the weekly passage card.
  ///
  /// In en, this message translates to:
  /// **'Filter by study'**
  String get homeFilterByStudy;

  /// Menu item that opens the current study's website in the browser.
  ///
  /// In en, this message translates to:
  /// **'Open study website'**
  String get homeOpenStudySite;

  /// Overline above the passage card for the current week's lesson. Shown in upper case.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get homeThisWeek;

  /// Overline above a passage card for a lesson from a past week. Shown in upper case.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get homeEarlier;

  /// Overline above a passage card for a lesson in a future week. Shown in upper case.
  ///
  /// In en, this message translates to:
  /// **'Coming up'**
  String get homeComingUp;

  /// Overline on a passage card: the week label (This week / Earlier / Coming up) followed by the lesson name from the study schedule. Shown in upper case on one line.
  ///
  /// In en, this message translates to:
  /// **'{when} · {lesson}'**
  String homeWeekOverline(String when, String lesson);

  /// Main button on a passage card when no homiletic exists for the passage yet.
  ///
  /// In en, this message translates to:
  /// **'Start homiletics'**
  String get homeStartHomiletics;

  /// Main button on a passage card when a homiletic is partly done.
  ///
  /// In en, this message translates to:
  /// **'Continue homiletics'**
  String get homeContinueHomiletics;

  /// Main button on a passage card when all homiletic steps are done.
  ///
  /// In en, this message translates to:
  /// **'Open homiletics'**
  String get homeOpenHomiletics;

  /// Shown on the placeholder card while this week's suggested passages load.
  ///
  /// In en, this message translates to:
  /// **'Loading suggested passages…'**
  String get homeLoadingPassages;

  /// Heading of the home section listing recently edited studies.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get homeContinue;

  /// Link next to a home section heading that opens the full list.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeSeeAll;

  /// Heading of the home section (and title of the full page) listing the user's application questions.
  ///
  /// In en, this message translates to:
  /// **'Living it out'**
  String get homeLivingItOut;

  /// Single letter on the small tile marking a homiletic in study lists (initial of 'Homiletics'). One character.
  ///
  /// In en, this message translates to:
  /// **'H'**
  String get homeKindTileHomiletic;

  /// Single letter on the small tile marking a word study in study lists (initial of 'Word study'). One character.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get homeKindTileWordStudy;

  /// Screen-reader label for the homiletic step progress bar when no step is done.
  ///
  /// In en, this message translates to:
  /// **'No steps done yet'**
  String get homeProgressNoneDone;

  /// Screen-reader label for the homiletic step progress bar; {steps} is a comma-separated list of completed step names.
  ///
  /// In en, this message translates to:
  /// **'Done: {steps}'**
  String homeProgressDone(String steps);

  /// Screen-reader label for the dots under the swipeable passage cards.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {count}'**
  String homePageOf(int page, int count);

  /// Compact page indicator under the passage cards when there are too many pages for dots, e.g. '3 / 12'.
  ///
  /// In en, this message translates to:
  /// **'{page} / {count}'**
  String homePageFraction(int page, int count);

  /// Title of the page listing every saved study.
  ///
  /// In en, this message translates to:
  /// **'Your studies'**
  String get studiesTitle;

  /// Tab on the 'Your studies' page listing homiletics.
  ///
  /// In en, this message translates to:
  /// **'Homiletics'**
  String get studiesTabHomiletics;

  /// Tab on the 'Your studies' page listing lecture notes.
  ///
  /// In en, this message translates to:
  /// **'Lectures'**
  String get studiesTabLectures;

  /// Tab on the 'Your studies' page listing word studies.
  ///
  /// In en, this message translates to:
  /// **'Word studies'**
  String get studiesTabWordStudies;

  /// Empty-state message in the homiletics list.
  ///
  /// In en, this message translates to:
  /// **'No homiletics yet.'**
  String get studiesNoHomiletics;

  /// Empty-state message in the lecture notes list.
  ///
  /// In en, this message translates to:
  /// **'No lecture notes yet.'**
  String get studiesNoLectureNotes;

  /// Empty-state message in the word studies list.
  ///
  /// In en, this message translates to:
  /// **'No word studies yet.'**
  String get studiesNoWordStudies;

  /// Empty-state message on the 'Living it out' page.
  ///
  /// In en, this message translates to:
  /// **'No application questions yet.'**
  String get studiesNoApplications;

  /// Homiletic progress summary when no homiletic exists yet. Short.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get studiesProgressNotStarted;

  /// Homiletic progress summary when every step is done, e.g. 'All 6 steps'. Short.
  ///
  /// In en, this message translates to:
  /// **'All {total} steps'**
  String studiesProgressAll(int total);

  /// Homiletic progress summary, e.g. '2 of 6 steps'. Short.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} steps'**
  String studiesProgressSome(int done, int total);

  /// Subtitle of a homiletic in a study list: kind, progress (e.g. '2 of 6 steps') and relative time (e.g. '3 days ago'). One line.
  ///
  /// In en, this message translates to:
  /// **'Homiletics · {progress} · {time}'**
  String studiesHomileticSubtitle(String progress, String time);

  /// Subtitle of a homiletic in a study list while its progress loads; {time} is a relative time like '3 days ago'.
  ///
  /// In en, this message translates to:
  /// **'Homiletics · {time}'**
  String studiesHomileticSubtitleNoProgress(String time);

  /// Title of a lecture note in a study list; {passage} is a Bible reference like 'John 3:1-21'.
  ///
  /// In en, this message translates to:
  /// **'{passage} lecture'**
  String studiesLectureTitle(String passage);

  /// Title of a lecture note in a study list when it has no passage.
  ///
  /// In en, this message translates to:
  /// **'Lecture'**
  String get studiesLectureUntitled;

  /// Subtitle of a lecture note in a study list; {time} is a relative time like '3 days ago'.
  ///
  /// In en, this message translates to:
  /// **'Lecture notes · {time}'**
  String studiesLectureSubtitle(String time);

  /// Title of a word study in a study list when it has no word or passage.
  ///
  /// In en, this message translates to:
  /// **'Word study'**
  String get studiesWordStudyUntitled;

  /// Subtitle of a word study in a study list; {time} is a relative time like '3 days ago'.
  ///
  /// In en, this message translates to:
  /// **'Word study · {time}'**
  String studiesWordStudySubtitle(String time);

  /// Subtitle of a word study in a study list; {passage} is a Bible reference, {time} a relative time like '3 days ago'.
  ///
  /// In en, this message translates to:
  /// **'Word study · {passage} · {time}'**
  String studiesWordStudySubtitleWithPassage(String passage, String time);

  /// Placeholder in a generic search field.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchHint;

  /// Heading of search results found in content summaries (homiletic step 1). Shown in upper case.
  ///
  /// In en, this message translates to:
  /// **'Content Summaries'**
  String get searchSectionContentSummaries;

  /// Heading of search results found in divisions (homiletic step 2). Shown in upper case.
  ///
  /// In en, this message translates to:
  /// **'Divisions'**
  String get searchSectionDivisions;

  /// Heading of search results found in application questions. Shown in upper case.
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get searchSectionApplications;

  /// Heading of search results found in homiletic aims. Shown in upper case.
  ///
  /// In en, this message translates to:
  /// **'Aims'**
  String get searchSectionAims;

  /// Heading of search results found in summary sentences. Shown in upper case.
  ///
  /// In en, this message translates to:
  /// **'Summary Sentences'**
  String get searchSectionSummarySentences;

  /// Heading of search results matching a homiletic's Bible passage. Shown in upper case.
  ///
  /// In en, this message translates to:
  /// **'Homiletics Passages'**
  String get searchSectionPassages;

  /// Heading of search results found in lecture notes. Shown in upper case.
  ///
  /// In en, this message translates to:
  /// **'Lecture Notes'**
  String get searchSectionLectureNotes;

  /// Heading of search results found in word studies. Shown in upper case.
  ///
  /// In en, this message translates to:
  /// **'Word Studies'**
  String get searchSectionWordStudies;

  /// Snackbar when a tapped search result can't be opened.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open that result. It may have been deleted.'**
  String get searchOpenFailed;

  /// Title of the settings page; also the tooltip of the gear button on the home screen.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Section heading on the settings page above the app-language row. Shown in upper case.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsSectionLanguage;

  /// Settings row (and picker title) for choosing the language of the app's interface (not the Bible translation).
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get settingsAppLanguage;

  /// Section heading on the settings page above Bible translation / reading options. Shown in upper case.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get settingsSectionReading;

  /// Section heading on the settings page above the speech and formatting model downloads. Shown in upper case.
  ///
  /// In en, this message translates to:
  /// **'On-device models'**
  String get settingsSectionModels;

  /// Section heading on the settings page above the feedback row. Shown in upper case.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get settingsSectionHelp;

  /// Copyright line at the bottom of the settings page. Keep '13one.org' unchanged.
  ///
  /// In en, this message translates to:
  /// **'Copyright (C) {year} 13one.org · All rights reserved'**
  String settingsCopyright(String year);

  /// Link / row that opens the help and feedback form.
  ///
  /// In en, this message translates to:
  /// **'Request help / leave feedback'**
  String get helpRequestFeedback;

  /// Copyright line at the foot of the home screen. Keep '13one.org' unchanged.
  ///
  /// In en, this message translates to:
  /// **'Copyright (C) {year} 13one.org'**
  String helpCopyright(String year);

  /// Second copyright line at the foot of the home screen.
  ///
  /// In en, this message translates to:
  /// **'All rights reserved'**
  String get helpAllRightsReserved;

  /// Title of the feedback form sheet.
  ///
  /// In en, this message translates to:
  /// **'Leave some feedback'**
  String get feedbackTitle;

  /// Privacy notice under the feedback form title. Keep 'GitHub' unchanged.
  ///
  /// In en, this message translates to:
  /// **'Your feedback is submitted as a public GitHub issue—anyone on the internet can read it. Do not include passwords or other private information. Your email is partially hidden on GitHub; we may keep the full address on our servers only to follow up.'**
  String get feedbackPublicNotice;

  /// Feedback form option: a general question or comment. Short (~18 chars), shown in a two-option segmented control.
  ///
  /// In en, this message translates to:
  /// **'Help or feedback'**
  String get feedbackTypeGeneral;

  /// Feedback form option: report wrong or awkward wording in the app's translation. Short (~18 chars), shown in a two-option segmented control.
  ///
  /// In en, this message translates to:
  /// **'Translation issue'**
  String get feedbackTypeTranslation;

  /// Help text shown when 'Translation issue' is selected in the feedback form.
  ///
  /// In en, this message translates to:
  /// **'Tell us which words look wrong and what they should say. We\'ll include your app language and Bible translation.'**
  String get feedbackTranslationHint;

  /// Label of the name field in the feedback form.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get feedbackNameLabel;

  /// Label of the email field in the feedback form.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get feedbackEmailLabel;

  /// Label of the message field in the feedback form.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackContentLabel;

  /// Button that sends the feedback form.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get feedbackSubmit;

  /// Snackbar when the user taps Submit with an empty message.
  ///
  /// In en, this message translates to:
  /// **'Please enter your feedback first.'**
  String get feedbackEmpty;

  /// Snackbar after feedback was filed as a GitHub issue.
  ///
  /// In en, this message translates to:
  /// **'Submitted. Open the issue on GitHub anytime to add comments (sign-in optional).'**
  String get feedbackSubmittedIssue;

  /// Snackbar action that opens the newly created GitHub issue. Very short.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get feedbackOpenIssue;

  /// Snackbar after feedback was sent.
  ///
  /// In en, this message translates to:
  /// **'Successfully submitted feedback'**
  String get feedbackSubmitted;

  /// Snackbar when the server rejected the feedback.
  ///
  /// In en, this message translates to:
  /// **'Could not submit that request. Check your message and try again.'**
  String get feedbackBadRequest;

  /// Title of the dialog shown when feedback couldn't be sent.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server'**
  String get feedbackServerUnreachableTitle;

  /// Body of the dialog shown when feedback couldn't be sent.
  ///
  /// In en, this message translates to:
  /// **'Open GitHub in your browser to file this report instead. You may need to sign in there to submit the issue.'**
  String get feedbackServerUnreachableBody;

  /// Dialog button that dismisses the 'could not reach the server' dialog.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get feedbackNotNow;

  /// Dialog button that opens GitHub in the browser to file the report.
  ///
  /// In en, this message translates to:
  /// **'Open GitHub'**
  String get feedbackOpenGitHub;

  /// Snackbar when no app could open a web link.
  ///
  /// In en, this message translates to:
  /// **'Could not open the browser.'**
  String get feedbackBrowserFailed;

  /// Button that starts a homiletic on the typed passage. Short (3 buttons share a row).
  ///
  /// In en, this message translates to:
  /// **'Homiletics'**
  String get startHomiletics;

  /// Button that starts lecture notes on a passage. Short (2-3 buttons share a row).
  ///
  /// In en, this message translates to:
  /// **'Lecture'**
  String get startLecture;

  /// Button that starts a word study on a passage. Short (2-3 buttons share a row).
  ///
  /// In en, this message translates to:
  /// **'Word study'**
  String get startWordStudy;

  /// Placeholder of the field at the bottom of the home screen where the user types a Bible reference to study.
  ///
  /// In en, this message translates to:
  /// **'Study another passage…'**
  String get startPassageHint;

  /// Tooltip of the X button that clears the passage field.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get startClear;

  /// Button that opens a menu of non-homiletic study types.
  ///
  /// In en, this message translates to:
  /// **'Other study'**
  String get startOtherStudy;

  /// Menu item that starts lecture notes on the passage.
  ///
  /// In en, this message translates to:
  /// **'Lecture Note'**
  String get startMenuLectureNote;

  /// Menu item that starts a word study on the passage.
  ///
  /// In en, this message translates to:
  /// **'Word Study'**
  String get startMenuWordStudy;

  /// Title of the dialog shown when starting a homiletic on a passage that already has one.
  ///
  /// In en, this message translates to:
  /// **'Already have a homiletic for this passage?'**
  String get startDuplicateHomileticTitle;

  /// Body of the duplicate-homiletic dialog when there are several; {passage} is a Bible reference. 'Edit existing' opens the most recent.
  ///
  /// In en, this message translates to:
  /// **'{passage}\n\nYou have {count} homiletics for this passage; opening the most recent.'**
  String startDuplicateHomileticMany(String passage, int count);

  /// Title of the dialog shown when starting lecture notes on a passage that already has some.
  ///
  /// In en, this message translates to:
  /// **'Already have lecture notes for this passage?'**
  String get startDuplicateLectureTitle;

  /// Body of the duplicate-lecture-notes dialog when there are several; {passage} is a Bible reference.
  ///
  /// In en, this message translates to:
  /// **'{passage}\n\nYou have {count} lecture notes for this passage; opening the most recent.'**
  String startDuplicateLectureMany(String passage, int count);

  /// Title of the dialog shown when starting a word study on a passage that already has one.
  ///
  /// In en, this message translates to:
  /// **'Already have a word study for this passage?'**
  String get startDuplicateWordStudyTitle;

  /// Body of the duplicate-word-study dialog when there are several; {passage} is a Bible reference.
  ///
  /// In en, this message translates to:
  /// **'{passage}\n\nYou have {count} word studies for this passage; opening the most recent.'**
  String startDuplicateWordStudyMany(String passage, int count);

  /// Duplicate-passage dialog button: create another study on the same passage.
  ///
  /// In en, this message translates to:
  /// **'Create new'**
  String get startCreateNew;

  /// Duplicate-passage dialog button: open the existing study.
  ///
  /// In en, this message translates to:
  /// **'Edit existing'**
  String get startEditExisting;

  /// Small label above the Bible passage pane in the homiletics editor. 'Homiletics' is the study method; keep short (~25 chars).
  ///
  /// In en, this message translates to:
  /// **'Homiletics · Passage'**
  String get homileticHeaderLabel;

  /// Name of the item used in the delete confirmation of the homiletics editor (e.g. 'Delete this Homiletics lesson?'). A 'homiletics' lesson is a structured six-step Bible-passage study (Content, Divisions, Summary sentence, FCF, Aim, Application).
  ///
  /// In en, this message translates to:
  /// **'Homiletics lesson'**
  String get homileticItemName;

  /// Snackbar shown after a homiletics lesson is deleted.
  ///
  /// In en, this message translates to:
  /// **'Homiletics Deleted'**
  String get homileticDeletedMessage;

  /// Snackbar shown when a homiletics lesson fails to load.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong loading this lesson.'**
  String get homileticLoadError;

  /// Snackbar after the homiletics lesson was exported to PDF and shared.
  ///
  /// In en, this message translates to:
  /// **'PDF shared successfully.'**
  String get homileticPdfShared;

  /// Snackbar when sharing the homiletics PDF fails.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong sharing your PDF. Try again soon.'**
  String get homileticPdfShareFailed;

  /// Snackbar after the homiletics lesson PDF was sent to the printer.
  ///
  /// In en, this message translates to:
  /// **'PDF printed successfully.'**
  String get homileticPdfPrinted;

  /// Snackbar when creating/printing the homiletics PDF fails.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong creating your PDF. Try again soon.'**
  String get homileticPdfPrintFailed;

  /// Title of the card shown at the bottom of the homiletics editor once all six steps have something written. Keep short (~25 chars).
  ///
  /// In en, this message translates to:
  /// **'All six steps done'**
  String get homileticCompleteTitle;

  /// Message under 'All six steps done', above Print and Share buttons.
  ///
  /// In en, this message translates to:
  /// **'Print it for class, or share it with your group.'**
  String get homileticCompleteMessage;

  /// Short muted hint on the right of the collapsed Content step when nothing is written yet. Each content row is a verse range plus a summary. Max ~20 chars.
  ///
  /// In en, this message translates to:
  /// **'Verses + summary'**
  String get homileticContentEmptySummary;

  /// Short muted hint on the collapsed Divisions step when empty: a passage is split into 2 to 4 groups of verses. Max ~20 chars.
  ///
  /// In en, this message translates to:
  /// **'2–4 groupings'**
  String get homileticDivisionsEmptySummary;

  /// Short muted hint on the collapsed Summary sentence step when empty: the sentence must be at most 10 words. Max ~15 chars.
  ///
  /// In en, this message translates to:
  /// **'≤ 10 words'**
  String get homileticSummaryEmptySummary;

  /// Short muted hint on the collapsed FCF step when empty; spells out the abbreviation FCF (the fallen human condition the passage addresses). Max ~25 chars.
  ///
  /// In en, this message translates to:
  /// **'Fallen condition focus'**
  String get homileticFcfEmptySummary;

  /// Short muted hint on the collapsed Aim step when empty. Max ~20 chars.
  ///
  /// In en, this message translates to:
  /// **'The main takeaway'**
  String get homileticAimEmptySummary;

  /// Short muted hint on the collapsed Application step when empty: application questions typically start this way. Max ~15 chars.
  ///
  /// In en, this message translates to:
  /// **'How can I…'**
  String get homileticApplicationEmptySummary;

  /// Screen-reader status of a homiletic step that has something written. Inserted as {status} in homileticStepTileLabel.
  ///
  /// In en, this message translates to:
  /// **'done'**
  String get homileticStepStatusDone;

  /// Screen-reader status of a homiletic step that is still empty. Inserted as {status} in homileticStepTileLabel.
  ///
  /// In en, this message translates to:
  /// **'to do'**
  String get homileticStepStatusToDo;

  /// Screen-reader label of an open step's header; tapping it closes the step.
  ///
  /// In en, this message translates to:
  /// **'{title}, collapse'**
  String homileticStepCollapseLabel(String title);

  /// Tooltip and screen-reader label of the '?' button that explains a homiletic step.
  ///
  /// In en, this message translates to:
  /// **'About {title}'**
  String homileticStepHelpLabel(String title);

  /// Screen-reader label of the verse-range field at the start of a Content or Divisions row.
  ///
  /// In en, this message translates to:
  /// **'Verses'**
  String get homileticVersesLabel;

  /// Placeholder in the narrow verse-range field (abbreviation of 'verses'). Max 3 chars; the field is only ~40px wide.
  ///
  /// In en, this message translates to:
  /// **'v.'**
  String get homileticVersesHint;

  /// Text of the dashed add button under a list step; {label} is e.g. 'Add summary'. Keep the plus sign unless your language puts it elsewhere.
  ///
  /// In en, this message translates to:
  /// **'+ {label}'**
  String homileticAddButtonLabel(String label);

  /// Body of the dialog asking to confirm removing a row that has text in it.
  ///
  /// In en, this message translates to:
  /// **'What you\'ve written here will be deleted.'**
  String get homileticRemoveRowMessage;

  /// Destructive button in the dialog that removes a row from a homiletic step.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get homileticRemoveRowConfirm;

  /// Placeholder of a Content row's summary field (the user's own-words summary of a few verses).
  ///
  /// In en, this message translates to:
  /// **'Summary…'**
  String get homileticContentSummaryHint;

  /// Label of the dashed button that adds a content-summary row. Shown after '+'.
  ///
  /// In en, this message translates to:
  /// **'Add summary'**
  String get homileticAddContentSummary;

  /// Tooltip of the × button on a Content row.
  ///
  /// In en, this message translates to:
  /// **'Remove content summary'**
  String get homileticRemoveContentSummaryTooltip;

  /// Title of the dialog confirming removal of a Content row that has text.
  ///
  /// In en, this message translates to:
  /// **'Remove this content summary?'**
  String get homileticRemoveContentSummaryTitle;

  /// Snackbar when removing a Content row fails.
  ///
  /// In en, this message translates to:
  /// **'Removing that Content Summary didn\'t work'**
  String get homileticRemoveContentSummaryFailed;

  /// Placeholder of a Divisions row's text field: one sentence describing a group of verses.
  ///
  /// In en, this message translates to:
  /// **'Division sentence…'**
  String get homileticDivisionHint;

  /// Label of the dashed button that adds a division row. Shown after '+'.
  ///
  /// In en, this message translates to:
  /// **'Add division'**
  String get homileticAddDivision;

  /// Tooltip of the × button on a Divisions row.
  ///
  /// In en, this message translates to:
  /// **'Remove division'**
  String get homileticRemoveDivisionTooltip;

  /// Title of the dialog confirming removal of a Divisions row that has text.
  ///
  /// In en, this message translates to:
  /// **'Remove this division?'**
  String get homileticRemoveDivisionTitle;

  /// Snackbar when removing a Divisions row fails.
  ///
  /// In en, this message translates to:
  /// **'Removing that Division didn\'t work'**
  String get homileticRemoveDivisionFailed;

  /// Placeholder of an application-question field: questions that help people apply the passage to their lives often start this way.
  ///
  /// In en, this message translates to:
  /// **'How can I…'**
  String get homileticApplicationHint;

  /// Label of the dashed button that adds an application question. Shown after '+'.
  ///
  /// In en, this message translates to:
  /// **'Add question'**
  String get homileticAddApplication;

  /// Tooltip of the × button on an Application row.
  ///
  /// In en, this message translates to:
  /// **'Remove application question'**
  String get homileticRemoveApplicationTooltip;

  /// Title of the dialog confirming removal of an Application row that has text.
  ///
  /// In en, this message translates to:
  /// **'Remove this application question?'**
  String get homileticRemoveApplicationTitle;

  /// Snackbar when removing an Application row fails.
  ///
  /// In en, this message translates to:
  /// **'Removing that Application didn\'t work'**
  String get homileticRemoveApplicationFailed;

  /// Placeholder of the Summary sentence field: the whole passage summarized in at most 10 words.
  ///
  /// In en, this message translates to:
  /// **'Summarize: 10 words or fewer'**
  String get homileticSummaryHint;

  /// Placeholder of the FCF (Fallen Condition Focus) field, listing example words for the human weakness the passage addresses. The English alliterates on F; translate the meaning, alliteration optional.
  ///
  /// In en, this message translates to:
  /// **'Fallen/Frail/Feeble/Fickle'**
  String get homileticFcfHint;

  /// Placeholder of the Aim field: the user completes the sentence with the main truth to teach.
  ///
  /// In en, this message translates to:
  /// **'Cause the audience to learn that…'**
  String get homileticAimHint;

  /// Title of the help dialog for the Content step.
  ///
  /// In en, this message translates to:
  /// **'Content Summaries'**
  String get homileticContentHelpTitle;

  /// Help dialog text for the Content step. Keep the line break.
  ///
  /// In en, this message translates to:
  /// **'A content summary is a summary of a section of the Bible. It doesn\'t need to be a sentence, it can also be more than one sentence. It should be a summary, in your own words, of the content of the passage.\nYou should have at least 10, but no more than 20 content summaries. Generally, depending on the length of the passage, you will divide your passage into chunks of an approximate size to hit the 10-20 mark. So, if your passage is 30 verses, I\'d try for 3 verses per content summary on average.'**
  String get homileticContentHelpText;

  /// Help dialog text for the Divisions step.
  ///
  /// In en, this message translates to:
  /// **'Divisions are groupings of verses that are related. There should be at least two and no more than four.'**
  String get homileticDivisionsHelpText;

  /// Title of the help dialog for the Summary sentence step.
  ///
  /// In en, this message translates to:
  /// **'Summary Sentence'**
  String get homileticSummaryHelpTitle;

  /// Help dialog text for the Summary sentence step. Keep the line break; the word limit may be adapted for languages where 10 words is unnatural.
  ///
  /// In en, this message translates to:
  /// **'The Summary Sentence is a concise, memorable statement that encapsulates the most relevant facts. A good way of thinking of it is the 2am test: if someone were to wake you up at 2am and ask you what the sermon was about, what would you say? You\'d say the Summary Sentence.\nIt should be 10 words or fewer. If you\'re feeling frisky, you can try to make an alliteration.'**
  String get homileticSummaryHelpText;

  /// Help dialog text for the FCF step.
  ///
  /// In en, this message translates to:
  /// **'The FCF (Fallen Condition Focus) is the part of humanity that is the most illustrated or referenced in the passage. It is the condition that the audience is in, the reason that the audience needs to be saved.'**
  String get homileticFcfHelpText;

  /// Help dialog text for the Aim step.
  ///
  /// In en, this message translates to:
  /// **'The Aim is the key point, the one main takeaway truth you want yourself or an audience to walk away with. It may be derivable from the FCF, and will likely influence the Application Questions.'**
  String get homileticAimHelpText;

  /// Title of the help dialog for the Application step.
  ///
  /// In en, this message translates to:
  /// **'Application Questions'**
  String get homileticApplicationHelpTitle;

  /// Help dialog text for the Application step.
  ///
  /// In en, this message translates to:
  /// **'These are questions that help the audience apply what they\'ve just heard to their own lives. They should be specific, personal, open-ended, and thought-provoking.'**
  String get homileticApplicationHelpText;

  /// Shown on the collapsed Content step: how many content summaries are written.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 summary} other{{count} summaries}}'**
  String homileticSummaryCount(int count);

  /// Shown on the collapsed Divisions step: how many divisions are written.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 division} other{{count} divisions}}'**
  String homileticDivisionCount(int count);

  /// Shown on the collapsed Application step: how many application questions are written.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 question} other{{count} questions}}'**
  String homileticQuestionCount(int count);

  /// Screen-reader label of a collapsed step in compact layout. {status} is 'done' or 'to do'.
  ///
  /// In en, this message translates to:
  /// **'{title}, {status}'**
  String homileticStepTileLabel(String title, String status);

  /// Screen-reader label of a collapsed step. {status} is 'done' or 'to do'; {summary} is the short text on the right (e.g. '3 summaries' or the user's text).
  ///
  /// In en, this message translates to:
  /// **'{title}, {status}, {summary}'**
  String homileticStepTileLabelWithSummary(
    String title,
    String status,
    String summary,
  );

  /// Name of a lecture note item, used in the delete confirmation (e.g. 'Delete Lecture Note?').
  ///
  /// In en, this message translates to:
  /// **'Lecture Note'**
  String get lectureItemName;

  /// Snackbar shown after a lecture note is deleted.
  ///
  /// In en, this message translates to:
  /// **'Lecture Note Deleted'**
  String get lectureDeleted;

  /// Hint in the Bible passage field of a lecture note (e.g. 'John 3:1-16').
  ///
  /// In en, this message translates to:
  /// **'Passage'**
  String get lecturePassageHint;

  /// Small uppercase-style header label above the passage field in the lecture note editor. Keep short (~20 chars).
  ///
  /// In en, this message translates to:
  /// **'Lecture · Passage'**
  String get lectureHeaderLabel;

  /// Placeholder in the empty rich-text notes editor.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get lectureNotesPlaceholder;

  /// Tooltip for the bold formatting button in the notes toolbar.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get lectureToolbarBold;

  /// Tooltip for the italic formatting button in the notes toolbar.
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get lectureToolbarItalic;

  /// Tooltip for the bulleted-list formatting button in the notes toolbar.
  ///
  /// In en, this message translates to:
  /// **'Bulleted list'**
  String get lectureToolbarBulletedList;

  /// Tooltip for the numbered-list formatting button in the notes toolbar.
  ///
  /// In en, this message translates to:
  /// **'Numbered list'**
  String get lectureToolbarNumberedList;

  /// Title of the dialog confirming a new recording will replace the old one.
  ///
  /// In en, this message translates to:
  /// **'Replace existing recording?'**
  String get lectureReplaceTitle;

  /// Body of the replace-recording confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'The old audio and transcript will be deleted.'**
  String get lectureReplaceMessage;

  /// Button confirming the existing recording should be replaced.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get lectureReplaceConfirm;

  /// Snackbar shown when microphone permission was denied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required to record.'**
  String get lectureMicPermissionRequired;

  /// Title of the Android ongoing notification shown while a lecture is recording in the background.
  ///
  /// In en, this message translates to:
  /// **'Recording lecture'**
  String get lectureNotificationTitle;

  /// Text of the Android ongoing notification shown while recording.
  ///
  /// In en, this message translates to:
  /// **'{appName} is recording audio'**
  String lectureNotificationContent(String appName);

  /// Snackbar shown when the recorder fails to start.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t start recording. The microphone may be in use by another app.'**
  String get lectureStartFailed;

  /// Title of the dialog offering to download the speech-to-text model.
  ///
  /// In en, this message translates to:
  /// **'Download offline transcription model?'**
  String get lectureTranscriptionModelTitle;

  /// Body of the transcription-model download dialog. 'Settings' is the app's settings screen.
  ///
  /// In en, this message translates to:
  /// **'A one-time ~140MB download lets your recordings be automatically transcribed and searched. You can skip this and download it later from Settings.'**
  String get lectureTranscriptionModelMessage;

  /// Dialog button declining a model download for now.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get lectureNotNow;

  /// Dialog button starting a model download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get lectureDownload;

  /// Snackbar shown when a model download fails.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong downloading the model. You can try again from Settings.'**
  String get lectureModelDownloadFailed;

  /// Snackbar shown when the saved audio file is missing.
  ///
  /// In en, this message translates to:
  /// **'The recording file couldn\'t be found.'**
  String get lectureRecordingFileNotFound;

  /// Snackbar shown when transcription finished but produced no text.
  ///
  /// In en, this message translates to:
  /// **'Transcription didn\'t produce any text.'**
  String get lectureTranscriptionEmpty;

  /// Title of the dialog offering to download the on-device model that formats transcripts into paragraphs.
  ///
  /// In en, this message translates to:
  /// **'Download transcript formatting model?'**
  String get lectureFormattingModelTitle;

  /// Body of the formatting-model download dialog. {size} is the approximate download size.
  ///
  /// In en, this message translates to:
  /// **'A one-time {size} download lets transcripts be cleaned up into readable paragraphs, entirely on your device. Wi-Fi recommended. You can also do this later from Settings.'**
  String lectureFormattingModelMessage(String size);

  /// Snackbar shown when formatting failed because the model is missing.
  ///
  /// In en, this message translates to:
  /// **'The formatting model isn\'t downloaded.'**
  String get lectureFormattingModelMissing;

  /// Snackbar shown when transcript formatting failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t format the transcript.'**
  String get lectureFormattingFailed;

  /// Snackbar shown when audio playback fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t play the recording.'**
  String get lecturePlaybackFailed;

  /// Progress line on the recording bar while a model downloads. Keep short (~30 chars).
  ///
  /// In en, this message translates to:
  /// **'Downloading model {percent}%'**
  String lectureDownloadingModel(String percent);

  /// Progress line on the recording bar while the recording is transcribed. Keep short (~30 chars).
  ///
  /// In en, this message translates to:
  /// **'Transcribing {percent}%'**
  String lectureTranscribingProgress(int percent);

  /// Progress line while the transcript is formatted, in chunks done/total. Keep short (~30 chars).
  ///
  /// In en, this message translates to:
  /// **'Formatting transcript {done}/{total}'**
  String lectureFormattingProgress(int done, int total);

  /// Progress line while the transcript is formatted and the number of chunks isn't known yet.
  ///
  /// In en, this message translates to:
  /// **'Formatting transcript…'**
  String get lectureFormattingIndeterminate;

  /// Screen-reader label for the live recording clock. {time} is elapsed mm:ss.
  ///
  /// In en, this message translates to:
  /// **'Recording, {time}'**
  String lectureRecordingSemantics(String time);

  /// Subtitle under the running clock on the recording bar. One line, keep short (~45 chars).
  ///
  /// In en, this message translates to:
  /// **'Recording · keeps going with the screen off'**
  String get lectureRecordingSubtitle;

  /// Tooltip for the stop button on the recording bar.
  ///
  /// In en, this message translates to:
  /// **'Stop recording'**
  String get lectureStopRecording;

  /// Tooltip and title of the idle recording bar that starts a recording. Keep short (~20 chars).
  ///
  /// In en, this message translates to:
  /// **'Record lecture'**
  String get lectureRecordLecture;

  /// Subtitle under 'Record lecture' on the idle recording bar. One line, keep short (~40 chars).
  ///
  /// In en, this message translates to:
  /// **'Keeps recording with the screen off'**
  String get lectureRecordIdleSubtitle;

  /// Tooltip for the pause playback button.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get lecturePause;

  /// Tooltip for the play button on the recording bar.
  ///
  /// In en, this message translates to:
  /// **'Play recording'**
  String get lecturePlayRecording;

  /// Tooltip for the button that records a new lecture, replacing the current one.
  ///
  /// In en, this message translates to:
  /// **'Record again'**
  String get lectureRecordAgain;

  /// Caption on the recording bar when the recording has no transcript.
  ///
  /// In en, this message translates to:
  /// **'Not transcribed yet'**
  String get lectureNotTranscribedYet;

  /// Button that transcribes the recording into text.
  ///
  /// In en, this message translates to:
  /// **'Transcribe'**
  String get lectureTranscribe;

  /// Button (shown while recording) that inserts the current recording time into the notes. Keep short (~14 chars).
  ///
  /// In en, this message translates to:
  /// **'+ Time mark'**
  String get lectureTimeMark;

  /// Transcript tab empty-state message while recording.
  ///
  /// In en, this message translates to:
  /// **'The lecture is transcribed on this phone after you stop recording.'**
  String get lectureTranscriptEmptyRecording;

  /// Transcript tab empty-state message while the model downloads or transcription runs.
  ///
  /// In en, this message translates to:
  /// **'The transcript will appear here when it\'s ready.'**
  String get lectureTranscriptEmptyPending;

  /// Transcript tab empty-state message when a recording exists but has no transcript.
  ///
  /// In en, this message translates to:
  /// **'Transcribe the recording to read and search it here.'**
  String get lectureTranscriptEmptyNotTranscribed;

  /// Transcript tab empty-state message when there is no recording yet.
  ///
  /// In en, this message translates to:
  /// **'Record the lecture and it\'s transcribed on this phone after you stop.'**
  String get lectureTranscriptEmptyNoRecording;

  /// Transcript tab empty-state title while transcription runs.
  ///
  /// In en, this message translates to:
  /// **'Transcribing…'**
  String get lectureTranscribing;

  /// Transcript tab empty-state title.
  ///
  /// In en, this message translates to:
  /// **'No transcript yet'**
  String get lectureNoTranscriptYet;

  /// Segment of a toggle showing the cleaned-up (paragraphed) transcript. Keep short (~12 chars).
  ///
  /// In en, this message translates to:
  /// **'Formatted'**
  String get lectureFormatted;

  /// Segment of a toggle showing the unedited transcript. Keep short (~12 chars).
  ///
  /// In en, this message translates to:
  /// **'Raw'**
  String get lectureRaw;

  /// Button that formats the raw transcript into readable paragraphs.
  ///
  /// In en, this message translates to:
  /// **'Format transcript'**
  String get lectureFormatTranscript;

  /// Tab label for the user's own notes in the lecture editor. Keep short (~14 chars).
  ///
  /// In en, this message translates to:
  /// **'My notes'**
  String get lectureTabMyNotes;

  /// Tab label for the recording transcript in the lecture editor. Keep short (~14 chars).
  ///
  /// In en, this message translates to:
  /// **'Transcript'**
  String get lectureTabTranscript;

  /// Settings card title for the downloadable on-device speech-to-text (Whisper) model.
  ///
  /// In en, this message translates to:
  /// **'Offline transcription model'**
  String get modelTranscriptionTitle;

  /// Settings card detail: this is the English-only speech-to-text model, and it is the one the current app language uses.
  ///
  /// In en, this message translates to:
  /// **'English model, needed for {language}'**
  String modelTranscriptionEnglishNeeded(String language);

  /// Settings card detail: this is the English-only speech-to-text model, which the current app language does not use (it can be deleted to save space).
  ///
  /// In en, this message translates to:
  /// **'English model, not needed for {language}'**
  String modelTranscriptionEnglishNotNeeded(String language);

  /// Settings card detail: this is the multilingual speech-to-text model, and it is the one the current app language uses.
  ///
  /// In en, this message translates to:
  /// **'Multilingual model, needed for {language}'**
  String modelTranscriptionMultilingualNeeded(String language);

  /// Settings card detail: this is the multilingual speech-to-text model, which the current app language does not use (it can be deleted to save space).
  ///
  /// In en, this message translates to:
  /// **'Multilingual model, not needed for {language}'**
  String modelTranscriptionMultilingualNotNeeded(String language);

  /// Settings card title for the downloadable on-device AI model that cleans up transcripts into readable paragraphs.
  ///
  /// In en, this message translates to:
  /// **'Transcript formatting model'**
  String get modelFormattingTitle;

  /// Status on the formatting-model card when the iPhone's built-in Apple Intelligence is used instead of a download. Keep 'Apple Intelligence' as Apple's product name.
  ///
  /// In en, this message translates to:
  /// **'Using Apple Intelligence (no download needed)'**
  String get modelAppleIntelligenceStatus;

  /// Model card status while checking whether the model is downloaded.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get modelStatusChecking;

  /// Model card status when the model is not downloaded; size is the approximate download size.
  ///
  /// In en, this message translates to:
  /// **'Not downloaded ({size})'**
  String modelStatusNotDownloaded(String size);

  /// Model card status while the model downloads.
  ///
  /// In en, this message translates to:
  /// **'Downloading… {percent}%'**
  String modelStatusDownloading(String percent);

  /// Model card status when the model is downloaded and its size is unknown.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get modelStatusDownloaded;

  /// Model card status when the model is downloaded, with its size on the device in megabytes.
  ///
  /// In en, this message translates to:
  /// **'Downloaded ({megabytes}MB)'**
  String modelStatusDownloadedSize(String megabytes);

  /// Button on a model card that starts downloading the model.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get modelDownload;

  /// Button on a model card that deletes the downloaded model from the device.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get modelDelete;

  /// Snackbar shown in Settings when a model download fails.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong downloading the model. Try again soon.'**
  String get modelDownloadFailed;

  /// Snackbar shown in Settings when deleting a model fails.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong deleting the model.'**
  String get modelDeleteFailed;

  /// Small all-caps label above the passage title on a printed homiletic handout (PDF). Use capitals where the script has them.
  ///
  /// In en, this message translates to:
  /// **'HOMILETICS'**
  String get pdfOverlineHomiletics;

  /// Small all-caps label above the word on a printed word-study handout (PDF). Use capitals where the script has them.
  ///
  /// In en, this message translates to:
  /// **'WORD STUDY'**
  String get pdfOverlineWordStudy;

  /// Title of a printed homiletic handout when no Bible passage has been entered.
  ///
  /// In en, this message translates to:
  /// **'Untitled passage'**
  String get pdfUntitledPassage;

  /// Title of a printed word-study handout when no word has been entered.
  ///
  /// In en, this message translates to:
  /// **'Untitled word'**
  String get pdfUntitledWord;

  /// Document title and running page footer of a printed homiletic handout. 'Homiletics' is the app name / method name.
  ///
  /// In en, this message translates to:
  /// **'Homiletics · {passage}'**
  String pdfHomileticLabel(String passage);

  /// Document title and running page footer of a printed word-study handout with no passage.
  ///
  /// In en, this message translates to:
  /// **'Word study · {word}'**
  String pdfWordStudyLabel(String word);

  /// Document title and running page footer of a printed word-study handout: the word studied and the Bible passage it comes from.
  ///
  /// In en, this message translates to:
  /// **'Word study · {word} · {passage}'**
  String pdfWordStudyLabelWithPassage(String word, String passage);

  /// Page number in the footer of a printed handout (lowercase in English).
  ///
  /// In en, this message translates to:
  /// **'page {current} of {total}'**
  String pdfPageOf(int current, int total);

  /// Italic caption next to the 'FCF' step heading on a printed homiletic, spelling out the abbreviation: the human need or brokenness the passage addresses.
  ///
  /// In en, this message translates to:
  /// **'Fallen Condition Focus'**
  String get pdfFcfCaption;

  /// Fixed sentence opening printed before the user's Aim statement, which completes it (e.g. '...learn that the risen Christ sees our labor'). Keep the trailing space if your language separates words with spaces.
  ///
  /// In en, this message translates to:
  /// **'Cause the audience to learn that '**
  String get pdfAimLeadIn;

  /// Note printed on a homiletic handout that has no content in any step.
  ///
  /// In en, this message translates to:
  /// **'Nothing has been written for this passage yet.'**
  String get pdfEmptyHomiletic;

  /// Note printed on a word-study handout that has no content in any section.
  ///
  /// In en, this message translates to:
  /// **'Nothing has been written for this word study yet.'**
  String get pdfEmptyWordStudy;

  /// Section heading on a printed word study: the dictionary definition of the word.
  ///
  /// In en, this message translates to:
  /// **'Definition'**
  String get pdfWordStudyDefinition;

  /// Section heading on a printed word study: other Bible verses where the word is used.
  ///
  /// In en, this message translates to:
  /// **'Other usage'**
  String get pdfWordStudyOtherUsage;

  /// Section heading on a printed word study: what the word means in this passage.
  ///
  /// In en, this message translates to:
  /// **'Contextual meaning'**
  String get pdfWordStudyContextualMeaning;

  /// Section heading on a printed word study: original-language and theological meaning.
  ///
  /// In en, this message translates to:
  /// **'Deeper meaning'**
  String get pdfWordStudyDeeperMeaning;

  /// Section heading on a printed word study: how the word applies to the reader's life.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get pdfWordStudyApplication;

  /// Study editor menu item: save the study (it autosaves) and close the editor.
  ///
  /// In en, this message translates to:
  /// **'Save and close'**
  String get editorSaveAndClose;

  /// Title of the dialog confirming deletion of a study.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get editorDeleteConfirmTitle;

  /// Body of the delete confirmation dialog in a study editor.
  ///
  /// In en, this message translates to:
  /// **'Deleting this {itemName} is permanent and cannot be undone. Are you sure you wish to proceed?'**
  String editorDeleteConfirmMessage(String itemName);

  /// Default small uppercase label above the Bible passage field in a study editor.
  ///
  /// In en, this message translates to:
  /// **'Passage'**
  String get editorPassageLabel;

  /// Placeholder in the empty Bible passage field at the top of a study editor (e.g. the user types 'John 3:16').
  ///
  /// In en, this message translates to:
  /// **'Add a passage'**
  String get editorAddPassageHint;

  /// Tooltip / screen reader label for the back arrow in a study editor.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get editorBack;

  /// Tooltip / screen reader label for the three-dot menu in a study editor.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get editorMoreOptions;

  /// Screen reader label for the button above the Bible text that changes the Bible translation.
  ///
  /// In en, this message translates to:
  /// **'Change translation'**
  String get editorChangeTranslation;

  /// Default message on the card shown when a study is finished, above Print and Share buttons.
  ///
  /// In en, this message translates to:
  /// **'Print it for class, or share it with your group.'**
  String get editorStudyCompleteMessage;

  /// Name of a word study, inserted into the delete confirmation ('Deleting this Word Study is permanent...').
  ///
  /// In en, this message translates to:
  /// **'Word Study'**
  String get wordStudyItemName;

  /// Snack bar shown after a word study is deleted.
  ///
  /// In en, this message translates to:
  /// **'Word Study Deleted'**
  String get wordStudyDeleted;

  /// Small label above the passage field in the word study editor.
  ///
  /// In en, this message translates to:
  /// **'Word study · Passage'**
  String get wordStudyHeaderLabel;

  /// Snack bar after a word study PDF is shared.
  ///
  /// In en, this message translates to:
  /// **'PDF shared successfully.'**
  String get wordStudyPdfShared;

  /// Snack bar when sharing a word study PDF fails.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong sharing your PDF. Try again soon.'**
  String get wordStudyPdfShareFailed;

  /// Snack bar after a word study PDF is printed.
  ///
  /// In en, this message translates to:
  /// **'PDF printed successfully.'**
  String get wordStudyPdfPrinted;

  /// Snack bar when creating a word study PDF for printing fails.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong creating your PDF. Try again soon.'**
  String get wordStudyPdfPrintFailed;

  /// Label (shown uppercase) on the top card of a word study, where the user types the word being studied.
  ///
  /// In en, this message translates to:
  /// **'Word'**
  String get wordStudyWordTitle;

  /// Help text for the Word card of a word study. 'Definition' and 'Other Usage' are section names.
  ///
  /// In en, this message translates to:
  /// **'The specific word or short phrase you\'re studying. Once you\'ve entered it, Definition and Other Usage can suggest content for you.'**
  String get wordStudyWordHelp;

  /// Placeholder in the empty word field of a word study.
  ///
  /// In en, this message translates to:
  /// **'Add a word'**
  String get wordStudyWordHint;

  /// Snack bar when the user asks for suggestions before typing a word.
  ///
  /// In en, this message translates to:
  /// **'Enter a word above first.'**
  String get wordStudyEnterWordFirst;

  /// Word study section title (shown uppercase): the plain meaning of the word.
  ///
  /// In en, this message translates to:
  /// **'Definition'**
  String get wordStudyDefinitionTitle;

  /// Help text for the Definition section when dictionary suggestions are available. '+' refers to the add button on the card.
  ///
  /// In en, this message translates to:
  /// **'What does this word mean, in plain terms? Tap \"+\" for candidate definitions pulled from a dictionary, or write your own.'**
  String get wordStudyDefinitionHelp;

  /// Help text for the Definition section when dictionary suggestions are not available (non-English Bible translation).
  ///
  /// In en, this message translates to:
  /// **'What does this word mean, in plain terms? Write your own.'**
  String get wordStudyDefinitionHelpNoSuggest;

  /// Placeholder question in the empty Definition field.
  ///
  /// In en, this message translates to:
  /// **'What does it mean, in plain terms?'**
  String get wordStudyDefinitionHint;

  /// Tooltip of the '+' button on the Definition card, and the small heading of the definition suggestions sheet.
  ///
  /// In en, this message translates to:
  /// **'Suggest a definition'**
  String get wordStudySuggestDefinition;

  /// Title of the sheet listing dictionary definitions.
  ///
  /// In en, this message translates to:
  /// **'Definitions for “{word}”'**
  String wordStudyDefinitionsFor(String word);

  /// Instruction under the definitions sheet title.
  ///
  /// In en, this message translates to:
  /// **'Tap one to use it.'**
  String get wordStudyDefinitionsTapToUse;

  /// Shown in the definitions sheet when the dictionary request fails; a Retry button follows.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load definitions. Try again soon.'**
  String get wordStudyDefinitionsLoadError;

  /// Shown in the definitions sheet when the dictionary has no entries.
  ///
  /// In en, this message translates to:
  /// **'No definitions found for this word.'**
  String get wordStudyNoDefinitions;

  /// Title of the dialog shown when picking a suggested definition while one is already written.
  ///
  /// In en, this message translates to:
  /// **'Replace your definition?'**
  String get wordStudyReplaceDefinitionTitle;

  /// Body of the replace-or-append definition dialog.
  ///
  /// In en, this message translates to:
  /// **'You\'ve already written a definition. Replace it with the suggestion, or add the suggestion below it?'**
  String get wordStudyReplaceDefinitionMessage;

  /// Dialog button: append the suggested definition below the existing one.
  ///
  /// In en, this message translates to:
  /// **'Add below'**
  String get wordStudyAddBelow;

  /// Dialog button: replace the existing definition with the suggestion.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get wordStudyReplace;

  /// Word study section title (shown uppercase) and sheet heading: other places in Scripture the word appears.
  ///
  /// In en, this message translates to:
  /// **'Other usage'**
  String get wordStudyOtherUsageTitle;

  /// Help text for the Other usage section. 'Bible Gateway' is a website name; '+' is the add button on the card.
  ///
  /// In en, this message translates to:
  /// **'Where else does this word or concept appear in Scripture? Tap \"+\" to search Bible Gateway and add references you find, or write your own.'**
  String get wordStudyOtherUsageHelp;

  /// Placeholder question in the empty Other usage field.
  ///
  /// In en, this message translates to:
  /// **'Where else does it appear in Scripture?'**
  String get wordStudyOtherUsageHint;

  /// Tooltip of the '+' button on the Other usage card.
  ///
  /// In en, this message translates to:
  /// **'Find other usages'**
  String get wordStudyFindOtherUsages;

  /// Title of the Bible search sheet for other usages of the word.
  ///
  /// In en, this message translates to:
  /// **'Where else “{word}” appears'**
  String wordStudyOtherUsageSheetTitle(String word);

  /// Label before the list of verse references already added from the search sheet.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get wordStudyOtherUsageAdded;

  /// Instruction above the Bible search results.
  ///
  /// In en, this message translates to:
  /// **'Tap a result below to add its reference.'**
  String get wordStudyOtherUsageInstructions;

  /// Small badge next to each Bible search result reference; tapping adds the reference. Keep very short.
  ///
  /// In en, this message translates to:
  /// **'+ Add'**
  String get wordStudyOtherUsageAddResult;

  /// Word study section title (shown uppercase): what the word means in this passage.
  ///
  /// In en, this message translates to:
  /// **'Contextual meaning'**
  String get wordStudyContextualMeaningTitle;

  /// Help text for the Contextual meaning section.
  ///
  /// In en, this message translates to:
  /// **'What did the author intend this word to mean here, in this passage? Consider the surrounding verses, not just the word alone.'**
  String get wordStudyContextualMeaningHelp;

  /// Placeholder question in the empty Contextual meaning field.
  ///
  /// In en, this message translates to:
  /// **'What does it mean here, in this passage?'**
  String get wordStudyContextualMeaningHint;

  /// Word study section title (shown uppercase): insight beyond the basic definition.
  ///
  /// In en, this message translates to:
  /// **'Deeper meaning'**
  String get wordStudyDeeperMeaningTitle;

  /// Help text for the Deeper meaning section. 'Strong's concordance' and 'Blue Letter Bible' are names of study resources.
  ///
  /// In en, this message translates to:
  /// **'Any insight from the original language, commentary, or outside study that adds depth beyond the basic definition? How does the rest of Scripture shape it? A Strong\'s concordance or Blue Letter Bible can help here.'**
  String get wordStudyDeeperMeaningHelp;

  /// Placeholder question in the empty Deeper meaning field.
  ///
  /// In en, this message translates to:
  /// **'How does the rest of Scripture shape it?'**
  String get wordStudyDeeperMeaningHint;

  /// Word study section title (shown uppercase): how the truth applies to the reader's life.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get wordStudyApplicationTitle;

  /// Help text for the Application section of a word study.
  ///
  /// In en, this message translates to:
  /// **'How should this truth shape your life? Be specific, personal, and practical.'**
  String get wordStudyApplicationHelp;

  /// Placeholder question in the empty Application field.
  ///
  /// In en, this message translates to:
  /// **'What will you do with it?'**
  String get wordStudyApplicationHint;

  /// Title of the card shown when every word study section is filled in.
  ///
  /// In en, this message translates to:
  /// **'Word study done'**
  String get wordStudyDoneTitle;

  /// Screen reader label for a section title that opens its help text.
  ///
  /// In en, this message translates to:
  /// **'{title}, about this section'**
  String wordStudySectionHelpSemantics(String title);

  /// Snackbar when the user taps a time mark like [14:02] in lecture notes but the note has no recording.
  ///
  /// In en, this message translates to:
  /// **'This note has no recording to play.'**
  String get lectureTimeMarkNoRecording;

  /// Snackbar when the user taps a time mark in lecture notes while a recording is still in progress.
  ///
  /// In en, this message translates to:
  /// **'Stop recording to play from a time mark.'**
  String get lectureTimeMarkStopRecordingFirst;

  /// Snackbar when a tapped time mark in lecture notes is later than the length of the note's recording (e.g. the lecture was recorded again).
  ///
  /// In en, this message translates to:
  /// **'That time mark is past the end of the recording.'**
  String get lectureTimeMarkPastEnd;

  /// First-run guide: button that closes the guide early.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// First-run guide: button to go to the previous page.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBack;

  /// First-run guide: button to go to the next page.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// First-run guide, page 1: small uppercase label above the title.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get onboardingWelcomeOverline;

  /// First-run guide, page 1: serif title.
  ///
  /// In en, this message translates to:
  /// **'Study the Bible, one passage at a time'**
  String get onboardingWelcomeTitle;

  /// First-run guide, page 1: what the app helps with. 'Homiletics' here is the BSF study method.
  ///
  /// In en, this message translates to:
  /// **'Homiletics helps you write your homiletics, take lecture notes and do word studies — all with the passage open beside you, in your language and your Bible translation.'**
  String get onboardingWelcomeBody;

  /// First-run guide, page 2: small uppercase label above the title.
  ///
  /// In en, this message translates to:
  /// **'The method'**
  String get onboardingMethodOverline;

  /// First-run guide, page 2: serif title. 'A homiletic' is one study written with the BSF homiletics method.
  ///
  /// In en, this message translates to:
  /// **'What is a homiletic?'**
  String get onboardingMethodTitle;

  /// First-run guide, page 2: short explanation of the homiletics method.
  ///
  /// In en, this message translates to:
  /// **'A homiletic is a short way of studying a passage: you find its main message, then think about how to live it out. It takes six steps — and it doesn\'t have to be perfect. It gets easier every week.'**
  String get onboardingMethodBody;

  /// First-run guide, page 3: small uppercase label above the title.
  ///
  /// In en, this message translates to:
  /// **'Step by step'**
  String get onboardingStepsOverline;

  /// First-run guide, page 3: serif title over the list of the six homiletic steps.
  ///
  /// In en, this message translates to:
  /// **'The six steps'**
  String get onboardingStepsTitle;

  /// First-run guide, page 3: one-line description of the Content step (shown after its name).
  ///
  /// In en, this message translates to:
  /// **'Summarize the passage in 10–20 short chunks, in your own words.'**
  String get onboardingStepContent;

  /// First-run guide, page 3: one-line description of the Divisions step.
  ///
  /// In en, this message translates to:
  /// **'Group those chunks into 2–4 sections.'**
  String get onboardingStepDivisions;

  /// First-run guide, page 3: one-line description of the Summary sentence step. Chinese uses 20 characters instead of 10 words, like the step's help text.
  ///
  /// In en, this message translates to:
  /// **'The whole passage in 10 words or fewer.'**
  String get onboardingStepSummary;

  /// First-run guide, page 3: one-line description of the FCF step; spells out the abbreviation (use the FCF gloss from docs/TRANSLATIONS.md).
  ///
  /// In en, this message translates to:
  /// **'Fallen Condition Focus: the human need or brokenness the passage speaks to.'**
  String get onboardingStepFcf;

  /// First-run guide, page 3: one-line description of the Aim step.
  ///
  /// In en, this message translates to:
  /// **'The one main truth you want your hearers to learn.'**
  String get onboardingStepAim;

  /// First-run guide, page 3: one-line description of the Application step.
  ///
  /// In en, this message translates to:
  /// **'Questions that turn the passage into everyday life.'**
  String get onboardingStepApplication;

  /// First-run guide, page 4: small uppercase label above the title.
  ///
  /// In en, this message translates to:
  /// **'Lectures & word studies'**
  String get onboardingLecturesOverline;

  /// First-run guide, page 4: serif title.
  ///
  /// In en, this message translates to:
  /// **'Listen closely, dig deeper'**
  String get onboardingLecturesTitle;

  /// First-run guide, page 4: what lecture notes do. Transcription happens on the device, not online.
  ///
  /// In en, this message translates to:
  /// **'Record the lecture — it keeps going with the screen off and is transcribed right on your phone. Take notes as you listen and add time marks to find a moment again.'**
  String get onboardingLecturesBody;

  /// First-run guide, page 4: what a word study is.
  ///
  /// In en, this message translates to:
  /// **'Curious about one word? Start a word study and dig into what it means in the passage.'**
  String get onboardingWordStudyBody;

  /// First-run guide, last page: small uppercase label above the title.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingStartOverline;

  /// First-run guide, last page: serif title.
  ///
  /// In en, this message translates to:
  /// **'You\'re ready to begin'**
  String get onboardingStartTitle;

  /// First-run guide, last page: encouragement before the start buttons.
  ///
  /// In en, this message translates to:
  /// **'Begin with this week\'s passage, or take a look around first. Every step you write is saved as you go.'**
  String get onboardingStartBody;

  /// First-run guide, last page: small note on where to find the guide again (Settings > Help > How homiletics works).
  ///
  /// In en, this message translates to:
  /// **'You can open this guide again anytime from Settings.'**
  String get onboardingReopenHint;

  /// First-run guide, last page: main button that opens a homiletic on this week's passage.
  ///
  /// In en, this message translates to:
  /// **'Start this week\'s homiletic'**
  String get onboardingStartThisWeek;

  /// First-run guide, last page: button that closes the guide and shows the home screen.
  ///
  /// In en, this message translates to:
  /// **'Explore on my own'**
  String get onboardingExplore;

  /// First-run guide, last page: line above the start button naming this week's passage, e.g. 'This week: John 3:1–21'.
  ///
  /// In en, this message translates to:
  /// **'This week: {passage}'**
  String onboardingThisWeekPassage(String passage);

  /// Settings > Help: row that reopens the first-run guide explaining the homiletics method.
  ///
  /// In en, this message translates to:
  /// **'How homiletics works'**
  String get onboardingSettingsRow;

  /// Picker subtitle for a Bible translation that can be downloaded to read without internet.
  ///
  /// In en, this message translates to:
  /// **'Offline · {size}'**
  String bibleOfflineSize(String size);

  /// Picker subtitle for a Bible translation already downloaded to the device.
  ///
  /// In en, this message translates to:
  /// **'Downloaded · {size}'**
  String bibleDownloadedSize(String size);

  /// Button / tooltip: download this Bible translation so passages show without internet.
  ///
  /// In en, this message translates to:
  /// **'Download for offline'**
  String get bibleDownloadAction;

  /// Shown while a Bible translation is downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading…'**
  String get bibleDownloading;

  /// Tooltip: delete the downloaded copy of a Bible translation (it can be downloaded again).
  ///
  /// In en, this message translates to:
  /// **'Remove download'**
  String get bibleRemoveDownload;

  /// Snack bar when downloading a Bible translation fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t download {translation}. Check your connection and try again.'**
  String bibleDownloadFailed(String translation);

  /// Title in the verse panel when the passage cannot load because the phone is offline.
  ///
  /// In en, this message translates to:
  /// **'No connection'**
  String get bibleOfflineTitle;

  /// Verse panel message when offline and the current Bible translation can be downloaded.
  ///
  /// In en, this message translates to:
  /// **'This passage comes from Bible Gateway, which needs the internet. Download {translation} to read it anywhere.'**
  String bibleOfflineMessage(String translation);

  /// Verse panel message when offline and the current Bible translation cannot be downloaded.
  ///
  /// In en, this message translates to:
  /// **'This passage comes from Bible Gateway, which needs the internet. Connect and try again.'**
  String get bibleOfflineNoDownloadMessage;

  /// Button in the verse panel to reload the passage.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get bibleTryAgain;

  /// Title in the verse panel for a Bible translation that is only available as a download.
  ///
  /// In en, this message translates to:
  /// **'Download {translation}'**
  String bibleNeedsDownloadTitle(String translation);

  /// Verse panel message for a Bible translation that must be downloaded before it can be shown.
  ///
  /// In en, this message translates to:
  /// **'This Bible is read from your device. Download it once (about {size}) to see the passage.'**
  String bibleNeedsDownloadMessage(String size);

  /// Verse panel message when the passage reference is not in the downloaded Bible text and there is no web fallback.
  ///
  /// In en, this message translates to:
  /// **'This passage couldn\'t be found in {translation}.'**
  String bibleNotInTranslation(String translation);

  /// Small hint under the Content step of a homiletics study: tapping a verse number in the passage adds a content summary starting at that verse.
  ///
  /// In en, this message translates to:
  /// **'Tip: tap a verse number to start a summary there.'**
  String get bibleVerseTapTip;

  /// Screen-reader label for a tappable verse number in the passage.
  ///
  /// In en, this message translates to:
  /// **'Start a summary at verse {verse}'**
  String bibleVerseTapLabel(String verse);

  /// Title of the bottom sheet listing the ways to share a study (link, QR code, PDF, print).
  ///
  /// In en, this message translates to:
  /// **'Share this study'**
  String get shareSheetTitle;

  /// Share-sheet option: send a link to the study through the system share sheet (Messages, AirDrop, email...).
  ///
  /// In en, this message translates to:
  /// **'Share link'**
  String get shareLink;

  /// Small line under "Share link": the recipient can open the link in Homiletics or on the website.
  ///
  /// In en, this message translates to:
  /// **'Opens in the app, or in any browser'**
  String get shareLinkSubtitle;

  /// Share-sheet option: copy the study link to the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get shareCopyLink;

  /// Snack bar after the study link was copied to the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get shareLinkCopied;

  /// Share-sheet option: show a QR code of the study link for another phone to scan.
  ///
  /// In en, this message translates to:
  /// **'Show QR code'**
  String get shareShowQr;

  /// Share-sheet option: share the study as a PDF document.
  ///
  /// In en, this message translates to:
  /// **'Share PDF'**
  String get shareSharePdf;

  /// Snack bar when sharing or copying the study link failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t share the link.'**
  String get shareLinkFailed;

  /// Title of the warning shown before sharing a study whose link is over ~8000 characters.
  ///
  /// In en, this message translates to:
  /// **'This link is very long'**
  String get shareLinkTooLongTitle;

  /// Warning before sharing a very long study link. {count} is the number of characters in the link.
  ///
  /// In en, this message translates to:
  /// **'This study makes a link of {count} characters. Some apps may cut it off, so it might not open. If that happens, share the PDF instead.'**
  String shareLinkTooLongMessage(int count);

  /// Button in the long-link warning that goes ahead with sharing.
  ///
  /// In en, this message translates to:
  /// **'Share anyway'**
  String get shareAnyway;

  /// Heading of the QR code sheet.
  ///
  /// In en, this message translates to:
  /// **'Scan to open'**
  String get shareQrTitle;

  /// Explanation under the QR code.
  ///
  /// In en, this message translates to:
  /// **'Point another phone\'s camera at the code to open this study.'**
  String get shareQrHint;

  /// Shown in the QR sheet when the link has too much data to fit in a QR code.
  ///
  /// In en, this message translates to:
  /// **'This study is too long for a QR code. Use Share link or Copy link instead.'**
  String get shareQrTooLong;

  /// Screen-reader label of the QR code image.
  ///
  /// In en, this message translates to:
  /// **'QR code linking to this study'**
  String get shareQrSemantics;

  /// Home header button and sheet title: open a study someone shared as a link.
  ///
  /// In en, this message translates to:
  /// **'Import from link'**
  String get importFromLink;

  /// Explanation in the "Import from link" sheet.
  ///
  /// In en, this message translates to:
  /// **'Paste a Homiletics link someone shared with you. You can look it over before saving a copy.'**
  String get importSheetMessage;

  /// Hint in the link field of the import sheet (an example link; usually left as is).
  ///
  /// In en, this message translates to:
  /// **'https://homiletics.app/view#…'**
  String get importFieldHint;

  /// Button that pastes the clipboard into the import field.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get importPaste;

  /// Button that opens the pasted link in the import preview.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get importOpen;

  /// Shown when Paste was tapped but the clipboard has no text.
  ///
  /// In en, this message translates to:
  /// **'There is no text to paste.'**
  String get importClipboardEmpty;

  /// Error for a link that cannot be read (not ours, cut off, or corrupted).
  ///
  /// In en, this message translates to:
  /// **'This isn\'t a Homiletics link, or part of it is missing. Ask for the link again.'**
  String get importInvalidLink;

  /// Error for a link made by a newer app version.
  ///
  /// In en, this message translates to:
  /// **'This study was shared from a newer version of Homiletics. Update Homiletics to open this.'**
  String get importNewerVersion;

  /// Title of the dialog shown when an incoming link cannot be opened.
  ///
  /// In en, this message translates to:
  /// **'Can\'t open this link'**
  String get importCouldNotOpenTitle;

  /// Small label above the passage on the preview of a shared homiletic.
  ///
  /// In en, this message translates to:
  /// **'Shared homiletics'**
  String get importPreviewHomiletic;

  /// Small label above the passage on the preview of a shared word study.
  ///
  /// In en, this message translates to:
  /// **'Shared word study'**
  String get importPreviewWordStudy;

  /// Note at the top of the shared-study preview.
  ///
  /// In en, this message translates to:
  /// **'Someone shared this with you. Saving adds a copy to your studies; nothing you already have is changed.'**
  String get importPreviewNote;

  /// Line on the shared-study preview naming the Bible translation the sharer used, e.g. "Written with NIV".
  ///
  /// In en, this message translates to:
  /// **'Written with {translation}'**
  String importPreviewTranslation(String translation);

  /// Button on the shared-study preview that saves it as a new study of the user.
  ///
  /// In en, this message translates to:
  /// **'Save a copy'**
  String get importSaveCopy;

  /// Snack bar after a shared study was saved as a copy.
  ///
  /// In en, this message translates to:
  /// **'Saved to your studies'**
  String get importSaved;

  /// Snack bar when saving a shared study failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the study. Try again.'**
  String get importSaveFailed;

  /// Button above the "Study another passage" field when a share link was pasted into it.
  ///
  /// In en, this message translates to:
  /// **'Open shared study'**
  String get startOpenSharedStudy;

  /// Windows only: verse panel title when the chosen translation is only available from Bible Gateway, which can't be shown inside the app on Windows.
  ///
  /// In en, this message translates to:
  /// **'Read {translation} in your browser'**
  String bibleWebUnavailableTitle(String translation);

  /// Windows only: verse panel message explaining that Bible Gateway passages open in the web browser, or the user can switch to an offline translation.
  ///
  /// In en, this message translates to:
  /// **'On Windows the app can\'t show Bible Gateway passages inside the app. Open this passage in your browser, or switch to a translation that\'s read from your device.'**
  String get bibleWebUnavailableMessage;

  /// Windows only: button in the verse panel that opens the passage on Bible Gateway in the web browser.
  ///
  /// In en, this message translates to:
  /// **'Open in browser'**
  String get bibleOpenInBrowser;

  /// Windows only: button in the verse panel that switches the Bible translation to one that can be read offline in the app.
  ///
  /// In en, this message translates to:
  /// **'Use an offline translation ({translation})'**
  String bibleUseOfflineTranslation(String translation);

  /// Windows only: snackbar after the 'other usage' Bible Gateway search was opened in the web browser (it can't be shown in the app there); the user types or pastes references into the field themselves.
  ///
  /// In en, this message translates to:
  /// **'Search results opened in your browser. Type or paste the references you want to keep here.'**
  String get wordStudyOtherUsageOpenedInBrowser;

  /// Section heading on the settings page above the lecture recording storage controls. Shown in upper case.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get settingsSectionStorage;

  /// Title of the settings card showing how much space lecture recordings take.
  ///
  /// In en, this message translates to:
  /// **'Lecture recordings'**
  String get storageRecordingsTitle;

  /// Shown on the recordings storage card while the app adds up the size of the recordings.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get storageChecking;

  /// Recordings storage card: how many lecture recordings are on the device and the space they take, e.g. "34 recordings · 1.2 GB".
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No recordings stored} =1{1 recording · {size}} other{{count} recordings · {size}}}'**
  String storageRecordingsSummary(int count, String size);

  /// Label next to the age picker (1 month, 3 months, …) on the recordings storage card.
  ///
  /// In en, this message translates to:
  /// **'Remove recordings older than'**
  String get storageRemoveOlderThan;

  /// Age option for removing old recordings.
  ///
  /// In en, this message translates to:
  /// **'1 month'**
  String get storageAgeOneMonth;

  /// Age option for removing old recordings.
  ///
  /// In en, this message translates to:
  /// **'3 months'**
  String get storageAgeThreeMonths;

  /// Age option for removing old recordings.
  ///
  /// In en, this message translates to:
  /// **'6 months'**
  String get storageAgeSixMonths;

  /// Age option for removing old recordings.
  ///
  /// In en, this message translates to:
  /// **'1 year'**
  String get storageAgeOneYear;

  /// Under the age picker: how many recordings are older than the chosen age and how much space removing them frees.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{None that old} =1{1 recording · {size}} other{{count} recordings · {size}}}'**
  String storageOlderSummary(int count, String size);

  /// Button that removes the old recordings (after a confirmation).
  ///
  /// In en, this message translates to:
  /// **'Free up space'**
  String get storageFreeUpSpace;

  /// Title of the confirmation before removing old recordings.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Remove 1 recording?} other{Remove {count} recordings?}}'**
  String storageConfirmTitle(int count);

  /// Confirmation body before removing old recordings. Make clear only the audio goes and the written notes/transcripts stay.
  ///
  /// In en, this message translates to:
  /// **'This frees about {size}. Your notes, transcripts and time marks are kept; only the audio is deleted, and it can’t be brought back.'**
  String storageConfirmMessage(String size);

  /// Extra line in the removal confirmation when some of the recordings have no transcript.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 of them was never transcribed, so only your notes will be left of it.} other{{count} of them were never transcribed, so only your notes will be left of them.}}'**
  String storageConfirmUntranscribed(int count);

  /// Destructive button in the confirmation that removes the old recordings.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get storageConfirmRemove;

  /// Snackbar after old recordings were removed.
  ///
  /// In en, this message translates to:
  /// **'Freed {size}.'**
  String storageFreed(String size);

  /// Snackbar when removing some recordings failed.
  ///
  /// In en, this message translates to:
  /// **'Some recordings couldn’t be removed. Try again.'**
  String get storageRemoveFailed;

  /// Switch on the recordings storage card that removes old recordings once a day.
  ///
  /// In en, this message translates to:
  /// **'Remove automatically'**
  String get storageAutoRemove;

  /// Under the "Remove automatically" switch. {age} is one of the age options, e.g. "3 months".
  ///
  /// In en, this message translates to:
  /// **'Once a day, removes recordings older than {age} that have a transcript.'**
  String storageAutoRemoveDetail(String age);

  /// Shown on the lecture recording bar in place of the player when the audio was removed by "Free up space".
  ///
  /// In en, this message translates to:
  /// **'Recording removed to save space'**
  String get lectureRecordingRemovedTitle;

  /// Second line on the recording bar under "Recording removed to save space".
  ///
  /// In en, this message translates to:
  /// **'Your notes and transcript are kept'**
  String get lectureRecordingRemovedSubtitle;

  /// Transcript tab when the recording was removed by "Free up space" and never transcribed.
  ///
  /// In en, this message translates to:
  /// **'The recording was removed to save space before it was transcribed.'**
  String get lectureTranscriptEmptyRecordingRemoved;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'es',
    'fr',
    'pt',
    'sw',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return AppLocalizationsZhHans();
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
    case 'sw':
      return AppLocalizationsSw();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
