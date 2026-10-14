import 'package:flutter/material.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:homiletics/common/report_error.dart';
import 'package:homiletics/common/study_data_builder.dart';
import 'package:homiletics/components/editor/passage_split_scaffold.dart';
import 'package:homiletics/components/homiletics/aim_card.dart';
import 'package:homiletics/components/homiletics/application_questions_card.dart';
import 'package:homiletics/components/homiletics/content_summaries_card.dart';
import 'package:homiletics/components/homiletics/divisions_card.dart';
import 'package:homiletics/components/homiletics/fcf_card.dart';
import 'package:homiletics/components/homiletics/summary_sentence_card.dart';
import 'package:homiletics/storage/application_storage.dart';
import 'package:homiletics/storage/content_summary_storage.dart';
import 'package:homiletics/storage/division_storage.dart';
import 'package:homiletics/storage/pdf_generation.dart';

class HomileticEditor extends StatefulWidget {
  const HomileticEditor({Key? key, this.homiletic}) : super(key: key);

  final Homiletic? homiletic;

  @override
  State<HomileticEditor> createState() => _HomileticState();
}

class _HomileticState extends State<HomileticEditor> {
  late final Homiletic _thisHomiletic;
  List<ContentSummary> _summaries = [];
  List<Division> _divisions = [];
  List<Application> _applications = [];

  @override
  void initState() {
    super.initState();
    _thisHomiletic = widget.homiletic ?? Homiletic();
    prepTheTable();
  }

  @override
  void dispose() {
    notifyStudyDataChanged();
    super.dispose();
  }

  Future<void> prepTheTable() async {
    try {
      // Only a brand-new homiletic needs saving up front (to get an id for
      // its rows); re-saving an existing one would bump its updated time
      // just for being opened.
      if (_thisHomiletic.id == -1) await _thisHomiletic.update();
      final List<ContentSummary> savedSummaries =
          await getSummariesByHomileticId(_thisHomiletic.id);
      final List<Division> savedDivisions =
          await getDivisionsByHomileticId(_thisHomiletic.id);
      final List<Application> savedApplications =
          await getApplicationsByHomileticId(_thisHomiletic.id);
      if (!mounted) return;

      setState(() {
        _summaries = savedSummaries.isNotEmpty
            ? savedSummaries
            : [ContentSummary.blank(_thisHomiletic.id)];
        _divisions = savedDivisions.isNotEmpty
            ? savedDivisions
            : [Division.blank(_thisHomiletic.id)];
        _applications = savedApplications.isNotEmpty
            ? savedApplications
            : [Application.blank(_thisHomiletic.id)];
      });
    } catch (error) {
      sendError(error, "load homiletics");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Something went wrong loading this lesson."),
        action: SnackBarAction(
          onPressed: () {},
          label: "Ok",
        ),
      ));
    }
  }

  /// Takes [item] out of [list] right away (so the row disappears and a
  /// second tap can't hit it), then deletes it, putting it back if the
  /// delete fails.
  Future<void> _removeRow<T>(
      List<T> list, T item, Future<void> Function() delete) async {
    final int index = list.indexOf(item);
    if (index == -1) return;
    setState(() {
      list.removeAt(index);
    });
    try {
      await delete();
    } catch (_) {
      if (mounted) {
        setState(() {
          list.insert(index.clamp(0, list.length), item);
        });
      }
      rethrow;
    }
  }

  Future<void> _runPdfAction(Future<void> Function() action, String success,
      String failure, String errorIdentifier) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      messenger.showSnackBar(SnackBar(
        content: Text(success),
        action: SnackBarAction(
          onPressed: () {},
          label: "Ok",
        ),
      ));
    } catch (error) {
      sendError(error, errorIdentifier);
      messenger.showSnackBar(SnackBar(
        content: Text(failure),
        action: SnackBarAction(
          onPressed: () {},
          label: "Ok",
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PassageSplitScaffold(
      initialPassage: _thisHomiletic.passage,
      onPassageChanged: _thisHomiletic.updatePassage,
      itemName: "Homiletics lesson",
      deletedMessage: "Homiletics Deleted",
      deleteErrorIdentifier: "delete homiletics",
      onDelete: _thisHomiletic.delete,
      extraActions: [
        EditorMenuAction(
          icon: Icons.share,
          title: 'Share',
          onSelected: () => _runPdfAction(
              () => shareHomiletic(
                  _thisHomiletic, _summaries, _divisions, _applications),
              "PDF shared successfully.",
              "Something went wrong sharing your PDF. Try again soon.",
              "Share PDF"),
        ),
        EditorMenuAction(
          icon: Icons.print,
          title: 'Print',
          onSelected: () => _runPdfAction(
              () => printHomiletic(
                  _thisHomiletic, _summaries, _divisions, _applications),
              "PDF printed successfully.",
              "Something went wrong creating your PDF. Try again soon.",
              "PDF print"),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(5),
        children: [
          ContentSummariesCard(
              contentSummaries: _summaries,
              homiletic: _thisHomiletic,
              addContentSummary: () {
                setState(() {
                  _summaries.add(ContentSummary.blank(_thisHomiletic.id));
                });
              },
              removeContentSummary: (summary) =>
                  _removeRow(_summaries, summary, summary.delete)),
          const SizedBox(height: 20),
          DivisionsCard(
              divisions: _divisions,
              homiletic: _thisHomiletic,
              addDivision: () {
                setState(() {
                  _divisions.add(Division.blank(_thisHomiletic.id));
                });
              },
              removeDivision: (division) =>
                  _removeRow(_divisions, division, division.delete)),
          const SizedBox(height: 20),
          SummarySentenceCard(homiletic: _thisHomiletic),
          const SizedBox(height: 20),
          FcfCard(homiletic: _thisHomiletic),
          const SizedBox(height: 20),
          AimCard(homiletic: _thisHomiletic),
          const SizedBox(height: 20),
          ApplicationQuestionsCard(
              applications: _applications,
              homiletic: _thisHomiletic,
              addApplication: () {
                setState(() {
                  _applications.add(Application.blank(_thisHomiletic.id));
                });
              },
              removeApplication: (application) =>
                  _removeRow(_applications, application, application.delete)),
        ],
      ),
    );
  }
}
