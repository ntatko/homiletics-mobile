// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get prefsTitle => 'Préférences';

  @override
  String get prefsAppLanguage => 'Langue préférée';

  @override
  String get prefsBibleVersion => 'Version de la Bible préférée';

  @override
  String get bibleNewTestamentOnly => 'Nouveau Testament uniquement';

  @override
  String get appTitle => 'Homiletics';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonOk => 'OK';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonDone => 'Terminé';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonSomethingWentWrong =>
      'Une erreur s’est produite. Réessayez plus tard.';

  @override
  String get languageSystemDefault => 'Langue du téléphone';

  @override
  String get stepContent => 'Contenu';

  @override
  String get stepDivisions => 'Divisions';

  @override
  String get stepSummary => 'Phrase de résumé';

  @override
  String get stepFcf => 'FCF';

  @override
  String get stepAim => 'Objectif';

  @override
  String get stepApplication => 'Application';

  @override
  String get stepShortContent => 'Contenu';

  @override
  String get stepShortDivisions => 'Diviser';

  @override
  String get stepShortSummary => 'Résumé';

  @override
  String get stepShortFcf => 'FCF';

  @override
  String get stepShortAim => 'Objectif';

  @override
  String get stepShortApplication => 'Appliquer';

  @override
  String get commonShare => 'Partager';

  @override
  String get commonPrint => 'Imprimer';

  @override
  String get commonPreferences => 'Préférences';

  @override
  String get commonUntitled => 'Sans titre';

  @override
  String get homeSearchIntro =>
      'Recherchez dans vos homilétiques, divisions, applications, notes d’exposé et études de mots.';

  @override
  String get homeSearchFieldHint => 'Leçons, passages, notes…';

  @override
  String get homeSearchTooltip => 'Rechercher';

  @override
  String get homeCloseSearch => 'Fermer la recherche';

  @override
  String get homeAllStudies => 'Toutes les études';

  @override
  String get homeFilterByStudy => 'Filtrer par étude';

  @override
  String get homeOpenStudySite => 'Ouvrir le site de l’étude';

  @override
  String get homeThisWeek => 'Cette semaine';

  @override
  String get homeEarlier => 'Précédemment';

  @override
  String get homeComingUp => 'À venir';

  @override
  String homeWeekOverline(String when, String lesson) {
    return '$when · $lesson';
  }

  @override
  String get homeStartHomiletics => 'Commencer l’homilétique';

  @override
  String get homeContinueHomiletics => 'Continuer l’homilétique';

  @override
  String get homeOpenHomiletics => 'Ouvrir l’homilétique';

  @override
  String get homeLoadingPassages => 'Chargement des passages suggérés…';

  @override
  String get homeContinue => 'Reprendre';

  @override
  String get homeSeeAll => 'Tout voir';

  @override
  String get homeLivingItOut => 'Mettre en pratique';

  @override
  String get homeKindTileHomiletic => 'H';

  @override
  String get homeKindTileWordStudy => 'M';

  @override
  String get homeProgressNoneDone => 'Aucune étape terminée';

  @override
  String homeProgressDone(String steps) {
    return 'Terminé : $steps';
  }

  @override
  String homePageOf(int page, int count) {
    return 'Page $page sur $count';
  }

  @override
  String homePageFraction(int page, int count) {
    return '$page / $count';
  }

  @override
  String get studiesTitle => 'Vos études';

  @override
  String get studiesTabHomiletics => 'Homilétiques';

  @override
  String get studiesTabLectures => 'Exposés';

  @override
  String get studiesTabWordStudies => 'Études de mots';

  @override
  String get studiesNoHomiletics => 'Aucune homilétique pour l’instant.';

  @override
  String get studiesNoLectureNotes => 'Aucune note d’exposé pour l’instant.';

  @override
  String get studiesNoWordStudies => 'Aucune étude de mot pour l’instant.';

  @override
  String get studiesNoApplications =>
      'Aucune question d’application pour l’instant.';

  @override
  String get studiesProgressNotStarted => 'Pas commencé';

  @override
  String studiesProgressAll(int total) {
    return 'Les $total étapes';
  }

  @override
  String studiesProgressSome(int done, int total) {
    return '$done étapes sur $total';
  }

  @override
  String studiesHomileticSubtitle(String progress, String time) {
    return 'Homilétique · $progress · $time';
  }

  @override
  String studiesHomileticSubtitleNoProgress(String time) {
    return 'Homilétique · $time';
  }

  @override
  String studiesLectureTitle(String passage) {
    return 'Exposé sur $passage';
  }

  @override
  String get studiesLectureUntitled => 'Exposé';

  @override
  String studiesLectureSubtitle(String time) {
    return 'Notes d’exposé · $time';
  }

  @override
  String get studiesWordStudyUntitled => 'Étude de mot';

  @override
  String studiesWordStudySubtitle(String time) {
    return 'Étude de mot · $time';
  }

  @override
  String studiesWordStudySubtitleWithPassage(String passage, String time) {
    return 'Étude de mot · $passage · $time';
  }

  @override
  String get searchHint => 'Rechercher';

  @override
  String get searchSectionContentSummaries => 'Résumés du contenu';

  @override
  String get searchSectionDivisions => 'Divisions';

  @override
  String get searchSectionApplications => 'Applications';

  @override
  String get searchSectionAims => 'Objectifs';

  @override
  String get searchSectionSummarySentences => 'Phrases de résumé';

  @override
  String get searchSectionPassages => 'Passages des homilétiques';

  @override
  String get searchSectionLectureNotes => 'Notes d’exposé';

  @override
  String get searchSectionWordStudies => 'Études de mots';

  @override
  String get searchOpenFailed =>
      'Impossible d’ouvrir ce résultat. Il a peut-être été supprimé.';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsSectionLanguage => 'Langue';

  @override
  String get settingsAppLanguage => 'Langue de l’application';

  @override
  String get settingsSectionReading => 'Lecture';

  @override
  String get settingsSectionModels => 'Modèles sur l’appareil';

  @override
  String get settingsSectionHelp => 'Aide';

  @override
  String settingsCopyright(String year) {
    return 'Copyright (C) $year 13one.org · Tous droits réservés';
  }

  @override
  String get helpRequestFeedback => 'Demander de l’aide / donner votre avis';

  @override
  String helpCopyright(String year) {
    return 'Copyright (C) $year 13one.org';
  }

  @override
  String get helpAllRightsReserved => 'Tous droits réservés';

  @override
  String get feedbackTitle => 'Donnez-nous votre avis';

  @override
  String get feedbackPublicNotice =>
      'Votre message est publié sous forme de ticket public sur GitHub : n’importe qui sur Internet peut le lire. N’y mettez pas de mot de passe ni d’autres informations privées. Votre adresse e-mail est partiellement masquée sur GitHub ; nous pouvons conserver l’adresse complète sur nos serveurs uniquement pour vous recontacter.';

  @override
  String get feedbackTypeGeneral => 'Aide ou avis';

  @override
  String get feedbackTypeTranslation => 'Traduction fautive';

  @override
  String get feedbackTranslationHint =>
      'Indiquez-nous les mots qui semblent incorrects et ce qu’ils devraient dire. Nous joindrons la langue de votre application et votre traduction de la Bible.';

  @override
  String get feedbackNameLabel => 'Nom';

  @override
  String get feedbackEmailLabel => 'E-mail (facultatif)';

  @override
  String get feedbackContentLabel => 'Votre avis';

  @override
  String get feedbackSubmit => 'Envoyer';

  @override
  String get feedbackEmpty => 'Veuillez d’abord écrire votre message.';

  @override
  String get feedbackSubmittedIssue =>
      'Envoyé. Vous pouvez ouvrir le ticket sur GitHub à tout moment pour ajouter des commentaires (connexion facultative).';

  @override
  String get feedbackOpenIssue => 'Ouvrir';

  @override
  String get feedbackSubmitted => 'Votre avis a bien été envoyé';

  @override
  String get feedbackBadRequest =>
      'Impossible d’envoyer cette demande. Vérifiez votre message et réessayez.';

  @override
  String get feedbackServerUnreachableTitle =>
      'Impossible de joindre le serveur';

  @override
  String get feedbackServerUnreachableBody =>
      'Ouvrez plutôt GitHub dans votre navigateur pour envoyer ce signalement. Il faudra peut-être vous y connecter pour créer le ticket.';

  @override
  String get feedbackNotNow => 'Pas maintenant';

  @override
  String get feedbackOpenGitHub => 'Ouvrir GitHub';

  @override
  String get feedbackBrowserFailed => 'Impossible d’ouvrir le navigateur.';

  @override
  String get startHomiletics => 'Homilétique';

  @override
  String get startLecture => 'Exposé';

  @override
  String get startWordStudy => 'Étude de mot';

  @override
  String get startPassageHint => 'Étudier un autre passage…';

  @override
  String get startClear => 'Effacer';

  @override
  String get startOtherStudy => 'Autre étude';

  @override
  String get startMenuLectureNote => 'Notes d’exposé';

  @override
  String get startMenuWordStudy => 'Étude de mot';

  @override
  String get startDuplicateHomileticTitle =>
      'Vous avez déjà une homilétique pour ce passage ?';

  @override
  String startDuplicateHomileticMany(String passage, int count) {
    return '$passage\n\nVous avez $count homilétiques pour ce passage ; la plus récente va s’ouvrir.';
  }

  @override
  String get startDuplicateLectureTitle =>
      'Vous avez déjà des notes d’exposé pour ce passage ?';

  @override
  String startDuplicateLectureMany(String passage, int count) {
    return '$passage\n\nVous avez $count notes d’exposé pour ce passage ; les plus récentes vont s’ouvrir.';
  }

  @override
  String get startDuplicateWordStudyTitle =>
      'Vous avez déjà une étude de mot pour ce passage ?';

  @override
  String startDuplicateWordStudyMany(String passage, int count) {
    return '$passage\n\nVous avez $count études de mots pour ce passage ; la plus récente va s’ouvrir.';
  }

  @override
  String get startCreateNew => 'Créer une nouvelle';

  @override
  String get startEditExisting => 'Modifier l’existante';

  @override
  String get homileticHeaderLabel => 'Homilétique · Passage';

  @override
  String get homileticItemName => 'homilétique';

  @override
  String get homileticDeletedMessage => 'Homilétique supprimée';

  @override
  String get homileticLoadError =>
      'Une erreur s’est produite lors du chargement de cette leçon.';

  @override
  String get homileticPdfShared => 'PDF partagé avec succès.';

  @override
  String get homileticPdfShareFailed =>
      'Une erreur s’est produite lors du partage de votre PDF. Réessayez plus tard.';

  @override
  String get homileticPdfPrinted => 'PDF imprimé avec succès.';

  @override
  String get homileticPdfPrintFailed =>
      'Une erreur s’est produite lors de la création de votre PDF. Réessayez plus tard.';

  @override
  String get homileticCompleteTitle => 'Les six étapes sont faites';

  @override
  String get homileticCompleteMessage =>
      'Imprimez-la pour le cours ou partagez-la avec votre groupe.';

  @override
  String get homileticContentEmptySummary => 'Versets + résumé';

  @override
  String get homileticDivisionsEmptySummary => '2 à 4 groupes';

  @override
  String get homileticSummaryEmptySummary => '≤ 10 mots';

  @override
  String get homileticFcfEmptySummary => 'Condition humaine déchue';

  @override
  String get homileticAimEmptySummary => 'Le message principal';

  @override
  String get homileticApplicationEmptySummary => 'Comment puis-je…';

  @override
  String get homileticStepStatusDone => 'terminé';

  @override
  String get homileticStepStatusToDo => 'à faire';

  @override
  String homileticStepCollapseLabel(String title) {
    return '$title, réduire';
  }

  @override
  String homileticStepHelpLabel(String title) {
    return 'À propos : $title';
  }

  @override
  String get homileticVersesLabel => 'Versets';

  @override
  String get homileticVersesHint => 'v.';

  @override
  String homileticAddButtonLabel(String label) {
    return '+ $label';
  }

  @override
  String get homileticRemoveRowMessage =>
      'Ce que vous avez écrit ici sera supprimé.';

  @override
  String get homileticRemoveRowConfirm => 'Retirer';

  @override
  String get homileticContentSummaryHint => 'Résumé…';

  @override
  String get homileticAddContentSummary => 'Ajouter un résumé';

  @override
  String get homileticRemoveContentSummaryTooltip =>
      'Retirer le résumé du contenu';

  @override
  String get homileticRemoveContentSummaryTitle =>
      'Retirer ce résumé du contenu ?';

  @override
  String get homileticRemoveContentSummaryFailed =>
      'Impossible de retirer ce résumé du contenu';

  @override
  String get homileticDivisionHint => 'Phrase de la division…';

  @override
  String get homileticAddDivision => 'Ajouter une division';

  @override
  String get homileticRemoveDivisionTooltip => 'Retirer la division';

  @override
  String get homileticRemoveDivisionTitle => 'Retirer cette division ?';

  @override
  String get homileticRemoveDivisionFailed =>
      'Impossible de retirer cette division';

  @override
  String get homileticApplicationHint => 'Comment puis-je…';

  @override
  String get homileticAddApplication => 'Ajouter une question';

  @override
  String get homileticRemoveApplicationTooltip =>
      'Retirer la question d’application';

  @override
  String get homileticRemoveApplicationTitle =>
      'Retirer cette question d’application ?';

  @override
  String get homileticRemoveApplicationFailed =>
      'Impossible de retirer cette application';

  @override
  String get homileticSummaryHint => 'Résumez en 10 mots au plus';

  @override
  String get homileticFcfHint => 'Déchu/Fragile/Faible/Fautif';

  @override
  String get homileticAimHint => 'Amener l’auditoire à comprendre que…';

  @override
  String get homileticContentHelpTitle => 'Résumés du contenu';

  @override
  String get homileticContentHelpText =>
      'Un résumé du contenu résume une section de la Bible. Ce n’est pas forcément une phrase ; il peut aussi compter plusieurs phrases. Il doit résumer, avec vos propres mots, le contenu du passage.\nVous devriez avoir au moins 10 résumés du contenu, mais pas plus de 20. En général, selon la longueur du passage, vous le découperez en parties de taille à peu près égale pour arriver à 10 à 20 résumés. Ainsi, si votre passage compte 30 versets, visez en moyenne 3 versets par résumé du contenu.';

  @override
  String get homileticDivisionsHelpText =>
      'Les divisions sont des groupes de versets liés entre eux. Il en faut au moins deux et pas plus de quatre.';

  @override
  String get homileticSummaryHelpTitle => 'Phrase de résumé';

  @override
  String get homileticSummaryHelpText =>
      'La phrase de résumé est une déclaration concise et facile à retenir qui rassemble les faits les plus importants. Pensez au « test de 2 heures du matin » : si quelqu’un vous réveillait à 2 heures du matin pour vous demander de quoi parlait la prédication, que répondriez-vous ? Vous diriez la phrase de résumé.\nElle doit compter 10 mots au plus. Si vous êtes d’humeur créative, essayez de faire une allitération.';

  @override
  String get homileticFcfHelpText =>
      'Le FCF (Fallen Condition Focus, « focus sur la condition déchue ») est l’aspect de la condition humaine le plus illustré ou évoqué dans le passage. C’est la condition dans laquelle se trouve l’auditoire, la raison pour laquelle il a besoin d’être sauvé.';

  @override
  String get homileticAimHelpText =>
      'L’objectif est le point clé, la vérité principale que vous voulez retenir vous-même ou faire retenir à l’auditoire. Il peut découler du FCF et influencera sans doute les questions d’application.';

  @override
  String get homileticApplicationHelpTitle => 'Questions d’application';

  @override
  String get homileticApplicationHelpText =>
      'Ce sont des questions qui aident l’auditoire à appliquer à sa propre vie ce qu’il vient d’entendre. Elles doivent être précises, personnelles, ouvertes et faire réfléchir.';

  @override
  String homileticSummaryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count résumés',
      one: '$count résumé',
    );
    return '$_temp0';
  }

  @override
  String homileticDivisionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count divisions',
      one: '$count division',
    );
    return '$_temp0';
  }

  @override
  String homileticQuestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions',
      one: '$count question',
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
  String get lectureItemName => 'note d’exposé';

  @override
  String get lectureDeleted => 'Note d’exposé supprimée';

  @override
  String get lecturePassageHint => 'Passage';

  @override
  String get lectureHeaderLabel => 'Exposé · Passage';

  @override
  String get lectureNotesPlaceholder => 'Notes';

  @override
  String get lectureToolbarBold => 'Gras';

  @override
  String get lectureToolbarItalic => 'Italique';

  @override
  String get lectureToolbarBulletedList => 'Liste à puces';

  @override
  String get lectureToolbarNumberedList => 'Liste numérotée';

  @override
  String get lectureReplaceTitle => 'Remplacer l’enregistrement existant ?';

  @override
  String get lectureReplaceMessage =>
      'L’ancien audio et sa transcription seront supprimés.';

  @override
  String get lectureReplaceConfirm => 'Remplacer';

  @override
  String get lectureMicPermissionRequired =>
      'L’autorisation du micro est nécessaire pour enregistrer.';

  @override
  String get lectureNotificationTitle => 'Enregistrement de l’exposé';

  @override
  String lectureNotificationContent(String appName) {
    return '$appName enregistre l’audio';
  }

  @override
  String get lectureStartFailed =>
      'Impossible de démarrer l’enregistrement. Le micro est peut-être utilisé par une autre application.';

  @override
  String get lectureTranscriptionModelTitle =>
      'Télécharger le modèle de transcription hors ligne ?';

  @override
  String get lectureTranscriptionModelMessage =>
      'Un téléchargement unique d’environ 140 Mo permet de transcrire automatiquement vos enregistrements et d’y faire des recherches. Vous pouvez passer cette étape et le télécharger plus tard depuis les Paramètres.';

  @override
  String get lectureNotNow => 'Pas maintenant';

  @override
  String get lectureDownload => 'Télécharger';

  @override
  String get lectureModelDownloadFailed =>
      'Une erreur s’est produite lors du téléchargement du modèle. Vous pouvez réessayer depuis les Paramètres.';

  @override
  String get lectureRecordingFileNotFound =>
      'Le fichier d’enregistrement est introuvable.';

  @override
  String get lectureTranscriptionEmpty =>
      'La transcription n’a produit aucun texte.';

  @override
  String get lectureFormattingModelTitle =>
      'Télécharger le modèle de mise en forme ?';

  @override
  String lectureFormattingModelMessage(String size) {
    return 'Un téléchargement unique de $size permet de mettre les transcriptions au propre en paragraphes lisibles, entièrement sur votre appareil. Wi-Fi recommandé. Vous pouvez aussi le faire plus tard depuis les Paramètres.';
  }

  @override
  String get lectureFormattingModelMissing =>
      'Le modèle de mise en forme n’est pas téléchargé.';

  @override
  String get lectureFormattingFailed =>
      'Impossible de mettre en forme la transcription.';

  @override
  String get lecturePlaybackFailed => 'Impossible de lire l’enregistrement.';

  @override
  String lectureDownloadingModel(String percent) {
    return 'Téléchargement du modèle $percent %';
  }

  @override
  String lectureTranscribingProgress(int percent) {
    return 'Transcription $percent %';
  }

  @override
  String lectureFormattingProgress(int done, int total) {
    return 'Mise en forme $done/$total';
  }

  @override
  String get lectureFormattingIndeterminate =>
      'Mise en forme de la transcription…';

  @override
  String lectureRecordingSemantics(String time) {
    return 'Enregistrement, $time';
  }

  @override
  String get lectureRecordingSubtitle =>
      'Enregistrement · continue écran éteint';

  @override
  String get lectureStopRecording => 'Arrêter l’enregistrement';

  @override
  String get lectureRecordLecture => 'Enregistrer l’exposé';

  @override
  String get lectureRecordIdleSubtitle => 'Continue d’enregistrer écran éteint';

  @override
  String get lecturePause => 'Pause';

  @override
  String get lecturePlayRecording => 'Écouter l’enregistrement';

  @override
  String get lectureRecordAgain => 'Réenregistrer';

  @override
  String get lectureNotTranscribedYet => 'Pas encore transcrit';

  @override
  String get lectureTranscribe => 'Transcrire';

  @override
  String get lectureTimeMark => '+ Repère';

  @override
  String get lectureTranscriptEmptyRecording =>
      'L’exposé sera transcrit sur ce téléphone une fois l’enregistrement arrêté.';

  @override
  String get lectureTranscriptEmptyPending =>
      'La transcription apparaîtra ici dès qu’elle sera prête.';

  @override
  String get lectureTranscriptEmptyNotTranscribed =>
      'Transcrivez l’enregistrement pour le lire et y faire des recherches ici.';

  @override
  String get lectureTranscriptEmptyNoRecording =>
      'Enregistrez l’exposé : il sera transcrit sur ce téléphone une fois l’enregistrement arrêté.';

  @override
  String get lectureTranscribing => 'Transcription…';

  @override
  String get lectureNoTranscriptYet => 'Pas encore de transcription';

  @override
  String get lectureFormatted => 'Mis en forme';

  @override
  String get lectureRaw => 'Brut';

  @override
  String get lectureFormatTranscript => 'Mettre en forme';

  @override
  String get lectureTabMyNotes => 'Mes notes';

  @override
  String get lectureTabTranscript => 'Transcription';

  @override
  String get modelTranscriptionTitle => 'Modèle de transcription hors ligne';

  @override
  String modelTranscriptionEnglishNeeded(String language) {
    return 'Modèle anglais, nécessaire pour $language';
  }

  @override
  String modelTranscriptionEnglishNotNeeded(String language) {
    return 'Modèle anglais, inutile pour $language';
  }

  @override
  String modelTranscriptionMultilingualNeeded(String language) {
    return 'Modèle multilingue, nécessaire pour $language';
  }

  @override
  String modelTranscriptionMultilingualNotNeeded(String language) {
    return 'Modèle multilingue, inutile pour $language';
  }

  @override
  String get modelFormattingTitle =>
      'Modèle de mise en forme des transcriptions';

  @override
  String get modelAppleIntelligenceStatus =>
      'Utilise Apple Intelligence (aucun téléchargement nécessaire)';

  @override
  String get modelStatusChecking => 'Vérification…';

  @override
  String modelStatusNotDownloaded(String size) {
    return 'Non téléchargé ($size)';
  }

  @override
  String modelStatusDownloading(String percent) {
    return 'Téléchargement… $percent %';
  }

  @override
  String get modelStatusDownloaded => 'Téléchargé';

  @override
  String modelStatusDownloadedSize(String megabytes) {
    return 'Téléchargé ($megabytes Mo)';
  }

  @override
  String get modelDownload => 'Télécharger';

  @override
  String get modelDelete => 'Supprimer';

  @override
  String get modelDownloadFailed =>
      'Une erreur s’est produite lors du téléchargement du modèle. Réessayez plus tard.';

  @override
  String get modelDeleteFailed =>
      'Une erreur s’est produite lors de la suppression du modèle.';

  @override
  String get pdfOverlineHomiletics => 'HOMILÉTIQUE';

  @override
  String get pdfOverlineWordStudy => 'ÉTUDE DE MOT';

  @override
  String get pdfUntitledPassage => 'Passage sans titre';

  @override
  String get pdfUntitledWord => 'Mot sans titre';

  @override
  String pdfHomileticLabel(String passage) {
    return 'Homilétique · $passage';
  }

  @override
  String pdfWordStudyLabel(String word) {
    return 'Étude de mot · $word';
  }

  @override
  String pdfWordStudyLabelWithPassage(String word, String passage) {
    return 'Étude de mot · $word · $passage';
  }

  @override
  String pdfPageOf(int current, int total) {
    return 'page $current sur $total';
  }

  @override
  String get pdfFcfCaption => 'Focus sur la condition déchue';

  @override
  String get pdfAimLeadIn => 'Amener l’auditoire à comprendre que ';

  @override
  String get pdfEmptyHomiletic => 'Rien n’a encore été écrit pour ce passage.';

  @override
  String get pdfEmptyWordStudy =>
      'Rien n’a encore été écrit pour cette étude de mot.';

  @override
  String get pdfWordStudyDefinition => 'Définition';

  @override
  String get pdfWordStudyOtherUsage => 'Autres emplois';

  @override
  String get pdfWordStudyContextualMeaning => 'Sens dans le contexte';

  @override
  String get pdfWordStudyDeeperMeaning => 'Sens approfondi';

  @override
  String get pdfWordStudyApplication => 'Application';

  @override
  String get editorSaveAndClose => 'Enregistrer et fermer';

  @override
  String get editorDeleteConfirmTitle => 'Êtes-vous sûr ?';

  @override
  String editorDeleteConfirmMessage(String itemName) {
    return 'La suppression de cette $itemName est définitive et irréversible. Voulez-vous vraiment continuer ?';
  }

  @override
  String get editorPassageLabel => 'Passage';

  @override
  String get editorAddPassageHint => 'Ajouter un passage';

  @override
  String get editorBack => 'Retour';

  @override
  String get editorMoreOptions => 'Plus d’options';

  @override
  String get editorChangeTranslation => 'Changer de traduction';

  @override
  String get editorStudyCompleteMessage =>
      'Imprimez-la pour le cours ou partagez-la avec votre groupe.';

  @override
  String get wordStudyItemName => 'étude de mot';

  @override
  String get wordStudyDeleted => 'Étude de mot supprimée';

  @override
  String get wordStudyHeaderLabel => 'Étude de mot · Passage';

  @override
  String get wordStudyPdfShared => 'PDF partagé avec succès.';

  @override
  String get wordStudyPdfShareFailed =>
      'Une erreur s’est produite lors du partage de votre PDF. Réessayez plus tard.';

  @override
  String get wordStudyPdfPrinted => 'PDF imprimé avec succès.';

  @override
  String get wordStudyPdfPrintFailed =>
      'Une erreur s’est produite lors de la création de votre PDF. Réessayez plus tard.';

  @override
  String get wordStudyWordTitle => 'Mot';

  @override
  String get wordStudyWordHelp =>
      'Le mot précis ou la courte expression que vous étudiez. Une fois saisi, les sections Définition et Autres emplois pourront vous proposer du contenu.';

  @override
  String get wordStudyWordHint => 'Ajouter un mot';

  @override
  String get wordStudyEnterWordFirst => 'Saisissez d’abord un mot ci-dessus.';

  @override
  String get wordStudyDefinitionTitle => 'Définition';

  @override
  String get wordStudyDefinitionHelp =>
      'Que signifie ce mot, en termes simples ? Touchez « + » pour obtenir des définitions tirées d’un dictionnaire, ou écrivez la vôtre.';

  @override
  String get wordStudyDefinitionHelpNoSuggest =>
      'Que signifie ce mot, en termes simples ? Écrivez votre propre définition.';

  @override
  String get wordStudyDefinitionHint =>
      'Que signifie-t-il, en termes simples ?';

  @override
  String get wordStudySuggestDefinition => 'Suggérer une définition';

  @override
  String wordStudyDefinitionsFor(String word) {
    return 'Définitions de « $word »';
  }

  @override
  String get wordStudyDefinitionsTapToUse => 'Touchez-en une pour l’utiliser.';

  @override
  String get wordStudyDefinitionsLoadError =>
      'Impossible de charger les définitions. Réessayez plus tard.';

  @override
  String get wordStudyNoDefinitions => 'Aucune définition trouvée pour ce mot.';

  @override
  String get wordStudyReplaceDefinitionTitle => 'Remplacer votre définition ?';

  @override
  String get wordStudyReplaceDefinitionMessage =>
      'Vous avez déjà écrit une définition. Voulez-vous la remplacer par la suggestion, ou ajouter la suggestion en dessous ?';

  @override
  String get wordStudyAddBelow => 'Ajouter en dessous';

  @override
  String get wordStudyReplace => 'Remplacer';

  @override
  String get wordStudyOtherUsageTitle => 'Autres emplois';

  @override
  String get wordStudyOtherUsageHelp =>
      'Où ailleurs ce mot ou cette notion apparaît-il dans les Écritures ? Touchez « + » pour chercher sur Bible Gateway et ajouter les références trouvées, ou écrivez les vôtres.';

  @override
  String get wordStudyOtherUsageHint =>
      'Où apparaît-il ailleurs dans les Écritures ?';

  @override
  String get wordStudyFindOtherUsages => 'Trouver d’autres emplois';

  @override
  String wordStudyOtherUsageSheetTitle(String word) {
    return 'Autres passages où apparaît « $word »';
  }

  @override
  String get wordStudyOtherUsageAdded => 'Ajoutées';

  @override
  String get wordStudyOtherUsageInstructions =>
      'Touchez un résultat ci-dessous pour ajouter sa référence.';

  @override
  String get wordStudyOtherUsageAddResult => '+ Ajouter';

  @override
  String get wordStudyContextualMeaningTitle => 'Sens dans le contexte';

  @override
  String get wordStudyContextualMeaningHelp =>
      'Quel sens l’auteur voulait-il donner à ce mot ici, dans ce passage ? Tenez compte des versets qui l’entourent, et pas seulement du mot isolé.';

  @override
  String get wordStudyContextualMeaningHint =>
      'Que signifie-t-il ici, dans ce passage ?';

  @override
  String get wordStudyDeeperMeaningTitle => 'Sens approfondi';

  @override
  String get wordStudyDeeperMeaningHelp =>
      'Une idée tirée de la langue originale, d’un commentaire ou d’une autre étude qui apporte de la profondeur au-delà de la définition de base ? Comment le reste des Écritures l’éclaire-t-il ? Une concordance Strong ou Blue Letter Bible peuvent vous aider ici.';

  @override
  String get wordStudyDeeperMeaningHint =>
      'Comment le reste des Écritures l’éclaire-t-il ?';

  @override
  String get wordStudyApplicationTitle => 'Application';

  @override
  String get wordStudyApplicationHelp =>
      'Comment cette vérité doit-elle façonner votre vie ? Soyez précis, personnel et concret.';

  @override
  String get wordStudyApplicationHint => 'Qu’allez-vous en faire ?';

  @override
  String get wordStudyDoneTitle => 'Étude de mot terminée';

  @override
  String wordStudySectionHelpSemantics(String title) {
    return '$title, à propos de cette section';
  }

  @override
  String get lectureTimeMarkNoRecording =>
      'Cette note n’a pas d’enregistrement à lire.';

  @override
  String get lectureTimeMarkStopRecordingFirst =>
      'Arrêtez l’enregistrement pour lire à partir d’un repère.';

  @override
  String get lectureTimeMarkPastEnd =>
      'Ce repère se situe après la fin de l’enregistrement.';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingBack => 'Retour';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingWelcomeOverline => 'Bienvenue';

  @override
  String get onboardingWelcomeTitle => 'Étudiez la Bible, un passage à la fois';

  @override
  String get onboardingWelcomeBody =>
      'Homiletics vous aide à rédiger votre homilétique, à prendre des notes pendant l\'exposé et à faire des études de mot — toujours avec le passage ouvert à côté, dans votre langue et votre traduction de la Bible.';

  @override
  String get onboardingMethodOverline => 'La méthode';

  @override
  String get onboardingMethodTitle => 'Qu\'est-ce qu\'une homilétique ?';

  @override
  String get onboardingMethodBody =>
      'Une homilétique est une façon brève d\'étudier un passage : vous en dégagez le message principal, puis vous réfléchissez à la manière de le vivre. Elle compte six étapes — et n\'a pas besoin d\'être parfaite. Cela devient plus facile chaque semaine.';

  @override
  String get onboardingStepsOverline => 'Étape par étape';

  @override
  String get onboardingStepsTitle => 'Les six étapes';

  @override
  String get onboardingStepContent =>
      'Résumez le passage en 10 à 20 courts morceaux, avec vos propres mots.';

  @override
  String get onboardingStepDivisions =>
      'Regroupez ces morceaux en 2 à 4 parties.';

  @override
  String get onboardingStepSummary => 'Tout le passage en 10 mots ou moins.';

  @override
  String get onboardingStepFcf =>
      'Focus sur la condition déchue : le besoin ou la brisure humaine dont parle le passage.';

  @override
  String get onboardingStepAim =>
      'La vérité principale que vous voulez que vos auditeurs retiennent.';

  @override
  String get onboardingStepApplication =>
      'Des questions qui font passer le passage dans la vie de tous les jours.';

  @override
  String get onboardingLecturesOverline => 'Exposés et études de mot';

  @override
  String get onboardingLecturesTitle =>
      'Écoutez attentivement, creusez plus loin';

  @override
  String get onboardingLecturesBody =>
      'Enregistrez l\'exposé — l\'enregistrement continue écran éteint et la transcription se fait sur votre téléphone. Prenez des notes en écoutant et ajoutez des repères de temps pour retrouver un moment.';

  @override
  String get onboardingWordStudyBody =>
      'Un mot vous interpelle ? Commencez une étude de mot et creusez ce qu\'il signifie dans le passage.';

  @override
  String get onboardingStartOverline => 'Pour commencer';

  @override
  String get onboardingStartTitle => 'Tout est prêt pour commencer';

  @override
  String get onboardingStartBody =>
      'Commencez par le passage de cette semaine, ou faites d\'abord un tour. Chaque étape que vous écrivez est enregistrée au fur et à mesure.';

  @override
  String get onboardingReopenHint =>
      'Vous pouvez rouvrir ce guide à tout moment depuis les Paramètres.';

  @override
  String get onboardingStartThisWeek =>
      'Commencer l\'homilétique de la semaine';

  @override
  String get onboardingExplore => 'Explorer par moi-même';

  @override
  String onboardingThisWeekPassage(String passage) {
    return 'Cette semaine : $passage';
  }

  @override
  String get onboardingSettingsRow => 'Comment fonctionne l\'homilétique';

  @override
  String bibleOfflineSize(String size) {
    return 'Hors ligne · $size';
  }

  @override
  String bibleDownloadedSize(String size) {
    return 'Téléchargée · $size';
  }

  @override
  String get bibleDownloadAction => 'Télécharger pour lire hors ligne';

  @override
  String get bibleDownloading => 'Téléchargement…';

  @override
  String get bibleRemoveDownload => 'Supprimer le téléchargement';

  @override
  String bibleDownloadFailed(String translation) {
    return 'Impossible de télécharger $translation. Vérifiez votre connexion et réessayez.';
  }

  @override
  String get bibleOfflineTitle => 'Pas de connexion';

  @override
  String bibleOfflineMessage(String translation) {
    return 'Ce passage vient de Bible Gateway, qui demande une connexion Internet. Téléchargez $translation pour le lire partout.';
  }

  @override
  String get bibleOfflineNoDownloadMessage =>
      'Ce passage vient de Bible Gateway, qui demande une connexion Internet. Connectez-vous et réessayez.';

  @override
  String get bibleTryAgain => 'Réessayer';

  @override
  String bibleNeedsDownloadTitle(String translation) {
    return 'Télécharger $translation';
  }

  @override
  String bibleNeedsDownloadMessage(String size) {
    return 'Cette Bible se lit depuis votre appareil. Téléchargez-la une fois (environ $size) pour voir le passage.';
  }

  @override
  String bibleNotInTranslation(String translation) {
    return 'Ce passage est introuvable dans $translation.';
  }

  @override
  String get bibleVerseTapTip =>
      'Astuce : touchez un numéro de verset pour commencer un résumé à cet endroit.';

  @override
  String bibleVerseTapLabel(String verse) {
    return 'Commencer un résumé au verset $verse';
  }

  @override
  String get shareSheetTitle => 'Partager cette étude';

  @override
  String get shareLink => 'Partager le lien';

  @override
  String get shareLinkSubtitle =>
      'S\'ouvre dans l\'app ou dans n\'importe quel navigateur';

  @override
  String get shareCopyLink => 'Copier le lien';

  @override
  String get shareLinkCopied => 'Lien copié';

  @override
  String get shareShowQr => 'Afficher le code QR';

  @override
  String get shareSharePdf => 'Partager le PDF';

  @override
  String get shareLinkFailed => 'Impossible de partager le lien.';

  @override
  String get shareLinkTooLongTitle => 'Ce lien est très long';

  @override
  String shareLinkTooLongMessage(int count) {
    return 'Cette étude produit un lien de $count caractères. Certaines apps peuvent le couper, et il risque de ne pas s\'ouvrir. Dans ce cas, partagez plutôt le PDF.';
  }

  @override
  String get shareAnyway => 'Partager quand même';

  @override
  String get shareQrTitle => 'Scanner pour ouvrir';

  @override
  String get shareQrHint =>
      'Visez le code avec l\'appareil photo d\'un autre téléphone pour ouvrir cette étude.';

  @override
  String get shareQrTooLong =>
      'Cette étude est trop longue pour un code QR. Utilisez plutôt Partager le lien ou Copier le lien.';

  @override
  String get shareQrSemantics => 'Code QR menant à cette étude';

  @override
  String get importFromLink => 'Importer depuis un lien';

  @override
  String get importSheetMessage =>
      'Collez un lien Homiletics qu\'on vous a partagé. Vous pourrez le consulter avant d\'en enregistrer une copie.';

  @override
  String get importFieldHint => 'https://homiletics.app/view#…';

  @override
  String get importPaste => 'Coller';

  @override
  String get importOpen => 'Ouvrir';

  @override
  String get importClipboardEmpty => 'Il n\'y a pas de texte à coller.';

  @override
  String get importInvalidLink =>
      'Ce n\'est pas un lien Homiletics, ou il en manque une partie. Redemandez le lien.';

  @override
  String get importNewerVersion =>
      'Cette étude a été partagée depuis une version plus récente de Homiletics. Mettez Homiletics à jour pour l\'ouvrir.';

  @override
  String get importCouldNotOpenTitle => 'Impossible d\'ouvrir ce lien';

  @override
  String get importPreviewHomiletic => 'Homilétique partagée';

  @override
  String get importPreviewWordStudy => 'Étude de mot partagée';

  @override
  String get importPreviewNote =>
      'Quelqu\'un vous a partagé ceci. L\'enregistrer ajoute une copie à vos études ; rien de ce que vous avez déjà n\'est modifié.';

  @override
  String importPreviewTranslation(String translation) {
    return 'Rédigé avec $translation';
  }

  @override
  String get importSaveCopy => 'Enregistrer une copie';

  @override
  String get importSaved => 'Enregistré dans vos études';

  @override
  String get importSaveFailed =>
      'Impossible d\'enregistrer l\'étude. Réessayez.';

  @override
  String get startOpenSharedStudy => 'Ouvrir l\'étude partagée';

  @override
  String bibleWebUnavailableTitle(String translation) {
    return 'Lire $translation dans votre navigateur';
  }

  @override
  String get bibleWebUnavailableMessage =>
      'Sous Windows, l\'application ne peut pas afficher les passages de Bible Gateway. Ouvrez ce passage dans votre navigateur ou choisissez une traduction lue depuis votre appareil.';

  @override
  String get bibleOpenInBrowser => 'Ouvrir dans le navigateur';

  @override
  String bibleUseOfflineTranslation(String translation) {
    return 'Utiliser une traduction hors ligne ($translation)';
  }

  @override
  String get wordStudyOtherUsageOpenedInBrowser =>
      'Les résultats se sont ouverts dans votre navigateur. Tapez ou collez ici les références à conserver.';

  @override
  String get settingsCheckForUpdates => 'Rechercher des mises à jour';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String updateAvailableTitle(String version) {
    return 'Homiletics $version est disponible';
  }

  @override
  String updateAvailableMessage(String current) {
    return 'Vous avez la version $current. Nouveautés :';
  }

  @override
  String get updateNow => 'Mettre à jour';

  @override
  String get updateDownload => 'Télécharger';

  @override
  String get updateLater => 'Plus tard';

  @override
  String get updateSkipVersion => 'Ignorer cette version';

  @override
  String get updateDownloading => 'Téléchargement de la mise à jour…';

  @override
  String get updateInstalling =>
      'Installation en cours. Homiletics va se rouvrir dans un instant.';

  @override
  String get updateFailed =>
      'Impossible de télécharger la mise à jour. Réessayez ou téléchargez-la sur homiletics.app.';

  @override
  String get updateTryAgain => 'Réessayer';

  @override
  String get updatePortableNote =>
      'Cette copie n’a pas été installée avec le programme d’installation : téléchargez la nouvelle version sur homiletics.app.';

  @override
  String updateUpToDate(String version) {
    return 'Vous avez la dernière version (Homiletics $version).';
  }

  @override
  String get updateCheckFailed =>
      'Impossible de rechercher des mises à jour. Vérifiez votre connexion internet et réessayez.';
}
