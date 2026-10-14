// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get prefsTitle => 'Preferências';

  @override
  String get prefsAppLanguage => 'Idioma preferido';

  @override
  String get prefsBibleVersion => 'Versão da Bíblia preferida';

  @override
  String get bibleNewTestamentOnly => 'Apenas o Novo Testamento';

  @override
  String get appTitle => 'Homiletics';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonOk => 'OK';

  @override
  String get commonDelete => 'Apagar';

  @override
  String get commonDone => 'Concluído';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonClose => 'Fechar';

  @override
  String get commonRetry => 'Tentar de novo';

  @override
  String get commonSomethingWentWrong =>
      'Ocorreu um erro. Tente de novo daqui a pouco.';

  @override
  String get languageSystemDefault => 'Idioma do dispositivo';

  @override
  String get stepContent => 'Conteúdo';

  @override
  String get stepDivisions => 'Divisões';

  @override
  String get stepSummary => 'Frase-resumo';

  @override
  String get stepFcf => 'FCF';

  @override
  String get stepAim => 'Objetivo';

  @override
  String get stepApplication => 'Aplicação';

  @override
  String get stepShortContent => 'Conteúdo';

  @override
  String get stepShortDivisions => 'Divisões';

  @override
  String get stepShortSummary => 'Resumo';

  @override
  String get stepShortFcf => 'FCF';

  @override
  String get stepShortAim => 'Objetivo';

  @override
  String get stepShortApplication => 'Aplicar';

  @override
  String get commonShare => 'Compartilhar';

  @override
  String get commonPrint => 'Imprimir';

  @override
  String get commonPreferences => 'Preferências';

  @override
  String get commonUntitled => 'Sem título';

  @override
  String get homeSearchIntro =>
      'Pesquise as suas homiléticas, divisões, aplicações, notas de palestras e estudos de palavras.';

  @override
  String get homeSearchFieldHint => 'Pesquisar lições, passagens, notas…';

  @override
  String get homeSearchTooltip => 'Pesquisar';

  @override
  String get homeCloseSearch => 'Fechar pesquisa';

  @override
  String get homeAllStudies => 'Todos os estudos';

  @override
  String get homeFilterByStudy => 'Filtrar por estudo';

  @override
  String get homeOpenStudySite => 'Abrir o site do estudo';

  @override
  String get homeThisWeek => 'Esta semana';

  @override
  String get homeEarlier => 'Anterior';

  @override
  String get homeComingUp => 'Em breve';

  @override
  String homeWeekOverline(String when, String lesson) {
    return '$when · $lesson';
  }

  @override
  String get homeStartHomiletics => 'Começar homilética';

  @override
  String get homeContinueHomiletics => 'Continuar homilética';

  @override
  String get homeOpenHomiletics => 'Abrir homilética';

  @override
  String get homeLoadingPassages => 'Carregamento das passagens sugeridas…';

  @override
  String get homeContinue => 'Continuar';

  @override
  String get homeSeeAll => 'Ver tudo';

  @override
  String get homeLivingItOut => 'Pôr em prática';

  @override
  String get homeKindTileHomiletic => 'H';

  @override
  String get homeKindTileWordStudy => 'P';

  @override
  String get homeProgressNoneDone => 'Nenhuma etapa concluída';

  @override
  String homeProgressDone(String steps) {
    return 'Concluídas: $steps';
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
  String get studiesTitle => 'Meus estudos';

  @override
  String get studiesTabHomiletics => 'Homiléticas';

  @override
  String get studiesTabLectures => 'Palestras';

  @override
  String get studiesTabWordStudies => 'Estudos de palavras';

  @override
  String get studiesNoHomiletics => 'Ainda não há homiléticas.';

  @override
  String get studiesNoLectureNotes => 'Ainda não há notas de palestras.';

  @override
  String get studiesNoWordStudies => 'Ainda não há estudos de palavras.';

  @override
  String get studiesNoApplications => 'Ainda não há perguntas de aplicação.';

  @override
  String get studiesProgressNotStarted => 'Não iniciada';

  @override
  String studiesProgressAll(int total) {
    return 'Todas as $total etapas';
  }

  @override
  String studiesProgressSome(int done, int total) {
    return '$done de $total etapas';
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
    return 'Palestra: $passage';
  }

  @override
  String get studiesLectureUntitled => 'Palestra';

  @override
  String studiesLectureSubtitle(String time) {
    return 'Notas de palestra · $time';
  }

  @override
  String get studiesWordStudyUntitled => 'Estudo de palavra';

  @override
  String studiesWordStudySubtitle(String time) {
    return 'Estudo de palavra · $time';
  }

  @override
  String studiesWordStudySubtitleWithPassage(String passage, String time) {
    return 'Estudo de palavra · $passage · $time';
  }

  @override
  String get searchHint => 'Pesquisar';

  @override
  String get searchSectionContentSummaries => 'Resumos do conteúdo';

  @override
  String get searchSectionDivisions => 'Divisões';

  @override
  String get searchSectionApplications => 'Aplicações';

  @override
  String get searchSectionAims => 'Objetivos';

  @override
  String get searchSectionSummarySentences => 'Frases-resumo';

  @override
  String get searchSectionPassages => 'Passagens das homiléticas';

  @override
  String get searchSectionLectureNotes => 'Notas de palestras';

  @override
  String get searchSectionWordStudies => 'Estudos de palavras';

  @override
  String get searchOpenFailed =>
      'Não foi possível abrir esse resultado. Talvez tenha sido apagado.';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsSectionLanguage => 'Idioma';

  @override
  String get settingsAppLanguage => 'Idioma da interface';

  @override
  String get settingsSectionReading => 'Leitura';

  @override
  String get settingsSectionModels => 'Modelos no dispositivo';

  @override
  String get settingsSectionHelp => 'Ajuda';

  @override
  String settingsCopyright(String year) {
    return 'Copyright (C) $year 13one.org · Todos os direitos reservados';
  }

  @override
  String get helpRequestFeedback => 'Pedir ajuda / deixar comentário';

  @override
  String helpCopyright(String year) {
    return 'Copyright (C) $year 13one.org';
  }

  @override
  String get helpAllRightsReserved => 'Todos os direitos reservados';

  @override
  String get feedbackTitle => 'Deixe o seu comentário';

  @override
  String get feedbackPublicNotice =>
      'O seu comentário é publicado como um tópico público (issue) no GitHub — qualquer pessoa na internet pode lê-lo. Não inclua senhas nem outras informações privadas. O seu e-mail fica parcialmente oculto no GitHub; podemos guardar o endereço completo nos nossos servidores apenas para dar seguimento.';

  @override
  String get feedbackTypeGeneral => 'Ajuda ou sugestão';

  @override
  String get feedbackTypeTranslation => 'Erro de tradução';

  @override
  String get feedbackTranslationHint =>
      'Diga-nos que palavras parecem erradas e o que deveriam dizer. Incluiremos o idioma da interface e a tradução da Bíblia que usa.';

  @override
  String get feedbackNameLabel => 'Nome';

  @override
  String get feedbackEmailLabel => 'E-mail (opcional)';

  @override
  String get feedbackContentLabel => 'Comentário';

  @override
  String get feedbackSubmit => 'Enviar';

  @override
  String get feedbackEmpty => 'Escreva primeiro o seu comentário.';

  @override
  String get feedbackSubmittedIssue =>
      'Enviado. Abra o tópico no GitHub a qualquer momento para acrescentar comentários (início de sessão opcional).';

  @override
  String get feedbackOpenIssue => 'Abrir';

  @override
  String get feedbackSubmitted => 'Comentário enviado com sucesso';

  @override
  String get feedbackBadRequest =>
      'Não foi possível enviar o pedido. Verifique a mensagem e tente de novo.';

  @override
  String get feedbackServerUnreachableTitle => 'O servidor não respondeu';

  @override
  String get feedbackServerUnreachableBody =>
      'Abra o GitHub no navegador para enviar este relatório. Talvez seja preciso iniciar sessão lá para enviar o tópico.';

  @override
  String get feedbackNotNow => 'Agora não';

  @override
  String get feedbackOpenGitHub => 'Abrir o GitHub';

  @override
  String get feedbackBrowserFailed => 'Não foi possível abrir o navegador.';

  @override
  String get startHomiletics => 'Homilética';

  @override
  String get startLecture => 'Palestra';

  @override
  String get startWordStudy => 'Estudo de palavra';

  @override
  String get startPassageHint => 'Estudar outra passagem…';

  @override
  String get startClear => 'Limpar';

  @override
  String get startOtherStudy => 'Outro estudo';

  @override
  String get startMenuLectureNote => 'Notas de palestra';

  @override
  String get startMenuWordStudy => 'Estudo de palavra';

  @override
  String get startDuplicateHomileticTitle =>
      'Já tem uma homilética para esta passagem?';

  @override
  String startDuplicateHomileticMany(String passage, int count) {
    return '$passage\n\nHá $count homiléticas para esta passagem; será aberta a mais recente.';
  }

  @override
  String get startDuplicateLectureTitle =>
      'Já tem notas de palestra para esta passagem?';

  @override
  String startDuplicateLectureMany(String passage, int count) {
    return '$passage\n\nHá $count notas de palestra para esta passagem; será aberta a mais recente.';
  }

  @override
  String get startDuplicateWordStudyTitle =>
      'Já tem um estudo de palavra para esta passagem?';

  @override
  String startDuplicateWordStudyMany(String passage, int count) {
    return '$passage\n\nHá $count estudos de palavra para esta passagem; será aberto o mais recente.';
  }

  @override
  String get startCreateNew => 'Criar novo';

  @override
  String get startEditExisting => 'Editar existente';

  @override
  String get homileticHeaderLabel => 'Homilética · Passagem';

  @override
  String get homileticItemName => 'Lição de homilética';

  @override
  String get homileticDeletedMessage => 'Homilética apagada';

  @override
  String get homileticLoadError => 'Ocorreu um erro ao carregar esta lição.';

  @override
  String get homileticPdfShared => 'PDF compartilhado com sucesso.';

  @override
  String get homileticPdfShareFailed =>
      'Ocorreu um erro ao compartilhar o PDF. Tente de novo daqui a pouco.';

  @override
  String get homileticPdfPrinted => 'PDF impresso com sucesso.';

  @override
  String get homileticPdfPrintFailed =>
      'Ocorreu um erro ao criar o PDF. Tente de novo daqui a pouco.';

  @override
  String get homileticCompleteTitle => 'Seis etapas concluídas';

  @override
  String get homileticCompleteMessage =>
      'Imprima para a aula ou compartilhe com o seu grupo.';

  @override
  String get homileticContentEmptySummary => 'Versículos + resumo';

  @override
  String get homileticDivisionsEmptySummary => '2–4 grupos';

  @override
  String get homileticSummaryEmptySummary => '≤ 10 palavras';

  @override
  String get homileticFcfEmptySummary => 'Foco na condição caída';

  @override
  String get homileticAimEmptySummary => 'A lição principal';

  @override
  String get homileticApplicationEmptySummary => 'Como posso…';

  @override
  String get homileticStepStatusDone => 'concluída';

  @override
  String get homileticStepStatusToDo => 'pendente';

  @override
  String homileticStepCollapseLabel(String title) {
    return '$title, recolher';
  }

  @override
  String homileticStepHelpLabel(String title) {
    return 'Sobre $title';
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
  String get homileticRemoveRowMessage => 'O que escreveu aqui será apagado.';

  @override
  String get homileticRemoveRowConfirm => 'Remover';

  @override
  String get homileticContentSummaryHint => 'Resumo…';

  @override
  String get homileticAddContentSummary => 'Adicionar resumo';

  @override
  String get homileticRemoveContentSummaryTooltip =>
      'Remover resumo do conteúdo';

  @override
  String get homileticRemoveContentSummaryTitle =>
      'Remover este resumo do conteúdo?';

  @override
  String get homileticRemoveContentSummaryFailed =>
      'Não foi possível remover esse resumo do conteúdo';

  @override
  String get homileticDivisionHint => 'Frase da divisão…';

  @override
  String get homileticAddDivision => 'Adicionar divisão';

  @override
  String get homileticRemoveDivisionTooltip => 'Remover divisão';

  @override
  String get homileticRemoveDivisionTitle => 'Remover esta divisão?';

  @override
  String get homileticRemoveDivisionFailed =>
      'Não foi possível remover essa divisão';

  @override
  String get homileticApplicationHint => 'Como posso…';

  @override
  String get homileticAddApplication => 'Adicionar pergunta';

  @override
  String get homileticRemoveApplicationTooltip =>
      'Remover pergunta de aplicação';

  @override
  String get homileticRemoveApplicationTitle =>
      'Remover esta pergunta de aplicação?';

  @override
  String get homileticRemoveApplicationFailed =>
      'Não foi possível remover essa pergunta de aplicação';

  @override
  String get homileticSummaryHint => 'Resuma em 10 palavras ou menos';

  @override
  String get homileticFcfHint => 'Caído/Frágil/Fraco/Falho';

  @override
  String get homileticAimHint => 'Levar os ouvintes a compreender que…';

  @override
  String get homileticContentHelpTitle => 'Resumos do conteúdo';

  @override
  String get homileticContentHelpText =>
      'Um resumo do conteúdo é um resumo de um trecho da Bíblia. Não precisa de ser uma frase completa e também pode ter mais de uma frase. Deve ser um resumo, com as suas próprias palavras, do conteúdo da passagem.\nDeve ter pelo menos 10 e no máximo 20 resumos do conteúdo. Em geral, conforme o tamanho da passagem, divida-a em trechos de tamanho aproximado para chegar aos 10 a 20 resumos. Por exemplo, se a passagem tiver 30 versículos, eu procuraria fazer, em média, um resumo a cada 3 versículos.';

  @override
  String get homileticDivisionsHelpText =>
      'As divisões são agrupamentos de versículos relacionados entre si. Deve haver no mínimo duas e no máximo quatro.';

  @override
  String get homileticSummaryHelpTitle => 'Frase-resumo';

  @override
  String get homileticSummaryHelpText =>
      'A Frase-resumo é uma afirmação concisa e fácil de lembrar que reúne os pontos mais relevantes. Uma boa forma de pensar nela é o teste das 2 da manhã: se fosse acordado às 2 da manhã e lhe perguntassem de que tratava o sermão, o que responderia? Responderia com a Frase-resumo.\nDeve ter 10 palavras ou menos. Se estiver inspirado, tente fazer uma aliteração.';

  @override
  String get homileticFcfHelpText =>
      'O FCF (Foco na Condição Caída) é a parte da condição humana mais ilustrado ou mencionado na passagem. É a condição em que os ouvintes se encontram, a razão pela qual precisam de salvação.';

  @override
  String get homileticAimHelpText =>
      'O Objetivo é o ponto-chave: a verdade principal que se deseja que a própria pessoa ou os ouvintes levem consigo. Pode decorrer do FCF e provavelmente influenciará as Perguntas de aplicação.';

  @override
  String get homileticApplicationHelpTitle => 'Perguntas de aplicação';

  @override
  String get homileticApplicationHelpText =>
      'São perguntas que ajudam os ouvintes a aplicar à própria vida o que acabaram de ouvir. Devem ser específicas, pessoais, abertas e levar à reflexão.';

  @override
  String homileticSummaryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resumos',
      one: '1 resumo',
    );
    return '$_temp0';
  }

  @override
  String homileticDivisionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count divisões',
      one: '1 divisão',
    );
    return '$_temp0';
  }

  @override
  String homileticQuestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count perguntas',
      one: '1 pergunta',
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
  String get lectureItemName => 'Nota de palestra';

  @override
  String get lectureDeleted => 'Nota de palestra apagada';

  @override
  String get lecturePassageHint => 'Passagem';

  @override
  String get lectureHeaderLabel => 'Palestra · Passagem';

  @override
  String get lectureNotesPlaceholder => 'Notas';

  @override
  String get lectureToolbarBold => 'Negrito';

  @override
  String get lectureToolbarItalic => 'Itálico';

  @override
  String get lectureToolbarBulletedList => 'Lista com marcadores';

  @override
  String get lectureToolbarNumberedList => 'Lista numerada';

  @override
  String get lectureReplaceTitle => 'Substituir a gravação existente?';

  @override
  String get lectureReplaceMessage =>
      'O áudio e a transcrição antigos serão apagados.';

  @override
  String get lectureReplaceConfirm => 'Substituir';

  @override
  String get lectureMicPermissionRequired =>
      'É necessária permissão de acesso ao microfone para gravar.';

  @override
  String get lectureNotificationTitle => 'Gravação da palestra';

  @override
  String lectureNotificationContent(String appName) {
    return '$appName: gravação de áudio em curso';
  }

  @override
  String get lectureStartFailed =>
      'Não foi possível iniciar a gravação. O microfone pode estar ocupado por outra aplicação.';

  @override
  String get lectureTranscriptionModelTitle =>
      'Fazer o download do modelo de transcrição offline?';

  @override
  String get lectureTranscriptionModelMessage =>
      'Um download único de ~140MB permite que as suas gravações sejam transcritas automaticamente e possam ser pesquisadas. Pode ignorar isto e fazer o download mais tarde nas Configurações.';

  @override
  String get lectureNotNow => 'Agora não';

  @override
  String get lectureDownload => 'Download';

  @override
  String get lectureModelDownloadFailed =>
      'Ocorreu um erro no download do modelo. Pode tentar de novo nas Configurações.';

  @override
  String get lectureRecordingFileNotFound =>
      'Não foi possível encontrar a gravação.';

  @override
  String get lectureTranscriptionEmpty =>
      'A transcrição não produziu nenhum texto.';

  @override
  String get lectureFormattingModelTitle =>
      'Fazer o download do modelo de formatação de transcrições?';

  @override
  String lectureFormattingModelMessage(String size) {
    return 'Um download único de $size permite organizar as transcrições em parágrafos legíveis, inteiramente no seu dispositivo. Recomenda-se Wi-Fi. Também pode fazer isto mais tarde nas Configurações.';
  }

  @override
  String get lectureFormattingModelMissing =>
      'O modelo de formatação não está instalado.';

  @override
  String get lectureFormattingFailed =>
      'Não foi possível formatar a transcrição.';

  @override
  String get lecturePlaybackFailed => 'Não foi possível reproduzir a gravação.';

  @override
  String lectureDownloadingModel(String percent) {
    return 'Download do modelo: $percent%';
  }

  @override
  String lectureTranscribingProgress(int percent) {
    return 'Transcrição: $percent%';
  }

  @override
  String lectureFormattingProgress(int done, int total) {
    return 'Formatação do texto $done/$total';
  }

  @override
  String get lectureFormattingIndeterminate => 'Formatação da transcrição…';

  @override
  String lectureRecordingSemantics(String time) {
    return 'Gravação, $time';
  }

  @override
  String get lectureRecordingSubtitle =>
      'Gravação · continua com o aparelho bloqueado';

  @override
  String get lectureStopRecording => 'Parar gravação';

  @override
  String get lectureRecordLecture => 'Gravar palestra';

  @override
  String get lectureRecordIdleSubtitle =>
      'Grava mesmo com o aparelho bloqueado';

  @override
  String get lecturePause => 'Pausar';

  @override
  String get lecturePlayRecording => 'Reproduzir gravação';

  @override
  String get lectureRecordAgain => 'Gravar de novo';

  @override
  String get lectureNotTranscribedYet => 'Ainda não transcrita';

  @override
  String get lectureTranscribe => 'Transcrever';

  @override
  String get lectureTimeMark => '+ Marcar tempo';

  @override
  String get lectureTranscriptEmptyRecording =>
      'A palestra é transcrita neste aparelho quando terminar a gravação.';

  @override
  String get lectureTranscriptEmptyPending =>
      'A transcrição aparecerá aqui quando estiver pronta.';

  @override
  String get lectureTranscriptEmptyNotTranscribed =>
      'Transcreva a gravação para lê-la e pesquisá-la aqui.';

  @override
  String get lectureTranscriptEmptyNoRecording =>
      'Grave a palestra; ela será transcrita neste aparelho quando terminar a gravação.';

  @override
  String get lectureTranscribing => 'Transcrição em curso…';

  @override
  String get lectureNoTranscriptYet => 'Ainda sem transcrição';

  @override
  String get lectureFormatted => 'Formatada';

  @override
  String get lectureRaw => 'Original';

  @override
  String get lectureFormatTranscript => 'Formatar transcrição';

  @override
  String get lectureTabMyNotes => 'Minhas notas';

  @override
  String get lectureTabTranscript => 'Transcrição';

  @override
  String get modelTranscriptionTitle => 'Modelo de transcrição offline';

  @override
  String modelTranscriptionEnglishNeeded(String language) {
    return 'Modelo em inglês, necessário para $language';
  }

  @override
  String modelTranscriptionEnglishNotNeeded(String language) {
    return 'Modelo em inglês, não necessário para $language';
  }

  @override
  String modelTranscriptionMultilingualNeeded(String language) {
    return 'Modelo para vários idiomas, necessário para $language';
  }

  @override
  String modelTranscriptionMultilingualNotNeeded(String language) {
    return 'Modelo para vários idiomas, não necessário para $language';
  }

  @override
  String get modelFormattingTitle => 'Modelo de formatação de transcrições';

  @override
  String get modelAppleIntelligenceStatus =>
      'Com Apple Intelligence (sem download)';

  @override
  String get modelStatusChecking => 'Em verificação…';

  @override
  String modelStatusNotDownloaded(String size) {
    return 'Não instalado ($size)';
  }

  @override
  String modelStatusDownloading(String percent) {
    return 'Download em curso… $percent%';
  }

  @override
  String get modelStatusDownloaded => 'Instalado';

  @override
  String modelStatusDownloadedSize(String megabytes) {
    return 'Instalado (${megabytes}MB)';
  }

  @override
  String get modelDownload => 'Download';

  @override
  String get modelDelete => 'Apagar';

  @override
  String get modelDownloadFailed =>
      'Ocorreu um erro no download do modelo. Tente de novo daqui a pouco.';

  @override
  String get modelDeleteFailed => 'Ocorreu um erro ao apagar o modelo.';

  @override
  String get pdfOverlineHomiletics => 'HOMILÉTICA';

  @override
  String get pdfOverlineWordStudy => 'ESTUDO DE PALAVRA';

  @override
  String get pdfUntitledPassage => 'Passagem sem título';

  @override
  String get pdfUntitledWord => 'Palavra sem título';

  @override
  String pdfHomileticLabel(String passage) {
    return 'Homilética · $passage';
  }

  @override
  String pdfWordStudyLabel(String word) {
    return 'Estudo de palavra · $word';
  }

  @override
  String pdfWordStudyLabelWithPassage(String word, String passage) {
    return 'Estudo de palavra · $word · $passage';
  }

  @override
  String pdfPageOf(int current, int total) {
    return 'página $current de $total';
  }

  @override
  String get pdfFcfCaption => 'Foco na Condição Caída';

  @override
  String get pdfAimLeadIn => 'Levar os ouvintes a compreender que ';

  @override
  String get pdfEmptyHomiletic =>
      'Ainda não há nada escrito para esta passagem.';

  @override
  String get pdfEmptyWordStudy =>
      'Ainda não há nada escrito para este estudo de palavra.';

  @override
  String get pdfWordStudyDefinition => 'Definição';

  @override
  String get pdfWordStudyOtherUsage => 'Outros usos';

  @override
  String get pdfWordStudyContextualMeaning => 'Significado no contexto';

  @override
  String get pdfWordStudyDeeperMeaning => 'Significado mais profundo';

  @override
  String get pdfWordStudyApplication => 'Aplicação';

  @override
  String get editorSaveAndClose => 'Guardar e fechar';

  @override
  String get editorDeleteConfirmTitle => 'Deseja mesmo apagar?';

  @override
  String editorDeleteConfirmMessage(String itemName) {
    return 'Este item ($itemName) será apagado permanentemente, e isso não pode ser desfeito. Deseja mesmo continuar?';
  }

  @override
  String get editorPassageLabel => 'Passagem';

  @override
  String get editorAddPassageHint => 'Adicionar uma passagem';

  @override
  String get editorBack => 'Voltar';

  @override
  String get editorMoreOptions => 'Mais opções';

  @override
  String get editorChangeTranslation => 'Mudar tradução';

  @override
  String get editorStudyCompleteMessage =>
      'Imprima para a aula ou compartilhe com o seu grupo.';

  @override
  String get wordStudyItemName => 'Estudo de palavra';

  @override
  String get wordStudyDeleted => 'Estudo de palavra apagado';

  @override
  String get wordStudyHeaderLabel => 'Estudo de palavra · Passagem';

  @override
  String get wordStudyPdfShared => 'PDF compartilhado com sucesso.';

  @override
  String get wordStudyPdfShareFailed =>
      'Ocorreu um erro ao compartilhar o PDF. Tente de novo daqui a pouco.';

  @override
  String get wordStudyPdfPrinted => 'PDF impresso com sucesso.';

  @override
  String get wordStudyPdfPrintFailed =>
      'Ocorreu um erro ao criar o PDF. Tente de novo daqui a pouco.';

  @override
  String get wordStudyWordTitle => 'Palavra';

  @override
  String get wordStudyWordHelp =>
      'A palavra ou expressão curta específica que vai estudar. Depois de escrevê-la, as partes Definição e Outros usos podem sugerir conteúdo.';

  @override
  String get wordStudyWordHint => 'Adicionar uma palavra';

  @override
  String get wordStudyEnterWordFirst => 'Escreva primeiro uma palavra acima.';

  @override
  String get wordStudyDefinitionTitle => 'Definição';

  @override
  String get wordStudyDefinitionHelp =>
      'O que significa esta palavra, em termos simples? Toque em \"+\" para ver definições sugeridas de um dicionário, ou escreva a sua.';

  @override
  String get wordStudyDefinitionHelpNoSuggest =>
      'O que significa esta palavra, em termos simples? Escreva a sua definição.';

  @override
  String get wordStudyDefinitionHint => 'O que significa, em termos simples?';

  @override
  String get wordStudySuggestDefinition => 'Sugerir uma definição';

  @override
  String wordStudyDefinitionsFor(String word) {
    return 'Definições de “$word”';
  }

  @override
  String get wordStudyDefinitionsTapToUse => 'Escolha uma para usá-la.';

  @override
  String get wordStudyDefinitionsLoadError =>
      'Não foi possível carregar as definições. Tente de novo daqui a pouco.';

  @override
  String get wordStudyNoDefinitions =>
      'Nenhuma definição encontrada para esta palavra.';

  @override
  String get wordStudyReplaceDefinitionTitle => 'Substituir a sua definição?';

  @override
  String get wordStudyReplaceDefinitionMessage =>
      'Já escreveu uma definição. Deseja substituí-la pela sugestão ou adicionar a sugestão abaixo dela?';

  @override
  String get wordStudyAddBelow => 'Adicionar abaixo';

  @override
  String get wordStudyReplace => 'Substituir';

  @override
  String get wordStudyOtherUsageTitle => 'Outros usos';

  @override
  String get wordStudyOtherUsageHelp =>
      'Onde mais esta palavra ou conceito aparece nas Escrituras? Toque em \"+\" para pesquisar no Bible Gateway e adicionar as referências que encontrar, ou escreva as suas.';

  @override
  String get wordStudyOtherUsageHint => 'Onde mais aparece nas Escrituras?';

  @override
  String get wordStudyFindOtherUsages => 'Encontrar outros usos';

  @override
  String wordStudyOtherUsageSheetTitle(String word) {
    return 'Onde mais aparece “$word”';
  }

  @override
  String get wordStudyOtherUsageAdded => 'Adicionadas';

  @override
  String get wordStudyOtherUsageInstructions =>
      'Escolha um resultado abaixo para adicionar a referência.';

  @override
  String get wordStudyOtherUsageAddResult => '+ Adicionar';

  @override
  String get wordStudyContextualMeaningTitle => 'Significado no contexto';

  @override
  String get wordStudyContextualMeaningHelp =>
      'O que o autor quis dizer com esta palavra aqui, nesta passagem? Considere os versículos ao redor, e não apenas a palavra isolada.';

  @override
  String get wordStudyContextualMeaningHint =>
      'O que significa aqui, nesta passagem?';

  @override
  String get wordStudyDeeperMeaningTitle => 'Significado mais profundo';

  @override
  String get wordStudyDeeperMeaningHelp =>
      'Há alguma ideia da língua original, de comentários bíblicos ou de outros estudos que dê mais profundidade além da definição básica? Como o resto das Escrituras molda o seu sentido? Uma concordância de Strong ou o Blue Letter Bible podem ajudar aqui.';

  @override
  String get wordStudyDeeperMeaningHint =>
      'Como o resto das Escrituras molda o seu sentido?';

  @override
  String get wordStudyApplicationTitle => 'Aplicação';

  @override
  String get wordStudyApplicationHelp =>
      'Como esta verdade deve moldar a sua vida? Seja específico, pessoal e prático.';

  @override
  String get wordStudyApplicationHint => 'O que vai fazer com isso?';

  @override
  String get wordStudyDoneTitle => 'Estudo de palavra concluído';

  @override
  String wordStudySectionHelpSemantics(String title) {
    return '$title, sobre esta parte';
  }

  @override
  String get lectureTimeMarkNoRecording =>
      'Esta anotação não tem gravação para reproduzir.';

  @override
  String get lectureTimeMarkStopRecordingFirst =>
      'Pare a gravação para reproduzir a partir de uma marca de tempo.';

  @override
  String get lectureTimeMarkPastEnd =>
      'Essa marca de tempo está depois do fim da gravação.';

  @override
  String get onboardingSkip => 'Pular';

  @override
  String get onboardingBack => 'Voltar';

  @override
  String get onboardingNext => 'Avançar';

  @override
  String get onboardingWelcomeOverline => 'Boas-vindas';

  @override
  String get onboardingWelcomeTitle =>
      'Estude a Bíblia, uma passagem de cada vez';

  @override
  String get onboardingWelcomeBody =>
      'O Homiletics ajuda a fazer a sua homilética, tomar notas da palestra e fazer estudos de palavra — sempre com a passagem aberta ao lado, no seu idioma e na sua tradução da Bíblia.';

  @override
  String get onboardingMethodOverline => 'O método';

  @override
  String get onboardingMethodTitle => 'O que é uma homilética?';

  @override
  String get onboardingMethodBody =>
      'A homilética é uma forma breve de estudar uma passagem: encontrar a mensagem principal e depois pensar em como vivê-la. São seis passos — e não precisa ficar perfeita. Fica mais fácil a cada semana.';

  @override
  String get onboardingStepsOverline => 'Passo a passo';

  @override
  String get onboardingStepsTitle => 'Os seis passos';

  @override
  String get onboardingStepContent =>
      'Resuma a passagem em 10 a 20 trechos curtos, com as suas próprias palavras.';

  @override
  String get onboardingStepDivisions => 'Agrupe esses trechos em 2 a 4 seções.';

  @override
  String get onboardingStepSummary =>
      'A passagem inteira em 10 palavras ou menos.';

  @override
  String get onboardingStepFcf =>
      'Foco na Condição Caída: a necessidade ou quebrantamento humano que a passagem aborda.';

  @override
  String get onboardingStepAim =>
      'A principal verdade que deseja que os ouvintes aprendam.';

  @override
  String get onboardingStepApplication =>
      'Perguntas que levam a passagem para a vida diária.';

  @override
  String get onboardingLecturesOverline => 'Palestras e estudos de palavra';

  @override
  String get onboardingLecturesTitle => 'Ouça com atenção, aprofunde-se';

  @override
  String get onboardingLecturesBody =>
      'Grave a palestra — a gravação continua mesmo com o aparelho bloqueado e a transcrição é feita no próprio aparelho. Tome notas enquanto ouve e adicione marcas de tempo para encontrar um momento depois.';

  @override
  String get onboardingWordStudyBody =>
      'Uma palavra chamou a atenção? Comece um estudo de palavra e aprofunde o que ela significa na passagem.';

  @override
  String get onboardingStartOverline => 'Comece';

  @override
  String get onboardingStartTitle => 'Tudo pronto para começar';

  @override
  String get onboardingStartBody =>
      'Comece pela passagem desta semana ou explore primeiro. Cada passo que escrever é guardado automaticamente.';

  @override
  String get onboardingReopenHint =>
      'Pode abrir este guia novamente a qualquer momento em Configurações.';

  @override
  String get onboardingStartThisWeek => 'Começar a homilética desta semana';

  @override
  String get onboardingExplore => 'Explorar por conta própria';

  @override
  String onboardingThisWeekPassage(String passage) {
    return 'Esta semana: $passage';
  }

  @override
  String get onboardingSettingsRow => 'Como funciona a homilética';

  @override
  String bibleOfflineSize(String size) {
    return 'Off-line · $size';
  }

  @override
  String bibleDownloadedSize(String size) {
    return 'Baixada · $size';
  }

  @override
  String get bibleDownloadAction => 'Baixar para usar off-line';

  @override
  String get bibleDownloading => 'Baixando…';

  @override
  String get bibleRemoveDownload => 'Remover download';

  @override
  String bibleDownloadFailed(String translation) {
    return 'Não foi possível baixar $translation. Verifique sua conexão e tente de novo.';
  }

  @override
  String get bibleOfflineTitle => 'Sem conexão';

  @override
  String bibleOfflineMessage(String translation) {
    return 'Esta passagem vem do Bible Gateway, que precisa de internet. Baixe $translation para ler em qualquer lugar.';
  }

  @override
  String get bibleOfflineNoDownloadMessage =>
      'Esta passagem vem do Bible Gateway, que precisa de internet. Conecte-se e tente de novo.';

  @override
  String get bibleTryAgain => 'Tentar de novo';

  @override
  String bibleNeedsDownloadTitle(String translation) {
    return 'Baixar $translation';
  }

  @override
  String bibleNeedsDownloadMessage(String size) {
    return 'Esta Bíblia é lida do seu aparelho. Baixe-a uma vez (cerca de $size) para ver a passagem.';
  }

  @override
  String bibleNotInTranslation(String translation) {
    return 'Não foi possível encontrar esta passagem em $translation.';
  }

  @override
  String get bibleVerseTapTip =>
      'Dica: toque no número de um versículo para começar um resumo ali.';

  @override
  String bibleVerseTapLabel(String verse) {
    return 'Começar um resumo no versículo $verse';
  }

  @override
  String get shareSheetTitle => 'Compartilhar este estudo';

  @override
  String get shareLink => 'Compartilhar link';

  @override
  String get shareLinkSubtitle => 'Abre no app ou em qualquer navegador';

  @override
  String get shareCopyLink => 'Copiar link';

  @override
  String get shareLinkCopied => 'Link copiado';

  @override
  String get shareShowQr => 'Mostrar código QR';

  @override
  String get shareSharePdf => 'Compartilhar PDF';

  @override
  String get shareLinkFailed => 'Não foi possível compartilhar o link.';

  @override
  String get shareLinkTooLongTitle => 'Este link é muito longo';

  @override
  String shareLinkTooLongMessage(int count) {
    return 'Este estudo gera um link de $count caracteres. Alguns apps podem cortá-lo, e ele pode não abrir. Se isso acontecer, compartilhe o PDF.';
  }

  @override
  String get shareAnyway => 'Compartilhar mesmo assim';

  @override
  String get shareQrTitle => 'Escaneie para abrir';

  @override
  String get shareQrHint =>
      'Aponte a câmera de outro celular para o código para abrir este estudo.';

  @override
  String get shareQrTooLong =>
      'Este estudo é longo demais para um código QR. Use Compartilhar link ou Copiar link.';

  @override
  String get shareQrSemantics => 'Código QR com o link para este estudo';

  @override
  String get importFromLink => 'Importar de um link';

  @override
  String get importSheetMessage =>
      'Cole um link do Homiletics que alguém compartilhou com você. Você poderá revisá-lo antes de salvar uma cópia.';

  @override
  String get importFieldHint => 'https://homiletics.app/view#…';

  @override
  String get importPaste => 'Colar';

  @override
  String get importOpen => 'Abrir';

  @override
  String get importClipboardEmpty => 'Não há texto para colar.';

  @override
  String get importInvalidLink =>
      'Isto não é um link do Homiletics, ou está faltando uma parte. Peça o link novamente.';

  @override
  String get importNewerVersion =>
      'Este estudo foi compartilhado de uma versão mais nova do Homiletics. Atualize o Homiletics para abri-lo.';

  @override
  String get importCouldNotOpenTitle => 'Não é possível abrir este link';

  @override
  String get importPreviewHomiletic => 'Homilética compartilhada';

  @override
  String get importPreviewWordStudy => 'Estudo de palavra compartilhado';

  @override
  String get importPreviewNote =>
      'Alguém compartilhou isto com você. Salvar adiciona uma cópia aos seus estudos; nada do que você já tem é alterado.';

  @override
  String importPreviewTranslation(String translation) {
    return 'Escrito com $translation';
  }

  @override
  String get importSaveCopy => 'Salvar uma cópia';

  @override
  String get importSaved => 'Salvo nos seus estudos';

  @override
  String get importSaveFailed =>
      'Não foi possível salvar o estudo. Tente novamente.';

  @override
  String get startOpenSharedStudy => 'Abrir estudo compartilhado';

  @override
  String bibleWebUnavailableTitle(String translation) {
    return 'Leia $translation no navegador';
  }

  @override
  String get bibleWebUnavailableMessage =>
      'No Windows, o aplicativo não consegue mostrar passagens do Bible Gateway. Abra esta passagem no navegador ou mude para uma tradução lida a partir do seu dispositivo.';

  @override
  String get bibleOpenInBrowser => 'Abrir no navegador';

  @override
  String bibleUseOfflineTranslation(String translation) {
    return 'Usar uma tradução offline ($translation)';
  }

  @override
  String get wordStudyOtherUsageOpenedInBrowser =>
      'Os resultados foram abertos no navegador. Digite ou cole aqui as referências que deseja guardar.';

  @override
  String get settingsCheckForUpdates => 'Procurar atualizações';

  @override
  String settingsVersion(String version) {
    return 'Versão $version';
  }

  @override
  String updateAvailableTitle(String version) {
    return 'Homiletics $version está disponível';
  }

  @override
  String updateAvailableMessage(String current) {
    return 'Versão instalada: $current. Novidades:';
  }

  @override
  String get updateNow => 'Atualizar agora';

  @override
  String get updateDownload => 'Download';

  @override
  String get updateLater => 'Mais tarde';

  @override
  String get updateSkipVersion => 'Ignorar esta versão';

  @override
  String get updateDownloading => 'A transferir a atualização…';

  @override
  String get updateInstalling =>
      'A instalar. O Homiletics vai reabrir dentro de momentos.';

  @override
  String get updateFailed =>
      'Não foi possível transferir a atualização. Tente novamente ou faça o download em homiletics.app.';

  @override
  String get updateTryAgain => 'Tentar novamente';

  @override
  String get updatePortableNote =>
      'Esta cópia não foi instalada com o instalador; faça o download da nova versão em homiletics.app.';

  @override
  String updateUpToDate(String version) {
    return 'Já tem a versão mais recente (Homiletics $version).';
  }

  @override
  String get updateCheckFailed =>
      'Não foi possível procurar atualizações. Verifique a ligação à internet e tente novamente.';
}
