import 'package:flutter/material.dart';
import 'package:homiletics/services/dictionary_api_service.dart';
import 'package:homiletics/l10n/l10n.dart';
import 'package:homiletics/theme/app_theme.dart';
import 'package:homiletics/theme/widgets.dart';

/// Shows a bottom sheet of candidate dictionary definitions for [word].
/// Returns the definition the user tapped, or null if they dismissed it.
Future<String?> showDefinitionSuggestionsSheet(
    BuildContext context, String word) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.card))),
    builder: (context) => _DefinitionSuggestionsSheet(word: word),
  );
}

class _DefinitionSuggestionsSheet extends StatefulWidget {
  final String word;

  const _DefinitionSuggestionsSheet({required this.word});

  @override
  State<_DefinitionSuggestionsSheet> createState() =>
      _DefinitionSuggestionsSheetState();
}

class _DefinitionSuggestionsSheetState
    extends State<_DefinitionSuggestionsSheet> {
  late Future<List<String>> _definitions;

  @override
  void initState() {
    super.initState();
    _definitions = DictionaryApiService.fetchDefinitions(widget.word);
  }

  void _retry() {
    setState(() {
      _definitions = DictionaryApiService.fetchDefinitions(widget.word);
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final Color color = c.step(StudyStep.application);
    final AppLocalizations l = context.l10n;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Overline(l.wordStudySuggestDefinition, color: color),
                const SizedBox(height: 2),
                Text(l.wordStudyDefinitionsFor(widget.word),
                    style: AppText.title.copyWith(color: c.ink)),
                const SizedBox(height: 4),
                Text(l.wordStudyDefinitionsTapToUse,
                    style: AppText.caption.copyWith(color: c.muted)),
                const SizedBox(height: 12),
                Expanded(
                  child: FutureBuilder<List<String>>(
                    future: _definitions,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(l.wordStudyDefinitionsLoadError,
                                  textAlign: TextAlign.center,
                                  style: AppText.body.copyWith(color: c.muted)),
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: _retry,
                                child: Text(l.commonRetry),
                              ),
                            ],
                          ),
                        );
                      }
                      final definitions = snapshot.data ?? [];
                      if (definitions.isEmpty) {
                        return Center(
                            child: Text(l.wordStudyNoDefinitions,
                                textAlign: TextAlign.center,
                                style: AppText.body.copyWith(color: c.muted)));
                      }
                      return ListView.separated(
                        controller: scrollController,
                        itemCount: definitions.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final definition = definitions[index];
                          return AppCard(
                            radius: AppRadius.tile,
                            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                            onTap: () => Navigator.of(context).pop(definition),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(definition,
                                      style:
                                          AppText.body.copyWith(color: c.ink)),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.add_circle_outline_rounded,
                                    size: 22, color: color),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
