import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/config/api_config.dart';
import 'package:homiletics/config/github_feedback_config.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

/// Thrown when the API rejects the payload (e.g. empty feedback) — no GitHub fallback.
class FeedbackBadRequest implements Exception {}

/// What the user is reporting. A translation issue is tagged so wording
/// reports are easy to find among the GitHub issues.
enum FeedbackType { general, translation }

/// The text that is sent: the user's message plus the app language and
/// Bible translation, which help triage (especially wording reports). This
/// goes to the maintainers, so it stays in English.
String composeFeedback(String content, FeedbackType type) {
  final String tag =
      type == FeedbackType.translation ? '[Translation issue] ' : '';
  return '$tag${content.trim()}\n\n---\n'
      'App language: ${Preferences.effectiveLanguage.code}\n'
      'Bible translation: ${Preferences.translation.code}';
}

class FeedbackForm extends StatefulWidget {
  const FeedbackForm({Key? key}) : super(key: key);

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  String _name = '';
  String _email = '';
  String _content = '';
  FeedbackType _type = FeedbackType.general;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final AppLocalizations l = context.l10n;
    return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l.feedbackTitle,
                    style: AppText.title.copyWith(color: c.ink),
                  ),
                ),
                IconButton(
                    tooltip: l.commonClose,
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: c.ink))
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l.feedbackPublicNotice,
                style: AppText.caption.copyWith(color: c.muted, height: 1.4),
              ),
            ),
            SizedBox(
              height: 300,
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 4),
                    child: SegmentedButton<FeedbackType>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                            value: FeedbackType.general,
                            label: Text(l.feedbackTypeGeneral)),
                        ButtonSegment(
                            value: FeedbackType.translation,
                            label: Text(l.feedbackTypeTranslation)),
                      ],
                      selected: {_type},
                      onSelectionChanged: (selection) =>
                          setState(() => _type = selection.first),
                    ),
                  ),
                  if (_type == FeedbackType.translation)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: Text(
                        l.feedbackTranslationHint,
                        style: AppText.caption
                            .copyWith(color: c.muted, height: 1.4),
                      ),
                    ),
                  Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: TextField(
                        onChanged: (value) => setState(() {
                          _name = value;
                        }),
                        decoration: InputDecoration(
                          labelText: l.feedbackNameLabel,
                        ),
                      )),
                  Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: TextField(
                        onChanged: (value) => setState(() {
                          _email = value;
                        }),
                        autocorrect: false,
                        enableSuggestions: false,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: l.feedbackEmailLabel,
                        ),
                      )),
                  Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: TextField(
                        onChanged: (value) => setState(() {
                          _content = value;
                        }),
                        minLines: 3,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: InputDecoration(
                          labelText: l.feedbackContentLabel,
                        ),
                      )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15, top: 12),
              child: FilledButton(
                onPressed: _submitting ? null : _submit,
                style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(46)),
                child: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l.feedbackSubmit),
              ),
            )
          ],
        ));
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final AppLocalizations l = context.l10n;
    if (_content.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.feedbackEmpty)),
      );
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final String feedback = composeFeedback(_content, _type);
    setState(() {
      _submitting = true;
    });
    try {
      final issueUrl = await submitFeedback(_name, _email, feedback);
      if (!mounted) return;
      Navigator.pop(context);
      if (issueUrl != null) {
        messenger.showSnackBar(SnackBar(
          content: Text(l.feedbackSubmittedIssue),
          duration: const Duration(seconds: 8),
          action: SnackBarAction(
            label: l.feedbackOpenIssue,
            onPressed: () => _openExternally(
              Uri.parse(issueUrl),
              messenger,
              l.feedbackBrowserFailed,
            ),
          ),
        ));
      } else {
        messenger.showSnackBar(SnackBar(
          content: Text(l.feedbackSubmitted),
          action: SnackBarAction(
            onPressed: () {},
            label: l.commonOk,
          ),
        ));
      }
    } on FeedbackBadRequest {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l.feedbackBadRequest)));
    } catch (error) {
      sendError(error, "Feedback Submission");
      if (!mounted) return;
      final fallbackUri = prefilledGitHubNewIssueUri(
        name: _name,
        email: _email,
        feedback: feedback,
      );
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.feedbackServerUnreachableTitle),
          content: Text(l.feedbackServerUnreachableBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.feedbackNotNow),
            ),
            TextButton(
              onPressed: () async {
                await _openExternally(
                    fallbackUri, messenger, l.feedbackBrowserFailed);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(l.feedbackOpenGitHub),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }
}

/// Opens [uri] in an external app, showing [failedMessage] in a snackbar if
/// nothing can handle it.
Future<void> _openExternally(
    Uri uri, ScaffoldMessengerState messenger, String failedMessage) async {
  bool launched;
  try {
    launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    launched = false;
  }
  if (!launched) {
    messenger.showSnackBar(SnackBar(content: Text(failedMessage)));
  }
}

/// Returns the GitHub issue URL when the server created an issue; otherwise null.
Future<String?> submitFeedback(
    String name, String email, String feedback) async {
  final response = await http
      .post(
        Uri.parse('$kHomileticsApiBase/feedback'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'name': name,
          'email': email,
          'feedback': feedback
        }),
      )
      .timeout(const Duration(seconds: 25));
  if (response.statusCode == 400) {
    throw FeedbackBadRequest();
  }
  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception('HTTP ${response.statusCode}');
  }
  final decoded = jsonDecode(response.body) as Map<String, dynamic>;
  final url = decoded['issueUrl'];
  if (url is String && url.isNotEmpty) return url;
  return null;
}
