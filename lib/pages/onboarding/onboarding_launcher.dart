import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:homiletics/classes/passage_schedule.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/common/start_passage_item_flow.dart';
import 'package:homiletics/pages/onboarding/onboarding_page.dart';
import 'package:homiletics/services/suggested_passages_repository.dart';
import 'package:homiletics/storage/homiletic_storage.dart';
import 'package:homiletics/storage/lecture_note_storage.dart';
import 'package:homiletics/storage/word_study_storage.dart';

/// Whether Home should open the first-run guide by itself.
///
/// Only a fresh install sees it: once [Preferences.hasSeenOnboarding] is
/// set it never opens again, and people who used the app before this guide
/// existed (they answered one of the earlier first-use prompts, or have a
/// saved homiletic, lecture or word study) are marked as having seen it
/// without it opening — they can still open it from Settings. The saved
/// studies are only read once per install, since the flag is stored either
/// way. If they can't be read, the guide stays closed and the check runs
/// again next launch.
///
/// [hasSavedStudies] replaces the storage check in tests.
Future<bool> shouldShowOnboarding(
    {Future<bool> Function()? hasSavedStudies}) async {
  if (Preferences.hasSeenOnboarding) return false;
  if (Preferences.hasSeenTranscriptionPrompt ||
      Preferences.hasSeenFormattingPrompt) {
    Preferences.hasSeenOnboarding = true;
    return false;
  }
  final bool existingUser;
  try {
    existingUser = await (hasSavedStudies ?? _hasSavedStudies)();
  } catch (_) {
    // The storage functions report their own errors.
    return false;
  }
  if (existingUser) {
    Preferences.hasSeenOnboarding = true;
    return false;
  }
  return true;
}

/// Read-only: whether anything has been saved yet.
Future<bool> _hasSavedStudies() async {
  final List<bool> found = await Future.wait([
    getAllHomiletics().then((list) => list.isNotEmpty),
    getLectureNotes().then((list) => list.isNotEmpty),
    getAllWordStudies().then((list) => list.isNotEmpty),
  ]);
  return found.contains(true);
}

/// The week Home's "This week" card opens on, from the cached passages
/// feed (Home refreshes it in the background), or null if there's none yet.
Future<PassageSchedule?> loadThisWeeksSchedule() async {
  final List<PassageSchedule>? schedules =
      await SuggestedPassagesRepository.readCachedSchedules();
  if (schedules == null || schedules.isEmpty) return null;
  final DateTime now = DateTime.now();
  final int current = schedules.lastIndexWhere((s) => s.rollout.isBefore(now));
  // Same rule as the week cards: before the first week, show the first.
  return schedules[math.max(0, current)];
}

/// Opens the guide full screen and marks it seen when it closes. If the
/// reader chose "Start this week's homiletic", opens that homiletic the way
/// the week card does.
Future<void> showOnboarding(BuildContext context,
    {Future<PassageSchedule?> Function()? loadThisWeek}) async {
  final String? passage = await Navigator.of(context).push<String>(
    MaterialPageRoute<String>(
      fullscreenDialog: true,
      builder: (_) => OnboardingPage(
        loadThisWeek: loadThisWeek ?? loadThisWeeksSchedule,
      ),
    ),
  );
  Preferences.hasSeenOnboarding = true;
  if (passage == null || !context.mounted) return;
  await startHomileticForPassage(context, passage, askIfExisting: false);
}
