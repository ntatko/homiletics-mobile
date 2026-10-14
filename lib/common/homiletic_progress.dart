import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/storage/application_storage.dart';
import 'package:homiletics/storage/content_summary_storage.dart';
import 'package:homiletics/storage/division_storage.dart';
import 'package:homiletics/storage/homiletic_storage.dart';
import 'package:homiletics/theme/app_theme.dart';

/// Which [StudyStep]s of a homiletic have something written in them.
///
/// A step counts as done when its fields are non-empty: any content summary,
/// any division, the summary sentence, the FCF, the aim, any application.
Future<Set<StudyStep>> loadHomileticProgress(Homiletic homiletic) async {
  final Set<StudyStep> done = {};
  if (homiletic.id < 0) return done;

  final summaries = await getSummariesByHomileticId(homiletic.id);
  final divisions = await getDivisionsByHomileticId(homiletic.id);
  final applications = await getApplicationsByHomileticId(homiletic.id);

  if (summaries.any((s) => s.summary.trim().isNotEmpty)) {
    done.add(StudyStep.content);
  }
  if (divisions.any((d) => d.title.trim().isNotEmpty)) {
    done.add(StudyStep.divisions);
  }
  if (homiletic.subjectSentence.trim().isNotEmpty) done.add(StudyStep.summary);
  if (homiletic.fcf.trim().isNotEmpty) done.add(StudyStep.fcf);
  if (homiletic.aim.trim().isNotEmpty) done.add(StudyStep.aim);
  if (applications.any((a) => a.text.trim().isNotEmpty)) {
    done.add(StudyStep.application);
  }
  return done;
}

/// Progress of the most recent homiletic for [passage], or null when there
/// is no homiletic for it yet.
Future<Set<StudyStep>?> loadPassageProgress(String passage) async {
  final List<Homiletic> matches =
      await getHomileticsMatchingPassageReference(passage);
  if (matches.isEmpty) return null;
  return loadHomileticProgress(matches.first);
}

/// "2 of 6 steps", "All 6 steps" or "Not started".
String describeProgress(Set<StudyStep>? done) {
  if (done == null) return 'Not started';
  if (done.length == StudyStep.values.length) return 'All 6 steps';
  return '${done.length} of ${StudyStep.values.length} steps';
}
