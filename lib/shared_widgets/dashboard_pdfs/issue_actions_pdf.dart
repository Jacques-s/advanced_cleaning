import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/helpers/export_helper.dart';
import 'package:advancedcleaning/models/corrective_action_model.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class IssueActionsPdf {
  IssueActionsPdf(
      {required this.answers,
      required this.siteTitle,
      required this.startDate});
  final Map<String, List<CorrectiveAction>> answers;
  final String siteTitle;
  final DateTime startDate;

  List<pw.TableRow> areaRows() {
    List<pw.TableRow> rows = [];
    answers.forEach((areaTitle, values) {
      rows.add(pw.TableRow(
        decoration: const pw.BoxDecoration(color: pdfPrimaryColor),
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(8.0),
            child: pw.Text(
              areaTitle,
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#FFF'),
                  fontSize: pdfFontSizeHeader),
            ),
          ),
          pw.SizedBox(),
          pw.SizedBox(),
          pw.SizedBox(),
        ],
      ));

      for (CorrectiveAction action in values) {
        rows.add(itemRow(action));
      }
    });

    return rows;
  }

  pw.TableRow itemRow(CorrectiveAction action) => pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(8.0),
            child: pw.Text(
              action.questionTitle,
              style: const pw.TextStyle(fontSize: pdfFontSizeGeneral),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8.0),
            child: pw.Text(
              '${action.failureCount}',
              style: const pw.TextStyle(fontSize: pdfFontSizeGeneral),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8.0),
            child: pw.Text(
              DateFormat('yyyy-MM-dd').format(action.updatedAt),
              style: const pw.TextStyle(fontSize: pdfFontSizeGeneral),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8.0),
            child: pw.Text(
              action.action,
              style: const pw.TextStyle(fontSize: pdfFontSizeGeneral),
            ),
          ),
        ],
      );

  pw.Widget pdfHeader(Uint8List imageBytes) {
    return pw.Row(
      children: [
        pw.Expanded(
          flex: 1,
          child: pw.Container(
            height: 120,
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
                constraints: const pw.BoxConstraints(minHeight: 40),
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
                constraints: const pw.BoxConstraints(minHeight: 40),
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
                constraints: const pw.BoxConstraints(minHeight: 40),
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
                constraints: const pw.BoxConstraints(minHeight: 40),
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
                constraints: const pw.BoxConstraints(minHeight: 40),
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
                constraints: const pw.BoxConstraints(minHeight: 40),
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

    pdf.addPage(pw.Page(
      build: (context) {
        return pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(2),
          child: pw.Column(
            children: [
              pdfHeader(imageBytes),
              pw.SizedBox(height: 20),
              pw.Text(
                'Issue Actions',
                style: pw.TextStyle(
                    color: PdfColor.fromHex('#0c19ab'),
                    fontSize: pdfFontSizeTitle,
                    fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColor.fromHex('#000')),
                children: [
                  pw.TableRow(
                    decoration:
                        pw.BoxDecoration(color: PdfColor.fromHex('#9ca19c')),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(
                          'Item Description',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: pdfFontSizeHeader),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(
                          'Failure Count',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: pdfFontSizeHeader),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(
                          'Last Updated',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: pdfFontSizeHeader),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(
                          'Action',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: pdfFontSizeHeader),
                        ),
                      ),
                    ],
                  ),
                  ...areaRows()
                ],
              )
            ],
          ),
        );
      },
    ));

    ExportHelper helper = ExportHelper();
    String filePath = await helper.savePDFFile(pdf, 'Issue_Actions.pdf');
    print("File saved at: $filePath");
  }
}
