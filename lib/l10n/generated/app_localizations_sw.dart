// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get prefsTitle => 'Mapendeleo';

  @override
  String get prefsAppLanguage => 'Lugha unayopendelea';

  @override
  String get prefsBibleVersion => 'Toleo la Biblia unalopendelea';

  @override
  String get bibleNewTestamentOnly => 'Agano Jipya pekee';

  @override
  String get appTitle => 'Homiletics';

  @override
  String get commonCancel => 'Ghairi';

  @override
  String get commonOk => 'Sawa';

  @override
  String get commonDelete => 'Futa';

  @override
  String get commonDone => 'Tayari';

  @override
  String get commonSave => 'Hifadhi';

  @override
  String get commonClose => 'Funga';

  @override
  String get commonRetry => 'Jaribu tena';

  @override
  String get commonSomethingWentWrong =>
      'Hitilafu imetokea. Jaribu tena baadaye kidogo.';

  @override
  String get languageSystemDefault => 'Lugha ya simu';

  @override
  String get stepContent => 'Maudhui';

  @override
  String get stepDivisions => 'Migawanyo';

  @override
  String get stepSummary => 'Sentensi ya muhtasari';

  @override
  String get stepFcf => 'FCF';

  @override
  String get stepAim => 'Lengo';

  @override
  String get stepApplication => 'Matumizi';

  @override
  String get stepShortContent => 'Maudhui';

  @override
  String get stepShortDivisions => 'Gawanya';

  @override
  String get stepShortSummary => 'Muhtasari';

  @override
  String get stepShortFcf => 'FCF';

  @override
  String get stepShortAim => 'Lengo';

  @override
  String get stepShortApplication => 'Tumia';

  @override
  String get commonShare => 'Shiriki';

  @override
  String get commonPrint => 'Chapisha';

  @override
  String get commonPreferences => 'Mapendeleo';

  @override
  String get commonUntitled => 'Bila kichwa';

  @override
  String get homeSearchIntro =>
      'Tafuta homiletiki zako, migawanyo, matumizi, madokezo ya hotuba na uchunguzi wa maneno.';

  @override
  String get homeSearchFieldHint => 'Tafuta masomo, vifungu, madokezo…';

  @override
  String get homeSearchTooltip => 'Tafuta';

  @override
  String get homeCloseSearch => 'Funga utafutaji';

  @override
  String get homeAllStudies => 'Masomo yote';

  @override
  String get homeFilterByStudy => 'Chuja kwa somo';

  @override
  String get homeOpenStudySite => 'Fungua tovuti ya somo';

  @override
  String get homeThisWeek => 'Wiki hii';

  @override
  String get homeEarlier => 'Awali';

  @override
  String get homeComingUp => 'Inakuja';

  @override
  String homeWeekOverline(String when, String lesson) {
    return '$when · $lesson';
  }

  @override
  String get homeStartHomiletics => 'Anza homiletiki';

  @override
  String get homeContinueHomiletics => 'Endelea na homiletiki';

  @override
  String get homeOpenHomiletics => 'Fungua homiletiki';

  @override
  String get homeLoadingPassages => 'Inapakia vifungu vilivyopendekezwa…';

  @override
  String get homeContinue => 'Endelea';

  @override
  String get homeSeeAll => 'Ona yote';

  @override
  String get homeLivingItOut => 'Kuishi kwa vitendo';

  @override
  String get homeKindTileHomiletic => 'H';

  @override
  String get homeKindTileWordStudy => 'N';

  @override
  String get homeProgressNoneDone => 'Bado hakuna hatua iliyokamilika';

  @override
  String homeProgressDone(String steps) {
    return 'Zimekamilika: $steps';
  }

  @override
  String homePageOf(int page, int count) {
    return 'Ukurasa $page kati ya $count';
  }

  @override
  String homePageFraction(int page, int count) {
    return '$page / $count';
  }

  @override
  String get studiesTitle => 'Masomo yako';

  @override
  String get studiesTabHomiletics => 'Homiletiki';

  @override
  String get studiesTabLectures => 'Hotuba';

  @override
  String get studiesTabWordStudies => 'Uchunguzi wa maneno';

  @override
  String get studiesNoHomiletics => 'Bado hakuna homiletiki.';

  @override
  String get studiesNoLectureNotes => 'Bado hakuna madokezo ya hotuba.';

  @override
  String get studiesNoWordStudies => 'Bado hakuna uchunguzi wa maneno.';

  @override
  String get studiesNoApplications => 'Bado hakuna maswali ya matumizi.';

  @override
  String get studiesProgressNotStarted => 'Haijaanza';

  @override
  String studiesProgressAll(int total) {
    return 'Hatua zote $total';
  }

  @override
  String studiesProgressSome(int done, int total) {
    return 'Hatua $done kati ya $total';
  }

  @override
  String studiesHomileticSubtitle(String progress, String time) {
    return 'Homiletiki · $progress · $time';
  }

  @override
  String studiesHomileticSubtitleNoProgress(String time) {
    return 'Homiletiki · $time';
  }

  @override
  String studiesLectureTitle(String passage) {
    return 'Hotuba ya $passage';
  }

  @override
  String get studiesLectureUntitled => 'Hotuba';

  @override
  String studiesLectureSubtitle(String time) {
    return 'Madokezo ya hotuba · $time';
  }

  @override
  String get studiesWordStudyUntitled => 'Uchunguzi wa neno';

  @override
  String studiesWordStudySubtitle(String time) {
    return 'Uchunguzi wa neno · $time';
  }

  @override
  String studiesWordStudySubtitleWithPassage(String passage, String time) {
    return 'Uchunguzi wa neno · $passage · $time';
  }

  @override
  String get searchHint => 'Tafuta';

  @override
  String get searchSectionContentSummaries => 'Mihtasari ya Maudhui';

  @override
  String get searchSectionDivisions => 'Migawanyo';

  @override
  String get searchSectionApplications => 'Matumizi';

  @override
  String get searchSectionAims => 'Malengo';

  @override
  String get searchSectionSummarySentences => 'Sentensi za Muhtasari';

  @override
  String get searchSectionPassages => 'Vifungu vya Homiletiki';

  @override
  String get searchSectionLectureNotes => 'Madokezo ya Hotuba';

  @override
  String get searchSectionWordStudies => 'Uchunguzi wa Maneno';

  @override
  String get searchOpenFailed =>
      'Imeshindikana kufungua tokeo hilo. Huenda limefutwa.';

  @override
  String get settingsTitle => 'Mipangilio';

  @override
  String get settingsSectionLanguage => 'Lugha';

  @override
  String get settingsAppLanguage => 'Lugha ya programu';

  @override
  String get settingsSectionReading => 'Usomaji';

  @override
  String get settingsSectionModels => 'Modeli za kwenye simu';

  @override
  String get settingsSectionHelp => 'Msaada';

  @override
  String settingsCopyright(String year) {
    return 'Hakimiliki (C) $year 13one.org · Haki zote zimehifadhiwa';
  }

  @override
  String get helpRequestFeedback => 'Omba msaada / toa maoni';

  @override
  String helpCopyright(String year) {
    return 'Hakimiliki (C) $year 13one.org';
  }

  @override
  String get helpAllRightsReserved => 'Haki zote zimehifadhiwa';

  @override
  String get feedbackTitle => 'Toa maoni yako';

  @override
  String get feedbackPublicNotice =>
      'Maoni yako yanawasilishwa kama suala (issue) la wazi kwenye GitHub—mtu yeyote kwenye mtandao anaweza kuyasoma. Usiweke nywila wala taarifa nyingine za faragha. Barua pepe yako inafichwa kwa sehemu kwenye GitHub; huenda tukahifadhi anwani kamili kwenye seva zetu kwa ajili ya kuwasiliana nawe tu.';

  @override
  String get feedbackTypeGeneral => 'Msaada au maoni';

  @override
  String get feedbackTypeTranslation => 'Tatizo la tafsiri';

  @override
  String get feedbackTranslationHint =>
      'Tuambie ni maneno gani yanaonekana si sahihi na yanapaswa kusema nini. Tutaambatisha lugha ya programu yako na tafsiri yako ya Biblia.';

  @override
  String get feedbackNameLabel => 'Jina';

  @override
  String get feedbackEmailLabel => 'Barua pepe (si lazima)';

  @override
  String get feedbackContentLabel => 'Maoni';

  @override
  String get feedbackSubmit => 'Tuma';

  @override
  String get feedbackEmpty => 'Tafadhali andika maoni yako kwanza.';

  @override
  String get feedbackSubmittedIssue =>
      'Yametumwa. Fungua suala hilo kwenye GitHub wakati wowote ili kuongeza maoni (kuingia si lazima).';

  @override
  String get feedbackOpenIssue => 'Fungua';

  @override
  String get feedbackSubmitted => 'Maoni yametumwa kikamilifu';

  @override
  String get feedbackBadRequest =>
      'Imeshindikana kutuma ombi hilo. Kagua ujumbe wako kisha ujaribu tena.';

  @override
  String get feedbackServerUnreachableTitle => 'Imeshindikana kufikia seva';

  @override
  String get feedbackServerUnreachableBody =>
      'Badala yake, fungua GitHub kwenye kivinjari chako ili uwasilishe ripoti hii. Huenda ukahitaji kuingia huko ili kuwasilisha suala hilo.';

  @override
  String get feedbackNotNow => 'Si sasa';

  @override
  String get feedbackOpenGitHub => 'Fungua GitHub';

  @override
  String get feedbackBrowserFailed => 'Imeshindikana kufungua kivinjari.';

  @override
  String get startHomiletics => 'Homiletiki';

  @override
  String get startLecture => 'Hotuba';

  @override
  String get startWordStudy => 'Chunguza neno';

  @override
  String get startPassageHint => 'Jifunze kifungu kingine…';

  @override
  String get startClear => 'Futa';

  @override
  String get startOtherStudy => 'Somo lingine';

  @override
  String get startMenuLectureNote => 'Madokezo ya hotuba';

  @override
  String get startMenuWordStudy => 'Uchunguzi wa neno';

  @override
  String get startDuplicateHomileticTitle =>
      'Tayari una homiletiki ya kifungu hiki?';

  @override
  String startDuplicateHomileticMany(String passage, int count) {
    return '$passage\n\nUna homiletiki $count za kifungu hiki; tutafungua ya karibuni zaidi.';
  }

  @override
  String get startDuplicateLectureTitle =>
      'Tayari una madokezo ya hotuba ya kifungu hiki?';

  @override
  String startDuplicateLectureMany(String passage, int count) {
    return '$passage\n\nUna madokezo $count ya hotuba ya kifungu hiki; tutafungua ya karibuni zaidi.';
  }

  @override
  String get startDuplicateWordStudyTitle =>
      'Tayari una uchunguzi wa neno wa kifungu hiki?';

  @override
  String startDuplicateWordStudyMany(String passage, int count) {
    return '$passage\n\nUna masomo $count ya neno ya kifungu hiki; tutafungua la karibuni zaidi.';
  }

  @override
  String get startCreateNew => 'Unda jipya';

  @override
  String get startEditExisting => 'Hariri lililopo';

  @override
  String get homileticHeaderLabel => 'Homiletiki · Kifungu';

  @override
  String get homileticItemName => 'somo la homiletiki';

  @override
  String get homileticDeletedMessage => 'Homiletiki imefutwa';

  @override
  String get homileticLoadError =>
      'Hitilafu imetokea wakati wa kupakia somo hili.';

  @override
  String get homileticPdfShared => 'PDF imeshirikiwa kikamilifu.';

  @override
  String get homileticPdfShareFailed =>
      'Hitilafu imetokea wakati wa kushiriki PDF yako. Jaribu tena baadaye kidogo.';

  @override
  String get homileticPdfPrinted => 'PDF imechapishwa kikamilifu.';

  @override
  String get homileticPdfPrintFailed =>
      'Hitilafu imetokea wakati wa kuunda PDF yako. Jaribu tena baadaye kidogo.';

  @override
  String get homileticCompleteTitle => 'Hatua zote sita zimekamilika';

  @override
  String get homileticCompleteMessage =>
      'Ichapishe kwa ajili ya darasa, au uishiriki na kikundi chako.';

  @override
  String get homileticContentEmptySummary => 'Mistari + muhtasari';

  @override
  String get homileticDivisionsEmptySummary => 'Makundi 2–4';

  @override
  String get homileticSummaryEmptySummary => '≤ maneno 10';

  @override
  String get homileticFcfEmptySummary => 'Hali ya kuanguka';

  @override
  String get homileticAimEmptySummary => 'Funzo kuu';

  @override
  String get homileticApplicationEmptySummary => 'Ninawezaje…';

  @override
  String get homileticStepStatusDone => 'imekamilika';

  @override
  String get homileticStepStatusToDo => 'bado';

  @override
  String homileticStepCollapseLabel(String title) {
    return '$title, kunja';
  }

  @override
  String homileticStepHelpLabel(String title) {
    return 'Kuhusu $title';
  }

  @override
  String get homileticVersesLabel => 'Mistari';

  @override
  String get homileticVersesHint => 'mst';

  @override
  String homileticAddButtonLabel(String label) {
    return '+ $label';
  }

  @override
  String get homileticRemoveRowMessage => 'Ulichoandika hapa kitafutwa.';

  @override
  String get homileticRemoveRowConfirm => 'Ondoa';

  @override
  String get homileticContentSummaryHint => 'Muhtasari…';

  @override
  String get homileticAddContentSummary => 'Ongeza muhtasari';

  @override
  String get homileticRemoveContentSummaryTooltip =>
      'Ondoa muhtasari wa maudhui';

  @override
  String get homileticRemoveContentSummaryTitle =>
      'Uondoe muhtasari huu wa maudhui?';

  @override
  String get homileticRemoveContentSummaryFailed =>
      'Imeshindikana kuondoa muhtasari huo wa maudhui';

  @override
  String get homileticDivisionHint => 'Sentensi ya mgawanyo…';

  @override
  String get homileticAddDivision => 'Ongeza mgawanyo';

  @override
  String get homileticRemoveDivisionTooltip => 'Ondoa mgawanyo';

  @override
  String get homileticRemoveDivisionTitle => 'Uondoe mgawanyo huu?';

  @override
  String get homileticRemoveDivisionFailed =>
      'Imeshindikana kuondoa mgawanyo huo';

  @override
  String get homileticApplicationHint => 'Ninawezaje…';

  @override
  String get homileticAddApplication => 'Ongeza swali';

  @override
  String get homileticRemoveApplicationTooltip => 'Ondoa swali la matumizi';

  @override
  String get homileticRemoveApplicationTitle =>
      'Uondoe swali hili la matumizi?';

  @override
  String get homileticRemoveApplicationFailed =>
      'Imeshindikana kuondoa swali hilo la matumizi';

  @override
  String get homileticSummaryHint => 'Fupisha: maneno 10 au machache';

  @override
  String get homileticFcfHint => 'Kuanguka/Udhaifu/Unyonge/Ugeugeu';

  @override
  String get homileticAimHint => 'Kuwafanya wasikilizaji wajifunze kwamba…';

  @override
  String get homileticContentHelpTitle => 'Mihtasari ya Maudhui';

  @override
  String get homileticContentHelpText =>
      'Muhtasari wa maudhui ni ufupisho wa sehemu ya Biblia. Si lazima uwe sentensi moja; unaweza pia kuwa zaidi ya sentensi moja. Unapaswa kuwa muhtasari, kwa maneno yako mwenyewe, wa maudhui ya kifungu.\nUnapaswa kuwa na mihtasari ya maudhui isiyopungua 10, lakini isiyozidi 20. Kwa kawaida, kutegemea urefu wa kifungu, utagawanya kifungu chako katika vipande vya ukubwa unaokaribiana ili ufikie kiwango cha 10–20. Kwa hiyo, kifungu chako kikiwa na mistari 30, ningejaribu kuweka wastani wa mistari 3 kwa kila muhtasari wa maudhui.';

  @override
  String get homileticDivisionsHelpText =>
      'Migawanyo ni makundi ya mistari inayohusiana. Inapaswa kuwa angalau miwili na isizidi minne.';

  @override
  String get homileticSummaryHelpTitle => 'Sentensi ya Muhtasari';

  @override
  String get homileticSummaryHelpText =>
      'Sentensi ya Muhtasari ni kauli fupi, inayokumbukika, inayojumlisha mambo muhimu zaidi. Njia nzuri ya kuifikiria ni jaribio la saa nane usiku: mtu akikuamsha saa nane usiku na kukuuliza mahubiri yalihusu nini, ungesema nini? Ungesema Sentensi ya Muhtasari.\nInapaswa kuwa na maneno 10 au machache. Ukijisikia mchangamfu, unaweza kujaribu kutumia maneno yanayoanza kwa sauti moja.';

  @override
  String get homileticFcfHelpText =>
      'FCF (Fallen Condition Focus — Kiini cha Hali ya Kuanguka) ni ile sehemu ya hali ya ubinadamu inayoonyeshwa au kutajwa zaidi katika kifungu. Ni hali waliyomo wasikilizaji, sababu inayowafanya wasikilizaji wahitaji kuokolewa.';

  @override
  String get homileticAimHelpText =>
      'Lengo ni hoja kuu, ile kweli moja kuu ambayo unataka wewe mwenyewe au wasikilizaji muondoke nayo. Huenda likatokana na FCF, na huenda likaathiri Maswali ya Matumizi.';

  @override
  String get homileticApplicationHelpTitle => 'Maswali ya Matumizi';

  @override
  String get homileticApplicationHelpText =>
      'Haya ni maswali yanayowasaidia wasikilizaji kutumia katika maisha yao wenyewe yale waliyoyasikia hivi punde. Yanapaswa kuwa mahususi, ya kibinafsi, ya wazi, na yenye kuchochea fikra.';

  @override
  String homileticSummaryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'mihtasari $count',
      one: 'muhtasari 1',
    );
    return '$_temp0';
  }

  @override
  String homileticDivisionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'migawanyo $count',
      one: 'mgawanyo 1',
    );
    return '$_temp0';
  }

  @override
  String homileticQuestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'maswali $count',
      one: 'swali 1',
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
  String get lectureItemName => 'madokezo ya hotuba';

  @override
  String get lectureDeleted => 'Madokezo ya hotuba yamefutwa';

  @override
  String get lecturePassageHint => 'Kifungu';

  @override
  String get lectureHeaderLabel => 'Hotuba · Kifungu';

  @override
  String get lectureNotesPlaceholder => 'Madokezo';

  @override
  String get lectureToolbarBold => 'Herufi nzito';

  @override
  String get lectureToolbarItalic => 'Herufi za mlalo';

  @override
  String get lectureToolbarBulletedList => 'Orodha ya vitone';

  @override
  String get lectureToolbarNumberedList => 'Orodha ya namba';

  @override
  String get lectureReplaceTitle => 'Ubadilishe rekodi iliyopo?';

  @override
  String get lectureReplaceMessage =>
      'Sauti ya zamani na nakala yake ya maandishi vitafutwa.';

  @override
  String get lectureReplaceConfirm => 'Badilisha';

  @override
  String get lectureMicPermissionRequired =>
      'Ruhusa ya kipaza sauti inahitajika ili kurekodi.';

  @override
  String get lectureNotificationTitle => 'Inarekodi hotuba';

  @override
  String lectureNotificationContent(String appName) {
    return '$appName inarekodi sauti';
  }

  @override
  String get lectureStartFailed =>
      'Imeshindikana kuanza kurekodi. Huenda kipaza sauti kinatumiwa na programu nyingine.';

  @override
  String get lectureTranscriptionModelTitle =>
      'Upakue modeli ya kunukuu sauti bila mtandao?';

  @override
  String get lectureTranscriptionModelMessage =>
      'Upakuaji wa mara moja wa takriban 140MB unawezesha rekodi zako kunukuliwa kuwa maandishi na kutafutwa kiotomatiki. Unaweza kuruka hatua hii na kuipakua baadaye kutoka Mipangilio.';

  @override
  String get lectureNotNow => 'Si sasa';

  @override
  String get lectureDownload => 'Pakua';

  @override
  String get lectureModelDownloadFailed =>
      'Hitilafu imetokea wakati wa kupakua modeli. Unaweza kujaribu tena kutoka Mipangilio.';

  @override
  String get lectureRecordingFileNotFound => 'Faili ya rekodi haikupatikana.';

  @override
  String get lectureTranscriptionEmpty => 'Unukuzi haukutoa maandishi yoyote.';

  @override
  String get lectureFormattingModelTitle => 'Upakue modeli ya kupanga nakala?';

  @override
  String lectureFormattingModelMessage(String size) {
    return 'Upakuaji wa mara moja wa $size unawezesha nakala za maandishi kusafishwa na kupangwa katika aya zinazosomeka, kikamilifu kwenye kifaa chako. Inapendekezwa kutumia Wi-Fi. Unaweza pia kufanya hivi baadaye kutoka Mipangilio.';
  }

  @override
  String get lectureFormattingModelMissing =>
      'Modeli ya kupanga haijapakuliwa.';

  @override
  String get lectureFormattingFailed => 'Imeshindikana kupanga nakala.';

  @override
  String get lecturePlaybackFailed => 'Imeshindikana kucheza rekodi.';

  @override
  String lectureDownloadingModel(String percent) {
    return 'Inapakua modeli $percent%';
  }

  @override
  String lectureTranscribingProgress(int percent) {
    return 'Inanukuu $percent%';
  }

  @override
  String lectureFormattingProgress(int done, int total) {
    return 'Inapanga nakala $done/$total';
  }

  @override
  String get lectureFormattingIndeterminate => 'Inapanga nakala…';

  @override
  String lectureRecordingSemantics(String time) {
    return 'Inarekodi, $time';
  }

  @override
  String get lectureRecordingSubtitle =>
      'Inarekodi · inaendelea skrini ikiwa imezimwa';

  @override
  String get lectureStopRecording => 'Acha kurekodi';

  @override
  String get lectureRecordLecture => 'Rekodi hotuba';

  @override
  String get lectureRecordIdleSubtitle => 'Inaendelea kurekodi skrini ikizimwa';

  @override
  String get lecturePause => 'Sitisha';

  @override
  String get lecturePlayRecording => 'Cheza rekodi';

  @override
  String get lectureRecordAgain => 'Rekodi tena';

  @override
  String get lectureNotTranscribedYet => 'Bado haijanukuliwa';

  @override
  String get lectureTranscribe => 'Nukuu';

  @override
  String get lectureTimeMark => '+ Alama ya muda';

  @override
  String get lectureTranscriptEmptyRecording =>
      'Hotuba itanukuliwa kwenye simu hii baada ya kuacha kurekodi.';

  @override
  String get lectureTranscriptEmptyPending =>
      'Nakala itaonekana hapa ikiwa tayari.';

  @override
  String get lectureTranscriptEmptyNotTranscribed =>
      'Nukuu rekodi ili uisome na kuitafuta hapa.';

  @override
  String get lectureTranscriptEmptyNoRecording =>
      'Rekodi hotuba, nayo itanukuliwa kwenye simu hii baada ya kuacha.';

  @override
  String get lectureTranscribing => 'Inanukuu…';

  @override
  String get lectureNoTranscriptYet => 'Bado hakuna nakala';

  @override
  String get lectureFormatted => 'Imepangwa';

  @override
  String get lectureRaw => 'Ghafi';

  @override
  String get lectureFormatTranscript => 'Panga nakala';

  @override
  String get lectureTabMyNotes => 'Madokezo yangu';

  @override
  String get lectureTabTranscript => 'Nakala';

  @override
  String get modelTranscriptionTitle => 'Modeli ya kunukuu bila mtandao';

  @override
  String modelTranscriptionEnglishNeeded(String language) {
    return 'Modeli ya Kiingereza, inahitajika kwa $language';
  }

  @override
  String modelTranscriptionEnglishNotNeeded(String language) {
    return 'Modeli ya Kiingereza, haihitajiki kwa $language';
  }

  @override
  String modelTranscriptionMultilingualNeeded(String language) {
    return 'Modeli ya lugha nyingi, inahitajika kwa $language';
  }

  @override
  String modelTranscriptionMultilingualNotNeeded(String language) {
    return 'Modeli ya lugha nyingi, haihitajiki kwa $language';
  }

  @override
  String get modelFormattingTitle => 'Modeli ya kupanga nakala';

  @override
  String get modelAppleIntelligenceStatus =>
      'Inatumia Apple Intelligence (hakuna haja ya kupakua)';

  @override
  String get modelStatusChecking => 'Inakagua…';

  @override
  String modelStatusNotDownloaded(String size) {
    return 'Haijapakuliwa ($size)';
  }

  @override
  String modelStatusDownloading(String percent) {
    return 'Inapakua… $percent%';
  }

  @override
  String get modelStatusDownloaded => 'Imepakuliwa';

  @override
  String modelStatusDownloadedSize(String megabytes) {
    return 'Imepakuliwa (${megabytes}MB)';
  }

  @override
  String get modelDownload => 'Pakua';

  @override
  String get modelDelete => 'Futa';

  @override
  String get modelDownloadFailed =>
      'Hitilafu imetokea wakati wa kupakua modeli. Jaribu tena baadaye kidogo.';

  @override
  String get modelDeleteFailed => 'Hitilafu imetokea wakati wa kufuta modeli.';

  @override
  String get pdfOverlineHomiletics => 'HOMILETIKI';

  @override
  String get pdfOverlineWordStudy => 'UCHUNGUZI WA NENO';

  @override
  String get pdfUntitledPassage => 'Kifungu bila kichwa';

  @override
  String get pdfUntitledWord => 'Neno bila kichwa';

  @override
  String pdfHomileticLabel(String passage) {
    return 'Homiletiki · $passage';
  }

  @override
  String pdfWordStudyLabel(String word) {
    return 'Uchunguzi wa neno · $word';
  }

  @override
  String pdfWordStudyLabelWithPassage(String word, String passage) {
    return 'Uchunguzi wa neno · $word · $passage';
  }

  @override
  String pdfPageOf(int current, int total) {
    return 'ukurasa $current kati ya $total';
  }

  @override
  String get pdfFcfCaption => 'Kiini cha Hali ya Kuanguka';

  @override
  String get pdfAimLeadIn => 'Kuwafanya wasikilizaji wajifunze kwamba ';

  @override
  String get pdfEmptyHomiletic =>
      'Bado hakuna kilichoandikwa kwa kifungu hiki.';

  @override
  String get pdfEmptyWordStudy =>
      'Bado hakuna kilichoandikwa kwa uchunguzi huu wa neno.';

  @override
  String get pdfWordStudyDefinition => 'Maana';

  @override
  String get pdfWordStudyOtherUsage => 'Matumizi mengine';

  @override
  String get pdfWordStudyContextualMeaning => 'Maana katika muktadha';

  @override
  String get pdfWordStudyDeeperMeaning => 'Maana ya ndani zaidi';

  @override
  String get pdfWordStudyApplication => 'Matumizi maishani';

  @override
  String get editorSaveAndClose => 'Hifadhi na funga';

  @override
  String get editorDeleteConfirmTitle => 'Una uhakika?';

  @override
  String editorDeleteConfirmMessage(String itemName) {
    return 'Kufuta $itemName ni kwa kudumu na hakuwezi kutenduliwa. Una uhakika unataka kuendelea?';
  }

  @override
  String get editorPassageLabel => 'Kifungu';

  @override
  String get editorAddPassageHint => 'Ongeza kifungu';

  @override
  String get editorBack => 'Rudi';

  @override
  String get editorMoreOptions => 'Chaguo zaidi';

  @override
  String get editorChangeTranslation => 'Badilisha tafsiri';

  @override
  String get editorStudyCompleteMessage =>
      'Ichapishe kwa ajili ya darasa, au uishiriki na kikundi chako.';

  @override
  String get wordStudyItemName => 'uchunguzi wa neno';

  @override
  String get wordStudyDeleted => 'Uchunguzi wa neno umefutwa';

  @override
  String get wordStudyHeaderLabel => 'Uchunguzi wa neno · Kifungu';

  @override
  String get wordStudyPdfShared => 'PDF imeshirikiwa kikamilifu.';

  @override
  String get wordStudyPdfShareFailed =>
      'Hitilafu imetokea wakati wa kushiriki PDF yako. Jaribu tena baadaye kidogo.';

  @override
  String get wordStudyPdfPrinted => 'PDF imechapishwa kikamilifu.';

  @override
  String get wordStudyPdfPrintFailed =>
      'Hitilafu imetokea wakati wa kuunda PDF yako. Jaribu tena baadaye kidogo.';

  @override
  String get wordStudyWordTitle => 'Neno';

  @override
  String get wordStudyWordHelp =>
      'Neno mahususi au kifungu kifupi cha maneno unachochunguza. Ukishaliandika, sehemu za Maana na Matumizi Mengine zinaweza kukupendekezea maudhui.';

  @override
  String get wordStudyWordHint => 'Ongeza neno';

  @override
  String get wordStudyEnterWordFirst => 'Andika neno hapo juu kwanza.';

  @override
  String get wordStudyDefinitionTitle => 'Maana';

  @override
  String get wordStudyDefinitionHelp =>
      'Neno hili lina maana gani, kwa lugha rahisi? Gusa \"+\" upate maana zinazopendekezwa kutoka kamusi, au andika yako mwenyewe.';

  @override
  String get wordStudyDefinitionHelpNoSuggest =>
      'Neno hili lina maana gani, kwa lugha rahisi? Andika yako mwenyewe.';

  @override
  String get wordStudyDefinitionHint => 'Lina maana gani, kwa lugha rahisi?';

  @override
  String get wordStudySuggestDefinition => 'Pendekeza maana';

  @override
  String wordStudyDefinitionsFor(String word) {
    return 'Maana za “$word”';
  }

  @override
  String get wordStudyDefinitionsTapToUse => 'Gusa mojawapo ili uitumie.';

  @override
  String get wordStudyDefinitionsLoadError =>
      'Imeshindikana kupakia maana. Jaribu tena baadaye kidogo.';

  @override
  String get wordStudyNoDefinitions =>
      'Hakuna maana zilizopatikana kwa neno hili.';

  @override
  String get wordStudyReplaceDefinitionTitle => 'Ubadilishe maana uliyoandika?';

  @override
  String get wordStudyReplaceDefinitionMessage =>
      'Tayari umeandika maana. Uibadilishe kwa pendekezo hili, au uongeze pendekezo chini yake?';

  @override
  String get wordStudyAddBelow => 'Ongeza chini';

  @override
  String get wordStudyReplace => 'Badilisha';

  @override
  String get wordStudyOtherUsageTitle => 'Matumizi mengine';

  @override
  String get wordStudyOtherUsageHelp =>
      'Neno hili au wazo hili linapatikana wapi kwingine katika Maandiko? Gusa \"+\" ili kutafuta kwenye Bible Gateway na kuongeza marejeo unayopata, au andika yako mwenyewe.';

  @override
  String get wordStudyOtherUsageHint =>
      'Linapatikana wapi kwingine katika Maandiko?';

  @override
  String get wordStudyFindOtherUsages => 'Tafuta matumizi mengine';

  @override
  String wordStudyOtherUsageSheetTitle(String word) {
    return 'Mahali pengine “$word” linapopatikana';
  }

  @override
  String get wordStudyOtherUsageAdded => 'Yameongezwa';

  @override
  String get wordStudyOtherUsageInstructions =>
      'Gusa tokeo hapa chini ili kuongeza rejeo lake.';

  @override
  String get wordStudyOtherUsageAddResult => '+ Ongeza';

  @override
  String get wordStudyContextualMeaningTitle => 'Maana katika muktadha';

  @override
  String get wordStudyContextualMeaningHelp =>
      'Mwandishi alikusudia neno hili limaanishe nini hapa, katika kifungu hiki? Tafakari mistari inayolizunguka, si neno peke yake.';

  @override
  String get wordStudyContextualMeaningHint =>
      'Lina maana gani hapa, katika kifungu hiki?';

  @override
  String get wordStudyDeeperMeaningTitle => 'Maana ya ndani zaidi';

  @override
  String get wordStudyDeeperMeaningHelp =>
      'Je, kuna ufahamu wowote kutoka lugha ya asili, maoni ya wafafanuzi, au uchunguzi mwingine unaoongeza kina zaidi ya maana ya msingi? Maandiko mengine yanaiundaje maana yake? Strong\'s concordance au Blue Letter Bible inaweza kusaidia hapa.';

  @override
  String get wordStudyDeeperMeaningHint =>
      'Maandiko mengine yanaiundaje maana yake?';

  @override
  String get wordStudyApplicationTitle => 'Matumizi maishani';

  @override
  String get wordStudyApplicationHelp =>
      'Kweli hii inapaswa kuyaundaje maisha yako? Kuwa mahususi, wa kibinafsi, na wa vitendo.';

  @override
  String get wordStudyApplicationHint => 'Utafanya nini nayo?';

  @override
  String get wordStudyDoneTitle => 'Uchunguzi wa neno umekamilika';

  @override
  String wordStudySectionHelpSemantics(String title) {
    return '$title, kuhusu sehemu hii';
  }

  @override
  String get lectureTimeMarkNoRecording =>
      'Maelezo haya hayana rekodi ya kucheza.';

  @override
  String get lectureTimeMarkStopRecordingFirst =>
      'Simamisha kurekodi ili kucheza kuanzia alama ya muda.';

  @override
  String get lectureTimeMarkPastEnd =>
      'Alama hiyo ya muda iko baada ya mwisho wa rekodi.';

  @override
  String get onboardingSkip => 'Ruka';

  @override
  String get onboardingBack => 'Rudi';

  @override
  String get onboardingNext => 'Endelea';

  @override
  String get onboardingWelcomeOverline => 'Karibu';

  @override
  String get onboardingWelcomeTitle =>
      'Jifunze Biblia, kifungu kimoja kwa wakati';

  @override
  String get onboardingWelcomeBody =>
      'Homiletics inakusaidia kuandika homiletiki yako, kuandika maelezo ya hotuba na kufanya uchunguzi wa neno — kifungu kikiwa wazi kando yako, kwa lugha yako na tafsiri yako ya Biblia.';

  @override
  String get onboardingMethodOverline => 'Mbinu';

  @override
  String get onboardingMethodTitle => 'Homiletiki ni nini?';

  @override
  String get onboardingMethodBody =>
      'Homiletiki ni njia fupi ya kujifunza kifungu: unatafuta ujumbe wake mkuu, kisha unafikiri jinsi ya kuuishi. Ina hatua sita — na haihitaji kuwa kamili. Inakuwa rahisi kila wiki.';

  @override
  String get onboardingStepsOverline => 'Hatua kwa hatua';

  @override
  String get onboardingStepsTitle => 'Hatua sita';

  @override
  String get onboardingStepContent =>
      'Fupisha kifungu kwa vipande vifupi 10–20, kwa maneno yako mwenyewe.';

  @override
  String get onboardingStepDivisions =>
      'Panga vipande hivyo katika sehemu 2–4.';

  @override
  String get onboardingStepSummary =>
      'Kifungu kizima kwa maneno 10 au machache.';

  @override
  String get onboardingStepFcf =>
      'Kiini cha Hali ya Kuanguka: hitaji au uvunjifu wa mwanadamu ambao kifungu kinazungumzia.';

  @override
  String get onboardingStepAim =>
      'Kweli moja kuu unayotaka wasikilizaji wako wajifunze.';

  @override
  String get onboardingStepApplication =>
      'Maswali yanayogeuza kifungu kuwa maisha ya kila siku.';

  @override
  String get onboardingLecturesOverline => 'Hotuba na uchunguzi wa neno';

  @override
  String get onboardingLecturesTitle => 'Sikiliza kwa makini, chimba zaidi';

  @override
  String get onboardingLecturesBody =>
      'Rekodi hotuba — inaendelea hata skrini ikiwa imezimwa na inanakiliwa kwenye simu yako yenyewe. Andika maelezo unaposikiliza na uweke alama za muda ili kupata tena sehemu fulani.';

  @override
  String get onboardingWordStudyBody =>
      'Una hamu ya kujua neno moja? Anza uchunguzi wa neno na uchimbe maana yake katika kifungu.';

  @override
  String get onboardingStartOverline => 'Anza';

  @override
  String get onboardingStartTitle => 'Uko tayari kuanza';

  @override
  String get onboardingStartBody =>
      'Anza na kifungu cha wiki hii, au angalia kwanza. Kila hatua unayoandika inahifadhiwa papo hapo.';

  @override
  String get onboardingReopenHint =>
      'Unaweza kufungua mwongozo huu tena wakati wowote kutoka Mipangilio.';

  @override
  String get onboardingStartThisWeek => 'Anza homiletiki ya wiki hii';

  @override
  String get onboardingExplore => 'Gundua mwenyewe';

  @override
  String onboardingThisWeekPassage(String passage) {
    return 'Wiki hii: $passage';
  }

  @override
  String get onboardingSettingsRow => 'Jinsi homiletiki inavyofanya kazi';

  @override
  String bibleOfflineSize(String size) {
    return 'Bila mtandao · $size';
  }

  @override
  String bibleDownloadedSize(String size) {
    return 'Imepakuliwa · $size';
  }

  @override
  String get bibleDownloadAction => 'Pakua kwa matumizi bila mtandao';

  @override
  String get bibleDownloading => 'Inapakua…';

  @override
  String get bibleRemoveDownload => 'Ondoa upakuaji';

  @override
  String bibleDownloadFailed(String translation) {
    return 'Imeshindwa kupakua $translation. Angalia muunganisho wako kisha ujaribu tena.';
  }

  @override
  String get bibleOfflineTitle => 'Hakuna muunganisho';

  @override
  String bibleOfflineMessage(String translation) {
    return 'Kifungu hiki kinatoka Bible Gateway, kinachohitaji intaneti. Pakua $translation ili ukisome popote.';
  }

  @override
  String get bibleOfflineNoDownloadMessage =>
      'Kifungu hiki kinatoka Bible Gateway, kinachohitaji intaneti. Unganisha kisha ujaribu tena.';

  @override
  String get bibleTryAgain => 'Jaribu tena';

  @override
  String bibleNeedsDownloadTitle(String translation) {
    return 'Pakua $translation';
  }

  @override
  String bibleNeedsDownloadMessage(String size) {
    return 'Biblia hii inasomwa kutoka kwenye kifaa chako. Ipakue mara moja (karibu $size) ili kuona kifungu.';
  }

  @override
  String bibleNotInTranslation(String translation) {
    return 'Kifungu hiki hakikupatikana katika $translation.';
  }

  @override
  String get bibleVerseTapTip =>
      'Kidokezo: gusa namba ya mstari ili kuanza muhtasari hapo.';

  @override
  String bibleVerseTapLabel(String verse) {
    return 'Anza muhtasari kwenye mstari $verse';
  }

  @override
  String get shareSheetTitle => 'Shiriki somo hili';

  @override
  String get shareLink => 'Shiriki kiungo';

  @override
  String get shareLinkSubtitle =>
      'Hufunguka kwenye programu, au kivinjari chochote';

  @override
  String get shareCopyLink => 'Nakili kiungo';

  @override
  String get shareLinkCopied => 'Kiungo kimenakiliwa';

  @override
  String get shareShowQr => 'Onyesha msimbo wa QR';

  @override
  String get shareSharePdf => 'Shiriki PDF';

  @override
  String get shareImages => 'Shiriki kama picha';

  @override
  String get shareImagesSubtitle =>
      'Za mraba, za kuchapisha kwenye mitandao ya kijamii';

  @override
  String get shareImagesSaved => 'Picha zimehifadhiwa.';

  @override
  String get shareImagesFailed =>
      'Imeshindikana kutengeneza picha. Jaribu tena baadaye.';

  @override
  String get shareLinkFailed => 'Imeshindwa kushiriki kiungo.';

  @override
  String get shareLinkTooLongTitle => 'Kiungo hiki ni kirefu sana';

  @override
  String shareLinkTooLongMessage(int count) {
    return 'Somo hili linatengeneza kiungo cha herufi $count. Baadhi ya programu zinaweza kukikata, na huenda kisifunguke. Ikitokea hivyo, shiriki PDF badala yake.';
  }

  @override
  String get shareAnyway => 'Shiriki hata hivyo';

  @override
  String get shareQrTitle => 'Changanua ili kufungua';

  @override
  String get shareQrHint =>
      'Elekeza kamera ya simu nyingine kwenye msimbo ili kufungua somo hili.';

  @override
  String get shareQrTooLong =>
      'Somo hili ni refu mno kwa msimbo wa QR. Tumia Shiriki kiungo au Nakili kiungo badala yake.';

  @override
  String get shareQrSemantics => 'Msimbo wa QR unaoelekeza kwenye somo hili';

  @override
  String get importFromLink => 'Leta kutoka kiungo';

  @override
  String get importSheetMessage =>
      'Bandika kiungo cha Homiletics ulichoshirikiwa. Unaweza kukipitia kabla ya kuhifadhi nakala.';

  @override
  String get importFieldHint => 'https://homiletics.app/view#…';

  @override
  String get importPaste => 'Bandika';

  @override
  String get importOpen => 'Fungua';

  @override
  String get importClipboardEmpty => 'Hakuna maandishi ya kubandika.';

  @override
  String get importInvalidLink =>
      'Hiki si kiungo cha Homiletics, au sehemu yake imekosekana. Omba kiungo tena.';

  @override
  String get importNewerVersion =>
      'Somo hili lilishirikiwa kutoka toleo jipya zaidi la Homiletics. Sasisha Homiletics ili kulifungua.';

  @override
  String get importCouldNotOpenTitle => 'Haiwezekani kufungua kiungo hiki';

  @override
  String get importPreviewHomiletic => 'Homiletiki iliyoshirikiwa';

  @override
  String get importPreviewWordStudy => 'Somo la neno lililoshirikiwa';

  @override
  String get importPreviewNote =>
      'Mtu amekushirikisha hili. Kuhifadhi kunaongeza nakala kwenye masomo yako; hakuna kitu ulicho nacho kinachobadilishwa.';

  @override
  String importPreviewTranslation(String translation) {
    return 'Imeandikwa kwa $translation';
  }

  @override
  String get importSaveCopy => 'Hifadhi nakala';

  @override
  String get importSaved => 'Imehifadhiwa kwenye masomo yako';

  @override
  String get importSaveFailed => 'Imeshindwa kuhifadhi somo. Jaribu tena.';

  @override
  String get startOpenSharedStudy => 'Fungua somo lililoshirikiwa';

  @override
  String bibleWebUnavailableTitle(String translation) {
    return 'Soma $translation kwenye kivinjari';
  }

  @override
  String get bibleWebUnavailableMessage =>
      'Kwenye Windows, programu haiwezi kuonyesha vifungu vya Bible Gateway ndani ya programu. Fungua kifungu hiki kwenye kivinjari chako, au badilisha kwenda tafsiri inayosomwa kutoka kwenye kifaa chako.';

  @override
  String get bibleOpenInBrowser => 'Fungua kwenye kivinjari';

  @override
  String bibleUseOfflineTranslation(String translation) {
    return 'Tumia tafsiri isiyohitaji mtandao ($translation)';
  }

  @override
  String get wordStudyOtherUsageOpenedInBrowser =>
      'Matokeo yamefunguliwa kwenye kivinjari chako. Andika au bandika hapa marejeo unayotaka kuhifadhi.';

  @override
  String get settingsSectionStorage => 'Hifadhi';

  @override
  String get storageRecordingsTitle => 'Rekodi za hotuba';

  @override
  String get storageChecking => 'Inakagua…';

  @override
  String storageRecordingsSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Rekodi $count · $size',
      one: 'Rekodi 1 · $size',
      zero: 'Hakuna rekodi zilizohifadhiwa',
    );
    return '$_temp0';
  }

  @override
  String get storageRemoveOlderThan => 'Futa rekodi za zamani kuliko';

  @override
  String get storageAgeOneMonth => 'Mwezi 1';

  @override
  String get storageAgeThreeMonths => 'Miezi 3';

  @override
  String get storageAgeSixMonths => 'Miezi 6';

  @override
  String get storageAgeOneYear => 'Mwaka 1';

  @override
  String storageOlderSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Rekodi $count · $size',
      one: 'Rekodi 1 · $size',
      zero: 'Hakuna za zamani hivyo',
    );
    return '$_temp0';
  }

  @override
  String get storageFreeUpSpace => 'Ongeza nafasi';

  @override
  String storageConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Futa rekodi $count?',
      one: 'Futa rekodi 1?',
    );
    return '$_temp0';
  }

  @override
  String storageConfirmMessage(String size) {
    return 'Hii itaongeza nafasi ya takriban $size. Maelezo, manukuu na alama za muda vitabaki; sauti pekee ndiyo itafutwa, na haiwezi kurudishwa.';
  }

  @override
  String storageConfirmUntranscribed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Rekodi $count kati ya hizo hazikunukuliwa, hivyo yatabaki maelezo yako tu.',
      one:
          'Rekodi 1 kati ya hizo haikunukuliwa, hivyo yatabaki maelezo yako tu.',
    );
    return '$_temp0';
  }

  @override
  String get storageConfirmRemove => 'Futa';

  @override
  String storageFreed(String size) {
    return 'Nafasi ya $size imeongezwa.';
  }

  @override
  String get storageRemoveFailed =>
      'Baadhi ya rekodi hazikuweza kufutwa. Jaribu tena.';

  @override
  String get storageAutoRemove => 'Futa kiotomatiki';

  @override
  String storageAutoRemoveDetail(String age) {
    return 'Mara moja kwa siku, hufuta rekodi za zamani kuliko $age ambazo zina manukuu.';
  }

  @override
  String get lectureRecordingRemovedTitle =>
      'Rekodi imefutwa ili kuokoa nafasi';

  @override
  String get lectureRecordingRemovedSubtitle =>
      'Maelezo na manukuu yako yamehifadhiwa';

  @override
  String get lectureTranscriptEmptyRecordingRemoved =>
      'Rekodi ilifutwa ili kuokoa nafasi kabla ya kunukuliwa.';

  @override
  String get settingsSectionBackup => 'Hifadhi na urejeshe';

  @override
  String get backupExplainer =>
      'Hifadhi masomo yako yote katika faili moja na uiweke Google Drive, Faili au popote upendapo. Programu haiipakii popote.';

  @override
  String get backupNow => 'Hifadhi sasa';

  @override
  String backupLastTime(String time) {
    return 'Mara ya mwisho: $time';
  }

  @override
  String get backupNever => 'Bado hujahifadhi';

  @override
  String backupIncludeRecordings(String size) {
    return 'Jumuisha rekodi za hotuba ($size)';
  }

  @override
  String get backupSaved => 'Imehifadhiwa';

  @override
  String get backupFailed => 'Imeshindikana kuhifadhi. Tafadhali jaribu tena.';

  @override
  String get restoreFromBackup => 'Rejesha kutoka nakala';

  @override
  String get restorePreviewTitle => 'Rejesha nakala hii?';

  @override
  String restorePreviewCreated(String date) {
    return 'Iliundwa $date';
  }

  @override
  String get restoreCountHomiletics => 'Homiletiki';

  @override
  String get restoreCountLectureNotes => 'Maelezo ya hotuba';

  @override
  String get restoreCountWordStudies => 'Uchunguzi wa neno';

  @override
  String get restoreCountRecordings => 'Rekodi';

  @override
  String get restorePreviewNote =>
      'Chochote usichokuwa nacho kitaongezwa. Hakuna kitakachobadilishwa au kufutwa kwenye kifaa hiki.';

  @override
  String get restoreConfirm => 'Rejesha';

  @override
  String restoreDone(String added, String skipped) {
    return 'Imerejeshwa. Vilivyoongezwa: $added · Vilivyokuwepo: $skipped';
  }

  @override
  String get restoreFailed =>
      'Imeshindikana kurejesha nakala. Tafadhali jaribu tena.';

  @override
  String get restoreNotABackup => 'Faili hiyo si nakala ya Homiletics.';

  @override
  String get restoreDamaged =>
      'Nakala hiyo inaonekana kuharibika na haisomeki.';

  @override
  String get restoreNewerVersion =>
      'Nakala hii iliundwa na toleo jipya la Homiletics. Sasisha programu, kisha ujaribu tena.';

  @override
  String get settingsCheckForUpdates => 'Angalia masasisho';

  @override
  String settingsVersion(String version) {
    return 'Toleo $version';
  }

  @override
  String updateAvailableTitle(String version) {
    return 'Homiletics $version inapatikana';
  }

  @override
  String updateAvailableMessage(String current) {
    return 'Una toleo $current. Mapya:';
  }

  @override
  String get updateNow => 'Sasisha sasa';

  @override
  String get updateDownload => 'Pakua';

  @override
  String get updateLater => 'Baadaye';

  @override
  String get updateSkipVersion => 'Ruka toleo hili';

  @override
  String get updateDownloading => 'Inapakua sasisho…';

  @override
  String get updateInstalling =>
      'Inasakinisha. Homiletics itafunguka tena baada ya muda mfupi.';

  @override
  String get updateFailed =>
      'Sasisho halikuweza kupakuliwa. Jaribu tena, au lipakue kutoka homiletics.app.';

  @override
  String get updateTryAgain => 'Jaribu tena';

  @override
  String get updatePortableNote =>
      'Nakala hii haikusakinishwa kwa kisakinishi, kwa hiyo pakua toleo jipya kutoka homiletics.app.';

  @override
  String updateUpToDate(String version) {
    return 'Una toleo la karibuni (Homiletics $version).';
  }

  @override
  String get updateCheckFailed =>
      'Haikuweza kuangalia masasisho. Angalia muunganisho wako wa intaneti kisha ujaribu tena.';
}
