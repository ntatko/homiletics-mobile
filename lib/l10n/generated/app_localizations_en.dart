// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get prefsTitle => 'Preferences';

  @override
  String get prefsAppLanguage => 'Preferred language';

  @override
  String get prefsBibleVersion => 'Preferred Bible version';

  @override
  String get bibleNewTestamentOnly => 'New Testament only';

  @override
  String get appTitle => 'Homiletics';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonOk => 'Ok';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonDone => 'Done';

  @override
  String get commonSave => 'Save';

  @override
  String get commonClose => 'Close';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonSomethingWentWrong =>
      'Something went wrong. Try again soon.';

  @override
  String get languageSystemDefault => 'Phone language';

  @override
  String get stepContent => 'Content';

  @override
  String get stepDivisions => 'Divisions';

  @override
  String get stepSummary => 'Summary sentence';

  @override
  String get stepFcf => 'FCF';

  @override
  String get stepAim => 'Aim';

  @override
  String get stepApplication => 'Application';

  @override
  String get stepShortContent => 'Content';

  @override
  String get stepShortDivisions => 'Divide';

  @override
  String get stepShortSummary => 'Summary';

  @override
  String get stepShortFcf => 'FCF';

  @override
  String get stepShortAim => 'Aim';

  @override
  String get stepShortApplication => 'Apply';

  @override
  String get commonShare => 'Share';

  @override
  String get commonPrint => 'Print';

  @override
  String get commonPreferences => 'Preferences';

  @override
  String get commonUntitled => 'Untitled';

  @override
  String get homeSearchIntro =>
      'Search your homiletics, divisions, applications, lecture notes and word studies.';

  @override
  String get homeSearchFieldHint => 'Search lessons, passages, notes…';

  @override
  String get homeSearchTooltip => 'Search';

  @override
  String get homeCloseSearch => 'Close search';

  @override
  String get homeAllStudies => 'All studies';

  @override
  String get homeFilterByStudy => 'Filter by study';

  @override
  String get homeOpenStudySite => 'Open study website';

  @override
  String get homeThisWeek => 'This week';

  @override
  String get homeEarlier => 'Earlier';

  @override
  String get homeComingUp => 'Coming up';

  @override
  String homeWeekOverline(String when, String lesson) {
    return '$when · $lesson';
  }

  @override
  String get homeStartHomiletics => 'Start homiletics';

  @override
  String get homeContinueHomiletics => 'Continue homiletics';

  @override
  String get homeOpenHomiletics => 'Open homiletics';

  @override
  String get homeLoadingPassages => 'Loading suggested passages…';

  @override
  String get homeContinue => 'Continue';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get homeLivingItOut => 'Living it out';

  @override
  String get homeKindTileHomiletic => 'H';

  @override
  String get homeKindTileWordStudy => 'W';

  @override
  String get homeProgressNoneDone => 'No steps done yet';

  @override
  String homeProgressDone(String steps) {
    return 'Done: $steps';
  }

  @override
  String homePageOf(int page, int count) {
    return 'Page $page of $count';
  }

  @override
  String homePageFraction(int page, int count) {
    return '$page / $count';
  }

  @override
  String get studiesTitle => 'Your studies';

  @override
  String get studiesTabHomiletics => 'Homiletics';

  @override
  String get studiesTabLectures => 'Lectures';

  @override
  String get studiesTabWordStudies => 'Word studies';

  @override
  String get studiesNoHomiletics => 'No homiletics yet.';

  @override
  String get studiesNoLectureNotes => 'No lecture notes yet.';

  @override
  String get studiesNoWordStudies => 'No word studies yet.';

  @override
  String get studiesNoApplications => 'No application questions yet.';

  @override
  String get studiesProgressNotStarted => 'Not started';

  @override
  String studiesProgressAll(int total) {
    return 'All $total steps';
  }

  @override
  String studiesProgressSome(int done, int total) {
    return '$done of $total steps';
  }

  @override
  String studiesHomileticSubtitle(String progress, String time) {
    return 'Homiletics · $progress · $time';
  }

  @override
  String studiesHomileticSubtitleNoProgress(String time) {
    return 'Homiletics · $time';
  }

  @override
  String studiesLectureTitle(String passage) {
    return '$passage lecture';
  }

  @override
  String get studiesLectureUntitled => 'Lecture';

  @override
  String studiesLectureSubtitle(String time) {
    return 'Lecture notes · $time';
  }

  @override
  String get studiesWordStudyUntitled => 'Word study';

  @override
  String studiesWordStudySubtitle(String time) {
    return 'Word study · $time';
  }

  @override
  String studiesWordStudySubtitleWithPassage(String passage, String time) {
    return 'Word study · $passage · $time';
  }

  @override
  String get searchHint => 'Search';

  @override
  String get searchSectionContentSummaries => 'Content Summaries';

  @override
  String get searchSectionDivisions => 'Divisions';

  @override
  String get searchSectionApplications => 'Applications';

  @override
  String get searchSectionAims => 'Aims';

  @override
  String get searchSectionSummarySentences => 'Summary Sentences';

  @override
  String get searchSectionPassages => 'Homiletics Passages';

  @override
  String get searchSectionLectureNotes => 'Lecture Notes';

  @override
  String get searchSectionWordStudies => 'Word Studies';

  @override
  String get searchOpenFailed =>
      'Couldn\'t open that result. It may have been deleted.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionLanguage => 'Language';

  @override
  String get settingsAppLanguage => 'App language';

  @override
  String get settingsSectionReading => 'Reading';

  @override
  String get settingsSectionModels => 'On-device models';

  @override
  String get settingsSectionHelp => 'Help';

  @override
  String settingsCopyright(String year) {
    return 'Copyright (C) $year 13one.org · All rights reserved';
  }

  @override
  String get helpRequestFeedback => 'Request help / leave feedback';

  @override
  String helpCopyright(String year) {
    return 'Copyright (C) $year 13one.org';
  }

  @override
  String get helpAllRightsReserved => 'All rights reserved';

  @override
  String get feedbackTitle => 'Leave some feedback';

  @override
  String get feedbackPublicNotice =>
      'Your feedback is submitted as a public GitHub issue—anyone on the internet can read it. Do not include passwords or other private information. Your email is partially hidden on GitHub; we may keep the full address on our servers only to follow up.';

  @override
  String get feedbackTypeGeneral => 'Help or feedback';

  @override
  String get feedbackTypeTranslation => 'Translation issue';

  @override
  String get feedbackTranslationHint =>
      'Tell us which words look wrong and what they should say. We\'ll include your app language and Bible translation.';

  @override
  String get feedbackNameLabel => 'Name';

  @override
  String get feedbackEmailLabel => 'Email (optional)';

  @override
  String get feedbackContentLabel => 'Feedback';

  @override
  String get feedbackSubmit => 'Submit';

  @override
  String get feedbackEmpty => 'Please enter your feedback first.';

  @override
  String get feedbackSubmittedIssue =>
      'Submitted. Open the issue on GitHub anytime to add comments (sign-in optional).';

  @override
  String get feedbackOpenIssue => 'Open';

  @override
  String get feedbackSubmitted => 'Successfully submitted feedback';

  @override
  String get feedbackBadRequest =>
      'Could not submit that request. Check your message and try again.';

  @override
  String get feedbackServerUnreachableTitle => 'Could not reach the server';

  @override
  String get feedbackServerUnreachableBody =>
      'Open GitHub in your browser to file this report instead. You may need to sign in there to submit the issue.';

  @override
  String get feedbackNotNow => 'Not now';

  @override
  String get feedbackOpenGitHub => 'Open GitHub';

  @override
  String get feedbackBrowserFailed => 'Could not open the browser.';

  @override
  String get startHomiletics => 'Homiletics';

  @override
  String get startLecture => 'Lecture';

  @override
  String get startWordStudy => 'Word study';

  @override
  String get startPassageHint => 'Study another passage…';

  @override
  String get startClear => 'Clear';

  @override
  String get startOtherStudy => 'Other study';

  @override
  String get startMenuLectureNote => 'Lecture Note';

  @override
  String get startMenuWordStudy => 'Word Study';

  @override
  String get startDuplicateHomileticTitle =>
      'Already have a homiletic for this passage?';

  @override
  String startDuplicateHomileticMany(String passage, int count) {
    return '$passage\n\nYou have $count homiletics for this passage; opening the most recent.';
  }

  @override
  String get startDuplicateLectureTitle =>
      'Already have lecture notes for this passage?';

  @override
  String startDuplicateLectureMany(String passage, int count) {
    return '$passage\n\nYou have $count lecture notes for this passage; opening the most recent.';
  }

  @override
  String get startDuplicateWordStudyTitle =>
      'Already have a word study for this passage?';

  @override
  String startDuplicateWordStudyMany(String passage, int count) {
    return '$passage\n\nYou have $count word studies for this passage; opening the most recent.';
  }

  @override
  String get startCreateNew => 'Create new';

  @override
  String get startEditExisting => 'Edit existing';

  @override
  String get homileticHeaderLabel => 'Homiletics · Passage';

  @override
  String get homileticItemName => 'Homiletics lesson';

  @override
  String get homileticDeletedMessage => 'Homiletics Deleted';

  @override
  String get homileticLoadError => 'Something went wrong loading this lesson.';

  @override
  String get homileticPdfShared => 'PDF shared successfully.';

  @override
  String get homileticPdfShareFailed =>
      'Something went wrong sharing your PDF. Try again soon.';

  @override
  String get homileticPdfPrinted => 'PDF printed successfully.';

  @override
  String get homileticPdfPrintFailed =>
      'Something went wrong creating your PDF. Try again soon.';

  @override
  String get homileticCompleteTitle => 'All six steps done';

  @override
  String get homileticCompleteMessage =>
      'Print it for class, or share it with your group.';

  @override
  String get homileticContentEmptySummary => 'Verses + summary';

  @override
  String get homileticDivisionsEmptySummary => '2–4 groupings';

  @override
  String get homileticSummaryEmptySummary => '≤ 10 words';

  @override
  String get homileticFcfEmptySummary => 'Fallen condition focus';

  @override
  String get homileticAimEmptySummary => 'The main takeaway';

  @override
  String get homileticApplicationEmptySummary => 'How can I…';

  @override
  String get homileticStepStatusDone => 'done';

  @override
  String get homileticStepStatusToDo => 'to do';

  @override
  String homileticStepCollapseLabel(String title) {
    return '$title, collapse';
  }

  @override
  String homileticStepHelpLabel(String title) {
    return 'About $title';
  }

  @override
  String get homileticVersesLabel => 'Verses';

  @override
  String get homileticVersesHint => 'v.';

  @override
  String homileticAddButtonLabel(String label) {
    return '+ $label';
  }

  @override
  String get homileticRemoveRowMessage =>
      'What you\'ve written here will be deleted.';

  @override
  String get homileticRemoveRowConfirm => 'Remove';

  @override
  String get homileticContentSummaryHint => 'Summary…';

  @override
  String get homileticAddContentSummary => 'Add summary';

  @override
  String get homileticRemoveContentSummaryTooltip => 'Remove content summary';

  @override
  String get homileticRemoveContentSummaryTitle =>
      'Remove this content summary?';

  @override
  String get homileticRemoveContentSummaryFailed =>
      'Removing that Content Summary didn\'t work';

  @override
  String get homileticDivisionHint => 'Division sentence…';

  @override
  String get homileticAddDivision => 'Add division';

  @override
  String get homileticRemoveDivisionTooltip => 'Remove division';

  @override
  String get homileticRemoveDivisionTitle => 'Remove this division?';

  @override
  String get homileticRemoveDivisionFailed =>
      'Removing that Division didn\'t work';

  @override
  String get homileticApplicationHint => 'How can I…';

  @override
  String get homileticAddApplication => 'Add question';

  @override
  String get homileticRemoveApplicationTooltip => 'Remove application question';

  @override
  String get homileticRemoveApplicationTitle =>
      'Remove this application question?';

  @override
  String get homileticRemoveApplicationFailed =>
      'Removing that Application didn\'t work';

  @override
  String get homileticSummaryHint => 'Summarize: 10 words or fewer';

  @override
  String get homileticFcfHint => 'Fallen/Frail/Feeble/Fickle';

  @override
  String get homileticAimHint => 'Cause the audience to learn that…';

  @override
  String get homileticContentHelpTitle => 'Content Summaries';

  @override
  String get homileticContentHelpText =>
      'A content summary is a summary of a section of the Bible. It doesn\'t need to be a sentence, it can also be more than one sentence. It should be a summary, in your own words, of the content of the passage.\nYou should have at least 10, but no more than 20 content summaries. Generally, depending on the length of the passage, you will divide your passage into chunks of an approximate size to hit the 10-20 mark. So, if your passage is 30 verses, I\'d try for 3 verses per content summary on average.';

  @override
  String get homileticDivisionsHelpText =>
      'Divisions are groupings of verses that are related. There should be at least two and no more than four.';

  @override
  String get homileticSummaryHelpTitle => 'Summary Sentence';

  @override
  String get homileticSummaryHelpText =>
      'The Summary Sentence is a concise, memorable statement that encapsulates the most relevant facts. A good way of thinking of it is the 2am test: if someone were to wake you up at 2am and ask you what the sermon was about, what would you say? You\'d say the Summary Sentence.\nIt should be 10 words or fewer. If you\'re feeling frisky, you can try to make an alliteration.';

  @override
  String get homileticFcfHelpText =>
      'The FCF (Fallen Condition Focus) is the part of humanity that is the most illustrated or referenced in the passage. It is the condition that the audience is in, the reason that the audience needs to be saved.';

  @override
  String get homileticAimHelpText =>
      'The Aim is the key point, the one main takeaway truth you want yourself or an audience to walk away with. It may be derivable from the FCF, and will likely influence the Application Questions.';

  @override
  String get homileticApplicationHelpTitle => 'Application Questions';

  @override
  String get homileticApplicationHelpText =>
      'These are questions that help the audience apply what they\'ve just heard to their own lives. They should be specific, personal, open-ended, and thought-provoking.';

  @override
  String homileticSummaryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count summaries',
      one: '1 summary',
    );
    return '$_temp0';
  }

  @override
  String homileticDivisionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count divisions',
      one: '1 division',
    );
    return '$_temp0';
  }

  @override
  String homileticQuestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions',
      one: '1 question',
    );
    return '$_temp0';
  }

  @override
  String homileticStepTileLabel(String title, String status) {
    return '$title, $status';
  }

  @override
  String homileticStepTileLabelWithSummary(
    String title,
    String status,
    String summary,
  ) {
    return '$title, $status, $summary';
  }

  @override
  String get lectureItemName => 'Lecture Note';

  @override
  String get lectureDeleted => 'Lecture Note Deleted';

  @override
  String get lecturePassageHint => 'Passage';

  @override
  String get lectureHeaderLabel => 'Lecture · Passage';

  @override
  String get lectureNotesPlaceholder => 'Notes';

  @override
  String get lectureToolbarBold => 'Bold';

  @override
  String get lectureToolbarItalic => 'Italic';

  @override
  String get lectureToolbarBulletedList => 'Bulleted list';

  @override
  String get lectureToolbarNumberedList => 'Numbered list';

  @override
  String get lectureReplaceTitle => 'Replace existing recording?';

  @override
  String get lectureReplaceMessage =>
      'The old audio and transcript will be deleted.';

  @override
  String get lectureReplaceConfirm => 'Replace';

  @override
  String get lectureMicPermissionRequired =>
      'Microphone permission is required to record.';

  @override
  String get lectureNotificationTitle => 'Recording lecture';

  @override
  String lectureNotificationContent(String appName) {
    return '$appName is recording audio';
  }

  @override
  String get lectureStartFailed =>
      'Couldn\'t start recording. The microphone may be in use by another app.';

  @override
  String get lectureTranscriptionModelTitle =>
      'Download offline transcription model?';

  @override
  String get lectureTranscriptionModelMessage =>
      'A one-time ~140MB download lets your recordings be automatically transcribed and searched. You can skip this and download it later from Settings.';

  @override
  String get lectureNotNow => 'Not now';

  @override
  String get lectureDownload => 'Download';

  @override
  String get lectureModelDownloadFailed =>
      'Something went wrong downloading the model. You can try again from Settings.';

  @override
  String get lectureRecordingFileNotFound =>
      'The recording file couldn\'t be found.';

  @override
  String get lectureTranscriptionEmpty =>
      'Transcription didn\'t produce any text.';

  @override
  String get lectureFormattingModelTitle =>
      'Download transcript formatting model?';

  @override
  String lectureFormattingModelMessage(String size) {
    return 'A one-time $size download lets transcripts be cleaned up into readable paragraphs, entirely on your device. Wi-Fi recommended. You can also do this later from Settings.';
  }

  @override
  String get lectureFormattingModelMissing =>
      'The formatting model isn\'t downloaded.';

  @override
  String get lectureFormattingFailed => 'Couldn\'t format the transcript.';

  @override
  String get lecturePlaybackFailed => 'Couldn\'t play the recording.';

  @override
  String lectureDownloadingModel(String percent) {
    return 'Downloading model $percent%';
  }

  @override
  String lectureTranscribingProgress(int percent) {
    return 'Transcribing $percent%';
  }

  @override
  String lectureFormattingProgress(int done, int total) {
    return 'Formatting transcript $done/$total';
  }

  @override
  String get lectureFormattingIndeterminate => 'Formatting transcript…';

  @override
  String lectureRecordingSemantics(String time) {
    return 'Recording, $time';
  }

  @override
  String get lectureRecordingSubtitle =>
      'Recording · keeps going with the screen off';

  @override
  String get lectureStopRecording => 'Stop recording';

  @override
  String get lectureRecordLecture => 'Record lecture';

  @override
  String get lectureRecordIdleSubtitle => 'Keeps recording with the screen off';

  @override
  String get lecturePause => 'Pause';

  @override
  String get lecturePlayRecording => 'Play recording';

  @override
  String get lectureRecordAgain => 'Record again';

  @override
  String get lectureNotTranscribedYet => 'Not transcribed yet';

  @override
  String get lectureTranscribe => 'Transcribe';

  @override
  String get lectureTimeMark => '+ Time mark';

  @override
  String get lectureTranscriptEmptyRecording =>
      'The lecture is transcribed on this phone after you stop recording.';

  @override
  String get lectureTranscriptEmptyPending =>
      'The transcript will appear here when it\'s ready.';

  @override
  String get lectureTranscriptEmptyNotTranscribed =>
      'Transcribe the recording to read and search it here.';

  @override
  String get lectureTranscriptEmptyNoRecording =>
      'Record the lecture and it\'s transcribed on this phone after you stop.';

  @override
  String get lectureTranscribing => 'Transcribing…';

  @override
  String get lectureNoTranscriptYet => 'No transcript yet';

  @override
  String get lectureFormatted => 'Formatted';

  @override
  String get lectureRaw => 'Raw';

  @override
  String get lectureFormatTranscript => 'Format transcript';

  @override
  String get lectureTabMyNotes => 'My notes';

  @override
  String get lectureTabTranscript => 'Transcript';

  @override
  String get modelTranscriptionTitle => 'Offline transcription model';

  @override
  String modelTranscriptionEnglishNeeded(String language) {
    return 'English model, needed for $language';
  }

  @override
  String modelTranscriptionEnglishNotNeeded(String language) {
    return 'English model, not needed for $language';
  }

  @override
  String modelTranscriptionMultilingualNeeded(String language) {
    return 'Multilingual model, needed for $language';
  }

  @override
  String modelTranscriptionMultilingualNotNeeded(String language) {
    return 'Multilingual model, not needed for $language';
  }

  @override
  String get modelFormattingTitle => 'Transcript formatting model';

  @override
  String get modelAppleIntelligenceStatus =>
      'Using Apple Intelligence (no download needed)';

  @override
  String get modelStatusChecking => 'Checking…';

  @override
  String modelStatusNotDownloaded(String size) {
    return 'Not downloaded ($size)';
  }

  @override
  String modelStatusDownloading(String percent) {
    return 'Downloading… $percent%';
  }

  @override
  String get modelStatusDownloaded => 'Downloaded';

  @override
  String modelStatusDownloadedSize(String megabytes) {
    return 'Downloaded (${megabytes}MB)';
  }

  @override
  String get modelDownload => 'Download';

  @override
  String get modelDelete => 'Delete';

  @override
  String get modelDownloadFailed =>
      'Something went wrong downloading the model. Try again soon.';

  @override
  String get modelDeleteFailed => 'Something went wrong deleting the model.';

  @override
  String get pdfOverlineHomiletics => 'HOMILETICS';

  @override
  String get pdfOverlineWordStudy => 'WORD STUDY';

  @override
  String get pdfUntitledPassage => 'Untitled passage';

  @override
  String get pdfUntitledWord => 'Untitled word';

  @override
  String pdfHomileticLabel(String passage) {
    return 'Homiletics · $passage';
  }

  @override
  String pdfWordStudyLabel(String word) {
    return 'Word study · $word';
  }

  @override
  String pdfWordStudyLabelWithPassage(String word, String passage) {
    return 'Word study · $word · $passage';
  }

  @override
  String pdfPageOf(int current, int total) {
    return 'page $current of $total';
  }

  @override
  String get pdfFcfCaption => 'Fallen Condition Focus';

  @override
  String get pdfAimLeadIn => 'Cause the audience to learn that ';

  @override
  String get pdfEmptyHomiletic =>
      'Nothing has been written for this passage yet.';

  @override
  String get pdfEmptyWordStudy =>
      'Nothing has been written for this word study yet.';

  @override
  String get pdfWordStudyDefinition => 'Definition';

  @override
  String get pdfWordStudyOtherUsage => 'Other usage';

  @override
  String get pdfWordStudyContextualMeaning => 'Contextual meaning';

  @override
  String get pdfWordStudyDeeperMeaning => 'Deeper meaning';

  @override
  String get pdfWordStudyApplication => 'Application';

  @override
  String get editorSaveAndClose => 'Save and close';

  @override
  String get editorDeleteConfirmTitle => 'Are you sure?';

  @override
  String editorDeleteConfirmMessage(String itemName) {
    return 'Deleting this $itemName is permanent and cannot be undone. Are you sure you wish to proceed?';
  }

  @override
  String get editorPassageLabel => 'Passage';

  @override
  String get editorAddPassageHint => 'Add a passage';

  @override
  String get editorBack => 'Back';

  @override
  String get editorMoreOptions => 'More options';

  @override
  String get editorChangeTranslation => 'Change translation';

  @override
  String get editorStudyCompleteMessage =>
      'Print it for class, or share it with your group.';

  @override
  String get wordStudyItemName => 'Word Study';

  @override
  String get wordStudyDeleted => 'Word Study Deleted';

  @override
  String get wordStudyHeaderLabel => 'Word study · Passage';

  @override
  String get wordStudyPdfShared => 'PDF shared successfully.';

  @override
  String get wordStudyPdfShareFailed =>
      'Something went wrong sharing your PDF. Try again soon.';

  @override
  String get wordStudyPdfPrinted => 'PDF printed successfully.';

  @override
  String get wordStudyPdfPrintFailed =>
      'Something went wrong creating your PDF. Try again soon.';

  @override
  String get wordStudyWordTitle => 'Word';

  @override
  String get wordStudyWordHelp =>
      'The specific word or short phrase you\'re studying. Once you\'ve entered it, Definition and Other Usage can suggest content for you.';

  @override
  String get wordStudyWordHint => 'Add a word';

  @override
  String get wordStudyEnterWordFirst => 'Enter a word above first.';

  @override
  String get wordStudyDefinitionTitle => 'Definition';

  @override
  String get wordStudyDefinitionHelp =>
      'What does this word mean, in plain terms? Tap \"+\" for candidate definitions pulled from a dictionary, or write your own.';

  @override
  String get wordStudyDefinitionHelpNoSuggest =>
      'What does this word mean, in plain terms? Write your own.';

  @override
  String get wordStudyDefinitionHint => 'What does it mean, in plain terms?';

  @override
  String get wordStudySuggestDefinition => 'Suggest a definition';

  @override
  String wordStudyDefinitionsFor(String word) {
    return 'Definitions for “$word”';
  }

  @override
  String get wordStudyDefinitionsTapToUse => 'Tap one to use it.';

  @override
  String get wordStudyDefinitionsLoadError =>
      'Couldn\'t load definitions. Try again soon.';

  @override
  String get wordStudyNoDefinitions => 'No definitions found for this word.';

  @override
  String get wordStudyReplaceDefinitionTitle => 'Replace your definition?';

  @override
  String get wordStudyReplaceDefinitionMessage =>
      'You\'ve already written a definition. Replace it with the suggestion, or add the suggestion below it?';

  @override
  String get wordStudyAddBelow => 'Add below';

  @override
  String get wordStudyReplace => 'Replace';

  @override
  String get wordStudyOtherUsageTitle => 'Other usage';

  @override
  String get wordStudyOtherUsageHelp =>
      'Where else does this word or concept appear in Scripture? Tap \"+\" to search Bible Gateway and add references you find, or write your own.';

  @override
  String get wordStudyOtherUsageHint =>
      'Where else does it appear in Scripture?';

  @override
  String get wordStudyFindOtherUsages => 'Find other usages';

  @override
  String wordStudyOtherUsageSheetTitle(String word) {
    return 'Where else “$word” appears';
  }

  @override
  String get wordStudyOtherUsageAdded => 'Added';

  @override
  String get wordStudyOtherUsageInstructions =>
      'Tap a result below to add its reference.';

  @override
  String get wordStudyOtherUsageAddResult => '+ Add';

  @override
  String get wordStudyContextualMeaningTitle => 'Contextual meaning';

  @override
  String get wordStudyContextualMeaningHelp =>
      'What did the author intend this word to mean here, in this passage? Consider the surrounding verses, not just the word alone.';

  @override
  String get wordStudyContextualMeaningHint =>
      'What does it mean here, in this passage?';

  @override
  String get wordStudyDeeperMeaningTitle => 'Deeper meaning';

  @override
  String get wordStudyDeeperMeaningHelp =>
      'Any insight from the original language, commentary, or outside study that adds depth beyond the basic definition? How does the rest of Scripture shape it? A Strong\'s concordance or Blue Letter Bible can help here.';

  @override
  String get wordStudyDeeperMeaningHint =>
      'How does the rest of Scripture shape it?';

  @override
  String get wordStudyApplicationTitle => 'Application';

  @override
  String get wordStudyApplicationHelp =>
      'How should this truth shape your life? Be specific, personal, and practical.';

  @override
  String get wordStudyApplicationHint => 'What will you do with it?';

  @override
  String get wordStudyDoneTitle => 'Word study done';

  @override
  String wordStudySectionHelpSemantics(String title) {
    return '$title, about this section';
  }

  @override
  String get lectureTimeMarkNoRecording =>
      'This note has no recording to play.';

  @override
  String get lectureTimeMarkStopRecordingFirst =>
      'Stop recording to play from a time mark.';

  @override
  String get lectureTimeMarkPastEnd =>
      'That time mark is past the end of the recording.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingBack => 'Back';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingWelcomeOverline => 'Welcome';

  @override
  String get onboardingWelcomeTitle => 'Study the Bible, one passage at a time';

  @override
  String get onboardingWelcomeBody =>
      'Homiletics helps you write your homiletics, take lecture notes and do word studies — all with the passage open beside you, in your language and your Bible translation.';

  @override
  String get onboardingMethodOverline => 'The method';

  @override
  String get onboardingMethodTitle => 'What is a homiletic?';

  @override
  String get onboardingMethodBody =>
      'A homiletic is a short way of studying a passage: you find its main message, then think about how to live it out. It takes six steps — and it doesn\'t have to be perfect. It gets easier every week.';

  @override
  String get onboardingStepsOverline => 'Step by step';

  @override
  String get onboardingStepsTitle => 'The six steps';

  @override
  String get onboardingStepContent =>
      'Summarize the passage in 10–20 short chunks, in your own words.';

  @override
  String get onboardingStepDivisions => 'Group those chunks into 2–4 sections.';

  @override
  String get onboardingStepSummary => 'The whole passage in 10 words or fewer.';

  @override
  String get onboardingStepFcf =>
      'Fallen Condition Focus: the human need or brokenness the passage speaks to.';

  @override
  String get onboardingStepAim =>
      'The one main truth you want your hearers to learn.';

  @override
  String get onboardingStepApplication =>
      'Questions that turn the passage into everyday life.';

  @override
  String get onboardingLecturesOverline => 'Lectures & word studies';

  @override
  String get onboardingLecturesTitle => 'Listen closely, dig deeper';

  @override
  String get onboardingLecturesBody =>
      'Record the lecture — it keeps going with the screen off and is transcribed right on your phone. Take notes as you listen and add time marks to find a moment again.';

  @override
  String get onboardingWordStudyBody =>
      'Curious about one word? Start a word study and dig into what it means in the passage.';

  @override
  String get onboardingStartOverline => 'Get started';

  @override
  String get onboardingStartTitle => 'You\'re ready to begin';

  @override
  String get onboardingStartBody =>
      'Begin with this week\'s passage, or take a look around first. Every step you write is saved as you go.';

  @override
  String get onboardingReopenHint =>
      'You can open this guide again anytime from Settings.';

  @override
  String get onboardingStartThisWeek => 'Start this week\'s homiletic';

  @override
  String get onboardingExplore => 'Explore on my own';

  @override
  String onboardingThisWeekPassage(String passage) {
    return 'This week: $passage';
  }

  @override
  String get onboardingSettingsRow => 'How homiletics works';

  @override
  String bibleOfflineSize(String size) {
    return 'Offline · $size';
  }

  @override
  String bibleDownloadedSize(String size) {
    return 'Downloaded · $size';
  }

  @override
  String get bibleDownloadAction => 'Download for offline';

  @override
  String get bibleDownloading => 'Downloading…';

  @override
  String get bibleRemoveDownload => 'Remove download';

  @override
  String bibleDownloadFailed(String translation) {
    return 'Couldn\'t download $translation. Check your connection and try again.';
  }

  @override
  String get bibleOfflineTitle => 'No connection';

  @override
  String bibleOfflineMessage(String translation) {
    return 'This passage comes from Bible Gateway, which needs the internet. Download $translation to read it anywhere.';
  }

  @override
  String get bibleOfflineNoDownloadMessage =>
      'This passage comes from Bible Gateway, which needs the internet. Connect and try again.';

  @override
  String get bibleTryAgain => 'Try again';

  @override
  String bibleNeedsDownloadTitle(String translation) {
    return 'Download $translation';
  }

  @override
  String bibleNeedsDownloadMessage(String size) {
    return 'This Bible is read from your device. Download it once (about $size) to see the passage.';
  }

  @override
  String bibleNotInTranslation(String translation) {
    return 'This passage couldn\'t be found in $translation.';
  }

  @override
  String get bibleVerseTapTip =>
      'Tip: tap a verse number to start a summary there.';

  @override
  String bibleVerseTapLabel(String verse) {
    return 'Start a summary at verse $verse';
  }

  @override
  String get shareSheetTitle => 'Share this study';

  @override
  String get shareLink => 'Share link';

  @override
  String get shareLinkSubtitle => 'Opens in the app, or in any browser';

  @override
  String get shareCopyLink => 'Copy link';

  @override
  String get shareLinkCopied => 'Link copied';

  @override
  String get shareShowQr => 'Show QR code';

  @override
  String get shareSharePdf => 'Share PDF';

  @override
  String get shareLinkFailed => 'Couldn\'t share the link.';

  @override
  String get shareLinkTooLongTitle => 'This link is very long';

  @override
  String shareLinkTooLongMessage(int count) {
    return 'This study makes a link of $count characters. Some apps may cut it off, so it might not open. If that happens, share the PDF instead.';
  }

  @override
  String get shareAnyway => 'Share anyway';

  @override
  String get shareQrTitle => 'Scan to open';

  @override
  String get shareQrHint =>
      'Point another phone\'s camera at the code to open this study.';

  @override
  String get shareQrTooLong =>
      'This study is too long for a QR code. Use Share link or Copy link instead.';

  @override
  String get shareQrSemantics => 'QR code linking to this study';

  @override
  String get importFromLink => 'Import from link';

  @override
  String get importSheetMessage =>
      'Paste a Homiletics link someone shared with you. You can look it over before saving a copy.';

  @override
  String get importFieldHint => 'https://homiletics.app/view#…';

  @override
  String get importPaste => 'Paste';

  @override
  String get importOpen => 'Open';

  @override
  String get importClipboardEmpty => 'There is no text to paste.';

  @override
  String get importInvalidLink =>
      'This isn\'t a Homiletics link, or part of it is missing. Ask for the link again.';

  @override
  String get importNewerVersion =>
      'This study was shared from a newer version of Homiletics. Update Homiletics to open this.';

  @override
  String get importCouldNotOpenTitle => 'Can\'t open this link';

  @override
  String get importPreviewHomiletic => 'Shared homiletics';

  @override
  String get importPreviewWordStudy => 'Shared word study';

  @override
  String get importPreviewNote =>
      'Someone shared this with you. Saving adds a copy to your studies; nothing you already have is changed.';

  @override
  String importPreviewTranslation(String translation) {
    return 'Written with $translation';
  }

  @override
  String get importSaveCopy => 'Save a copy';

  @override
  String get importSaved => 'Saved to your studies';

  @override
  String get importSaveFailed => 'Couldn\'t save the study. Try again.';

  @override
  String get startOpenSharedStudy => 'Open shared study';

  @override
  String bibleWebUnavailableTitle(String translation) {
    return 'Read $translation in your browser';
  }

  @override
  String get bibleWebUnavailableMessage =>
      'On Windows the app can\'t show Bible Gateway passages inside the app. Open this passage in your browser, or switch to a translation that\'s read from your device.';

  @override
  String get bibleOpenInBrowser => 'Open in browser';

  @override
  String bibleUseOfflineTranslation(String translation) {
    return 'Use an offline translation ($translation)';
  }

  @override
  String get wordStudyOtherUsageOpenedInBrowser =>
      'Search results opened in your browser. Type or paste the references you want to keep here.';
}
