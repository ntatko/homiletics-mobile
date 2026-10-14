// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get prefsTitle => 'Preferencias';

  @override
  String get prefsAppLanguage => 'Idioma preferido';

  @override
  String get prefsBibleVersion => 'Versión de la Biblia preferida';

  @override
  String get bibleNewTestamentOnly => 'Solo Nuevo Testamento';

  @override
  String get appTitle => 'Homiletics';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonOk => 'Aceptar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonDone => 'Listo';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonSomethingWentWrong =>
      'Algo salió mal. Inténtalo de nuevo en un momento.';

  @override
  String get languageSystemDefault => 'Idioma del teléfono';

  @override
  String get stepContent => 'Contenido';

  @override
  String get stepDivisions => 'Divisiones';

  @override
  String get stepSummary => 'Frase resumen';

  @override
  String get stepFcf => 'FCF';

  @override
  String get stepAim => 'Objetivo';

  @override
  String get stepApplication => 'Aplicación';

  @override
  String get stepShortContent => 'Contenido';

  @override
  String get stepShortDivisions => 'Dividir';

  @override
  String get stepShortSummary => 'Resumen';

  @override
  String get stepShortFcf => 'FCF';

  @override
  String get stepShortAim => 'Objetivo';

  @override
  String get stepShortApplication => 'Aplicar';

  @override
  String get commonShare => 'Compartir';

  @override
  String get commonPrint => 'Imprimir';

  @override
  String get commonPreferences => 'Preferencias';

  @override
  String get commonUntitled => 'Sin título';

  @override
  String get homeSearchIntro =>
      'Busca en tus homiléticas, divisiones, aplicaciones, notas de conferencias y estudios de palabras.';

  @override
  String get homeSearchFieldHint => 'Buscar lecciones, pasajes, notas…';

  @override
  String get homeSearchTooltip => 'Buscar';

  @override
  String get homeCloseSearch => 'Cerrar búsqueda';

  @override
  String get homeAllStudies => 'Todos los estudios';

  @override
  String get homeFilterByStudy => 'Filtrar por estudio';

  @override
  String get homeOpenStudySite => 'Abrir sitio web del estudio';

  @override
  String get homeThisWeek => 'Esta semana';

  @override
  String get homeEarlier => 'Anteriores';

  @override
  String get homeComingUp => 'Próximamente';

  @override
  String homeWeekOverline(String when, String lesson) {
    return '$when · $lesson';
  }

  @override
  String get homeStartHomiletics => 'Comenzar homilética';

  @override
  String get homeContinueHomiletics => 'Continuar homilética';

  @override
  String get homeOpenHomiletics => 'Abrir homilética';

  @override
  String get homeLoadingPassages => 'Cargando pasajes sugeridos…';

  @override
  String get homeContinue => 'Continuar';

  @override
  String get homeSeeAll => 'Ver todo';

  @override
  String get homeLivingItOut => 'Ponerlo en práctica';

  @override
  String get homeKindTileHomiletic => 'H';

  @override
  String get homeKindTileWordStudy => 'P';

  @override
  String get homeProgressNoneDone => 'Ningún paso completado aún';

  @override
  String homeProgressDone(String steps) {
    return 'Completados: $steps';
  }

  @override
  String homePageOf(int page, int count) {
    return 'Página $page de $count';
  }

  @override
  String homePageFraction(int page, int count) {
    return '$page / $count';
  }

  @override
  String get studiesTitle => 'Tus estudios';

  @override
  String get studiesTabHomiletics => 'Homiléticas';

  @override
  String get studiesTabLectures => 'Conferencias';

  @override
  String get studiesTabWordStudies => 'Estudios de palabras';

  @override
  String get studiesNoHomiletics => 'Aún no hay homiléticas.';

  @override
  String get studiesNoLectureNotes => 'Aún no hay notas de conferencias.';

  @override
  String get studiesNoWordStudies => 'Aún no hay estudios de palabras.';

  @override
  String get studiesNoApplications => 'Aún no hay preguntas de aplicación.';

  @override
  String get studiesProgressNotStarted => 'Sin comenzar';

  @override
  String studiesProgressAll(int total) {
    return 'Los $total pasos';
  }

  @override
  String studiesProgressSome(int done, int total) {
    return '$done de $total pasos';
  }

  @override
  String studiesHomileticSubtitle(String progress, String time) {
    return 'Homilética · $progress · $time';
  }

  @override
  String studiesHomileticSubtitleNoProgress(String time) {
    return 'Homilética · $time';
  }

  @override
  String studiesLectureTitle(String passage) {
    return 'Conferencia de $passage';
  }

  @override
  String get studiesLectureUntitled => 'Conferencia';

  @override
  String studiesLectureSubtitle(String time) {
    return 'Notas de conferencia · $time';
  }

  @override
  String get studiesWordStudyUntitled => 'Estudio de palabra';

  @override
  String studiesWordStudySubtitle(String time) {
    return 'Estudio de palabra · $time';
  }

  @override
  String studiesWordStudySubtitleWithPassage(String passage, String time) {
    return 'Estudio de palabra · $passage · $time';
  }

  @override
  String get searchHint => 'Buscar';

  @override
  String get searchSectionContentSummaries => 'Resúmenes de contenido';

  @override
  String get searchSectionDivisions => 'Divisiones';

  @override
  String get searchSectionApplications => 'Aplicaciones';

  @override
  String get searchSectionAims => 'Objetivos';

  @override
  String get searchSectionSummarySentences => 'Frases resumen';

  @override
  String get searchSectionPassages => 'Pasajes de homiléticas';

  @override
  String get searchSectionLectureNotes => 'Notas de conferencias';

  @override
  String get searchSectionWordStudies => 'Estudios de palabras';

  @override
  String get searchOpenFailed =>
      'No se pudo abrir ese resultado. Es posible que se haya eliminado.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSectionLanguage => 'Idioma';

  @override
  String get settingsAppLanguage => 'Idioma de la app';

  @override
  String get settingsSectionReading => 'Lectura';

  @override
  String get settingsSectionModels => 'Modelos en el dispositivo';

  @override
  String get settingsSectionHelp => 'Ayuda';

  @override
  String settingsCopyright(String year) {
    return 'Copyright (C) $year 13one.org · Todos los derechos reservados';
  }

  @override
  String get helpRequestFeedback => 'Pedir ayuda / dejar comentarios';

  @override
  String helpCopyright(String year) {
    return 'Copyright (C) $year 13one.org';
  }

  @override
  String get helpAllRightsReserved => 'Todos los derechos reservados';

  @override
  String get feedbackTitle => 'Déjanos tus comentarios';

  @override
  String get feedbackPublicNotice =>
      'Tus comentarios se envían como un issue público de GitHub: cualquier persona en internet puede leerlos. No incluyas contraseñas ni otra información privada. Tu correo aparece parcialmente oculto en GitHub; podríamos guardar la dirección completa en nuestros servidores solo para darte seguimiento.';

  @override
  String get feedbackTypeGeneral => 'Ayuda o comentarios';

  @override
  String get feedbackTypeTranslation => 'Error de traducción';

  @override
  String get feedbackTranslationHint =>
      'Dinos qué palabras se ven mal y qué deberían decir. Incluiremos el idioma de tu app y tu traducción de la Biblia.';

  @override
  String get feedbackNameLabel => 'Nombre';

  @override
  String get feedbackEmailLabel => 'Correo (opcional)';

  @override
  String get feedbackContentLabel => 'Comentarios';

  @override
  String get feedbackSubmit => 'Enviar';

  @override
  String get feedbackEmpty => 'Primero escribe tus comentarios.';

  @override
  String get feedbackSubmittedIssue =>
      'Enviado. Abre el issue en GitHub cuando quieras para agregar comentarios (iniciar sesión es opcional).';

  @override
  String get feedbackOpenIssue => 'Abrir';

  @override
  String get feedbackSubmitted => 'Comentarios enviados correctamente';

  @override
  String get feedbackBadRequest =>
      'No se pudo enviar la solicitud. Revisa tu mensaje e inténtalo de nuevo.';

  @override
  String get feedbackServerUnreachableTitle =>
      'No se pudo conectar con el servidor';

  @override
  String get feedbackServerUnreachableBody =>
      'Abre GitHub en tu navegador para enviar este reporte allí. Es posible que tengas que iniciar sesión para crear el issue.';

  @override
  String get feedbackNotNow => 'Ahora no';

  @override
  String get feedbackOpenGitHub => 'Abrir GitHub';

  @override
  String get feedbackBrowserFailed => 'No se pudo abrir el navegador.';

  @override
  String get startHomiletics => 'Homilética';

  @override
  String get startLecture => 'Conferencia';

  @override
  String get startWordStudy => 'Palabra';

  @override
  String get startPassageHint => 'Estudiar otro pasaje…';

  @override
  String get startClear => 'Borrar';

  @override
  String get startOtherStudy => 'Otro estudio';

  @override
  String get startMenuLectureNote => 'Nota de conferencia';

  @override
  String get startMenuWordStudy => 'Estudio de palabra';

  @override
  String get startDuplicateHomileticTitle =>
      '¿Ya tienes una homilética de este pasaje?';

  @override
  String startDuplicateHomileticMany(String passage, int count) {
    return '$passage\n\nTienes $count homiléticas de este pasaje; se abrirá la más reciente.';
  }

  @override
  String get startDuplicateLectureTitle =>
      '¿Ya tienes notas de conferencia de este pasaje?';

  @override
  String startDuplicateLectureMany(String passage, int count) {
    return '$passage\n\nTienes $count notas de conferencia de este pasaje; se abrirán las más recientes.';
  }

  @override
  String get startDuplicateWordStudyTitle =>
      '¿Ya tienes un estudio de palabra de este pasaje?';

  @override
  String startDuplicateWordStudyMany(String passage, int count) {
    return '$passage\n\nTienes $count estudios de palabras de este pasaje; se abrirá el más reciente.';
  }

  @override
  String get startCreateNew => 'Crear nuevo';

  @override
  String get startEditExisting => 'Editar existente';

  @override
  String get homileticHeaderLabel => 'Homilética · Pasaje';

  @override
  String get homileticItemName => 'esta lección de homilética';

  @override
  String get homileticDeletedMessage => 'Homilética eliminada';

  @override
  String get homileticLoadError => 'Algo salió mal al cargar esta lección.';

  @override
  String get homileticPdfShared => 'PDF compartido correctamente.';

  @override
  String get homileticPdfShareFailed =>
      'Algo salió mal al compartir tu PDF. Inténtalo de nuevo en un momento.';

  @override
  String get homileticPdfPrinted => 'PDF impreso correctamente.';

  @override
  String get homileticPdfPrintFailed =>
      'Algo salió mal al crear tu PDF. Inténtalo de nuevo en un momento.';

  @override
  String get homileticCompleteTitle => '¡Los seis pasos listos!';

  @override
  String get homileticCompleteMessage =>
      'Imprímela para la clase o compártela con tu grupo.';

  @override
  String get homileticContentEmptySummary => 'Versículos + resumen';

  @override
  String get homileticDivisionsEmptySummary => '2–4 grupos';

  @override
  String get homileticSummaryEmptySummary => '≤ 10 palabras';

  @override
  String get homileticFcfEmptySummary => 'Condición caída';

  @override
  String get homileticAimEmptySummary => 'La idea principal';

  @override
  String get homileticApplicationEmptySummary => '¿Cómo puedo…?';

  @override
  String get homileticStepStatusDone => 'completado';

  @override
  String get homileticStepStatusToDo => 'pendiente';

  @override
  String homileticStepCollapseLabel(String title) {
    return '$title, contraer';
  }

  @override
  String homileticStepHelpLabel(String title) {
    return 'Acerca de $title';
  }

  @override
  String get homileticVersesLabel => 'Versículos';

  @override
  String get homileticVersesHint => 'v.';

  @override
  String homileticAddButtonLabel(String label) {
    return '+ $label';
  }

  @override
  String get homileticRemoveRowMessage =>
      'Lo que escribiste aquí se eliminará.';

  @override
  String get homileticRemoveRowConfirm => 'Quitar';

  @override
  String get homileticContentSummaryHint => 'Resumen…';

  @override
  String get homileticAddContentSummary => 'Agregar resumen';

  @override
  String get homileticRemoveContentSummaryTooltip =>
      'Quitar resumen de contenido';

  @override
  String get homileticRemoveContentSummaryTitle =>
      '¿Quitar este resumen de contenido?';

  @override
  String get homileticRemoveContentSummaryFailed =>
      'No se pudo quitar ese resumen de contenido';

  @override
  String get homileticDivisionHint => 'Frase de la división…';

  @override
  String get homileticAddDivision => 'Agregar división';

  @override
  String get homileticRemoveDivisionTooltip => 'Quitar división';

  @override
  String get homileticRemoveDivisionTitle => '¿Quitar esta división?';

  @override
  String get homileticRemoveDivisionFailed => 'No se pudo quitar esa división';

  @override
  String get homileticApplicationHint => '¿Cómo puedo…?';

  @override
  String get homileticAddApplication => 'Agregar pregunta';

  @override
  String get homileticRemoveApplicationTooltip =>
      'Quitar pregunta de aplicación';

  @override
  String get homileticRemoveApplicationTitle =>
      '¿Quitar esta pregunta de aplicación?';

  @override
  String get homileticRemoveApplicationFailed =>
      'No se pudo quitar esa aplicación';

  @override
  String get homileticSummaryHint => 'Resume en 10 palabras o menos';

  @override
  String get homileticFcfHint => 'Caído/Frágil/Débil/Inconstante';

  @override
  String get homileticAimHint => 'Que la audiencia aprenda que…';

  @override
  String get homileticContentHelpTitle => 'Resúmenes de contenido';

  @override
  String get homileticContentHelpText =>
      'Un resumen de contenido es un resumen de una sección de la Biblia. No tiene que ser una sola oración; también puede ser más de una. Debe ser un resumen, en tus propias palabras, del contenido del pasaje.\nDebes tener al menos 10 resúmenes de contenido, pero no más de 20. Por lo general, según la extensión del pasaje, lo dividirás en partes de un tamaño aproximado para llegar a ese rango de 10 a 20. Así que, si tu pasaje tiene 30 versículos, yo intentaría hacer en promedio un resumen de contenido cada 3 versículos.';

  @override
  String get homileticDivisionsHelpText =>
      'Las divisiones son grupos de versículos relacionados entre sí. Debe haber al menos dos y no más de cuatro.';

  @override
  String get homileticSummaryHelpTitle => 'Frase resumen';

  @override
  String get homileticSummaryHelpText =>
      'La frase resumen es una declaración concisa y fácil de recordar que reúne los hechos más importantes. Una buena forma de pensarla es la prueba de las 2 de la mañana: si alguien te despertara a las 2 a. m. y te preguntara de qué trataba el sermón, ¿qué dirías? Dirías la frase resumen.\nDebe tener 10 palabras o menos. Si te sientes inspirado, puedes intentar hacer una aliteración.';

  @override
  String get homileticFcfHelpText =>
      'El FCF (Fallen Condition Focus, enfoque en la condición caída) es el aspecto de la humanidad que más se ilustra o se menciona en el pasaje. Es la condición en la que se encuentra la audiencia, la razón por la que necesita ser salva.';

  @override
  String get homileticAimHelpText =>
      'El objetivo es el punto clave, la verdad principal que quieres que tú o tu audiencia se lleven. Puede derivarse del FCF y probablemente influirá en las preguntas de aplicación.';

  @override
  String get homileticApplicationHelpTitle => 'Preguntas de aplicación';

  @override
  String get homileticApplicationHelpText =>
      'Son preguntas que ayudan a la audiencia a aplicar a su propia vida lo que acaba de escuchar. Deben ser específicas, personales, abiertas y que inviten a la reflexión.';

  @override
  String homileticSummaryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resúmenes',
      one: '1 resumen',
    );
    return '$_temp0';
  }

  @override
  String homileticDivisionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count divisiones',
      one: '1 división',
    );
    return '$_temp0';
  }

  @override
  String homileticQuestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count preguntas',
      one: '1 pregunta',
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
  String get lectureItemName => 'esta nota de conferencia';

  @override
  String get lectureDeleted => 'Nota de conferencia eliminada';

  @override
  String get lecturePassageHint => 'Pasaje';

  @override
  String get lectureHeaderLabel => 'Conferencia · Pasaje';

  @override
  String get lectureNotesPlaceholder => 'Notas';

  @override
  String get lectureToolbarBold => 'Negrita';

  @override
  String get lectureToolbarItalic => 'Cursiva';

  @override
  String get lectureToolbarBulletedList => 'Lista con viñetas';

  @override
  String get lectureToolbarNumberedList => 'Lista numerada';

  @override
  String get lectureReplaceTitle => '¿Reemplazar la grabación existente?';

  @override
  String get lectureReplaceMessage =>
      'Se eliminarán el audio y la transcripción anteriores.';

  @override
  String get lectureReplaceConfirm => 'Reemplazar';

  @override
  String get lectureMicPermissionRequired =>
      'Se necesita permiso para usar el micrófono para grabar.';

  @override
  String get lectureNotificationTitle => 'Grabando conferencia';

  @override
  String lectureNotificationContent(String appName) {
    return '$appName está grabando audio';
  }

  @override
  String get lectureStartFailed =>
      'No se pudo iniciar la grabación. Es posible que otra app esté usando el micrófono.';

  @override
  String get lectureTranscriptionModelTitle =>
      '¿Descargar el modelo de transcripción sin conexión?';

  @override
  String get lectureTranscriptionModelMessage =>
      'Una descarga única de ~140 MB permite que tus grabaciones se transcriban y se puedan buscar automáticamente. Puedes omitir este paso y descargarlo más tarde desde Ajustes.';

  @override
  String get lectureNotNow => 'Ahora no';

  @override
  String get lectureDownload => 'Descargar';

  @override
  String get lectureModelDownloadFailed =>
      'Algo salió mal al descargar el modelo. Puedes volver a intentarlo desde Ajustes.';

  @override
  String get lectureRecordingFileNotFound =>
      'No se encontró el archivo de la grabación.';

  @override
  String get lectureTranscriptionEmpty =>
      'La transcripción no produjo ningún texto.';

  @override
  String get lectureFormattingModelTitle =>
      '¿Descargar el modelo para dar formato a la transcripción?';

  @override
  String lectureFormattingModelMessage(String size) {
    return 'Una descarga única de $size permite ordenar las transcripciones en párrafos legibles, todo en tu dispositivo. Se recomienda usar Wi-Fi. También puedes hacerlo más tarde desde Ajustes.';
  }

  @override
  String get lectureFormattingModelMissing =>
      'El modelo de formato no está descargado.';

  @override
  String get lectureFormattingFailed =>
      'No se pudo dar formato a la transcripción.';

  @override
  String get lecturePlaybackFailed => 'No se pudo reproducir la grabación.';

  @override
  String lectureDownloadingModel(String percent) {
    return 'Descargando modelo $percent %';
  }

  @override
  String lectureTranscribingProgress(int percent) {
    return 'Transcribiendo $percent %';
  }

  @override
  String lectureFormattingProgress(int done, int total) {
    return 'Dando formato $done/$total';
  }

  @override
  String get lectureFormattingIndeterminate =>
      'Dando formato a la transcripción…';

  @override
  String lectureRecordingSemantics(String time) {
    return 'Grabando, $time';
  }

  @override
  String get lectureRecordingSubtitle =>
      'Grabando · sigue con la pantalla apagada';

  @override
  String get lectureStopRecording => 'Detener grabación';

  @override
  String get lectureRecordLecture => 'Grabar conferencia';

  @override
  String get lectureRecordIdleSubtitle =>
      'Sigue grabando con la pantalla apagada';

  @override
  String get lecturePause => 'Pausa';

  @override
  String get lecturePlayRecording => 'Reproducir grabación';

  @override
  String get lectureRecordAgain => 'Grabar de nuevo';

  @override
  String get lectureNotTranscribedYet => 'Aún sin transcribir';

  @override
  String get lectureTranscribe => 'Transcribir';

  @override
  String get lectureTimeMark => '+ Marca de tiempo';

  @override
  String get lectureTranscriptEmptyRecording =>
      'La conferencia se transcribe en este teléfono cuando detienes la grabación.';

  @override
  String get lectureTranscriptEmptyPending =>
      'La transcripción aparecerá aquí cuando esté lista.';

  @override
  String get lectureTranscriptEmptyNotTranscribed =>
      'Transcribe la grabación para leerla y buscar en ella aquí.';

  @override
  String get lectureTranscriptEmptyNoRecording =>
      'Graba la conferencia y se transcribirá en este teléfono cuando te detengas.';

  @override
  String get lectureTranscribing => 'Transcribiendo…';

  @override
  String get lectureNoTranscriptYet => 'Aún no hay transcripción';

  @override
  String get lectureFormatted => 'Con formato';

  @override
  String get lectureRaw => 'Original';

  @override
  String get lectureFormatTranscript => 'Dar formato';

  @override
  String get lectureTabMyNotes => 'Mis notas';

  @override
  String get lectureTabTranscript => 'Transcripción';

  @override
  String get modelTranscriptionTitle => 'Modelo de transcripción sin conexión';

  @override
  String modelTranscriptionEnglishNeeded(String language) {
    return 'Modelo en inglés, necesario para $language';
  }

  @override
  String modelTranscriptionEnglishNotNeeded(String language) {
    return 'Modelo en inglés, no necesario para $language';
  }

  @override
  String modelTranscriptionMultilingualNeeded(String language) {
    return 'Modelo multilingüe, necesario para $language';
  }

  @override
  String modelTranscriptionMultilingualNotNeeded(String language) {
    return 'Modelo multilingüe, no necesario para $language';
  }

  @override
  String get modelFormattingTitle => 'Modelo de formato de transcripciones';

  @override
  String get modelAppleIntelligenceStatus =>
      'Usando Apple Intelligence (no requiere descarga)';

  @override
  String get modelStatusChecking => 'Comprobando…';

  @override
  String modelStatusNotDownloaded(String size) {
    return 'No descargado ($size)';
  }

  @override
  String modelStatusDownloading(String percent) {
    return 'Descargando… $percent %';
  }

  @override
  String get modelStatusDownloaded => 'Descargado';

  @override
  String modelStatusDownloadedSize(String megabytes) {
    return 'Descargado ($megabytes MB)';
  }

  @override
  String get modelDownload => 'Descargar';

  @override
  String get modelDelete => 'Eliminar';

  @override
  String get modelDownloadFailed =>
      'Algo salió mal al descargar el modelo. Inténtalo de nuevo en un momento.';

  @override
  String get modelDeleteFailed => 'Algo salió mal al eliminar el modelo.';

  @override
  String get pdfOverlineHomiletics => 'HOMILÉTICA';

  @override
  String get pdfOverlineWordStudy => 'ESTUDIO DE PALABRA';

  @override
  String get pdfUntitledPassage => 'Pasaje sin título';

  @override
  String get pdfUntitledWord => 'Palabra sin título';

  @override
  String pdfHomileticLabel(String passage) {
    return 'Homilética · $passage';
  }

  @override
  String pdfWordStudyLabel(String word) {
    return 'Estudio de palabra · $word';
  }

  @override
  String pdfWordStudyLabelWithPassage(String word, String passage) {
    return 'Estudio de palabra · $word · $passage';
  }

  @override
  String pdfPageOf(int current, int total) {
    return 'página $current de $total';
  }

  @override
  String get pdfFcfCaption => 'Enfoque en la condición caída';

  @override
  String get pdfAimLeadIn => 'Que la audiencia aprenda que ';

  @override
  String get pdfEmptyHomiletic => 'Aún no se ha escrito nada para este pasaje.';

  @override
  String get pdfEmptyWordStudy =>
      'Aún no se ha escrito nada para este estudio de palabra.';

  @override
  String get pdfWordStudyDefinition => 'Definición';

  @override
  String get pdfWordStudyOtherUsage => 'Otros usos';

  @override
  String get pdfWordStudyContextualMeaning => 'Significado en contexto';

  @override
  String get pdfWordStudyDeeperMeaning => 'Significado profundo';

  @override
  String get pdfWordStudyApplication => 'Aplicación';

  @override
  String get editorSaveAndClose => 'Guardar y cerrar';

  @override
  String get editorDeleteConfirmTitle => '¿Estás seguro?';

  @override
  String editorDeleteConfirmMessage(String itemName) {
    return 'Eliminar $itemName es permanente y no se puede deshacer. ¿Seguro que quieres continuar?';
  }

  @override
  String get editorPassageLabel => 'Pasaje';

  @override
  String get editorAddPassageHint => 'Agrega un pasaje';

  @override
  String get editorBack => 'Atrás';

  @override
  String get editorMoreOptions => 'Más opciones';

  @override
  String get editorChangeTranslation => 'Cambiar traducción';

  @override
  String get editorStudyCompleteMessage =>
      'Imprímelo para la clase o compártelo con tu grupo.';

  @override
  String get wordStudyItemName => 'este estudio de palabra';

  @override
  String get wordStudyDeleted => 'Estudio de palabra eliminado';

  @override
  String get wordStudyHeaderLabel => 'Estudio de palabra · Pasaje';

  @override
  String get wordStudyPdfShared => 'PDF compartido correctamente.';

  @override
  String get wordStudyPdfShareFailed =>
      'Algo salió mal al compartir tu PDF. Inténtalo de nuevo en un momento.';

  @override
  String get wordStudyPdfPrinted => 'PDF impreso correctamente.';

  @override
  String get wordStudyPdfPrintFailed =>
      'Algo salió mal al crear tu PDF. Inténtalo de nuevo en un momento.';

  @override
  String get wordStudyWordTitle => 'Palabra';

  @override
  String get wordStudyWordHelp =>
      'La palabra o frase corta específica que estás estudiando. Cuando la escribas, Definición y Otros usos podrán sugerirte contenido.';

  @override
  String get wordStudyWordHint => 'Agrega una palabra';

  @override
  String get wordStudyEnterWordFirst => 'Primero escribe una palabra arriba.';

  @override
  String get wordStudyDefinitionTitle => 'Definición';

  @override
  String get wordStudyDefinitionHelp =>
      '¿Qué significa esta palabra, en términos sencillos? Toca \"+\" para ver posibles definiciones tomadas de un diccionario, o escribe la tuya.';

  @override
  String get wordStudyDefinitionHelpNoSuggest =>
      '¿Qué significa esta palabra, en términos sencillos? Escribe tu propia definición.';

  @override
  String get wordStudyDefinitionHint =>
      '¿Qué significa, en términos sencillos?';

  @override
  String get wordStudySuggestDefinition => 'Sugerir una definición';

  @override
  String wordStudyDefinitionsFor(String word) {
    return 'Definiciones de «$word»';
  }

  @override
  String get wordStudyDefinitionsTapToUse => 'Toca una para usarla.';

  @override
  String get wordStudyDefinitionsLoadError =>
      'No se pudieron cargar las definiciones. Inténtalo de nuevo en un momento.';

  @override
  String get wordStudyNoDefinitions =>
      'No se encontraron definiciones para esta palabra.';

  @override
  String get wordStudyReplaceDefinitionTitle => '¿Reemplazar tu definición?';

  @override
  String get wordStudyReplaceDefinitionMessage =>
      'Ya escribiste una definición. ¿Quieres reemplazarla con la sugerencia o agregar la sugerencia debajo?';

  @override
  String get wordStudyAddBelow => 'Agregar debajo';

  @override
  String get wordStudyReplace => 'Reemplazar';

  @override
  String get wordStudyOtherUsageTitle => 'Otros usos';

  @override
  String get wordStudyOtherUsageHelp =>
      '¿Dónde más aparece esta palabra o concepto en las Escrituras? Toca \"+\" para buscar en Bible Gateway y agregar las referencias que encuentres, o escribe las tuyas.';

  @override
  String get wordStudyOtherUsageHint => '¿Dónde más aparece en las Escrituras?';

  @override
  String get wordStudyFindOtherUsages => 'Buscar otros usos';

  @override
  String wordStudyOtherUsageSheetTitle(String word) {
    return 'Dónde más aparece «$word»';
  }

  @override
  String get wordStudyOtherUsageAdded => 'Agregadas';

  @override
  String get wordStudyOtherUsageInstructions =>
      'Toca un resultado para agregar su referencia.';

  @override
  String get wordStudyOtherUsageAddResult => '+ Agregar';

  @override
  String get wordStudyContextualMeaningTitle => 'Significado en contexto';

  @override
  String get wordStudyContextualMeaningHelp =>
      '¿Qué quiso decir el autor con esta palabra aquí, en este pasaje? Considera los versículos que la rodean, no solo la palabra aislada.';

  @override
  String get wordStudyContextualMeaningHint =>
      '¿Qué significa aquí, en este pasaje?';

  @override
  String get wordStudyDeeperMeaningTitle => 'Significado profundo';

  @override
  String get wordStudyDeeperMeaningHelp =>
      '¿Hay alguna idea del idioma original, de comentarios bíblicos o de otros estudios que profundice más allá de la definición básica? ¿Cómo la moldea el resto de las Escrituras? La concordancia Strong o Blue Letter Bible pueden ayudarte aquí.';

  @override
  String get wordStudyDeeperMeaningHint =>
      '¿Cómo la moldea el resto de las Escrituras?';

  @override
  String get wordStudyApplicationTitle => 'Aplicación';

  @override
  String get wordStudyApplicationHelp =>
      '¿Cómo debería esta verdad dar forma a tu vida? Sé específico, personal y práctico.';

  @override
  String get wordStudyApplicationHint => '¿Qué harás con esto?';

  @override
  String get wordStudyDoneTitle => 'Estudio de palabra listo';

  @override
  String wordStudySectionHelpSemantics(String title) {
    return '$title, acerca de esta sección';
  }

  @override
  String get lectureTimeMarkNoRecording =>
      'Esta nota no tiene una grabación para reproducir.';

  @override
  String get lectureTimeMarkStopRecordingFirst =>
      'Detén la grabación para reproducir desde una marca de tiempo.';

  @override
  String get lectureTimeMarkPastEnd =>
      'Esa marca de tiempo está después del final de la grabación.';

  @override
  String get onboardingSkip => 'Omitir';

  @override
  String get onboardingBack => 'Atrás';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingWelcomeOverline => 'Te damos la bienvenida';

  @override
  String get onboardingWelcomeTitle => 'Estudia la Biblia, un pasaje a la vez';

  @override
  String get onboardingWelcomeBody =>
      'Homiletics te ayuda a escribir tu homilética, tomar notas de la conferencia y hacer estudios de palabra, todo con el pasaje abierto a tu lado, en tu idioma y tu traducción de la Biblia.';

  @override
  String get onboardingMethodOverline => 'El método';

  @override
  String get onboardingMethodTitle => '¿Qué es una homilética?';

  @override
  String get onboardingMethodBody =>
      'Una homilética es una forma breve de estudiar un pasaje: encuentras su mensaje principal y luego piensas cómo vivirlo. Son seis pasos, y no tiene que quedar perfecta. Cada semana se hace más fácil.';

  @override
  String get onboardingStepsOverline => 'Paso a paso';

  @override
  String get onboardingStepsTitle => 'Los seis pasos';

  @override
  String get onboardingStepContent =>
      'Resume el pasaje en 10 a 20 partes breves, con tus propias palabras.';

  @override
  String get onboardingStepDivisions =>
      'Agrupa esas partes en 2 a 4 secciones.';

  @override
  String get onboardingStepSummary => 'Todo el pasaje en 10 palabras o menos.';

  @override
  String get onboardingStepFcf =>
      'Enfoque en la condición caída: la necesidad o el quebranto humano al que habla el pasaje.';

  @override
  String get onboardingStepAim =>
      'La verdad principal que quieres que aprendan tus oyentes.';

  @override
  String get onboardingStepApplication =>
      'Preguntas que llevan el pasaje a la vida diaria.';

  @override
  String get onboardingLecturesOverline => 'Conferencias y estudios de palabra';

  @override
  String get onboardingLecturesTitle => 'Escucha con atención, profundiza';

  @override
  String get onboardingLecturesBody =>
      'Graba la conferencia: sigue grabando con la pantalla apagada y se transcribe en tu propio teléfono. Toma notas mientras escuchas y añade marcas de tiempo para volver a un momento.';

  @override
  String get onboardingWordStudyBody =>
      '¿Te llama la atención una palabra? Comienza un estudio de palabra y profundiza en lo que significa en el pasaje.';

  @override
  String get onboardingStartOverline => 'Comienza';

  @override
  String get onboardingStartTitle => 'Ya puedes empezar';

  @override
  String get onboardingStartBody =>
      'Empieza con el pasaje de esta semana o explora primero. Cada paso que escribes se guarda al instante.';

  @override
  String get onboardingReopenHint =>
      'Puedes volver a abrir esta guía cuando quieras desde Ajustes.';

  @override
  String get onboardingStartThisWeek => 'Empezar la homilética de esta semana';

  @override
  String get onboardingExplore => 'Explorar por mi cuenta';

  @override
  String onboardingThisWeekPassage(String passage) {
    return 'Esta semana: $passage';
  }

  @override
  String get onboardingSettingsRow => 'Cómo funciona la homilética';

  @override
  String bibleOfflineSize(String size) {
    return 'Sin conexión · $size';
  }

  @override
  String bibleDownloadedSize(String size) {
    return 'Descargada · $size';
  }

  @override
  String get bibleDownloadAction => 'Descargar para usar sin conexión';

  @override
  String get bibleDownloading => 'Descargando…';

  @override
  String get bibleRemoveDownload => 'Eliminar descarga';

  @override
  String bibleDownloadFailed(String translation) {
    return 'No se pudo descargar $translation. Revisa tu conexión e inténtalo de nuevo.';
  }

  @override
  String get bibleOfflineTitle => 'Sin conexión';

  @override
  String bibleOfflineMessage(String translation) {
    return 'Este pasaje viene de Bible Gateway, que necesita internet. Descarga $translation para leerlo en cualquier lugar.';
  }

  @override
  String get bibleOfflineNoDownloadMessage =>
      'Este pasaje viene de Bible Gateway, que necesita internet. Conéctate e inténtalo de nuevo.';

  @override
  String get bibleTryAgain => 'Reintentar';

  @override
  String bibleNeedsDownloadTitle(String translation) {
    return 'Descargar $translation';
  }

  @override
  String bibleNeedsDownloadMessage(String size) {
    return 'Esta Biblia se lee desde tu dispositivo. Descárgala una vez (unos $size) para ver el pasaje.';
  }

  @override
  String bibleNotInTranslation(String translation) {
    return 'No se encontró este pasaje en $translation.';
  }

  @override
  String get bibleVerseTapTip =>
      'Consejo: toca el número de un versículo para empezar un resumen ahí.';

  @override
  String bibleVerseTapLabel(String verse) {
    return 'Empezar un resumen en el versículo $verse';
  }

  @override
  String get shareSheetTitle => 'Compartir este estudio';

  @override
  String get shareLink => 'Compartir enlace';

  @override
  String get shareLinkSubtitle => 'Se abre en la app o en cualquier navegador';

  @override
  String get shareCopyLink => 'Copiar enlace';

  @override
  String get shareLinkCopied => 'Enlace copiado';

  @override
  String get shareShowQr => 'Mostrar código QR';

  @override
  String get shareSharePdf => 'Compartir PDF';

  @override
  String get shareLinkFailed => 'No se pudo compartir el enlace.';

  @override
  String get shareLinkTooLongTitle => 'Este enlace es muy largo';

  @override
  String shareLinkTooLongMessage(int count) {
    return 'Este estudio genera un enlace de $count caracteres. Algunas apps podrían cortarlo y entonces no se abriría. Si pasa, comparte el PDF.';
  }

  @override
  String get shareAnyway => 'Compartir de todos modos';

  @override
  String get shareQrTitle => 'Escanea para abrir';

  @override
  String get shareQrHint =>
      'Apunta la cámara de otro teléfono al código para abrir este estudio.';

  @override
  String get shareQrTooLong =>
      'Este estudio es demasiado largo para un código QR. Usa Compartir enlace o Copiar enlace.';

  @override
  String get shareQrSemantics => 'Código QR con el enlace a este estudio';

  @override
  String get importFromLink => 'Importar desde enlace';

  @override
  String get importSheetMessage =>
      'Pega un enlace de Homiletics que alguien te compartió. Podrás revisarlo antes de guardar una copia.';

  @override
  String get importFieldHint => 'https://homiletics.app/view#…';

  @override
  String get importPaste => 'Pegar';

  @override
  String get importOpen => 'Abrir';

  @override
  String get importClipboardEmpty => 'No hay texto para pegar.';

  @override
  String get importInvalidLink =>
      'Esto no es un enlace de Homiletics o le falta una parte. Pide el enlace otra vez.';

  @override
  String get importNewerVersion =>
      'Este estudio se compartió desde una versión más nueva de Homiletics. Actualiza Homiletics para abrirlo.';

  @override
  String get importCouldNotOpenTitle => 'No se puede abrir este enlace';

  @override
  String get importPreviewHomiletic => 'Homilética compartida';

  @override
  String get importPreviewWordStudy => 'Estudio de palabra compartido';

  @override
  String get importPreviewNote =>
      'Alguien te compartió esto. Al guardarlo se añade una copia a tus estudios; no se cambia nada de lo que ya tienes.';

  @override
  String importPreviewTranslation(String translation) {
    return 'Escrito con $translation';
  }

  @override
  String get importSaveCopy => 'Guardar una copia';

  @override
  String get importSaved => 'Guardado en tus estudios';

  @override
  String get importSaveFailed =>
      'No se pudo guardar el estudio. Inténtalo de nuevo.';

  @override
  String get startOpenSharedStudy => 'Abrir estudio compartido';
}
