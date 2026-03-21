import 'package:flutter/material.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/pages/homeletic_editor.dart';
import 'package:homiletics/storage/homiletic_storage.dart';

Future<Map<int, String>> _passagesForApplications(List<Application> apps) async {
  final ids = apps.map((a) => a.homileticsId).toSet();
  final entries = await Future.wait(ids.map((id) async {
    try {
      final h = await getHomileticById(id);
      return MapEntry(id, h.passage);
    } catch (_) {
      return MapEntry(id, '');
    }
  }));
  return Map.fromEntries(entries);
}

class ApplicationPage extends StatefulWidget {
  final List<Application> applications;

  const ApplicationPage({Key? key, required this.applications}) : super(key: key);

  @override
  State<ApplicationPage> createState() => _ApplicationPageState();
}

class _ApplicationPageState extends State<ApplicationPage> {
  late final Future<Map<int, String>> _passageFuture;

  @override
  void initState() {
    super.initState();
    _passageFuture = _passagesForApplications(widget.applications);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Application Questions"),
      ),
      body: FutureBuilder<Map<int, String>>(
        future: _passageFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final passages = snapshot.data ?? {};

          if (widget.applications.isEmpty) {
            return Center(
              child: Text(
                "No application questions yet.",
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: widget.applications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final application = widget.applications[index];
              final passage = passages[application.homileticsId]?.trim() ?? '';
              return _ApplicationQuestionTile(
                application: application,
                passage: passage,
              );
            },
          );
        },
      ),
    );
  }
}

class _ApplicationQuestionTile extends StatelessWidget {
  final Application application;
  final String passage;

  const _ApplicationQuestionTile({
    required this.application,
    required this.passage,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          Homiletic homiletic =
              await getHomileticById(application.homileticsId);
          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomileticEditor(homiletic: homiletic),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (passage.isNotEmpty) ...[
                Text(
                  passage,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
              ],
              Text(
                application.text,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
