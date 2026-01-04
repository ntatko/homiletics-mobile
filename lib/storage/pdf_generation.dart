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

  // Load regular and bold fonts to ensure all characters are properly embedded
  final regularFont = await rootBundle.load("assets/fonts/Ubuntu-Regular.ttf");
  final boldFont = await rootBundle.load("assets/fonts/Ubuntu-Bold.ttf");
  final regularTtf = pw.Font.ttf(regularFont);
  final boldTtf = pw.Font.ttf(boldFont);

  final pw.TextStyle defaultStyle = pw.TextStyle(font: regularTtf);
  final pw.TextStyle titleStyle = pw.TextStyle(
      font: boldTtf, fontSize: 20);

  final profileImage = pw.MemoryImage(
    (await rootBundle.load('assets/images/icon.png')).buffer.asUint8List(),
  );

  pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return [
          pw.Center(
              child: pw.Text(homiletic.passage,
                  style: pw.TextStyle(font: regularTtf, fontSize: 30))),
          pw.Divider(),
          pw.Text("Content List:", style: titleStyle),
          pw.Table(columnWidths: {
            0: const pw.FixedColumnWidth(
                20), // Set fixed width for the first column
            1: const pw.FixedColumnWidth(
                50), // Adjust other column widths as needed
            2: const pw.FlexColumnWidth(3),
          }, children: [
            ...summaries
                .map((summary) => pw.TableRow(children: [
                      pw.Container(
                        width: 20,
                        child: pw.Text("${summaries.indexOf(summary) + 1}.",
                            style: defaultStyle),
                      ),
                      pw.Container(
                          width: 50,
                          child: pw.Text(summary.passage, style: defaultStyle)),
                      pw.Text(summary.summary, style: defaultStyle)
                    ]))
                .toList()
          ]),
          pw.SizedBox(height: 15),
          if (divisions.isNotEmpty) ...[
            pw.Text("Divisions:", style: titleStyle),
            pw.Table(columnWidths: {
              0: const pw.FixedColumnWidth(
                  40), // Set fixed width for the first column
              2: const pw.FlexColumnWidth(3),
            }, children: [
              ...divisions
                  .map((division) => pw.TableRow(children: [
                        pw.Container(
                          width: 40,
                          child: pw.Text(division.passage, style: defaultStyle),
                        ),
                        pw.Text(division.title, style: defaultStyle)
                      ]))
                  .toList()
            ]),
            pw.SizedBox(height: 15),
          ],
          if (homiletic.subjectSentence != '') ...[
            pw.Text("Summary Sentence", style: titleStyle),
            pw.Text(homiletic.subjectSentence, style: defaultStyle),
            pw.SizedBox(height: 15),
          ],
          if (homiletic.fcf != '') ...[
            pw.Text("F.C.F.", style: titleStyle),
            pw.Text(homiletic.fcf, style: defaultStyle),
            pw.SizedBox(height: 15),
          ],
          if (homiletic.aim != '') ...[
            pw.Text("AIM:", style: titleStyle),
            pw.Text("Cause the audience to learn that ${homiletic.aim}", style: defaultStyle),
            pw.SizedBox(height: 15),
          ],
          if (applications.isNotEmpty) ...[
            pw.Text("Applications:", style: titleStyle),
            ...applications
                .map((application) => pw.Text(application.text, style: defaultStyle))
                .toList(),
            pw.SizedBox(height: 15),
          ],
          pw.Center(
              child: pw.Container(
                  margin: const pw.EdgeInsets.only(top: 15),
                  child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Image(profileImage, height: 30),
                        pw.SizedBox(width: 10),
                        pw.Text(
                            'made with ',
                            style: pw.TextStyle(font: regularTtf, color: PdfColors.grey)),
                        pw.UrlLink(
                          destination: 'https://homiletics.app',
                          child: pw.Text(
                              'homiletics.app',
                              style: pw.TextStyle(font: regularTtf, color: PdfColors.blue)),
                        ),
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
