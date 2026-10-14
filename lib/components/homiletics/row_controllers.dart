import 'package:flutter/material.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/theme/app_theme.dart';

/// Owns the [TextEditingController]s for each row of a list card, keyed by
/// the row object's identity, so typing isn't reset by rebuilds and
/// controllers are disposed when their row goes away.
class RowControllers<T extends Object> {
  final List<TextEditingController> Function(T row) _create;
  final Map<T, List<TextEditingController>> _controllers =
      Map<T, List<TextEditingController>>.identity();
  bool _focusNextNewRow = false;
  T? _autofocusRow;

  RowControllers(this._create);

  /// The controllers for [row], created the first time it's seen.
  List<TextEditingController> of(T row) {
    return _controllers.putIfAbsent(row, () {
      if (_focusNextNewRow) {
        _focusNextNewRow = false;
        _autofocusRow = row;
      }
      return _create(row);
    });
  }

  /// Makes the next row seen for the first time autofocus (call when the
  /// user adds a row, so rows loaded from storage don't grab focus).
  void focusNextNewRow() => _focusNextNewRow = true;

  bool shouldAutofocus(T row) => identical(row, _autofocusRow);

  /// Disposes controllers for rows no longer in [rows]. Disposal waits a
  /// frame because the removed rows' text fields are still mounted until the
  /// current build finishes.
  void retainOnly(Iterable<T> rows) {
    final Set<T> keep = Set<T>.identity()..addAll(rows);
    final List<T> removed =
        _controllers.keys.where((row) => !keep.contains(row)).toList();
    for (final T row in removed) {
      final List<TextEditingController> controllers = _controllers.remove(row)!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (final c in controllers) {
          c.dispose();
        }
      });
    }
    if (_autofocusRow != null && !keep.contains(_autofocusRow)) {
      _autofocusRow = null;
    }
  }

  void dispose() {
    for (final controllers in _controllers.values) {
      for (final c in controllers) {
        c.dispose();
      }
    }
    _controllers.clear();
  }
}

/// Asks before removing a row that has text in it. Returns true to remove.
Future<bool> confirmRemoveRow(BuildContext context, String rowName) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Remove this $rowName?"),
      content: const Text("What you've written here will be deleted."),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel')),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(
              foregroundColor: AppColors.of(context).danger),
          child: const Text('Remove'),
        ),
      ],
    ),
  );
  return confirmed == true;
}

/// Removes rows one at a time: ignores taps while a removal is in progress,
/// confirms first when the row has text, and reports failures.
class RowRemover {
  bool _busy = false;

  Future<void> remove(
    BuildContext context, {
    required bool hasText,
    required String rowName,
    required Future<void> Function() remove,
    required String failureMessage,
    required String errorIdentifier,
  }) async {
    if (_busy) return;
    _busy = true;
    try {
      final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
      if (hasText) {
        final bool confirmed = await confirmRemoveRow(context, rowName);
        if (!confirmed || !context.mounted) return;
      }
      try {
        await remove();
      } catch (error) {
        messenger.showSnackBar(SnackBar(
          content: Text(failureMessage),
          action: SnackBarAction(
            onPressed: () {},
            label: "Ok",
          ),
        ));
        sendError(error, errorIdentifier);
      }
    } finally {
      _busy = false;
    }
  }
}
