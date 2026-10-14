import 'dart:async';

import 'package:flutter/material.dart';

/// Bumped whenever a study (homiletic, lecture note, word study) may have
/// been created, edited or deleted, so screens listing saved studies can
/// re-query instead of showing what they loaded when first built.
final ValueNotifier<int> studyDataVersion = ValueNotifier<int>(0);

/// Tells every [StudyDataBuilder] to reload.
///
/// The bump is deferred to a microtask so this is safe to call from
/// `dispose()` (listeners call setState, which isn't allowed while the tree
/// is being finalized).
void notifyStudyDataChanged() {
  scheduleMicrotask(() => studyDataVersion.value++);
}

/// A [FutureBuilder] that runs [load] once, caches the future in its state,
/// and runs it again whenever [notifyStudyDataChanged] is called.
///
/// While a reload is in flight the previous data stays on screen (that's how
/// [FutureBuilder] treats a replaced future), so lists don't flicker.
class StudyDataBuilder<T> extends StatefulWidget {
  final Future<T> Function() load;
  final AsyncWidgetBuilder<T> builder;
  final T? initialData;

  const StudyDataBuilder({
    Key? key,
    required this.load,
    required this.builder,
    this.initialData,
  }) : super(key: key);

  @override
  State<StudyDataBuilder<T>> createState() => _StudyDataBuilderState<T>();
}

class _StudyDataBuilderState<T> extends State<StudyDataBuilder<T>> {
  late Future<T> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.load();
    studyDataVersion.addListener(_reload);
  }

  void _reload() {
    if (!mounted) return;
    setState(() {
      _future = widget.load();
    });
  }

  @override
  void dispose() {
    studyDataVersion.removeListener(_reload);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      initialData: widget.initialData,
      builder: widget.builder,
    );
  }
}
