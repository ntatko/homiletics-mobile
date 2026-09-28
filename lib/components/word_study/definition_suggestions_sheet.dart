import 'package:flutter/material.dart';
import 'package:homiletics/services/dictionary_api_service.dart';

/// Shows a bottom sheet of candidate dictionary definitions for [word].
/// Returns the definition the user tapped, or null if they dismissed it.
Future<String?> showDefinitionSuggestionsSheet(
    BuildContext context, String word) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
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

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Definitions for "${widget.word}"',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
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
                              const Text(
                                  "Couldn't load definitions. Try again soon."),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _definitions = DictionaryApiService
                                        .fetchDefinitions(widget.word);
                                  });
                                },
                                child: const Text("Retry"),
                              ),
                            ],
                          ),
                        );
                      }
                      final definitions = snapshot.data ?? [];
                      if (definitions.isEmpty) {
                        return const Center(
                            child: Text("No definitions found for this word."));
                      }
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: definitions.length,
                        itemBuilder: (context, index) {
                          final definition = definitions[index];
                          return Card(
                            child: ListTile(
                              title: Text(definition),
                              onTap: () => Navigator.of(context).pop(definition),
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
