import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:homiletics/classes/word_study.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/common/verse_container.dart';
import 'package:homiletics/components/help_menu.dart';
import 'package:homiletics/components/preferences_modal.dart';
import 'package:homiletics/components/word_study/definition_card.dart';
import 'package:homiletics/components/word_study/other_usage_card.dart';
import 'package:homiletics/components/word_study/word_study_section_card.dart';
import 'package:homiletics/pages/home.dart';
import 'package:split_view/split_view.dart';

class WordStudyEditor extends StatefulWidget {
  const WordStudyEditor({Key? key, this.study}) : super(key: key);

  final WordStudy? study;

  @override
  State<WordStudyEditor> createState() => _WordStudyEditorState();
}

class _WordStudyEditorState extends State<WordStudyEditor> {
  late WordStudy _thisStudy;
  String _translationVersion = 'web';
  final GlobalKey<VerseContainerState> _verseContainerKey =
      GlobalKey<VerseContainerState>();

  late final TextEditingController _wordController;
  late final TextEditingController _definitionController;
  late final TextEditingController _otherUsageController;
  late final TextEditingController _contextualMeaningController;
  late final TextEditingController _deeperMeaningController;
  late final TextEditingController _applicationController;
  final FocusNode _wordFocusNode = FocusNode();
  bool _autoUsageShown = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _thisStudy = widget.study ?? WordStudy();
      _translationVersion = Preferences.preferredVersion;
    });
    _wordController = TextEditingController(text: _thisStudy.word);
    _definitionController = TextEditingController(text: _thisStudy.definition);
    _otherUsageController = TextEditingController(text: _thisStudy.otherUsage);
    _contextualMeaningController =
        TextEditingController(text: _thisStudy.contextualMeaning);
    _deeperMeaningController =
        TextEditingController(text: _thisStudy.deeperMeaning);
    _applicationController = TextEditingController(text: _thisStudy.application);
    _wordFocusNode.addListener(_onWordFocusChange);
    prepTheTable();
  }

  void _onWordFocusChange() {
    if (_wordFocusNode.hasFocus) return;
    if (_autoUsageShown) return;
    if (_wordController.text.trim().isEmpty) return;
    if (_otherUsageController.text.trim().isNotEmpty) return;
    _autoUsageShown = true;
    OtherUsageCard.openUsageSearch(
      context,
      word: _wordController.text,
      translation: Preferences.translation,
      controller: _otherUsageController,
      onChanged: _thisStudy.updateOtherUsage,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if translation preference has changed and reload if needed
    final currentTranslation = Preferences.preferredVersion;
    if (currentTranslation != _translationVersion) {
      setState(() {
        _translationVersion = currentTranslation;
      });
      // Reload the verse container with new translation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _verseContainerKey.currentState?.reloadPassage();
      });
    }
  }

  prepTheTable() async {
    await _thisStudy.update();
  }

  @override
  void dispose() {
    _wordFocusNode.removeListener(_onWordFocusChange);
    _wordFocusNode.dispose();
    _wordController.dispose();
    _definitionController.dispose();
    _otherUsageController.dispose();
    _contextualMeaningController.dispose();
    _deeperMeaningController.dispose();
    _applicationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> splitChildren = [
      ListView(
        padding: const EdgeInsets.all(15),
        children: [
          WordStudySectionCard(
            title: 'Word',
            helpText:
                'The specific word or short phrase you\'re studying. Once you\'ve entered it, Definition and Other Usage can suggest content for you.',
            hint: 'The specific word or short phrase you\'re studying',
            controller: _wordController,
            onChanged: _thisStudy.updateWord,
            lightColor: Colors.grey[200]!,
            minLines: 1,
            focusNode: _wordFocusNode,
          ),
          const SizedBox(height: 12),
          DefinitionCard(
            wordController: _wordController,
            controller: _definitionController,
            onChanged: _thisStudy.updateDefinition,
            lightColor: const Color.fromARGB(255, 196, 255, 241),
          ),
          const SizedBox(height: 12),
          OtherUsageCard(
            wordController: _wordController,
            translation: Preferences.translation,
            controller: _otherUsageController,
            onChanged: _thisStudy.updateOtherUsage,
            lightColor: const Color.fromARGB(255, 209, 227, 255),
          ),
          const SizedBox(height: 12),
          WordStudySectionCard(
            title: 'Contextual Meaning',
            helpText:
                'What did the author intend this word to mean here, in this passage? Consider the surrounding verses, not just the word alone.',
            hint: 'What did the author intend this word to mean here, in this passage?',
            controller: _contextualMeaningController,
            onChanged: _thisStudy.updateContextualMeaning,
            lightColor: const Color.fromARGB(255, 230, 220, 255),
          ),
          const SizedBox(height: 12),
          WordStudySectionCard(
            title: 'Deeper Meaning',
            helpText:
                'Any insight from the original language, commentary, or outside study that adds depth beyond the basic definition? A Strong\'s concordance or Blue Letter Bible can help here.',
            hint: 'Any insight from the original language, commentary, or outside study that adds depth?',
            controller: _deeperMeaningController,
            onChanged: _thisStudy.updateDeeperMeaning,
            lightColor: const Color.fromARGB(255, 255, 236, 179),
          ),
          const SizedBox(height: 12),
          WordStudySectionCard(
            title: 'Application',
            helpText:
                'How should this truth shape your life? Be specific, personal, and practical.',
            hint: 'How should this truth shape your life?',
            controller: _applicationController,
            onChanged: _thisStudy.updateApplication,
            lightColor: const Color.fromARGB(255, 214, 245, 214),
          ),
          const SizedBox(height: 12),
          const HelpMenu(),
        ],
      ),
      VerseContainer(
          key: _verseContainerKey,
          passage: _thisStudy.passage,
          translation: Preferences.translation)
    ];

    return Scaffold(
        appBar: AppBar(
          title: TextField(
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
            controller: TextEditingController()..text = _thisStudy.passage,
            decoration: const InputDecoration(suffixIcon: Icon(Icons.edit)),
            onChanged: (String value) {
              _thisStudy.updatePassage(value);
            },
            onEditingComplete: () => setState(() => {}),
            onSubmitted: (_) => setState(() {}),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (kIsWeb) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Are you sure?'),
                    content: const Text('You will lose all your work.'),
                    actions: [
                      ElevatedButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      ElevatedButton(
                        child: const Text('OK'),
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Home()),
                              (r) => false);
                        },
                      ),
                    ],
                  ),
                );
              } else {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const Home()),
                    (r) => false);
              }
            },
          ),
          actions: [
            PopupMenuButton(
                onSelected: (value) async {
                  switch (value) {
                    case 0:
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const Home()),
                          (r) => false);
                      return;
                    case 1:
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Are you sure?"),
                              content: const Text(
                                  "Deleting this Word Study is permanent and cannot be undone. Are you sure you wish to proceed?"),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () async {
                                    try {
                                      await _thisStudy.delete();
                                      if (!mounted) return;
                                      final navigatorContext = context;
                                      Navigator.pushAndRemoveUntil(
                                          navigatorContext,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const Home()),
                                          (r) => false);
                                      ScaffoldMessenger.of(navigatorContext)
                                          .showSnackBar(SnackBar(
                                        content:
                                            const Text("Word Study Deleted"),
                                        action: SnackBarAction(
                                          onPressed: () {},
                                          label: "Ok",
                                        ),
                                      ));
                                    } catch (error) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: const Text(
                                            "Something went wrong. Try again soon."),
                                        action: SnackBarAction(
                                          onPressed: () {},
                                          label: "Ok",
                                        ),
                                      ));
                                      sendError(error, "word study deletion");
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text("Delete"),
                                )
                              ],
                            );
                          });
                      return;
                    case 2:
                      showDialog(
                          context: context,
                          builder: ((context) => PreferencesModal(
                                onTranslationChanged: () {
                                  // Reload the verse container when translation changes
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    _verseContainerKey.currentState
                                        ?.reloadPassage();
                                  });
                                },
                              )));
                      return;
                  }
                },
                icon: const Icon(Icons.menu),
                itemBuilder: (context) => [
                      if (!kIsWeb)
                        const PopupMenuItem(
                          value: 0,
                          child: ListTile(
                              leading: Icon(Icons.save), title: Text("Save")),
                        ),
                      if (!kIsWeb)
                        const PopupMenuItem(
                          value: 1,
                          child: ListTile(
                            title: Text('Delete'),
                            leading: Icon(Icons.delete),
                          ),
                        ),
                      if (!kIsWeb)
                        const PopupMenuItem(
                          value: 2,
                          child: ListTile(
                            title: Text('Preferences'),
                            leading: Icon(Icons.settings),
                          ),
                        ),
                    ]),
          ],
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          // Use screen size to determine orientation, not available space
          // This prevents keyboard opening from triggering layout changes
          final screenSize = MediaQuery.sizeOf(context);
          final isLandscape = screenSize.width > screenSize.height;

          return SafeArea(
            bottom: false,
            child: SplitView(
                indicator: SplitIndicator(
                    viewMode: isLandscape
                        ? SplitViewMode.Horizontal
                        : SplitViewMode.Vertical),
                viewMode: isLandscape
                    ? SplitViewMode.Horizontal
                    : SplitViewMode.Vertical,
                children: isLandscape
                    ? splitChildren.reversed.toList()
                    : splitChildren),
          );
        }));
  }
}
