import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:homiletics/storage/pdf_generation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../tool/templates/worksheet_templates.dart';

/// Builds the blank homiletic and word study worksheets in every app
/// language, Letter and A4. Set TEMPLATES_OUT_DIR to write them there as
/// homiletic-template-<locale>-<letter|a4>.pdf and
/// word-study-template-<locale>-<letter|a4>.pdf, and PDF_NOTO_DIR to a folder
/// holding NotoSansSC-Regular.ttf / NotoSansTC-Regular.ttf for Chinese
/// (without it the Chinese worksheets are skipped).
void main() {
  late HomileticPdfFonts fonts;
  final String? outDir = Platform.environment['TEMPLATES_OUT_DIR'];
  final String? notoDir = Platform.environment['PDF_NOTO_DIR'];

  setUpAll(() async {
    fonts = await HomileticPdfFonts.load((String path) async =>
        ByteData.sublistView(await File(path).readAsBytes()));
  });

  int pageCount(Uint8List bytes) => RegExp(r'/Type\s*/Page[^s]')
      .allMatches(String.fromCharCodes(bytes))
      .length;

  HomileticPdfFonts? fontsFor(TemplateLocale loc) {
    if (!loc.isChinese) return fonts;
    final String name =
        loc.isTraditional ? 'NotoSansTC-Regular.ttf' : 'NotoSansSC-Regular.ttf';
    final File file = File('$notoDir/$name');
    if (notoDir == null || !file.existsSync()) return null;
    return fonts
        .withFallback([pw.Font.ttf(paddedFont(file.readAsBytesSync()))]);
  }

  for (final TemplateLocale loc in templateLocales) {
    for (final MapEntry<String, PdfPageFormat> format
        in templateFormats.entries) {
      test('worksheets ${loc.tag} ${format.key}', () async {
        final HomileticPdfFonts? f = fontsFor(loc);
        if (f == null) {
          markTestSkipped('set PDF_NOTO_DIR for Chinese');
          return;
        }
        final Uint8List homiletic =
            await buildHomileticTemplate(loc, fonts: f, format: format.value)
                .save();
        final Uint8List wordStudy =
            await buildWordStudyTemplate(loc, fonts: f, format: format.value)
                .save();
        expect(pageCount(homiletic), 2);
        expect(pageCount(wordStudy), 1);
        if (outDir != null) {
          await Directory(outDir).create(recursive: true);
          await File('$outDir/homiletic-template-${loc.tag}-${format.key}.pdf')
              .writeAsBytes(homiletic);
          await File('$outDir/word-study-template-${loc.tag}-${format.key}.pdf')
              .writeAsBytes(wordStudy);
        }
      });
    }
  }
}
