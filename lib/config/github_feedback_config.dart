import 'package:homiletics/common/email_for_public_issue.dart';

/// Repo where in-browser issue fallback opens (`owner/name`).
///
/// Match the server’s `GITHUB_FEEDBACK_REPO` / default `ntatko/homiletics-mobile`.
const String kGitHubFeedbackRepo = String.fromEnvironment(
  'GITHUB_FEEDBACK_REPO',
  defaultValue: 'ntatko/homiletics-mobile',
);

/// Opens GitHub’s “new issue” page with title/body prefilled (no API key).
/// User completes submit in the browser (sign-in may be required).
///
/// [GitHub docs](https://docs.github.com/en/issues/tracking-your-work-with-issues/creating-an-issue#creating-an-issue-from-a-url-query)
Uri prefilledGitHubNewIssueUri({
  required String name,
  required String email,
  required String feedback,
}) {
  final parts = kGitHubFeedbackRepo.split('/');
  if (parts.length != 2 || parts[0].isEmpty || parts[1].isEmpty) {
    throw StateError('Invalid kGitHubFeedbackRepo: $kGitHubFeedbackRepo');
  }
  final path = '/${parts[0]}/${parts[1]}/issues/new';
  final title = _issueTitle(feedback);
  final safeName = _cap(name.trim(), _maxNameChars);
  final safeEmail = _cap(email.trim(), _maxEmailChars);

  Uri build(String feedbackText) => Uri.https('github.com', path, {
        'title': title,
        'body': _issueBody(
            name: safeName, email: safeEmail, feedback: feedbackText),
      });

  // Browsers/servers differ; keep the whole URL bounded.
  final full = build(feedback);
  if (full.toString().length <= _maxUriChars) return full;

  // Too long: keep the longest prefix of the feedback that fits. Query
  // encoding is per character, so the encoded length of a prefix is the sum
  // of each character's encoded length — computed in a single pass.
  const marker = 'X';
  final overhead =
      build('$marker\n\n$_truncationNote').toString().length - marker.length;
  final budget = _maxUriChars - overhead;
  final text = feedback.trim();
  var used = 0;
  var end = 0;
  for (final rune in text.runes) {
    final encodedLength =
        Uri.encodeQueryComponent(String.fromCharCode(rune)).length;
    if (used + encodedLength > budget) break;
    used += encodedLength;
    end += rune > 0xFFFF ? 2 : 1;
  }
  final kept = text.substring(0, end);
  return build(kept.isEmpty ? _truncationNote : '$kept\n\n$_truncationNote');
}

const int _maxUriChars = 7500;
const int _maxNameChars = 100;
// RFC 5321 maximum address length.
const int _maxEmailChars = 254;
const String _truncationNote = '…(truncated; server was unreachable)';

String _cap(String value, int maxChars) {
  if (value.length <= maxChars) return value;
  // Avoid splitting a surrogate pair.
  var end = maxChars;
  final unit = value.codeUnitAt(end - 1);
  if (unit >= 0xD800 && unit <= 0xDBFF) end--;
  return '${value.substring(0, end)}…';
}

String _issueTitle(String feedback) {
  final line = feedback.trim().split(RegExp(r'\s+')).take(12).join(' ');
  if (line.length <= 72) return line.isEmpty ? 'App feedback' : line;
  return '${line.substring(0, 69)}…';
}

String _issueBody({
  required String name,
  required String email,
  required String feedback,
}) {
  final buf = StringBuffer()
    ..writeln(
        'Submitted from the Homiletics app (could not reach the feedback server).')
    ..writeln()
    ..writeln('**Name:** ${name.isEmpty ? '_(not provided)_' : name}')
    ..writeln('**Email:** ${obscureEmailForPublicIssue(email)}')
    ..writeln()
    ..writeln('---')
    ..writeln()
    ..write(feedback.trim());
  return buf.toString();
}
