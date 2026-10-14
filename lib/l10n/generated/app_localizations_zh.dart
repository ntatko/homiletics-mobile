// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get prefsTitle => '偏好设置';

  @override
  String get prefsAppLanguage => '首选语言';

  @override
  String get prefsBibleVersion => '首选圣经译本';

  @override
  String get bibleNewTestamentOnly => '仅含新约';

  @override
  String get appTitle => 'Homiletics';

  @override
  String get commonCancel => '取消';

  @override
  String get commonOk => '好';

  @override
  String get commonDelete => '删除';

  @override
  String get commonDone => '完成';

  @override
  String get commonSave => '保存';

  @override
  String get commonClose => '关闭';

  @override
  String get commonRetry => '重试';

  @override
  String get commonSomethingWentWrong => '出了点问题，请稍后再试。';

  @override
  String get languageSystemDefault => '跟随手机语言';

  @override
  String get stepContent => '内容摘要';

  @override
  String get stepDivisions => '段落划分';

  @override
  String get stepSummary => '总结句';

  @override
  String get stepFcf => 'FCF';

  @override
  String get stepAim => '目标';

  @override
  String get stepApplication => '应用';

  @override
  String get stepShortContent => '内容';

  @override
  String get stepShortDivisions => '分段';

  @override
  String get stepShortSummary => '总结';

  @override
  String get stepShortFcf => 'FCF';

  @override
  String get stepShortAim => '目标';

  @override
  String get stepShortApplication => '应用';

  @override
  String get commonShare => '分享';

  @override
  String get commonPrint => '打印';

  @override
  String get commonPreferences => '偏好设置';

  @override
  String get commonUntitled => '未命名';

  @override
  String get homeSearchIntro => '搜索你的讲道大纲、段落划分、应用问题、讲课笔记和字词研究。';

  @override
  String get homeSearchFieldHint => '搜索课程、经文、笔记…';

  @override
  String get homeSearchTooltip => '搜索';

  @override
  String get homeCloseSearch => '关闭搜索';

  @override
  String get homeAllStudies => '全部查经课程';

  @override
  String get homeFilterByStudy => '按查经课程筛选';

  @override
  String get homeOpenStudySite => '打开查经课程网站';

  @override
  String get homeThisWeek => '本周';

  @override
  String get homeEarlier => '之前';

  @override
  String get homeComingUp => '即将开始';

  @override
  String homeWeekOverline(String when, String lesson) {
    return '$when · $lesson';
  }

  @override
  String get homeStartHomiletics => '开始写讲道大纲';

  @override
  String get homeContinueHomiletics => '继续写讲道大纲';

  @override
  String get homeOpenHomiletics => '打开讲道大纲';

  @override
  String get homeLoadingPassages => '正在加载推荐经文…';

  @override
  String get homeContinue => '继续';

  @override
  String get homeSeeAll => '查看全部';

  @override
  String get homeLivingItOut => '活出真道';

  @override
  String get homeKindTileHomiletic => '讲';

  @override
  String get homeKindTileWordStudy => '词';

  @override
  String get homeProgressNoneDone => '尚未完成任何步骤';

  @override
  String homeProgressDone(String steps) {
    return '已完成：$steps';
  }

  @override
  String homePageOf(int page, int count) {
    return '第$page页，共$count页';
  }

  @override
  String homePageFraction(int page, int count) {
    return '$page / $count';
  }

  @override
  String get studiesTitle => '我的查经';

  @override
  String get studiesTabHomiletics => '讲道大纲';

  @override
  String get studiesTabLectures => '讲课';

  @override
  String get studiesTabWordStudies => '字词研究';

  @override
  String get studiesNoHomiletics => '还没有讲道大纲。';

  @override
  String get studiesNoLectureNotes => '还没有讲课笔记。';

  @override
  String get studiesNoWordStudies => '还没有字词研究。';

  @override
  String get studiesNoApplications => '还没有应用问题。';

  @override
  String get studiesProgressNotStarted => '未开始';

  @override
  String studiesProgressAll(int total) {
    return '全部$total步';
  }

  @override
  String studiesProgressSome(int done, int total) {
    return '$done/$total步';
  }

  @override
  String studiesHomileticSubtitle(String progress, String time) {
    return '讲道大纲 · $progress · $time';
  }

  @override
  String studiesHomileticSubtitleNoProgress(String time) {
    return '讲道大纲 · $time';
  }

  @override
  String studiesLectureTitle(String passage) {
    return '$passage讲课';
  }

  @override
  String get studiesLectureUntitled => '讲课';

  @override
  String studiesLectureSubtitle(String time) {
    return '讲课笔记 · $time';
  }

  @override
  String get studiesWordStudyUntitled => '字词研究';

  @override
  String studiesWordStudySubtitle(String time) {
    return '字词研究 · $time';
  }

  @override
  String studiesWordStudySubtitleWithPassage(String passage, String time) {
    return '字词研究 · $passage · $time';
  }

  @override
  String get searchHint => '搜索';

  @override
  String get searchSectionContentSummaries => '内容摘要';

  @override
  String get searchSectionDivisions => '段落划分';

  @override
  String get searchSectionApplications => '应用问题';

  @override
  String get searchSectionAims => '目标';

  @override
  String get searchSectionSummarySentences => '总结句';

  @override
  String get searchSectionPassages => '讲道大纲经文';

  @override
  String get searchSectionLectureNotes => '讲课笔记';

  @override
  String get searchSectionWordStudies => '字词研究';

  @override
  String get searchOpenFailed => '无法打开该结果，它可能已被删除。';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsSectionLanguage => '语言';

  @override
  String get settingsAppLanguage => '应用语言';

  @override
  String get settingsSectionReading => '阅读';

  @override
  String get settingsSectionModels => '设备端模型';

  @override
  String get settingsSectionHelp => '帮助';

  @override
  String settingsCopyright(String year) {
    return '版权所有 (C) $year 13one.org · 保留所有权利';
  }

  @override
  String get helpRequestFeedback => '寻求帮助 / 提供反馈';

  @override
  String helpCopyright(String year) {
    return '版权所有 (C) $year 13one.org';
  }

  @override
  String get helpAllRightsReserved => '保留所有权利';

  @override
  String get feedbackTitle => '提供反馈';

  @override
  String get feedbackPublicNotice =>
      '你的反馈会作为公开的 GitHub issue 提交，互联网上的任何人都能看到。请勿包含密码或其他私人信息。你的电子邮箱在 GitHub 上会被部分隐藏；我们可能仅为跟进联系而在服务器上保留完整地址。';

  @override
  String get feedbackTypeGeneral => '帮助或反馈';

  @override
  String get feedbackTypeTranslation => '翻译问题';

  @override
  String get feedbackTranslationHint => '请告诉我们哪些文字有误，以及应该怎么写。我们会附上你的应用语言和圣经译本。';

  @override
  String get feedbackNameLabel => '姓名';

  @override
  String get feedbackEmailLabel => '电子邮箱（选填）';

  @override
  String get feedbackContentLabel => '反馈内容';

  @override
  String get feedbackSubmit => '提交';

  @override
  String get feedbackEmpty => '请先输入反馈内容。';

  @override
  String get feedbackSubmittedIssue =>
      '已提交。你可以随时在 GitHub 上打开该 issue 添加评论（可不登录）。';

  @override
  String get feedbackOpenIssue => '打开';

  @override
  String get feedbackSubmitted => '反馈提交成功';

  @override
  String get feedbackBadRequest => '无法提交该请求。请检查你的留言后重试。';

  @override
  String get feedbackServerUnreachableTitle => '无法连接服务器';

  @override
  String get feedbackServerUnreachableBody =>
      '请改为在浏览器中打开 GitHub 提交此报告。你可能需要先在那里登录才能提交 issue。';

  @override
  String get feedbackNotNow => '以后再说';

  @override
  String get feedbackOpenGitHub => '打开 GitHub';

  @override
  String get feedbackBrowserFailed => '无法打开浏览器。';

  @override
  String get startHomiletics => '讲道大纲';

  @override
  String get startLecture => '讲课';

  @override
  String get startWordStudy => '字词研究';

  @override
  String get startPassageHint => '查考其他经文…';

  @override
  String get startClear => '清除';

  @override
  String get startOtherStudy => '其他查经';

  @override
  String get startMenuLectureNote => '讲课笔记';

  @override
  String get startMenuWordStudy => '字词研究';

  @override
  String get startDuplicateHomileticTitle => '这段经文已有讲道大纲？';

  @override
  String startDuplicateHomileticMany(String passage, int count) {
    return '$passage\n\n这段经文你已有$count份讲道大纲，将打开最近的一份。';
  }

  @override
  String get startDuplicateLectureTitle => '这段经文已有讲课笔记？';

  @override
  String startDuplicateLectureMany(String passage, int count) {
    return '$passage\n\n这段经文你已有$count份讲课笔记，将打开最近的一份。';
  }

  @override
  String get startDuplicateWordStudyTitle => '这段经文已有字词研究？';

  @override
  String startDuplicateWordStudyMany(String passage, int count) {
    return '$passage\n\n这段经文你已有$count份字词研究，将打开最近的一份。';
  }

  @override
  String get startCreateNew => '新建';

  @override
  String get startEditExisting => '编辑现有的';

  @override
  String get homileticHeaderLabel => '讲道大纲 · 经文';

  @override
  String get homileticItemName => '讲道大纲';

  @override
  String get homileticDeletedMessage => '讲道大纲已删除';

  @override
  String get homileticLoadError => '加载这份讲道大纲时出了问题。';

  @override
  String get homileticPdfShared => 'PDF 分享成功。';

  @override
  String get homileticPdfShareFailed => '分享 PDF 时出了问题，请稍后再试。';

  @override
  String get homileticPdfPrinted => 'PDF 打印成功。';

  @override
  String get homileticPdfPrintFailed => '生成 PDF 时出了问题，请稍后再试。';

  @override
  String get homileticCompleteTitle => '六个步骤全部完成';

  @override
  String get homileticCompleteMessage => '打印出来带去课堂，或分享给你的小组。';

  @override
  String get homileticContentEmptySummary => '经节 + 摘要';

  @override
  String get homileticDivisionsEmptySummary => '分成2–4段';

  @override
  String get homileticSummaryEmptySummary => '≤ 20字';

  @override
  String get homileticFcfEmptySummary => '堕落景况焦点';

  @override
  String get homileticAimEmptySummary => '最主要的收获';

  @override
  String get homileticApplicationEmptySummary => '我该如何…';

  @override
  String get homileticStepStatusDone => '已完成';

  @override
  String get homileticStepStatusToDo => '待完成';

  @override
  String homileticStepCollapseLabel(String title) {
    return '$title，收起';
  }

  @override
  String homileticStepHelpLabel(String title) {
    return '关于$title';
  }

  @override
  String get homileticVersesLabel => '经节';

  @override
  String get homileticVersesHint => '节';

  @override
  String homileticAddButtonLabel(String label) {
    return '+ $label';
  }

  @override
  String get homileticRemoveRowMessage => '你在这里写的内容将被删除。';

  @override
  String get homileticRemoveRowConfirm => '移除';

  @override
  String get homileticContentSummaryHint => '摘要…';

  @override
  String get homileticAddContentSummary => '添加摘要';

  @override
  String get homileticRemoveContentSummaryTooltip => '移除内容摘要';

  @override
  String get homileticRemoveContentSummaryTitle => '移除这条内容摘要？';

  @override
  String get homileticRemoveContentSummaryFailed => '未能移除该内容摘要';

  @override
  String get homileticDivisionHint => '段落句…';

  @override
  String get homileticAddDivision => '添加段落';

  @override
  String get homileticRemoveDivisionTooltip => '移除段落';

  @override
  String get homileticRemoveDivisionTitle => '移除这个段落？';

  @override
  String get homileticRemoveDivisionFailed => '未能移除该段落';

  @override
  String get homileticApplicationHint => '我该如何…';

  @override
  String get homileticAddApplication => '添加问题';

  @override
  String get homileticRemoveApplicationTooltip => '移除应用问题';

  @override
  String get homileticRemoveApplicationTitle => '移除这个应用问题？';

  @override
  String get homileticRemoveApplicationFailed => '未能移除该应用问题';

  @override
  String get homileticSummaryHint => '总结：不超过20个字';

  @override
  String get homileticFcfHint => '堕落/软弱/无力/善变';

  @override
  String get homileticAimHint => '使听众明白…';

  @override
  String get homileticContentHelpTitle => '内容摘要';

  @override
  String get homileticContentHelpText =>
      '内容摘要是对一段圣经经文的概括。它不一定是一个完整的句子，也可以不止一句。它应当用你自己的话，概括这段经文的内容。\n内容摘要至少要写10条，但不超过20条。一般来说，可根据经文的长短，把经文分成大小差不多的几块，以达到10–20条的目标。例如，如果你的经文有30节，我会尽量让每条内容摘要平均涵盖3节。';

  @override
  String get homileticDivisionsHelpText => '段落划分是把彼此相关的经节归为一组。至少要分成两段，最多不超过四段。';

  @override
  String get homileticSummaryHelpTitle => '总结句';

  @override
  String get homileticSummaryHelpText =>
      '总结句是一句简洁、好记的话，概括了最关键的内容。可以用“凌晨两点测试”来想：如果有人在凌晨两点把你叫醒，问你这篇讲道讲的是什么，你会怎么回答？你的回答就是总结句。\n它应当不超过20个字。如果你有兴致，还可以试着让它押韵或对仗。';

  @override
  String get homileticFcfHelpText =>
      'FCF（堕落景况焦点）是这段经文最多描绘或提到的人性层面。它是听众所处的光景，也是听众需要被拯救的原因。';

  @override
  String get homileticAimHelpText =>
      '目标是核心要点，是你希望自己或听众带走的那一个最主要的真理。它可以从FCF推导出来，也很可能会影响应用问题。';

  @override
  String get homileticApplicationHelpTitle => '应用问题';

  @override
  String get homileticApplicationHelpText =>
      '这些问题帮助听众把刚听到的内容应用到自己的生活中。问题应当具体、贴近个人、开放式，并且发人深省。';

  @override
  String homileticSummaryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count条摘要',
    );
    return '$_temp0';
  }

  @override
  String homileticDivisionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个段落',
    );
    return '$_temp0';
  }

  @override
  String homileticQuestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个问题',
    );
    return '$_temp0';
  }

  @override
  String homileticStepTileLabel(String title, String status) {
    return '$title，$status';
  }

  @override
  String homileticStepTileLabelWithSummary(
    String title,
    String status,
    String summary,
  ) {
    return '$title，$status，$summary';
  }

  @override
  String get lectureItemName => '讲课笔记';

  @override
  String get lectureDeleted => '讲课笔记已删除';

  @override
  String get lecturePassageHint => '经文';

  @override
  String get lectureHeaderLabel => '讲课 · 经文';

  @override
  String get lectureNotesPlaceholder => '笔记';

  @override
  String get lectureToolbarBold => '粗体';

  @override
  String get lectureToolbarItalic => '斜体';

  @override
  String get lectureToolbarBulletedList => '项目符号列表';

  @override
  String get lectureToolbarNumberedList => '编号列表';

  @override
  String get lectureReplaceTitle => '替换现有录音？';

  @override
  String get lectureReplaceMessage => '旧的音频和转录文字将被删除。';

  @override
  String get lectureReplaceConfirm => '替换';

  @override
  String get lectureMicPermissionRequired => '需要麦克风权限才能录音。';

  @override
  String get lectureNotificationTitle => '正在录制讲课';

  @override
  String lectureNotificationContent(String appName) {
    return '$appName正在录音';
  }

  @override
  String get lectureStartFailed => '无法开始录音。麦克风可能正被其他应用使用。';

  @override
  String get lectureTranscriptionModelTitle => '下载离线转录模型？';

  @override
  String get lectureTranscriptionModelMessage =>
      '一次性下载约140MB后，你的录音就能自动转成文字并可供搜索。你也可以先跳过，以后在“设置”中下载。';

  @override
  String get lectureNotNow => '以后再说';

  @override
  String get lectureDownload => '下载';

  @override
  String get lectureModelDownloadFailed => '下载模型时出了问题。你可以在“设置”中重试。';

  @override
  String get lectureRecordingFileNotFound => '找不到录音文件。';

  @override
  String get lectureTranscriptionEmpty => '转录没有生成任何文字。';

  @override
  String get lectureFormattingModelTitle => '下载转录排版模型？';

  @override
  String lectureFormattingModelMessage(String size) {
    return '一次性下载$size后，转录文字就能整理成易读的段落，全程在你的设备上完成。建议使用 Wi-Fi。你也可以以后在“设置”中进行。';
  }

  @override
  String get lectureFormattingModelMissing => '尚未下载排版模型。';

  @override
  String get lectureFormattingFailed => '无法整理转录文字。';

  @override
  String get lecturePlaybackFailed => '无法播放录音。';

  @override
  String lectureDownloadingModel(String percent) {
    return '正在下载模型 $percent%';
  }

  @override
  String lectureTranscribingProgress(int percent) {
    return '正在转录 $percent%';
  }

  @override
  String lectureFormattingProgress(int done, int total) {
    return '正在整理转录 $done/$total';
  }

  @override
  String get lectureFormattingIndeterminate => '正在整理转录…';

  @override
  String lectureRecordingSemantics(String time) {
    return '正在录音，$time';
  }

  @override
  String get lectureRecordingSubtitle => '录音中 · 关闭屏幕也会继续';

  @override
  String get lectureStopRecording => '停止录音';

  @override
  String get lectureRecordLecture => '录制讲课';

  @override
  String get lectureRecordIdleSubtitle => '关闭屏幕也能继续录音';

  @override
  String get lecturePause => '暂停';

  @override
  String get lecturePlayRecording => '播放录音';

  @override
  String get lectureRecordAgain => '重新录制';

  @override
  String get lectureNotTranscribedYet => '尚未转录';

  @override
  String get lectureTranscribe => '转录';

  @override
  String get lectureTimeMark => '+ 时间标记';

  @override
  String get lectureTranscriptEmptyRecording => '停止录音后，讲课内容会在这部手机上转成文字。';

  @override
  String get lectureTranscriptEmptyPending => '转录文字准备好后会显示在这里。';

  @override
  String get lectureTranscriptEmptyNotTranscribed => '转录这段录音后，就能在这里阅读和搜索。';

  @override
  String get lectureTranscriptEmptyNoRecording => '录下讲课，停止后会在这部手机上转成文字。';

  @override
  String get lectureTranscribing => '正在转录…';

  @override
  String get lectureNoTranscriptYet => '还没有转录文字';

  @override
  String get lectureFormatted => '已整理';

  @override
  String get lectureRaw => '原文';

  @override
  String get lectureFormatTranscript => '整理转录文字';

  @override
  String get lectureTabMyNotes => '我的笔记';

  @override
  String get lectureTabTranscript => '转录文字';

  @override
  String get modelTranscriptionTitle => '离线转录模型';

  @override
  String modelTranscriptionEnglishNeeded(String language) {
    return '英语模型，$language需要';
  }

  @override
  String modelTranscriptionEnglishNotNeeded(String language) {
    return '英语模型，$language不需要';
  }

  @override
  String modelTranscriptionMultilingualNeeded(String language) {
    return '多语言模型，$language需要';
  }

  @override
  String modelTranscriptionMultilingualNotNeeded(String language) {
    return '多语言模型，$language不需要';
  }

  @override
  String get modelFormattingTitle => '转录排版模型';

  @override
  String get modelAppleIntelligenceStatus => '正在使用 Apple Intelligence（无需下载）';

  @override
  String get modelStatusChecking => '正在检查…';

  @override
  String modelStatusNotDownloaded(String size) {
    return '未下载（$size）';
  }

  @override
  String modelStatusDownloading(String percent) {
    return '正在下载… $percent%';
  }

  @override
  String get modelStatusDownloaded => '已下载';

  @override
  String modelStatusDownloadedSize(String megabytes) {
    return '已下载（${megabytes}MB）';
  }

  @override
  String get modelDownload => '下载';

  @override
  String get modelDelete => '删除';

  @override
  String get modelDownloadFailed => '下载模型时出了问题，请稍后再试。';

  @override
  String get modelDeleteFailed => '删除模型时出了问题。';

  @override
  String get pdfOverlineHomiletics => '讲道大纲';

  @override
  String get pdfOverlineWordStudy => '字词研究';

  @override
  String get pdfUntitledPassage => '未命名经文';

  @override
  String get pdfUntitledWord => '未命名字词';

  @override
  String pdfHomileticLabel(String passage) {
    return '讲道大纲 · $passage';
  }

  @override
  String pdfWordStudyLabel(String word) {
    return '字词研究 · $word';
  }

  @override
  String pdfWordStudyLabelWithPassage(String word, String passage) {
    return '字词研究 · $word · $passage';
  }

  @override
  String pdfPageOf(int current, int total) {
    return '第$current页，共$total页';
  }

  @override
  String get pdfFcfCaption => '堕落景况焦点';

  @override
  String get pdfAimLeadIn => '使听众明白：';

  @override
  String get pdfEmptyHomiletic => '这段经文还没有写任何内容。';

  @override
  String get pdfEmptyWordStudy => '这份字词研究还没有写任何内容。';

  @override
  String get pdfWordStudyDefinition => '定义';

  @override
  String get pdfWordStudyOtherUsage => '其他用法';

  @override
  String get pdfWordStudyContextualMeaning => '上下文含义';

  @override
  String get pdfWordStudyDeeperMeaning => '深层含义';

  @override
  String get pdfWordStudyApplication => '应用';

  @override
  String get editorSaveAndClose => '保存并关闭';

  @override
  String get editorDeleteConfirmTitle => '确定吗？';

  @override
  String editorDeleteConfirmMessage(String itemName) {
    return '删除这份$itemName后将无法恢复。确定要继续吗？';
  }

  @override
  String get editorPassageLabel => '经文';

  @override
  String get editorAddPassageHint => '添加经文';

  @override
  String get editorBack => '返回';

  @override
  String get editorMoreOptions => '更多选项';

  @override
  String get editorChangeTranslation => '更换译本';

  @override
  String get editorStudyCompleteMessage => '打印出来带去课堂，或分享给你的小组。';

  @override
  String get wordStudyItemName => '字词研究';

  @override
  String get wordStudyDeleted => '字词研究已删除';

  @override
  String get wordStudyHeaderLabel => '字词研究 · 经文';

  @override
  String get wordStudyPdfShared => 'PDF 分享成功。';

  @override
  String get wordStudyPdfShareFailed => '分享 PDF 时出了问题，请稍后再试。';

  @override
  String get wordStudyPdfPrinted => 'PDF 打印成功。';

  @override
  String get wordStudyPdfPrintFailed => '生成 PDF 时出了问题，请稍后再试。';

  @override
  String get wordStudyWordTitle => '字词';

  @override
  String get wordStudyWordHelp => '你要研究的具体字词或短语。输入后，“定义”和“其他用法”可以为你推荐内容。';

  @override
  String get wordStudyWordHint => '添加字词';

  @override
  String get wordStudyEnterWordFirst => '请先在上方输入字词。';

  @override
  String get wordStudyDefinitionTitle => '定义';

  @override
  String get wordStudyDefinitionHelp =>
      '这个字词用浅白的话说是什么意思？点按“+”可查看从词典中找到的候选定义，也可以自己写。';

  @override
  String get wordStudyDefinitionHelpNoSuggest => '这个字词用浅白的话说是什么意思？请自己写下来。';

  @override
  String get wordStudyDefinitionHint => '用浅白的话说，它是什么意思？';

  @override
  String get wordStudySuggestDefinition => '推荐定义';

  @override
  String wordStudyDefinitionsFor(String word) {
    return '“$word”的定义';
  }

  @override
  String get wordStudyDefinitionsTapToUse => '点按一项即可使用。';

  @override
  String get wordStudyDefinitionsLoadError => '无法加载定义，请稍后再试。';

  @override
  String get wordStudyNoDefinitions => '没有找到这个字词的定义。';

  @override
  String get wordStudyReplaceDefinitionTitle => '替换你的定义？';

  @override
  String get wordStudyReplaceDefinitionMessage =>
      '你已经写了定义。要用推荐内容替换它，还是把推荐内容添加在下方？';

  @override
  String get wordStudyAddBelow => '添加在下方';

  @override
  String get wordStudyReplace => '替换';

  @override
  String get wordStudyOtherUsageTitle => '其他用法';

  @override
  String get wordStudyOtherUsageHelp =>
      '这个字词或概念在圣经的其他什么地方出现？点按“+”可在 Bible Gateway 上搜索并添加你找到的经文出处，也可以自己写。';

  @override
  String get wordStudyOtherUsageHint => '它在圣经的其他什么地方出现？';

  @override
  String get wordStudyFindOtherUsages => '查找其他用法';

  @override
  String wordStudyOtherUsageSheetTitle(String word) {
    return '“$word”还出现在哪里';
  }

  @override
  String get wordStudyOtherUsageAdded => '已添加';

  @override
  String get wordStudyOtherUsageInstructions => '点按下方结果即可添加其经文出处。';

  @override
  String get wordStudyOtherUsageAddResult => '+ 添加';

  @override
  String get wordStudyContextualMeaningTitle => '上下文含义';

  @override
  String get wordStudyContextualMeaningHelp =>
      '作者在这段经文中用这个字词想表达什么意思？请参考前后的经节，而不只看这个字词本身。';

  @override
  String get wordStudyContextualMeaningHint => '它在这段经文中是什么意思？';

  @override
  String get wordStudyDeeperMeaningTitle => '深层含义';

  @override
  String get wordStudyDeeperMeaningHelp =>
      '原文、注释书或其他研读资料中，有没有超越基本定义、带来更深理解的见解？圣经其他部分如何塑造它的含义？Strong\'s 经文汇编或 Blue Letter Bible 会有帮助。';

  @override
  String get wordStudyDeeperMeaningHint => '圣经其他部分如何塑造它的含义？';

  @override
  String get wordStudyApplicationTitle => '应用';

  @override
  String get wordStudyApplicationHelp => '这个真理应当如何塑造你的生活？要具体、贴近个人、切实可行。';

  @override
  String get wordStudyApplicationHint => '你会怎样活出来？';

  @override
  String get wordStudyDoneTitle => '字词研究已完成';

  @override
  String wordStudySectionHelpSemantics(String title) {
    return '$title，关于此部分';
  }

  @override
  String get lectureTimeMarkNoRecording => '此笔记没有可播放的录音。';

  @override
  String get lectureTimeMarkStopRecordingFirst => '请先停止录音，再从时间标记处播放。';

  @override
  String get lectureTimeMarkPastEnd => '该时间标记超出了录音的长度。';

  @override
  String get onboardingSkip => '跳过';

  @override
  String get onboardingBack => '上一步';

  @override
  String get onboardingNext => '下一步';

  @override
  String get onboardingWelcomeOverline => '欢迎';

  @override
  String get onboardingWelcomeTitle => '一次一段经文，好好查考圣经';

  @override
  String get onboardingWelcomeBody =>
      '这个应用帮助你写讲道大纲、做讲课笔记和字词研究——经文始终就在旁边，用你的语言和你选择的圣经译本。';

  @override
  String get onboardingMethodOverline => '方法';

  @override
  String get onboardingMethodTitle => '什么是讲道大纲？';

  @override
  String get onboardingMethodBody =>
      '讲道大纲是一种简短的查经方法：找出经文的中心信息，再思考如何活出来。共有六个步骤——不需要做得完美，每周都会越来越顺手。';

  @override
  String get onboardingStepsOverline => '逐步进行';

  @override
  String get onboardingStepsTitle => '六个步骤';

  @override
  String get onboardingStepContent => '用自己的话，把经文概括成10到20个简短的小段。';

  @override
  String get onboardingStepDivisions => '把这些小段归纳成2到4个部分。';

  @override
  String get onboardingStepSummary => '用不超过20个字概括整段经文。';

  @override
  String get onboardingStepFcf => '堕落景况焦点：经文所针对的人的需要或破碎。';

  @override
  String get onboardingStepAim => '你希望听众学到的那个核心真理。';

  @override
  String get onboardingStepApplication => '帮助人把经文活在日常生活中的问题。';

  @override
  String get onboardingLecturesOverline => '讲课与字词研究';

  @override
  String get onboardingLecturesTitle => '用心聆听，深入挖掘';

  @override
  String get onboardingLecturesBody =>
      '录下讲课——关闭屏幕也会继续录音，并直接在手机上转成文字。一边听一边做笔记，加上时间标记，方便以后找到那一刻。';

  @override
  String get onboardingWordStudyBody => '对某个词感到好奇？开始一个字词研究，深入了解它在经文中的意思。';

  @override
  String get onboardingStartOverline => '开始';

  @override
  String get onboardingStartTitle => '你已准备好开始了';

  @override
  String get onboardingStartBody => '从本周的经文开始，或者先四处看看。你写下的每一步都会自动保存。';

  @override
  String get onboardingReopenHint => '你随时可以在设置中再次打开本指南。';

  @override
  String get onboardingStartThisWeek => '开始本周的讲道大纲';

  @override
  String get onboardingExplore => '自己先看看';

  @override
  String onboardingThisWeekPassage(String passage) {
    return '本周：$passage';
  }

  @override
  String get onboardingSettingsRow => '讲道大纲怎么做';

  @override
  String bibleOfflineSize(String size) {
    return '可离线 · $size';
  }

  @override
  String bibleDownloadedSize(String size) {
    return '已下载 · $size';
  }

  @override
  String get bibleDownloadAction => '下载以离线使用';

  @override
  String get bibleDownloading => '正在下载…';

  @override
  String get bibleRemoveDownload => '删除下载';

  @override
  String bibleDownloadFailed(String translation) {
    return '无法下载 $translation。请检查网络后重试。';
  }

  @override
  String get bibleOfflineTitle => '没有网络连接';

  @override
  String bibleOfflineMessage(String translation) {
    return '这段经文来自 Bible Gateway，需要连接网络。下载 $translation 后可随时阅读。';
  }

  @override
  String get bibleOfflineNoDownloadMessage =>
      '这段经文来自 Bible Gateway，需要连接网络。请连接网络后重试。';

  @override
  String get bibleTryAgain => '重试';

  @override
  String bibleNeedsDownloadTitle(String translation) {
    return '下载 $translation';
  }

  @override
  String bibleNeedsDownloadMessage(String size) {
    return '这本圣经从你的设备读取。下载一次（约 $size）即可查看经文。';
  }

  @override
  String bibleNotInTranslation(String translation) {
    return '在 $translation 中找不到这段经文。';
  }

  @override
  String get bibleVerseTapTip => '提示：点按经节编号，即可从该节开始写摘要。';

  @override
  String bibleVerseTapLabel(String verse) {
    return '从第 $verse 节开始写摘要';
  }

  @override
  String get shareSheetTitle => '分享这份学习';

  @override
  String get shareLink => '分享链接';

  @override
  String get shareLinkSubtitle => '可在应用或任何浏览器中打开';

  @override
  String get shareCopyLink => '复制链接';

  @override
  String get shareLinkCopied => '链接已复制';

  @override
  String get shareShowQr => '显示二维码';

  @override
  String get shareSharePdf => '分享 PDF';

  @override
  String get shareLinkFailed => '无法分享链接。';

  @override
  String get shareLinkTooLongTitle => '这个链接很长';

  @override
  String shareLinkTooLongMessage(int count) {
    return '这份学习生成的链接有 $count 个字符。有些应用可能会截断它，导致无法打开。如果发生这种情况，请改为分享 PDF。';
  }

  @override
  String get shareAnyway => '仍然分享';

  @override
  String get shareQrTitle => '扫码打开';

  @override
  String get shareQrHint => '用另一部手机的相机对准二维码即可打开这份学习。';

  @override
  String get shareQrTooLong => '这份学习太长，无法生成二维码。请改用“分享链接”或“复制链接”。';

  @override
  String get shareQrSemantics => '指向这份学习的二维码';

  @override
  String get importFromLink => '从链接导入';

  @override
  String get importSheetMessage => '粘贴别人分享给你的 Homiletics 链接。保存副本前可以先查看内容。';

  @override
  String get importFieldHint => 'https://homiletics.app/view#…';

  @override
  String get importPaste => '粘贴';

  @override
  String get importOpen => '打开';

  @override
  String get importClipboardEmpty => '没有可粘贴的文字。';

  @override
  String get importInvalidLink => '这不是 Homiletics 链接，或链接不完整。请再向对方索取一次。';

  @override
  String get importNewerVersion =>
      '这份学习来自较新版本的 Homiletics。请更新 Homiletics 后再打开。';

  @override
  String get importCouldNotOpenTitle => '无法打开此链接';

  @override
  String get importPreviewHomiletic => '分享的讲道大纲';

  @override
  String get importPreviewWordStudy => '分享的字词研究';

  @override
  String get importPreviewNote => '这是别人分享给你的。保存会在你的学习中新增一份副本，不会更改你已有的内容。';

  @override
  String importPreviewTranslation(String translation) {
    return '使用 $translation 撰写';
  }

  @override
  String get importSaveCopy => '保存副本';

  @override
  String get importSaved => '已保存到你的学习';

  @override
  String get importSaveFailed => '无法保存这份学习，请重试。';

  @override
  String get startOpenSharedStudy => '打开分享的学习';
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get prefsTitle => '偏好设置';

  @override
  String get prefsAppLanguage => '首选语言';

  @override
  String get prefsBibleVersion => '首选圣经译本';

  @override
  String get bibleNewTestamentOnly => '仅含新约';

  @override
  String get appTitle => 'Homiletics';

  @override
  String get commonCancel => '取消';

  @override
  String get commonOk => '好';

  @override
  String get commonDelete => '删除';

  @override
  String get commonDone => '完成';

  @override
  String get commonSave => '保存';

  @override
  String get commonClose => '关闭';

  @override
  String get commonRetry => '重试';

  @override
  String get commonSomethingWentWrong => '出了点问题，请稍后再试。';

  @override
  String get languageSystemDefault => '跟随手机语言';

  @override
  String get stepContent => '内容摘要';

  @override
  String get stepDivisions => '段落划分';

  @override
  String get stepSummary => '总结句';

  @override
  String get stepFcf => 'FCF';

  @override
  String get stepAim => '目标';

  @override
  String get stepApplication => '应用';

  @override
  String get stepShortContent => '内容';

  @override
  String get stepShortDivisions => '分段';

  @override
  String get stepShortSummary => '总结';

  @override
  String get stepShortFcf => 'FCF';

  @override
  String get stepShortAim => '目标';

  @override
  String get stepShortApplication => '应用';

  @override
  String get commonShare => '分享';

  @override
  String get commonPrint => '打印';

  @override
  String get commonPreferences => '偏好设置';

  @override
  String get commonUntitled => '未命名';

  @override
  String get homeSearchIntro => '搜索你的讲道大纲、段落划分、应用问题、讲课笔记和字词研究。';

  @override
  String get homeSearchFieldHint => '搜索课程、经文、笔记…';

  @override
  String get homeSearchTooltip => '搜索';

  @override
  String get homeCloseSearch => '关闭搜索';

  @override
  String get homeAllStudies => '全部查经课程';

  @override
  String get homeFilterByStudy => '按查经课程筛选';

  @override
  String get homeOpenStudySite => '打开查经课程网站';

  @override
  String get homeThisWeek => '本周';

  @override
  String get homeEarlier => '之前';

  @override
  String get homeComingUp => '即将开始';

  @override
  String homeWeekOverline(String when, String lesson) {
    return '$when · $lesson';
  }

  @override
  String get homeStartHomiletics => '开始写讲道大纲';

  @override
  String get homeContinueHomiletics => '继续写讲道大纲';

  @override
  String get homeOpenHomiletics => '打开讲道大纲';

  @override
  String get homeLoadingPassages => '正在加载推荐经文…';

  @override
  String get homeContinue => '继续';

  @override
  String get homeSeeAll => '查看全部';

  @override
  String get homeLivingItOut => '活出真道';

  @override
  String get homeKindTileHomiletic => '讲';

  @override
  String get homeKindTileWordStudy => '词';

  @override
  String get homeProgressNoneDone => '尚未完成任何步骤';

  @override
  String homeProgressDone(String steps) {
    return '已完成：$steps';
  }

  @override
  String homePageOf(int page, int count) {
    return '第$page页，共$count页';
  }

  @override
  String homePageFraction(int page, int count) {
    return '$page / $count';
  }

  @override
  String get studiesTitle => '我的查经';

  @override
  String get studiesTabHomiletics => '讲道大纲';

  @override
  String get studiesTabLectures => '讲课';

  @override
  String get studiesTabWordStudies => '字词研究';

  @override
  String get studiesNoHomiletics => '还没有讲道大纲。';

  @override
  String get studiesNoLectureNotes => '还没有讲课笔记。';

  @override
  String get studiesNoWordStudies => '还没有字词研究。';

  @override
  String get studiesNoApplications => '还没有应用问题。';

  @override
  String get studiesProgressNotStarted => '未开始';

  @override
  String studiesProgressAll(int total) {
    return '全部$total步';
  }

  @override
  String studiesProgressSome(int done, int total) {
    return '$done/$total步';
  }

  @override
  String studiesHomileticSubtitle(String progress, String time) {
    return '讲道大纲 · $progress · $time';
  }

  @override
  String studiesHomileticSubtitleNoProgress(String time) {
    return '讲道大纲 · $time';
  }

  @override
  String studiesLectureTitle(String passage) {
    return '$passage讲课';
  }

  @override
  String get studiesLectureUntitled => '讲课';

  @override
  String studiesLectureSubtitle(String time) {
    return '讲课笔记 · $time';
  }

  @override
  String get studiesWordStudyUntitled => '字词研究';

  @override
  String studiesWordStudySubtitle(String time) {
    return '字词研究 · $time';
  }

  @override
  String studiesWordStudySubtitleWithPassage(String passage, String time) {
    return '字词研究 · $passage · $time';
  }

  @override
  String get searchHint => '搜索';

  @override
  String get searchSectionContentSummaries => '内容摘要';

  @override
  String get searchSectionDivisions => '段落划分';

  @override
  String get searchSectionApplications => '应用问题';

  @override
  String get searchSectionAims => '目标';

  @override
  String get searchSectionSummarySentences => '总结句';

  @override
  String get searchSectionPassages => '讲道大纲经文';

  @override
  String get searchSectionLectureNotes => '讲课笔记';

  @override
  String get searchSectionWordStudies => '字词研究';

  @override
  String get searchOpenFailed => '无法打开该结果，它可能已被删除。';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsSectionLanguage => '语言';

  @override
  String get settingsAppLanguage => '应用语言';

  @override
  String get settingsSectionReading => '阅读';

  @override
  String get settingsSectionModels => '设备端模型';

  @override
  String get settingsSectionHelp => '帮助';

  @override
  String settingsCopyright(String year) {
    return '版权所有 (C) $year 13one.org · 保留所有权利';
  }

  @override
  String get helpRequestFeedback => '寻求帮助 / 提供反馈';

  @override
  String helpCopyright(String year) {
    return '版权所有 (C) $year 13one.org';
  }

  @override
  String get helpAllRightsReserved => '保留所有权利';

  @override
  String get feedbackTitle => '提供反馈';

  @override
  String get feedbackPublicNotice =>
      '你的反馈会作为公开的 GitHub issue 提交，互联网上的任何人都能看到。请勿包含密码或其他私人信息。你的电子邮箱在 GitHub 上会被部分隐藏；我们可能仅为跟进联系而在服务器上保留完整地址。';

  @override
  String get feedbackTypeGeneral => '帮助或反馈';

  @override
  String get feedbackTypeTranslation => '翻译问题';

  @override
  String get feedbackTranslationHint => '请告诉我们哪些文字有误，以及应该怎么写。我们会附上你的应用语言和圣经译本。';

  @override
  String get feedbackNameLabel => '姓名';

  @override
  String get feedbackEmailLabel => '电子邮箱（选填）';

  @override
  String get feedbackContentLabel => '反馈内容';

  @override
  String get feedbackSubmit => '提交';

  @override
  String get feedbackEmpty => '请先输入反馈内容。';

  @override
  String get feedbackSubmittedIssue =>
      '已提交。你可以随时在 GitHub 上打开该 issue 添加评论（可不登录）。';

  @override
  String get feedbackOpenIssue => '打开';

  @override
  String get feedbackSubmitted => '反馈提交成功';

  @override
  String get feedbackBadRequest => '无法提交该请求。请检查你的留言后重试。';

  @override
  String get feedbackServerUnreachableTitle => '无法连接服务器';

  @override
  String get feedbackServerUnreachableBody =>
      '请改为在浏览器中打开 GitHub 提交此报告。你可能需要先在那里登录才能提交 issue。';

  @override
  String get feedbackNotNow => '以后再说';

  @override
  String get feedbackOpenGitHub => '打开 GitHub';

  @override
  String get feedbackBrowserFailed => '无法打开浏览器。';

  @override
  String get startHomiletics => '讲道大纲';

  @override
  String get startLecture => '讲课';

  @override
  String get startWordStudy => '字词研究';

  @override
  String get startPassageHint => '查考其他经文…';

  @override
  String get startClear => '清除';

  @override
  String get startOtherStudy => '其他查经';

  @override
  String get startMenuLectureNote => '讲课笔记';

  @override
  String get startMenuWordStudy => '字词研究';

  @override
  String get startDuplicateHomileticTitle => '这段经文已有讲道大纲？';

  @override
  String startDuplicateHomileticMany(String passage, int count) {
    return '$passage\n\n这段经文你已有$count份讲道大纲，将打开最近的一份。';
  }

  @override
  String get startDuplicateLectureTitle => '这段经文已有讲课笔记？';

  @override
  String startDuplicateLectureMany(String passage, int count) {
    return '$passage\n\n这段经文你已有$count份讲课笔记，将打开最近的一份。';
  }

  @override
  String get startDuplicateWordStudyTitle => '这段经文已有字词研究？';

  @override
  String startDuplicateWordStudyMany(String passage, int count) {
    return '$passage\n\n这段经文你已有$count份字词研究，将打开最近的一份。';
  }

  @override
  String get startCreateNew => '新建';

  @override
  String get startEditExisting => '编辑现有的';

  @override
  String get homileticHeaderLabel => '讲道大纲 · 经文';

  @override
  String get homileticItemName => '讲道大纲';

  @override
  String get homileticDeletedMessage => '讲道大纲已删除';

  @override
  String get homileticLoadError => '加载这份讲道大纲时出了问题。';

  @override
  String get homileticPdfShared => 'PDF 分享成功。';

  @override
  String get homileticPdfShareFailed => '分享 PDF 时出了问题，请稍后再试。';

  @override
  String get homileticPdfPrinted => 'PDF 打印成功。';

  @override
  String get homileticPdfPrintFailed => '生成 PDF 时出了问题，请稍后再试。';

  @override
  String get homileticCompleteTitle => '六个步骤全部完成';

  @override
  String get homileticCompleteMessage => '打印出来带去课堂，或分享给你的小组。';

  @override
  String get homileticContentEmptySummary => '经节 + 摘要';

  @override
  String get homileticDivisionsEmptySummary => '分成2–4段';

  @override
  String get homileticSummaryEmptySummary => '≤ 20字';

  @override
  String get homileticFcfEmptySummary => '堕落景况焦点';

  @override
  String get homileticAimEmptySummary => '最主要的收获';

  @override
  String get homileticApplicationEmptySummary => '我该如何…';

  @override
  String get homileticStepStatusDone => '已完成';

  @override
  String get homileticStepStatusToDo => '待完成';

  @override
  String homileticStepCollapseLabel(String title) {
    return '$title，收起';
  }

  @override
  String homileticStepHelpLabel(String title) {
    return '关于$title';
  }

  @override
  String get homileticVersesLabel => '经节';

  @override
  String get homileticVersesHint => '节';

  @override
  String homileticAddButtonLabel(String label) {
    return '+ $label';
  }

  @override
  String get homileticRemoveRowMessage => '你在这里写的内容将被删除。';

  @override
  String get homileticRemoveRowConfirm => '移除';

  @override
  String get homileticContentSummaryHint => '摘要…';

  @override
  String get homileticAddContentSummary => '添加摘要';

  @override
  String get homileticRemoveContentSummaryTooltip => '移除内容摘要';

  @override
  String get homileticRemoveContentSummaryTitle => '移除这条内容摘要？';

  @override
  String get homileticRemoveContentSummaryFailed => '未能移除该内容摘要';

  @override
  String get homileticDivisionHint => '段落句…';

  @override
  String get homileticAddDivision => '添加段落';

  @override
  String get homileticRemoveDivisionTooltip => '移除段落';

  @override
  String get homileticRemoveDivisionTitle => '移除这个段落？';

  @override
  String get homileticRemoveDivisionFailed => '未能移除该段落';

  @override
  String get homileticApplicationHint => '我该如何…';

  @override
  String get homileticAddApplication => '添加问题';

  @override
  String get homileticRemoveApplicationTooltip => '移除应用问题';

  @override
  String get homileticRemoveApplicationTitle => '移除这个应用问题？';

  @override
  String get homileticRemoveApplicationFailed => '未能移除该应用问题';

  @override
  String get homileticSummaryHint => '总结：不超过20个字';

  @override
  String get homileticFcfHint => '堕落/软弱/无力/善变';

  @override
  String get homileticAimHint => '使听众明白…';

  @override
  String get homileticContentHelpTitle => '内容摘要';

  @override
  String get homileticContentHelpText =>
      '内容摘要是对一段圣经经文的概括。它不一定是一个完整的句子，也可以不止一句。它应当用你自己的话，概括这段经文的内容。\n内容摘要至少要写10条，但不超过20条。一般来说，可根据经文的长短，把经文分成大小差不多的几块，以达到10–20条的目标。例如，如果你的经文有30节，我会尽量让每条内容摘要平均涵盖3节。';

  @override
  String get homileticDivisionsHelpText => '段落划分是把彼此相关的经节归为一组。至少要分成两段，最多不超过四段。';

  @override
  String get homileticSummaryHelpTitle => '总结句';

  @override
  String get homileticSummaryHelpText =>
      '总结句是一句简洁、好记的话，概括了最关键的内容。可以用“凌晨两点测试”来想：如果有人在凌晨两点把你叫醒，问你这篇讲道讲的是什么，你会怎么回答？你的回答就是总结句。\n它应当不超过20个字。如果你有兴致，还可以试着让它押韵或对仗。';

  @override
  String get homileticFcfHelpText =>
      'FCF（堕落景况焦点）是这段经文最多描绘或提到的人性层面。它是听众所处的光景，也是听众需要被拯救的原因。';

  @override
  String get homileticAimHelpText =>
      '目标是核心要点，是你希望自己或听众带走的那一个最主要的真理。它可以从FCF推导出来，也很可能会影响应用问题。';

  @override
  String get homileticApplicationHelpTitle => '应用问题';

  @override
  String get homileticApplicationHelpText =>
      '这些问题帮助听众把刚听到的内容应用到自己的生活中。问题应当具体、贴近个人、开放式，并且发人深省。';

  @override
  String homileticSummaryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count条摘要',
    );
    return '$_temp0';
  }

  @override
  String homileticDivisionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个段落',
    );
    return '$_temp0';
  }

  @override
  String homileticQuestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个问题',
    );
    return '$_temp0';
  }

  @override
  String homileticStepTileLabel(String title, String status) {
    return '$title，$status';
  }

  @override
  String homileticStepTileLabelWithSummary(
    String title,
    String status,
    String summary,
  ) {
    return '$title，$status，$summary';
  }

  @override
  String get lectureItemName => '讲课笔记';

  @override
  String get lectureDeleted => '讲课笔记已删除';

  @override
  String get lecturePassageHint => '经文';

  @override
  String get lectureHeaderLabel => '讲课 · 经文';

  @override
  String get lectureNotesPlaceholder => '笔记';

  @override
  String get lectureToolbarBold => '粗体';

  @override
  String get lectureToolbarItalic => '斜体';

  @override
  String get lectureToolbarBulletedList => '项目符号列表';

  @override
  String get lectureToolbarNumberedList => '编号列表';

  @override
  String get lectureReplaceTitle => '替换现有录音？';

  @override
  String get lectureReplaceMessage => '旧的音频和转录文字将被删除。';

  @override
  String get lectureReplaceConfirm => '替换';

  @override
  String get lectureMicPermissionRequired => '需要麦克风权限才能录音。';

  @override
  String get lectureNotificationTitle => '正在录制讲课';

  @override
  String lectureNotificationContent(String appName) {
    return '$appName正在录音';
  }

  @override
  String get lectureStartFailed => '无法开始录音。麦克风可能正被其他应用使用。';

  @override
  String get lectureTranscriptionModelTitle => '下载离线转录模型？';

  @override
  String get lectureTranscriptionModelMessage =>
      '一次性下载约140MB后，你的录音就能自动转成文字并可供搜索。你也可以先跳过，以后在“设置”中下载。';

  @override
  String get lectureNotNow => '以后再说';

  @override
  String get lectureDownload => '下载';

  @override
  String get lectureModelDownloadFailed => '下载模型时出了问题。你可以在“设置”中重试。';

  @override
  String get lectureRecordingFileNotFound => '找不到录音文件。';

  @override
  String get lectureTranscriptionEmpty => '转录没有生成任何文字。';

  @override
  String get lectureFormattingModelTitle => '下载转录排版模型？';

  @override
  String lectureFormattingModelMessage(String size) {
    return '一次性下载$size后，转录文字就能整理成易读的段落，全程在你的设备上完成。建议使用 Wi-Fi。你也可以以后在“设置”中进行。';
  }

  @override
  String get lectureFormattingModelMissing => '尚未下载排版模型。';

  @override
  String get lectureFormattingFailed => '无法整理转录文字。';

  @override
  String get lecturePlaybackFailed => '无法播放录音。';

  @override
  String lectureDownloadingModel(String percent) {
    return '正在下载模型 $percent%';
  }

  @override
  String lectureTranscribingProgress(int percent) {
    return '正在转录 $percent%';
  }

  @override
  String lectureFormattingProgress(int done, int total) {
    return '正在整理转录 $done/$total';
  }

  @override
  String get lectureFormattingIndeterminate => '正在整理转录…';

  @override
  String lectureRecordingSemantics(String time) {
    return '正在录音，$time';
  }

  @override
  String get lectureRecordingSubtitle => '录音中 · 关闭屏幕也会继续';

  @override
  String get lectureStopRecording => '停止录音';

  @override
  String get lectureRecordLecture => '录制讲课';

  @override
  String get lectureRecordIdleSubtitle => '关闭屏幕也能继续录音';

  @override
  String get lecturePause => '暂停';

  @override
  String get lecturePlayRecording => '播放录音';

  @override
  String get lectureRecordAgain => '重新录制';

  @override
  String get lectureNotTranscribedYet => '尚未转录';

  @override
  String get lectureTranscribe => '转录';

  @override
  String get lectureTimeMark => '+ 时间标记';

  @override
  String get lectureTranscriptEmptyRecording => '停止录音后，讲课内容会在这部手机上转成文字。';

  @override
  String get lectureTranscriptEmptyPending => '转录文字准备好后会显示在这里。';

  @override
  String get lectureTranscriptEmptyNotTranscribed => '转录这段录音后，就能在这里阅读和搜索。';

  @override
  String get lectureTranscriptEmptyNoRecording => '录下讲课，停止后会在这部手机上转成文字。';

  @override
  String get lectureTranscribing => '正在转录…';

  @override
  String get lectureNoTranscriptYet => '还没有转录文字';

  @override
  String get lectureFormatted => '已整理';

  @override
  String get lectureRaw => '原文';

  @override
  String get lectureFormatTranscript => '整理转录文字';

  @override
  String get lectureTabMyNotes => '我的笔记';

  @override
  String get lectureTabTranscript => '转录文字';

  @override
  String get modelTranscriptionTitle => '离线转录模型';

  @override
  String modelTranscriptionEnglishNeeded(String language) {
    return '英语模型，$language需要';
  }

  @override
  String modelTranscriptionEnglishNotNeeded(String language) {
    return '英语模型，$language不需要';
  }

  @override
  String modelTranscriptionMultilingualNeeded(String language) {
    return '多语言模型，$language需要';
  }

  @override
  String modelTranscriptionMultilingualNotNeeded(String language) {
    return '多语言模型，$language不需要';
  }

  @override
  String get modelFormattingTitle => '转录排版模型';

  @override
  String get modelAppleIntelligenceStatus => '正在使用 Apple Intelligence（无需下载）';

  @override
  String get modelStatusChecking => '正在检查…';

  @override
  String modelStatusNotDownloaded(String size) {
    return '未下载（$size）';
  }

  @override
  String modelStatusDownloading(String percent) {
    return '正在下载… $percent%';
  }

  @override
  String get modelStatusDownloaded => '已下载';

  @override
  String modelStatusDownloadedSize(String megabytes) {
    return '已下载（${megabytes}MB）';
  }

  @override
  String get modelDownload => '下载';

  @override
  String get modelDelete => '删除';

  @override
  String get modelDownloadFailed => '下载模型时出了问题，请稍后再试。';

  @override
  String get modelDeleteFailed => '删除模型时出了问题。';

  @override
  String get pdfOverlineHomiletics => '讲道大纲';

  @override
  String get pdfOverlineWordStudy => '字词研究';

  @override
  String get pdfUntitledPassage => '未命名经文';

  @override
  String get pdfUntitledWord => '未命名字词';

  @override
  String pdfHomileticLabel(String passage) {
    return '讲道大纲 · $passage';
  }

  @override
  String pdfWordStudyLabel(String word) {
    return '字词研究 · $word';
  }

  @override
  String pdfWordStudyLabelWithPassage(String word, String passage) {
    return '字词研究 · $word · $passage';
  }

  @override
  String pdfPageOf(int current, int total) {
    return '第$current页，共$total页';
  }

  @override
  String get pdfFcfCaption => '堕落景况焦点';

  @override
  String get pdfAimLeadIn => '使听众明白：';

  @override
  String get pdfEmptyHomiletic => '这段经文还没有写任何内容。';

  @override
  String get pdfEmptyWordStudy => '这份字词研究还没有写任何内容。';

  @override
  String get pdfWordStudyDefinition => '定义';

  @override
  String get pdfWordStudyOtherUsage => '其他用法';

  @override
  String get pdfWordStudyContextualMeaning => '上下文含义';

  @override
  String get pdfWordStudyDeeperMeaning => '深层含义';

  @override
  String get pdfWordStudyApplication => '应用';

  @override
  String get editorSaveAndClose => '保存并关闭';

  @override
  String get editorDeleteConfirmTitle => '确定吗？';

  @override
  String editorDeleteConfirmMessage(String itemName) {
    return '删除这份$itemName后将无法恢复。确定要继续吗？';
  }

  @override
  String get editorPassageLabel => '经文';

  @override
  String get editorAddPassageHint => '添加经文';

  @override
  String get editorBack => '返回';

  @override
  String get editorMoreOptions => '更多选项';

  @override
  String get editorChangeTranslation => '更换译本';

  @override
  String get editorStudyCompleteMessage => '打印出来带去课堂，或分享给你的小组。';

  @override
  String get wordStudyItemName => '字词研究';

  @override
  String get wordStudyDeleted => '字词研究已删除';

  @override
  String get wordStudyHeaderLabel => '字词研究 · 经文';

  @override
  String get wordStudyPdfShared => 'PDF 分享成功。';

  @override
  String get wordStudyPdfShareFailed => '分享 PDF 时出了问题，请稍后再试。';

  @override
  String get wordStudyPdfPrinted => 'PDF 打印成功。';

  @override
  String get wordStudyPdfPrintFailed => '生成 PDF 时出了问题，请稍后再试。';

  @override
  String get wordStudyWordTitle => '字词';

  @override
  String get wordStudyWordHelp => '你要研究的具体字词或短语。输入后，“定义”和“其他用法”可以为你推荐内容。';

  @override
  String get wordStudyWordHint => '添加字词';

  @override
  String get wordStudyEnterWordFirst => '请先在上方输入字词。';

  @override
  String get wordStudyDefinitionTitle => '定义';

  @override
  String get wordStudyDefinitionHelp =>
      '这个字词用浅白的话说是什么意思？点按“+”可查看从词典中找到的候选定义，也可以自己写。';

  @override
  String get wordStudyDefinitionHelpNoSuggest => '这个字词用浅白的话说是什么意思？请自己写下来。';

  @override
  String get wordStudyDefinitionHint => '用浅白的话说，它是什么意思？';

  @override
  String get wordStudySuggestDefinition => '推荐定义';

  @override
  String wordStudyDefinitionsFor(String word) {
    return '“$word”的定义';
  }

  @override
  String get wordStudyDefinitionsTapToUse => '点按一项即可使用。';

  @override
  String get wordStudyDefinitionsLoadError => '无法加载定义，请稍后再试。';

  @override
  String get wordStudyNoDefinitions => '没有找到这个字词的定义。';

  @override
  String get wordStudyReplaceDefinitionTitle => '替换你的定义？';

  @override
  String get wordStudyReplaceDefinitionMessage =>
      '你已经写了定义。要用推荐内容替换它，还是把推荐内容添加在下方？';

  @override
  String get wordStudyAddBelow => '添加在下方';

  @override
  String get wordStudyReplace => '替换';

  @override
  String get wordStudyOtherUsageTitle => '其他用法';

  @override
  String get wordStudyOtherUsageHelp =>
      '这个字词或概念在圣经的其他什么地方出现？点按“+”可在 Bible Gateway 上搜索并添加你找到的经文出处，也可以自己写。';

  @override
  String get wordStudyOtherUsageHint => '它在圣经的其他什么地方出现？';

  @override
  String get wordStudyFindOtherUsages => '查找其他用法';

  @override
  String wordStudyOtherUsageSheetTitle(String word) {
    return '“$word”还出现在哪里';
  }

  @override
  String get wordStudyOtherUsageAdded => '已添加';

  @override
  String get wordStudyOtherUsageInstructions => '点按下方结果即可添加其经文出处。';

  @override
  String get wordStudyOtherUsageAddResult => '+ 添加';

  @override
  String get wordStudyContextualMeaningTitle => '上下文含义';

  @override
  String get wordStudyContextualMeaningHelp =>
      '作者在这段经文中用这个字词想表达什么意思？请参考前后的经节，而不只看这个字词本身。';

  @override
  String get wordStudyContextualMeaningHint => '它在这段经文中是什么意思？';

  @override
  String get wordStudyDeeperMeaningTitle => '深层含义';

  @override
  String get wordStudyDeeperMeaningHelp =>
      '原文、注释书或其他研读资料中，有没有超越基本定义、带来更深理解的见解？圣经其他部分如何塑造它的含义？Strong\'s 经文汇编或 Blue Letter Bible 会有帮助。';

  @override
  String get wordStudyDeeperMeaningHint => '圣经其他部分如何塑造它的含义？';

  @override
  String get wordStudyApplicationTitle => '应用';

  @override
  String get wordStudyApplicationHelp => '这个真理应当如何塑造你的生活？要具体、贴近个人、切实可行。';

  @override
  String get wordStudyApplicationHint => '你会怎样活出来？';

  @override
  String get wordStudyDoneTitle => '字词研究已完成';

  @override
  String wordStudySectionHelpSemantics(String title) {
    return '$title，关于此部分';
  }

  @override
  String get lectureTimeMarkNoRecording => '此笔记没有可播放的录音。';

  @override
  String get lectureTimeMarkStopRecordingFirst => '请先停止录音，再从时间标记处播放。';

  @override
  String get lectureTimeMarkPastEnd => '该时间标记超出了录音的长度。';

  @override
  String get onboardingSkip => '跳过';

  @override
  String get onboardingBack => '上一步';

  @override
  String get onboardingNext => '下一步';

  @override
  String get onboardingWelcomeOverline => '欢迎';

  @override
  String get onboardingWelcomeTitle => '一次一段经文，好好查考圣经';

  @override
  String get onboardingWelcomeBody =>
      '这个应用帮助你写讲道大纲、做讲课笔记和字词研究——经文始终就在旁边，用你的语言和你选择的圣经译本。';

  @override
  String get onboardingMethodOverline => '方法';

  @override
  String get onboardingMethodTitle => '什么是讲道大纲？';

  @override
  String get onboardingMethodBody =>
      '讲道大纲是一种简短的查经方法：找出经文的中心信息，再思考如何活出来。共有六个步骤——不需要做得完美，每周都会越来越顺手。';

  @override
  String get onboardingStepsOverline => '逐步进行';

  @override
  String get onboardingStepsTitle => '六个步骤';

  @override
  String get onboardingStepContent => '用自己的话，把经文概括成10到20个简短的小段。';

  @override
  String get onboardingStepDivisions => '把这些小段归纳成2到4个部分。';

  @override
  String get onboardingStepSummary => '用不超过20个字概括整段经文。';

  @override
  String get onboardingStepFcf => '堕落景况焦点：经文所针对的人的需要或破碎。';

  @override
  String get onboardingStepAim => '你希望听众学到的那个核心真理。';

  @override
  String get onboardingStepApplication => '帮助人把经文活在日常生活中的问题。';

  @override
  String get onboardingLecturesOverline => '讲课与字词研究';

  @override
  String get onboardingLecturesTitle => '用心聆听，深入挖掘';

  @override
  String get onboardingLecturesBody =>
      '录下讲课——关闭屏幕也会继续录音，并直接在手机上转成文字。一边听一边做笔记，加上时间标记，方便以后找到那一刻。';

  @override
  String get onboardingWordStudyBody => '对某个词感到好奇？开始一个字词研究，深入了解它在经文中的意思。';

  @override
  String get onboardingStartOverline => '开始';

  @override
  String get onboardingStartTitle => '你已准备好开始了';

  @override
  String get onboardingStartBody => '从本周的经文开始，或者先四处看看。你写下的每一步都会自动保存。';

  @override
  String get onboardingReopenHint => '你随时可以在设置中再次打开本指南。';

  @override
  String get onboardingStartThisWeek => '开始本周的讲道大纲';

  @override
  String get onboardingExplore => '自己先看看';

  @override
  String onboardingThisWeekPassage(String passage) {
    return '本周：$passage';
  }

  @override
  String get onboardingSettingsRow => '讲道大纲怎么做';

  @override
  String bibleOfflineSize(String size) {
    return '可离线 · $size';
  }

  @override
  String bibleDownloadedSize(String size) {
    return '已下载 · $size';
  }

  @override
  String get bibleDownloadAction => '下载以离线使用';

  @override
  String get bibleDownloading => '正在下载…';

  @override
  String get bibleRemoveDownload => '删除下载';

  @override
  String bibleDownloadFailed(String translation) {
    return '无法下载 $translation。请检查网络后重试。';
  }

  @override
  String get bibleOfflineTitle => '没有网络连接';

  @override
  String bibleOfflineMessage(String translation) {
    return '这段经文来自 Bible Gateway，需要连接网络。下载 $translation 后可随时阅读。';
  }

  @override
  String get bibleOfflineNoDownloadMessage =>
      '这段经文来自 Bible Gateway，需要连接网络。请连接网络后重试。';

  @override
  String get bibleTryAgain => '重试';

  @override
  String bibleNeedsDownloadTitle(String translation) {
    return '下载 $translation';
  }

  @override
  String bibleNeedsDownloadMessage(String size) {
    return '这本圣经从你的设备读取。下载一次（约 $size）即可查看经文。';
  }

  @override
  String bibleNotInTranslation(String translation) {
    return '在 $translation 中找不到这段经文。';
  }

  @override
  String get bibleVerseTapTip => '提示：点按经节编号，即可从该节开始写摘要。';

  @override
  String bibleVerseTapLabel(String verse) {
    return '从第 $verse 节开始写摘要';
  }

  @override
  String get shareSheetTitle => '分享这份学习';

  @override
  String get shareLink => '分享链接';

  @override
  String get shareLinkSubtitle => '可在应用或任何浏览器中打开';

  @override
  String get shareCopyLink => '复制链接';

  @override
  String get shareLinkCopied => '链接已复制';

  @override
  String get shareShowQr => '显示二维码';

  @override
  String get shareSharePdf => '分享 PDF';

  @override
  String get shareLinkFailed => '无法分享链接。';

  @override
  String get shareLinkTooLongTitle => '这个链接很长';

  @override
  String shareLinkTooLongMessage(int count) {
    return '这份学习生成的链接有 $count 个字符。有些应用可能会截断它，导致无法打开。如果发生这种情况，请改为分享 PDF。';
  }

  @override
  String get shareAnyway => '仍然分享';

  @override
  String get shareQrTitle => '扫码打开';

  @override
  String get shareQrHint => '用另一部手机的相机对准二维码即可打开这份学习。';

  @override
  String get shareQrTooLong => '这份学习太长，无法生成二维码。请改用“分享链接”或“复制链接”。';

  @override
  String get shareQrSemantics => '指向这份学习的二维码';

  @override
  String get importFromLink => '从链接导入';

  @override
  String get importSheetMessage => '粘贴别人分享给你的 Homiletics 链接。保存副本前可以先查看内容。';

  @override
  String get importFieldHint => 'https://homiletics.app/view#…';

  @override
  String get importPaste => '粘贴';

  @override
  String get importOpen => '打开';

  @override
  String get importClipboardEmpty => '没有可粘贴的文字。';

  @override
  String get importInvalidLink => '这不是 Homiletics 链接，或链接不完整。请再向对方索取一次。';

  @override
  String get importNewerVersion =>
      '这份学习来自较新版本的 Homiletics。请更新 Homiletics 后再打开。';

  @override
  String get importCouldNotOpenTitle => '无法打开此链接';

  @override
  String get importPreviewHomiletic => '分享的讲道大纲';

  @override
  String get importPreviewWordStudy => '分享的字词研究';

  @override
  String get importPreviewNote => '这是别人分享给你的。保存会在你的学习中新增一份副本，不会更改你已有的内容。';

  @override
  String importPreviewTranslation(String translation) {
    return '使用 $translation 撰写';
  }

  @override
  String get importSaveCopy => '保存副本';

  @override
  String get importSaved => '已保存到你的学习';

  @override
  String get importSaveFailed => '无法保存这份学习，请重试。';

  @override
  String get startOpenSharedStudy => '打开分享的学习';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get prefsTitle => '偏好設定';

  @override
  String get prefsAppLanguage => '偏好語言';

  @override
  String get prefsBibleVersion => '偏好聖經譯本';

  @override
  String get bibleNewTestamentOnly => '僅有新約';

  @override
  String get appTitle => 'Homiletics';

  @override
  String get commonCancel => '取消';

  @override
  String get commonOk => '確定';

  @override
  String get commonDelete => '刪除';

  @override
  String get commonDone => '完成';

  @override
  String get commonSave => '儲存';

  @override
  String get commonClose => '關閉';

  @override
  String get commonRetry => '重試';

  @override
  String get commonSomethingWentWrong => '發生錯誤，請稍後再試。';

  @override
  String get languageSystemDefault => '手機語言';

  @override
  String get stepContent => '內容摘要';

  @override
  String get stepDivisions => '段落劃分';

  @override
  String get stepSummary => '摘要句';

  @override
  String get stepFcf => 'FCF';

  @override
  String get stepAim => '目標';

  @override
  String get stepApplication => '應用';

  @override
  String get stepShortContent => '內容';

  @override
  String get stepShortDivisions => '分段';

  @override
  String get stepShortSummary => '摘要';

  @override
  String get stepShortFcf => 'FCF';

  @override
  String get stepShortAim => '目標';

  @override
  String get stepShortApplication => '應用';

  @override
  String get commonShare => '分享';

  @override
  String get commonPrint => '列印';

  @override
  String get commonPreferences => '偏好設定';

  @override
  String get commonUntitled => '未命名';

  @override
  String get homeSearchIntro => '搜尋你的講道大綱、段落劃分、應用問題、講課筆記和字詞研究。';

  @override
  String get homeSearchFieldHint => '搜尋課程、經文、筆記…';

  @override
  String get homeSearchTooltip => '搜尋';

  @override
  String get homeCloseSearch => '關閉搜尋';

  @override
  String get homeAllStudies => '所有查經';

  @override
  String get homeFilterByStudy => '依查經篩選';

  @override
  String get homeOpenStudySite => '開啟查經網站';

  @override
  String get homeThisWeek => '本週';

  @override
  String get homeEarlier => '先前';

  @override
  String get homeComingUp => '即將到來';

  @override
  String homeWeekOverline(String when, String lesson) {
    return '$when · $lesson';
  }

  @override
  String get homeStartHomiletics => '開始講道大綱';

  @override
  String get homeContinueHomiletics => '繼續講道大綱';

  @override
  String get homeOpenHomiletics => '開啟講道大綱';

  @override
  String get homeLoadingPassages => '正在載入建議經文…';

  @override
  String get homeContinue => '繼續';

  @override
  String get homeSeeAll => '查看全部';

  @override
  String get homeLivingItOut => '活出真道';

  @override
  String get homeKindTileHomiletic => '講';

  @override
  String get homeKindTileWordStudy => '字';

  @override
  String get homeProgressNoneDone => '尚未完成任何步驟';

  @override
  String homeProgressDone(String steps) {
    return '已完成：$steps';
  }

  @override
  String homePageOf(int page, int count) {
    return '第$page頁，共$count頁';
  }

  @override
  String homePageFraction(int page, int count) {
    return '$page / $count';
  }

  @override
  String get studiesTitle => '我的查經';

  @override
  String get studiesTabHomiletics => '講道大綱';

  @override
  String get studiesTabLectures => '講課';

  @override
  String get studiesTabWordStudies => '字詞研究';

  @override
  String get studiesNoHomiletics => '還沒有講道大綱。';

  @override
  String get studiesNoLectureNotes => '還沒有講課筆記。';

  @override
  String get studiesNoWordStudies => '還沒有字詞研究。';

  @override
  String get studiesNoApplications => '還沒有應用問題。';

  @override
  String get studiesProgressNotStarted => '尚未開始';

  @override
  String studiesProgressAll(int total) {
    return '全部$total步';
  }

  @override
  String studiesProgressSome(int done, int total) {
    return '$done/$total步';
  }

  @override
  String studiesHomileticSubtitle(String progress, String time) {
    return '講道大綱 · $progress · $time';
  }

  @override
  String studiesHomileticSubtitleNoProgress(String time) {
    return '講道大綱 · $time';
  }

  @override
  String studiesLectureTitle(String passage) {
    return '$passage講課';
  }

  @override
  String get studiesLectureUntitled => '講課';

  @override
  String studiesLectureSubtitle(String time) {
    return '講課筆記 · $time';
  }

  @override
  String get studiesWordStudyUntitled => '字詞研究';

  @override
  String studiesWordStudySubtitle(String time) {
    return '字詞研究 · $time';
  }

  @override
  String studiesWordStudySubtitleWithPassage(String passage, String time) {
    return '字詞研究 · $passage · $time';
  }

  @override
  String get searchHint => '搜尋';

  @override
  String get searchSectionContentSummaries => '內容摘要';

  @override
  String get searchSectionDivisions => '段落劃分';

  @override
  String get searchSectionApplications => '應用問題';

  @override
  String get searchSectionAims => '目標';

  @override
  String get searchSectionSummarySentences => '摘要句';

  @override
  String get searchSectionPassages => '講道大綱經文';

  @override
  String get searchSectionLectureNotes => '講課筆記';

  @override
  String get searchSectionWordStudies => '字詞研究';

  @override
  String get searchOpenFailed => '無法開啟這個結果，它可能已被刪除。';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsSectionLanguage => '語言';

  @override
  String get settingsAppLanguage => 'App 語言';

  @override
  String get settingsSectionReading => '閱讀';

  @override
  String get settingsSectionModels => '裝置端模型';

  @override
  String get settingsSectionHelp => '說明';

  @override
  String settingsCopyright(String year) {
    return 'Copyright (C) $year 13one.org · 版權所有';
  }

  @override
  String get helpRequestFeedback => '尋求協助／提供意見';

  @override
  String helpCopyright(String year) {
    return 'Copyright (C) $year 13one.org';
  }

  @override
  String get helpAllRightsReserved => '版權所有';

  @override
  String get feedbackTitle => '提供意見';

  @override
  String get feedbackPublicNotice =>
      '你的意見會以公開的 GitHub issue 送出——網路上任何人都能閱讀。請勿填寫密碼或其他私人資訊。你的電子郵件在 GitHub 上會部分隱藏；我們可能會在伺服器上保留完整地址，僅用於後續聯繫。';

  @override
  String get feedbackTypeGeneral => '協助或意見';

  @override
  String get feedbackTypeTranslation => '翻譯問題';

  @override
  String get feedbackTranslationHint =>
      '請告訴我們哪些字詞看起來不對，以及應該怎麼寫。我們會一併附上你的 App 語言和聖經譯本。';

  @override
  String get feedbackNameLabel => '姓名';

  @override
  String get feedbackEmailLabel => '電子郵件（選填）';

  @override
  String get feedbackContentLabel => '意見';

  @override
  String get feedbackSubmit => '送出';

  @override
  String get feedbackEmpty => '請先輸入你的意見。';

  @override
  String get feedbackSubmittedIssue =>
      '已送出。你隨時可以在 GitHub 上開啟這個 issue 新增留言（不一定需要登入）。';

  @override
  String get feedbackOpenIssue => '開啟';

  @override
  String get feedbackSubmitted => '意見已成功送出';

  @override
  String get feedbackBadRequest => '無法送出這個請求，請檢查你的訊息後再試一次。';

  @override
  String get feedbackServerUnreachableTitle => '無法連線到伺服器';

  @override
  String get feedbackServerUnreachableBody =>
      '請改用瀏覽器開啟 GitHub 來回報。你可能需要在那裡登入才能送出 issue。';

  @override
  String get feedbackNotNow => '以後再說';

  @override
  String get feedbackOpenGitHub => '開啟 GitHub';

  @override
  String get feedbackBrowserFailed => '無法開啟瀏覽器。';

  @override
  String get startHomiletics => '講道大綱';

  @override
  String get startLecture => '講課';

  @override
  String get startWordStudy => '字詞研究';

  @override
  String get startPassageHint => '查考其他經文…';

  @override
  String get startClear => '清除';

  @override
  String get startOtherStudy => '其他查經';

  @override
  String get startMenuLectureNote => '講課筆記';

  @override
  String get startMenuWordStudy => '字詞研究';

  @override
  String get startDuplicateHomileticTitle => '這段經文已經有講道大綱了？';

  @override
  String startDuplicateHomileticMany(String passage, int count) {
    return '$passage\n\n這段經文你已有$count份講道大綱；將開啟最近的一份。';
  }

  @override
  String get startDuplicateLectureTitle => '這段經文已經有講課筆記了？';

  @override
  String startDuplicateLectureMany(String passage, int count) {
    return '$passage\n\n這段經文你已有$count份講課筆記；將開啟最近的一份。';
  }

  @override
  String get startDuplicateWordStudyTitle => '這段經文已經有字詞研究了？';

  @override
  String startDuplicateWordStudyMany(String passage, int count) {
    return '$passage\n\n這段經文你已有$count份字詞研究；將開啟最近的一份。';
  }

  @override
  String get startCreateNew => '建立新的';

  @override
  String get startEditExisting => '編輯現有的';

  @override
  String get homileticHeaderLabel => '講道大綱 · 經文';

  @override
  String get homileticItemName => '講道大綱';

  @override
  String get homileticDeletedMessage => '講道大綱已刪除';

  @override
  String get homileticLoadError => '載入這份講道大綱時發生錯誤。';

  @override
  String get homileticPdfShared => 'PDF 已成功分享。';

  @override
  String get homileticPdfShareFailed => '分享 PDF 時發生錯誤，請稍後再試。';

  @override
  String get homileticPdfPrinted => 'PDF 已成功列印。';

  @override
  String get homileticPdfPrintFailed => '建立 PDF 時發生錯誤，請稍後再試。';

  @override
  String get homileticCompleteTitle => '六個步驟都完成了';

  @override
  String get homileticCompleteMessage => '列印出來帶去上課，或分享給你的小組。';

  @override
  String get homileticContentEmptySummary => '經節＋摘要';

  @override
  String get homileticDivisionsEmptySummary => '分成2–4段';

  @override
  String get homileticSummaryEmptySummary => '≤ 20字';

  @override
  String get homileticFcfEmptySummary => '墮落景況焦點';

  @override
  String get homileticAimEmptySummary => '最主要的信息';

  @override
  String get homileticApplicationEmptySummary => '我可以如何…';

  @override
  String get homileticStepStatusDone => '已完成';

  @override
  String get homileticStepStatusToDo => '待完成';

  @override
  String homileticStepCollapseLabel(String title) {
    return '$title，收合';
  }

  @override
  String homileticStepHelpLabel(String title) {
    return '關於$title';
  }

  @override
  String get homileticVersesLabel => '經節';

  @override
  String get homileticVersesHint => '節';

  @override
  String homileticAddButtonLabel(String label) {
    return '+ $label';
  }

  @override
  String get homileticRemoveRowMessage => '你在這裡寫的內容將被刪除。';

  @override
  String get homileticRemoveRowConfirm => '移除';

  @override
  String get homileticContentSummaryHint => '摘要…';

  @override
  String get homileticAddContentSummary => '新增摘要';

  @override
  String get homileticRemoveContentSummaryTooltip => '移除內容摘要';

  @override
  String get homileticRemoveContentSummaryTitle => '要移除這則內容摘要嗎？';

  @override
  String get homileticRemoveContentSummaryFailed => '無法移除這則內容摘要';

  @override
  String get homileticDivisionHint => '分段句…';

  @override
  String get homileticAddDivision => '新增分段';

  @override
  String get homileticRemoveDivisionTooltip => '移除分段';

  @override
  String get homileticRemoveDivisionTitle => '要移除這個分段嗎？';

  @override
  String get homileticRemoveDivisionFailed => '無法移除這個分段';

  @override
  String get homileticApplicationHint => '我可以如何…';

  @override
  String get homileticAddApplication => '新增問題';

  @override
  String get homileticRemoveApplicationTooltip => '移除應用問題';

  @override
  String get homileticRemoveApplicationTitle => '要移除這個應用問題嗎？';

  @override
  String get homileticRemoveApplicationFailed => '無法移除這個應用問題';

  @override
  String get homileticSummaryHint => '用一句話概括（20字以內）';

  @override
  String get homileticFcfHint => '墮落／軟弱／無力／善變';

  @override
  String get homileticAimHint => '使聽眾明白…';

  @override
  String get homileticContentHelpTitle => '內容摘要';

  @override
  String get homileticContentHelpText =>
      '內容摘要是針對一段聖經經文所寫的摘要。它不一定要是一個完整的句子，也可以超過一句。它應該用你自己的話，概括這段經文的內容。\n你應該寫至少10則、但不超過20則內容摘要。一般來說，視經文長短而定，你可以把經文切成大小差不多的段落，讓總數落在10到20則之間。例如經文有30節，我會試著平均每3節寫一則內容摘要。';

  @override
  String get homileticDivisionsHelpText => '段落劃分是把彼此相關的經節歸為一組。至少要分成兩段，最多不超過四段。';

  @override
  String get homileticSummaryHelpTitle => '摘要句';

  @override
  String get homileticSummaryHelpText =>
      '摘要句是一句簡潔、好記的話，概括這段經文中最重要的事實。一個好方法是「凌晨兩點測試」：如果有人在凌晨兩點把你叫醒，問你這篇講道在講什麼，你會怎麼回答？你說出口的那句話就是摘要句。\n它應該簡短，大約20字以內。如果你有興致，也可以試著讓它押韻或對仗。';

  @override
  String get homileticFcfHelpText =>
      'FCF（墮落景況焦點）是這段經文中最突顯或最常提到的人性狀況。它是聽眾所處的景況，也是聽眾需要被拯救的原因。';

  @override
  String get homileticAimHelpText =>
      '目標是重點，是你希望自己或聽眾帶走的那一個最主要的真理。它可能可以從FCF推導出來，而且很可能會影響應用問題。';

  @override
  String get homileticApplicationHelpTitle => '應用問題';

  @override
  String get homileticApplicationHelpText =>
      '這些問題幫助聽眾把剛聽到的內容應用在自己的生活中。問題應該具體、切身、開放，並且引人深思。';

  @override
  String homileticSummaryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count則摘要',
    );
    return '$_temp0';
  }

  @override
  String homileticDivisionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count個分段',
    );
    return '$_temp0';
  }

  @override
  String homileticQuestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count個問題',
    );
    return '$_temp0';
  }

  @override
  String homileticStepTileLabel(String title, String status) {
    return '$title，$status';
  }

  @override
  String homileticStepTileLabelWithSummary(
    String title,
    String status,
    String summary,
  ) {
    return '$title，$status，$summary';
  }

  @override
  String get lectureItemName => '講課筆記';

  @override
  String get lectureDeleted => '講課筆記已刪除';

  @override
  String get lecturePassageHint => '經文';

  @override
  String get lectureHeaderLabel => '講課 · 經文';

  @override
  String get lectureNotesPlaceholder => '筆記';

  @override
  String get lectureToolbarBold => '粗體';

  @override
  String get lectureToolbarItalic => '斜體';

  @override
  String get lectureToolbarBulletedList => '項目符號清單';

  @override
  String get lectureToolbarNumberedList => '編號清單';

  @override
  String get lectureReplaceTitle => '要取代現有的錄音嗎？';

  @override
  String get lectureReplaceMessage => '舊的錄音和逐字稿將被刪除。';

  @override
  String get lectureReplaceConfirm => '取代';

  @override
  String get lectureMicPermissionRequired => '需要麥克風權限才能錄音。';

  @override
  String get lectureNotificationTitle => '正在錄製講課';

  @override
  String lectureNotificationContent(String appName) {
    return '$appName正在錄音';
  }

  @override
  String get lectureStartFailed => '無法開始錄音。麥克風可能正被其他 App 使用。';

  @override
  String get lectureTranscriptionModelTitle => '要下載離線轉錄模型嗎？';

  @override
  String get lectureTranscriptionModelMessage =>
      '只需下載一次（約140MB），你的錄音就能自動轉成文字並可供搜尋。你可以先略過，之後再到「設定」下載。';

  @override
  String get lectureNotNow => '以後再說';

  @override
  String get lectureDownload => '下載';

  @override
  String get lectureModelDownloadFailed => '下載模型時發生錯誤。你可以到「設定」再試一次。';

  @override
  String get lectureRecordingFileNotFound => '找不到錄音檔案。';

  @override
  String get lectureTranscriptionEmpty => '轉錄沒有產生任何文字。';

  @override
  String get lectureFormattingModelTitle => '要下載逐字稿整理模型嗎？';

  @override
  String lectureFormattingModelMessage(String size) {
    return '只需下載一次（$size），就能在你的裝置上把逐字稿整理成易讀的段落，完全不需上傳。建議使用 Wi-Fi。你也可以之後再到「設定」下載。';
  }

  @override
  String get lectureFormattingModelMissing => '尚未下載整理模型。';

  @override
  String get lectureFormattingFailed => '無法整理逐字稿。';

  @override
  String get lecturePlaybackFailed => '無法播放錄音。';

  @override
  String lectureDownloadingModel(String percent) {
    return '正在下載模型 $percent%';
  }

  @override
  String lectureTranscribingProgress(int percent) {
    return '正在轉錄 $percent%';
  }

  @override
  String lectureFormattingProgress(int done, int total) {
    return '正在整理逐字稿 $done/$total';
  }

  @override
  String get lectureFormattingIndeterminate => '正在整理逐字稿…';

  @override
  String lectureRecordingSemantics(String time) {
    return '錄音中，$time';
  }

  @override
  String get lectureRecordingSubtitle => '錄音中 · 關閉螢幕也會繼續錄';

  @override
  String get lectureStopRecording => '停止錄音';

  @override
  String get lectureRecordLecture => '錄製講課';

  @override
  String get lectureRecordIdleSubtitle => '關閉螢幕也會繼續錄音';

  @override
  String get lecturePause => '暫停';

  @override
  String get lecturePlayRecording => '播放錄音';

  @override
  String get lectureRecordAgain => '重新錄音';

  @override
  String get lectureNotTranscribedYet => '尚未轉錄';

  @override
  String get lectureTranscribe => '轉錄';

  @override
  String get lectureTimeMark => '+ 時間標記';

  @override
  String get lectureTranscriptEmptyRecording => '停止錄音後，講課內容會在這支手機上轉錄成文字。';

  @override
  String get lectureTranscriptEmptyPending => '逐字稿完成後會顯示在這裡。';

  @override
  String get lectureTranscriptEmptyNotTranscribed => '轉錄錄音後，就能在這裡閱讀和搜尋。';

  @override
  String get lectureTranscriptEmptyNoRecording => '錄製講課後，停止錄音時就會在這支手機上轉錄成文字。';

  @override
  String get lectureTranscribing => '正在轉錄…';

  @override
  String get lectureNoTranscriptYet => '還沒有逐字稿';

  @override
  String get lectureFormatted => '已整理';

  @override
  String get lectureRaw => '原始';

  @override
  String get lectureFormatTranscript => '整理逐字稿';

  @override
  String get lectureTabMyNotes => '我的筆記';

  @override
  String get lectureTabTranscript => '逐字稿';

  @override
  String get modelTranscriptionTitle => '離線轉錄模型';

  @override
  String modelTranscriptionEnglishNeeded(String language) {
    return '英文模型，$language需要使用';
  }

  @override
  String modelTranscriptionEnglishNotNeeded(String language) {
    return '英文模型，$language不需要使用';
  }

  @override
  String modelTranscriptionMultilingualNeeded(String language) {
    return '多語言模型，$language需要使用';
  }

  @override
  String modelTranscriptionMultilingualNotNeeded(String language) {
    return '多語言模型，$language不需要使用';
  }

  @override
  String get modelFormattingTitle => '逐字稿整理模型';

  @override
  String get modelAppleIntelligenceStatus => '使用 Apple Intelligence（不需下載）';

  @override
  String get modelStatusChecking => '正在檢查…';

  @override
  String modelStatusNotDownloaded(String size) {
    return '未下載（$size）';
  }

  @override
  String modelStatusDownloading(String percent) {
    return '正在下載… $percent%';
  }

  @override
  String get modelStatusDownloaded => '已下載';

  @override
  String modelStatusDownloadedSize(String megabytes) {
    return '已下載（${megabytes}MB）';
  }

  @override
  String get modelDownload => '下載';

  @override
  String get modelDelete => '刪除';

  @override
  String get modelDownloadFailed => '下載模型時發生錯誤，請稍後再試。';

  @override
  String get modelDeleteFailed => '刪除模型時發生錯誤。';

  @override
  String get pdfOverlineHomiletics => '講道大綱';

  @override
  String get pdfOverlineWordStudy => '字詞研究';

  @override
  String get pdfUntitledPassage => '未命名經文';

  @override
  String get pdfUntitledWord => '未命名字詞';

  @override
  String pdfHomileticLabel(String passage) {
    return '講道大綱 · $passage';
  }

  @override
  String pdfWordStudyLabel(String word) {
    return '字詞研究 · $word';
  }

  @override
  String pdfWordStudyLabelWithPassage(String word, String passage) {
    return '字詞研究 · $word · $passage';
  }

  @override
  String pdfPageOf(int current, int total) {
    return '第$current頁，共$total頁';
  }

  @override
  String get pdfFcfCaption => '墮落景況焦點';

  @override
  String get pdfAimLeadIn => '使聽眾明白';

  @override
  String get pdfEmptyHomiletic => '這段經文還沒有寫任何內容。';

  @override
  String get pdfEmptyWordStudy => '這份字詞研究還沒有寫任何內容。';

  @override
  String get pdfWordStudyDefinition => '定義';

  @override
  String get pdfWordStudyOtherUsage => '其他用法';

  @override
  String get pdfWordStudyContextualMeaning => '上下文含義';

  @override
  String get pdfWordStudyDeeperMeaning => '深層含義';

  @override
  String get pdfWordStudyApplication => '應用';

  @override
  String get editorSaveAndClose => '儲存並關閉';

  @override
  String get editorDeleteConfirmTitle => '確定嗎？';

  @override
  String editorDeleteConfirmMessage(String itemName) {
    return '刪除這份$itemName後將無法復原。確定要繼續嗎？';
  }

  @override
  String get editorPassageLabel => '經文';

  @override
  String get editorAddPassageHint => '新增經文';

  @override
  String get editorBack => '返回';

  @override
  String get editorMoreOptions => '更多選項';

  @override
  String get editorChangeTranslation => '更換譯本';

  @override
  String get editorStudyCompleteMessage => '列印出來帶去上課，或分享給你的小組。';

  @override
  String get wordStudyItemName => '字詞研究';

  @override
  String get wordStudyDeleted => '字詞研究已刪除';

  @override
  String get wordStudyHeaderLabel => '字詞研究 · 經文';

  @override
  String get wordStudyPdfShared => 'PDF 已成功分享。';

  @override
  String get wordStudyPdfShareFailed => '分享 PDF 時發生錯誤，請稍後再試。';

  @override
  String get wordStudyPdfPrinted => 'PDF 已成功列印。';

  @override
  String get wordStudyPdfPrintFailed => '建立 PDF 時發生錯誤，請稍後再試。';

  @override
  String get wordStudyWordTitle => '字詞';

  @override
  String get wordStudyWordHelp => '你要研究的特定字詞或短語。輸入之後，「定義」和「其他用法」可以為你建議內容。';

  @override
  String get wordStudyWordHint => '新增字詞';

  @override
  String get wordStudyEnterWordFirst => '請先在上方輸入字詞。';

  @override
  String get wordStudyDefinitionTitle => '定義';

  @override
  String get wordStudyDefinitionHelp =>
      '這個字詞用淺白的話來說是什麼意思？點「+」查看從字典找到的候選定義，或自己寫。';

  @override
  String get wordStudyDefinitionHelpNoSuggest => '這個字詞用淺白的話來說是什麼意思？請自己寫下來。';

  @override
  String get wordStudyDefinitionHint => '用淺白的話來說，它是什麼意思？';

  @override
  String get wordStudySuggestDefinition => '建議定義';

  @override
  String wordStudyDefinitionsFor(String word) {
    return '「$word」的定義';
  }

  @override
  String get wordStudyDefinitionsTapToUse => '點一個來使用。';

  @override
  String get wordStudyDefinitionsLoadError => '無法載入定義，請稍後再試。';

  @override
  String get wordStudyNoDefinitions => '找不到這個字詞的定義。';

  @override
  String get wordStudyReplaceDefinitionTitle => '要取代你的定義嗎？';

  @override
  String get wordStudyReplaceDefinitionMessage =>
      '你已經寫了定義。要用建議內容取代它，還是把建議內容加在下方？';

  @override
  String get wordStudyAddBelow => '加在下方';

  @override
  String get wordStudyReplace => '取代';

  @override
  String get wordStudyOtherUsageTitle => '其他用法';

  @override
  String get wordStudyOtherUsageHelp =>
      '這個字詞或概念在聖經其他地方還出現在哪裡？點「+」搜尋 Bible Gateway，加入你找到的經文出處，或自己寫。';

  @override
  String get wordStudyOtherUsageHint => '它在聖經其他地方還出現在哪裡？';

  @override
  String get wordStudyFindOtherUsages => '尋找其他用法';

  @override
  String wordStudyOtherUsageSheetTitle(String word) {
    return '「$word」還出現在哪裡';
  }

  @override
  String get wordStudyOtherUsageAdded => '已加入';

  @override
  String get wordStudyOtherUsageInstructions => '點下方的結果來加入它的經文出處。';

  @override
  String get wordStudyOtherUsageAddResult => '+ 加入';

  @override
  String get wordStudyContextualMeaningTitle => '上下文含義';

  @override
  String get wordStudyContextualMeaningHelp =>
      '作者在這段經文裡，想用這個字詞表達什麼意思？請考慮上下文的經節，而不是只看這個字詞本身。';

  @override
  String get wordStudyContextualMeaningHint => '它在這段經文裡是什麼意思？';

  @override
  String get wordStudyDeeperMeaningTitle => '深層含義';

  @override
  String get wordStudyDeeperMeaningHelp =>
      '有沒有來自原文、註釋書或其他研讀資料的洞見，能在基本定義之外帶來更深的理解？聖經其他部分如何塑造它的意義？Strong\'s 經文彙編或 Blue Letter Bible 在這裡會有幫助。';

  @override
  String get wordStudyDeeperMeaningHint => '聖經其他部分如何塑造它的意義？';

  @override
  String get wordStudyApplicationTitle => '應用';

  @override
  String get wordStudyApplicationHelp => '這個真理應該如何塑造你的生活？要具體、切身、實際。';

  @override
  String get wordStudyApplicationHint => '你要如何實踐？';

  @override
  String get wordStudyDoneTitle => '字詞研究完成';

  @override
  String wordStudySectionHelpSemantics(String title) {
    return '$title，關於這個部分';
  }

  @override
  String get lectureTimeMarkNoRecording => '此筆記沒有可播放的錄音。';

  @override
  String get lectureTimeMarkStopRecordingFirst => '請先停止錄音，再從時間標記處播放。';

  @override
  String get lectureTimeMarkPastEnd => '該時間標記超出了錄音的長度。';

  @override
  String get onboardingSkip => '跳過';

  @override
  String get onboardingBack => '上一步';

  @override
  String get onboardingNext => '下一步';

  @override
  String get onboardingWelcomeOverline => '歡迎';

  @override
  String get onboardingWelcomeTitle => '一次一段經文，好好查考聖經';

  @override
  String get onboardingWelcomeBody =>
      '這個應用程式幫助你寫講道大綱、做講課筆記和字詞研究——經文始終就在旁邊，用你的語言和你選擇的聖經譯本。';

  @override
  String get onboardingMethodOverline => '方法';

  @override
  String get onboardingMethodTitle => '什麼是講道大綱？';

  @override
  String get onboardingMethodBody =>
      '講道大綱是一種簡短的查經方法：找出經文的中心信息，再思考如何活出來。共有六個步驟——不需要做得完美，每週都會越來越順手。';

  @override
  String get onboardingStepsOverline => '逐步進行';

  @override
  String get onboardingStepsTitle => '六個步驟';

  @override
  String get onboardingStepContent => '用自己的話，把經文概括成10到20個簡短的小段。';

  @override
  String get onboardingStepDivisions => '把這些小段歸納成2到4個部分。';

  @override
  String get onboardingStepSummary => '用不超過20個字概括整段經文。';

  @override
  String get onboardingStepFcf => '墮落景況焦點：經文所針對的人的需要或破碎。';

  @override
  String get onboardingStepAim => '你希望聽眾學到的那個核心真理。';

  @override
  String get onboardingStepApplication => '幫助人把經文活在日常生活中的問題。';

  @override
  String get onboardingLecturesOverline => '講課與字詞研究';

  @override
  String get onboardingLecturesTitle => '用心聆聽，深入挖掘';

  @override
  String get onboardingLecturesBody =>
      '錄下講課——關閉螢幕也會繼續錄音，並直接在手機上轉成文字。一邊聽一邊做筆記，加上時間標記，方便以後找到那一刻。';

  @override
  String get onboardingWordStudyBody => '對某個詞感到好奇？開始一個字詞研究，深入了解它在經文中的意思。';

  @override
  String get onboardingStartOverline => '開始';

  @override
  String get onboardingStartTitle => '你已準備好開始了';

  @override
  String get onboardingStartBody => '從本週的經文開始，或者先四處看看。你寫下的每一步都會自動儲存。';

  @override
  String get onboardingReopenHint => '你隨時可以在設定中再次開啟本指南。';

  @override
  String get onboardingStartThisWeek => '開始本週的講道大綱';

  @override
  String get onboardingExplore => '自己先看看';

  @override
  String onboardingThisWeekPassage(String passage) {
    return '本週：$passage';
  }

  @override
  String get onboardingSettingsRow => '講道大綱怎麼做';

  @override
  String bibleOfflineSize(String size) {
    return '可離線 · $size';
  }

  @override
  String bibleDownloadedSize(String size) {
    return '已下載 · $size';
  }

  @override
  String get bibleDownloadAction => '下載以離線使用';

  @override
  String get bibleDownloading => '正在下載…';

  @override
  String get bibleRemoveDownload => '刪除下載';

  @override
  String bibleDownloadFailed(String translation) {
    return '無法下載 $translation。請檢查網路後再試一次。';
  }

  @override
  String get bibleOfflineTitle => '沒有網路連線';

  @override
  String bibleOfflineMessage(String translation) {
    return '這段經文來自 Bible Gateway，需要連上網路。下載 $translation 後可隨時閱讀。';
  }

  @override
  String get bibleOfflineNoDownloadMessage =>
      '這段經文來自 Bible Gateway，需要連上網路。請連線後再試一次。';

  @override
  String get bibleTryAgain => '再試一次';

  @override
  String bibleNeedsDownloadTitle(String translation) {
    return '下載 $translation';
  }

  @override
  String bibleNeedsDownloadMessage(String size) {
    return '這本聖經從你的裝置讀取。下載一次（約 $size）即可查看經文。';
  }

  @override
  String bibleNotInTranslation(String translation) {
    return '在 $translation 中找不到這段經文。';
  }

  @override
  String get bibleVerseTapTip => '提示：點按經節編號，即可從該節開始寫摘要。';

  @override
  String bibleVerseTapLabel(String verse) {
    return '從第 $verse 節開始寫摘要';
  }

  @override
  String get shareSheetTitle => '分享這份學習';

  @override
  String get shareLink => '分享連結';

  @override
  String get shareLinkSubtitle => '可在應用程式或任何瀏覽器中開啟';

  @override
  String get shareCopyLink => '複製連結';

  @override
  String get shareLinkCopied => '連結已複製';

  @override
  String get shareShowQr => '顯示 QR 碼';

  @override
  String get shareSharePdf => '分享 PDF';

  @override
  String get shareLinkFailed => '無法分享連結。';

  @override
  String get shareLinkTooLongTitle => '這個連結很長';

  @override
  String shareLinkTooLongMessage(int count) {
    return '這份學習產生的連結有 $count 個字元。有些應用程式可能會截斷它，導致無法開啟。如果發生這種情況，請改為分享 PDF。';
  }

  @override
  String get shareAnyway => '仍然分享';

  @override
  String get shareQrTitle => '掃描開啟';

  @override
  String get shareQrHint => '用另一支手機的相機對準 QR 碼即可開啟這份學習。';

  @override
  String get shareQrTooLong => '這份學習太長，無法產生 QR 碼。請改用「分享連結」或「複製連結」。';

  @override
  String get shareQrSemantics => '指向這份學習的 QR 碼';

  @override
  String get importFromLink => '從連結匯入';

  @override
  String get importSheetMessage => '貼上別人分享給你的 Homiletics 連結。儲存副本前可以先查看內容。';

  @override
  String get importFieldHint => 'https://homiletics.app/view#…';

  @override
  String get importPaste => '貼上';

  @override
  String get importOpen => '開啟';

  @override
  String get importClipboardEmpty => '沒有可貼上的文字。';

  @override
  String get importInvalidLink => '這不是 Homiletics 連結，或連結不完整。請再向對方索取一次。';

  @override
  String get importNewerVersion =>
      '這份學習來自較新版本的 Homiletics。請更新 Homiletics 後再開啟。';

  @override
  String get importCouldNotOpenTitle => '無法開啟此連結';

  @override
  String get importPreviewHomiletic => '分享的講道大綱';

  @override
  String get importPreviewWordStudy => '分享的字詞研究';

  @override
  String get importPreviewNote => '這是別人分享給你的。儲存會在你的學習中新增一份副本，不會更改你已有的內容。';

  @override
  String importPreviewTranslation(String translation) {
    return '使用 $translation 撰寫';
  }

  @override
  String get importSaveCopy => '儲存副本';

  @override
  String get importSaved => '已儲存到你的學習';

  @override
  String get importSaveFailed => '無法儲存這份學習，請重試。';

  @override
  String get startOpenSharedStudy => '開啟分享的學習';
}
