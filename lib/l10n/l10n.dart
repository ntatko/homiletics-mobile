import 'package:flutter/widgets.dart';
import 'package:homiletics/l10n/generated/app_localizations.dart';
import 'package:homiletics/theme/app_theme.dart';

export 'package:homiletics/l10n/generated/app_localizations.dart';

/// Shorthand for the current interface strings: `context.l10n.appTitle`.
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Localized names for the homiletic steps (also used for word-study
/// section colors). Use these in the UI instead of [StudyStep.label],
/// which stays English for code that has no BuildContext.
extension StudyStepL10n on StudyStep {
  String localizedLabel(AppLocalizations l) => switch (this) {
        StudyStep.content => l.stepContent,
        StudyStep.divisions => l.stepDivisions,
        StudyStep.summary => l.stepSummary,
        StudyStep.fcf => l.stepFcf,
        StudyStep.aim => l.stepAim,
        StudyStep.application => l.stepApplication,
      };

  String localizedShortLabel(AppLocalizations l) => switch (this) {
        StudyStep.content => l.stepShortContent,
        StudyStep.divisions => l.stepShortDivisions,
        StudyStep.summary => l.stepShortSummary,
        StudyStep.fcf => l.stepShortFcf,
        StudyStep.aim => l.stepShortAim,
        StudyStep.application => l.stepShortApplication,
      };
}
