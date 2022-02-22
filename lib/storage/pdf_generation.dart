// import 'package:flutter/services.dart';
// import 'package:homiletics/classes/Division.dart';
// import 'package:homiletics/classes/application.dart';
// import 'package:homiletics/classes/content_summary.dart';
// import 'package:homiletics/classes/homiletic.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'dart:io';

// Future<void> createHomileticsPdf(
//     Homiletic homiletic,
//     List<ContentSummary> summaries,
//     List<Division> divisions,
//     List<Application> applications) async {
//   final pdf = pw.Document();

//   final font = await rootBundle.load("assets/fonts/Ubuntu-Regular.ttf");
//   final regularTtf = pw.Font.ttf(font);

//   final pw.TextStyle defaultStyle = pw.TextStyle(font: regularTtf);

//   pdf.addPage(pw.Page(
//       pageFormat: PdfPageFormat.a4,
//       build: (pw.Context context) {
//         return pw.Column(children: [
//           pw.Text(homiletic.passage),
//           pw.Text("Content List:", style: defaultStyle),
//           pw.Table(children: [
//             ...summaries
//                 .map((summary) => pw.TableRow(children: [
//                       pw.Text("${summaries.indexOf(summary) + 1}",
//                           style: defaultStyle),
//                       pw.Text(summary.passage, style: defaultStyle),
//                       pw.Text(summary.summary, style: defaultStyle)
//                     ]))
//                 .toList()
//           ])
//         ]);
//       }));

//   if (Platform.isAndroid) {
//     final outputDir =
//         (await getExternalStorageDirectories(type: StorageDirectory.downloads))!
//             .first;

//     final file = File(
//         "${outputDir.path}/${homiletic.passage.replaceAll(' ', "_")}_homiletics.pdf");
//     await file.writeAsBytes(await pdf.save());
//   } else if (Platform.isMacOS) {
//     final outputDir = getDownloadsDirectory();

//     final file = File(
//         "$outputDir/${homiletic.passage.replaceAll(' ', "_")}_homiletics.pdf");
//     await file.writeAsBytes(await pdf.save());
//   } else if (Platform.isIOS) {
//     final outputDir = await getApplicationDocumentsDirectory();

//     final file = File(
//         "${outputDir.path}/${homiletic.passage.replaceAll(' ', "_")}_homiletics.pdf");
//     await file.writeAsBytes(await pdf.save());
//   } else {
//     print("none of the above");
//   }
// }
