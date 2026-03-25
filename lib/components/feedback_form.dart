import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/config/api_config.dart';
import 'package:homiletics/config/github_feedback_config.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

/// Thrown when the API rejects the payload (e.g. empty feedback) — no GitHub fallback.
class FeedbackBadRequest implements Exception {}

class FeedbackForm extends StatefulWidget {
  const FeedbackForm({Key? key}) : super(key: key);

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  String _name = '';
  String _email = '';
  String _content = '';

  @override
  Widget build(BuildContext context) {
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
                const Text(
                  'Leave Some Feedback',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close))
              ],
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Your feedback is submitted as a public GitHub issue—anyone on the internet can read it. '
                'Do not include passwords or other private information. '
                'Your email is partially hidden on GitHub; we may keep the full address on our servers only to follow up.',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ),
            SizedBox(
              height: 300,
              child: ListView(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: TextField(
                        onChanged: (value) => setState(() {
                          _name = value;
                        }),
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
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
                        decoration: const InputDecoration(
                          labelText: 'Email (optional)',
                          border: OutlineInputBorder(),
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
                        decoration: const InputDecoration(
                          labelText: 'Feedback',
                          border: OutlineInputBorder(),
                        ),
                      )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15, top: 12),
              child: ElevatedButton(
                child: const Text("Submit"),
                onPressed: () async {
                  if (_content.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please enter your feedback first.')),
                    );
                    return;
                  }
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    final issueUrl =
                        await submitFeedback(_name, _email, _content);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    if (issueUrl != null) {
                      messenger.showSnackBar(SnackBar(
                        content: const Text(
                          'Submitted. Open the issue on GitHub anytime to add comments (sign-in optional).',
                        ),
                        duration: const Duration(seconds: 8),
                        action: SnackBarAction(
                          label: 'Open',
                          onPressed: () async {
                            final uri = Uri.parse(issueUrl);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                        ),
                      ));
                    } else {
                      messenger.showSnackBar(SnackBar(
                        content: const Text('Successfully submitted feedback'),
                        action: SnackBarAction(
                          onPressed: () {},
                          label: 'Ok',
                        ),
                      ));
                    }
                  } on FeedbackBadRequest {
                    if (!context.mounted) return;
                    messenger.showSnackBar(const SnackBar(
                      content: Text(
                          'Could not submit that request. Check your message and try again.'),
                    ));
                  } catch (error) {
                    if (!context.mounted) return;
                    sendError(error, "Feedback Submission");
                    final fallbackUri = prefilledGitHubNewIssueUri(
                      name: _name,
                      email: _email,
                      feedback: _content,
                    );
                    await showDialog<void>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Could not reach the server'),
                        content: const Text(
                          'Open GitHub in your browser to file this report instead. '
                          'You may need to sign in there to submit the issue.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Not now'),
                          ),
                          TextButton(
                            onPressed: () async {
                              if (await canLaunchUrl(fallbackUri)) {
                                await launchUrl(
                                  fallbackUri,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                              if (ctx.mounted) Navigator.pop(ctx);
                            },
                            child: const Text('Open GitHub'),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            )
          ],
        ));
  }
}

/// Returns the GitHub issue URL when the server created an issue; otherwise null.
Future<String?> submitFeedback(String name, String email, String feedback) async {
  final response = await http
      .post(
    Uri.parse('$kHomileticsApiBase/feedback'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(
        <String, String>{'name': name, 'email': email, 'feedback': feedback}),
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
