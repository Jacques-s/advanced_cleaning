import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/helpers/export_helper.dart';
import 'package:advancedcleaning/models/corrective_action_model.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TopIssuesPdf {
  TopIssuesPdf(
      {required this.answers,
      required this.siteTitle,
      required this.startDate});
  final Map<String, Map<String, dynamic>> answers;
  final String siteTitle;
  final DateTime startDate;

  List<pw.Widget> areaRows() {
    List<pw.Widget> rows = [];
    answers.forEach((areaTitle, values) {
      rows.add(
        pw.Row(
          children: [
            cellItem(areaTitle, 1,
                bold: true, color: pdfPrimaryColor, whiteText: true)
          ],
        ),
      );

      values.forEach((questionId, question) {
        String questionTitle = question['questionTitle'] ?? '-';
        var count = question['count'] ?? 0;

        CorrectiveAction action = CorrectiveAction(
            id: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            accountId: question['accountId'] ?? '',
            siteId: question['siteId'] ?? '',
            areaId: question['areaId'] ?? '',
            questionId: questionId,
            questionTitle: questionTitle,
            failureCount: count,
            userId: '',
            action: '',
            actionMonth: startDate);

        rows.add(itemRow(action));
      });
    });

    return rows;
  }

  pw.Widget itemRow(CorrectiveAction action) => pw.Row(
        children: [
          cellItem(action.questionTitle, 3),
          cellItem('${action.failureCount}', 2),
        ],
      );

  pw.Widget cellItem(String title, int flex,
          {bool bold = false,
          double fontSize = pdfFontSizeGeneral,
          PdfColor? color,
          bool whiteText = false}) =>
      pw.Expanded(
        flex: flex,
        child: pw.Container(
          padding: const pw.EdgeInsets.all(4.0),
          decoration: pw.BoxDecoration(
            color: color,
            border: pw.Border.all(color: PdfColor.fromHex('#000'), width: 0.5),
          ),
          child: pw.Text(
            title,
            style: pw.TextStyle(
                color: whiteText ? PdfColor.fromHex('#FFF') : null,
                fontWeight: bold ? pw.FontWeight.bold : null,
                fontSize: fontSize),
          ),
        ),
      );

  pw.Widget pdfHeader(Uint8List imageBytes) {
    return pw.Row(
      children: [
        pw.Expanded(
          flex: 1,
          child: pw.Container(
            height: 90,
            width: double.infinity,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(
                color: PdfColor.fromHex('#000'),
              ),
            ),
            child: pw.Center(
                child: pw.Image(pw.MemoryImage(imageBytes),
                    fit: pw.BoxFit.contain)),
          ),
        ),
        pw.Expanded(
          flex: 1,
          child: pw.Column(children: [
            pw.Container(
                padding: const pw.EdgeInsets.all(8.0),
                constraints: const pw.BoxConstraints(minHeight: 30),
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColor.fromHex('#000'),
                  ),
                ),
                child: pw.Text('Site: $siteTitle',
                    style: const pw.TextStyle(fontSize: pdfFontSizeGeneral))),
            pw.Container(
                padding: const pw.EdgeInsets.all(8.0),
                constraints: const pw.BoxConstraints(minHeight: 30),
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColor.fromHex('#000'),
                  ),
                ),
                child: pw.Text('Issued By: QA Manager',
                    style: const pw.TextStyle(fontSize: pdfFontSizeGeneral))),
            pw.Container(
                padding: const pw.EdgeInsets.all(8.0),
                constraints: const pw.BoxConstraints(minHeight: 30),
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColor.fromHex('#000'),
                  ),
                ),
                child: pw.Text('Document Number: V01',
                    style: const pw.TextStyle(fontSize: pdfFontSizeGeneral))),
          ]),
        ),
        pw.Expanded(
          flex: 1,
          child: pw.Column(children: [
            pw.Container(
                padding: const pw.EdgeInsets.all(8.0),
                constraints: const pw.BoxConstraints(minHeight: 30),
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColor.fromHex('#000'),
                  ),
                ),
                child: pw.Text(
                    'Effective Date: ${DateFormat('d MMM yyyy').format(startDate)}',
                    style: const pw.TextStyle(fontSize: pdfFontSizeGeneral))),
            pw.Container(
                padding: const pw.EdgeInsets.all(8.0),
                constraints: const pw.BoxConstraints(minHeight: 30),
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColor.fromHex('#000'),
                  ),
                ),
                child: pw.Text('Approved By: Operations Director',
                    style: const pw.TextStyle(fontSize: pdfFontSizeGeneral))),
            pw.Container(
                padding: const pw.EdgeInsets.all(8.0),
                constraints: const pw.BoxConstraints(minHeight: 30),
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColor.fromHex('#000'),
                  ),
                ),
                child: pw.Text('Revision Number: 01',
                    style: const pw.TextStyle(fontSize: pdfFontSizeGeneral))),
          ]),
        ),
      ],
    );
  }

  Future<void> generateReport() async {
    final img = await rootBundle.load('assets/images/icleanLogo.png');
    final imageBytes = img.buffer.asUint8List();

    var myTheme = pw.ThemeData.withFont(
        base: await PdfGoogleFonts.robotoRegular(),
        bold: await PdfGoogleFonts.robotoBold(),
        italic: await PdfGoogleFonts.robotoItalic(),
        boldItalic: await PdfGoogleFonts.robotoBoldItalic(),
        icons: await PdfGoogleFonts.materialIcons());

    final pdf = pw.Document(theme: myTheme);

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      maxPages: 99,
      build: (context) {
        return [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(2),
            child: pw.Column(
              children: [
                pdfHeader(imageBytes),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Top Issues',
                  style: pw.TextStyle(
                      color: PdfColor.fromHex('#0c19ab'),
                      fontSize: pdfFontSizeTitle,
                      fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Column(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Row(
                      children: [
                        cellItem('Item Description', 3,
                            bold: true,
                            color: pdfAccentColor,
                            fontSize: pdfFontSizeHeader),
                        cellItem('Failure Count', 2,
                            bold: true,
                            color: pdfAccentColor,
                            fontSize: pdfFontSizeHeader),
                      ],
                    ),
                    ...areaRows()
                  ],
                )
              ],
            ),
          ),
        ];
      },
    ));

    ExportHelper helper = ExportHelper();
    String filePath = await helper.savePDFFile(pdf, 'Top_Issues.pdf');
    print("File saved at: $filePath");
  }
}
