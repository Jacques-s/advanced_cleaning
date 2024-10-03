import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/helpers/export_helper.dart';
import 'package:advancedcleaning/models/answer_model.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class FailurePDF {
  FailurePDF(
      {required this.answers,
      required this.siteTitle,
      required this.startDate});
  final Map<String, Map<String, List<InspectionAnswer>>> answers;
  final String siteTitle;
  final DateTime startDate;

  List<pw.Widget> areaRows() {
    List<pw.Widget> rows = [];
    answers.forEach((formatedDate, areas) {
      rows.add(pw.Row(
        children: [
          cellItem(formatedDate, 1,
              bold: true, color: pdfSecondaryColor, whiteText: true)
        ],
      ));

      areas.forEach((areaTitle, values) {
        rows.add(
          pw.Row(
            children: [
              cellItem(areaTitle, 1,
                  bold: true, color: pdfPrimaryColor, whiteText: true)
            ],
          ),
        );

        for (var question in values) {
          rows.add(itemRow(question));
        }
      });
    });

    return rows;
  }

  pw.Widget itemRow(InspectionAnswer answer) => pw.Row(
        children: [
          cellItem(answer.questionTitle ?? '-', 3),
          cellItem(answer.questionFrequency.name, 2),
          cellItem(answer.failureReason ?? '-', 2),
          cellItem(answer.correctiveAction ?? '-', 2),
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
                  'Failure Report',
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
                        cellItem('Frequency', 2,
                            bold: true,
                            color: pdfAccentColor,
                            fontSize: pdfFontSizeHeader),
                        cellItem('Reason For Failure', 2,
                            bold: true,
                            color: pdfAccentColor,
                            fontSize: pdfFontSizeHeader),
                        cellItem('Corrections', 2,
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
          )
        ];
      },
    ));

    ExportHelper helper = ExportHelper();
    String filePath = await helper.savePDFFile(pdf, 'Failures.pdf');
    print("File saved at: $filePath");
  }
}
