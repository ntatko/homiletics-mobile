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
  if (parts.length != 2 ||
      parts[0].isEmpty ||
      parts[1].isEmpty) {
    throw StateError('Invalid kGitHubFeedbackRepo: $kGitHubFeedbackRepo');
  }
  final path = '/${parts[0]}/${parts[1]}/issues/new';
  var title = _issueTitle(feedback);
  var body = _issueBody(name: name, email: email, feedback: feedback);

  // Browsers/servers differ; keep the whole URL bounded.
  const maxUriChars = 7500;
  var uri = Uri.https('github.com', path, {'title': title, 'body': body});
  var bodyText = feedback;
  while (uri.toString().length > maxUriChars && bodyText.isNotEmpty) {
    bodyText = bodyText.substring(0, bodyText.length > 50 ? bodyText.length - 50 : 0);
    body = _issueBody(
      name: name,
      email: email,
      feedback: bodyText.isEmpty
          ? '…(truncated; server was unreachable)'
          : '$bodyText\n\n…(truncated; server was unreachable)',
    );
    uri = Uri.https('github.com', path, {'title': title, 'body': body});
  }
  return uri;
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
