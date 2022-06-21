import 'package:flutter/services.dart';
import 'package:homiletics/classes/Division.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/classes/content_summary.dart';
import 'package:homiletics/classes/homiletic.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<pw.Document> createHomileticsPdf(
    Homiletic homiletic,
    List<ContentSummary> summaries,
    List<Division> divisions,
    List<Application> applications) async {
  final pdf = pw.Document();

  final font = await rootBundle.load("assets/fonts/Ubuntu-Regular.ttf");
  final regularTtf = pw.Font.ttf(font);

  final pw.TextStyle defaultStyle = pw.TextStyle(font: regularTtf);
  final pw.TextStyle titleStyle = pw.TextStyle(
      font: regularTtf, fontWeight: pw.FontWeight.bold, fontSize: 20);

  final profileImage = pw.MemoryImage(
    (await rootBundle.load('assets/images/icon.png')).buffer.asUint8List(),
  );

  pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return [
          pw.Center(
              child: pw.Text(homiletic.passage,
                  style: const pw.TextStyle(fontSize: 30))),
          pw.Divider(),
          pw.Text("Content List:", style: titleStyle),
          pw.Table(children: [
            ...summaries
                .map((summary) => pw.TableRow(children: [
                      pw.Text("${summaries.indexOf(summary) + 1}.",
                          style: defaultStyle),
                      pw.Text(summary.passage, style: defaultStyle),
                      pw.Text(summary.summary, style: defaultStyle)
                    ]))
                .toList()
          ]),
          pw.SizedBox(height: 15),
          if (divisions.isNotEmpty) ...[
            pw.Text("Divisions:", style: titleStyle),
            pw.Table(children: [
              ...divisions
                  .map((division) => pw.TableRow(children: [
                        pw.Text(division.passage),
                        pw.Text(division.title)
                      ]))
                  .toList()
            ]),
            pw.SizedBox(height: 15),
          ],
          if (homiletic.subjectSentence != '') ...[
            pw.Text("Summary Sentence", style: titleStyle),
            pw.Text(homiletic.subjectSentence),
            pw.SizedBox(height: 15),
          ],
          if (homiletic.aim != '') ...[
            pw.Text("AIM:", style: titleStyle),
            pw.Text("Cause the audience to learn that ${homiletic.aim}"),
            pw.SizedBox(height: 15),
          ],
          if (applications.isNotEmpty) ...[
            pw.Text("Applications:", style: titleStyle),
            ...applications
                .map((application) => pw.Text(application.text))
                .toList(),
            pw.SizedBox(height: 15),
          ],
          pw.Center(
              child: pw.Container(
                  margin: const pw.EdgeInsets.only(top: 15),
                  width: 300,
                  child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                      children: [
                        pw.Image(profileImage, height: 30),
                        pw.Column(children: [
                          pw.Text(
                              'Copyright (c) ${DateTime.now().year} 13one.org',
                              style: const pw.TextStyle(color: PdfColors.grey)),
                          pw.Text('All rights reserved',
                              style: const pw.TextStyle(color: PdfColors.grey)),
                        ])
                      ])))
        ];
      }));

  return pdf;
}

Future<void> printHomiletic(Homiletic homiletic, List<ContentSummary> summaries,
    List<Division> divisions, List<Application> applications) async {
  pw.Document pdf =
      await createHomileticsPdf(homiletic, summaries, divisions, applications);
  await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save());
}

Future<void> shareHomiletic(Homiletic homiletic, List<ContentSummary> summaries,
    List<Division> divisions, List<Application> applications) async {
  pw.Document pdf =
      await createHomileticsPdf(homiletic, summaries, divisions, applications);
  await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: "homiletics-${homiletic.passage.replaceAll(" ", "_")}.pdf");
}
