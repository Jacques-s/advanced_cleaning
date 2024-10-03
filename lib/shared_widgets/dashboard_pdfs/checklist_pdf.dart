import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/helpers/export_helper.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ChecklistPDF {
  const ChecklistPDF(
      {required this.reportMonth,
      required this.siteTitle,
      required this.answers});

  final DateTime reportMonth;
  final String siteTitle;
  final Map<String, dynamic> answers;

  List<String> getDaysOfMonth() {
    DateTime date = DateTime(reportMonth.year, reportMonth.month + 1,
        0); // The zero day of the next month is the last day of the current month
    int numOfDays = date.day;
    List<String> daysOfMonth = [];
    for (var i = 1; i <= numOfDays; i++) {
      daysOfMonth.add(DateFormat('dd')
          .format(DateTime(reportMonth.year, reportMonth.month, i)));
    }

    return daysOfMonth;
  }

  List<pw.Widget> areaRows() {
    List<pw.Widget> rows = [];

    answers.forEach((areaId, data) {
      String areaTitle = data['areaTitle'] ?? '-';
      Map<dynamic, dynamic> questions = data['questions'] ?? {};

      //Area row
      rows.add(
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                      color: PdfColor.fromHex('#000'), width: 0.5),
                  color: pdfPrimaryColor,
                ),
                padding: const pw.EdgeInsets.all(2.0),
                child: pw.Text(
                  areaTitle,
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8.0,
                      color: PdfColor.fromHex('#FFF')),
                ),
              ),
            ),
          ],
        ),
      );
      /////////////////////

      questions.forEach((questionId, question) {
        String questionTitle = question['questionTitle'] ?? '-';
        Map<dynamic, dynamic> days = question['days'] ?? {};

        pw.Container questionContainer = pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.symmetric(
              vertical:
                  pw.BorderSide(color: PdfColor.fromHex('#000'), width: 0.5),
            ),
          ),
          padding: const pw.EdgeInsets.all(2.0),
          width: 100,
          child: pw.Text(
            questionTitle,
            style: const pw.TextStyle(fontSize: 6.0),
          ),
        );

        rows.add(
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.symmetric(
                horizontal:
                    pw.BorderSide(color: PdfColor.fromHex('#000'), width: 0.5),
              ),
            ),
            child: pw.Row(
              children: [
                questionContainer,
                pw.Expanded(
                  child: pw.Row(
                      children: days.values
                          .map((answer) => pw.Expanded(
                                child: pw.Container(
                                  decoration: pw.BoxDecoration(
                                    border: pw.Border.symmetric(
                                      vertical: pw.BorderSide(
                                          color: PdfColor.fromHex('#000'),
                                          width: 0.5),
                                    ),
                                  ),
                                  padding: const pw.EdgeInsets.all(2.0),
                                  alignment:
                                      pw.Alignment.center as pw.Alignment?,
                                  child: pw.Center(
                                    child: answer == 'pass'
                                        ? pw.Icon(
                                            const pw.IconData(0xe5ca),
                                            size: 6.0,
                                            color: PdfColor.fromHex('#0da11c'),
                                          )
                                        : answer == 'fail'
                                            ? pw.Icon(
                                                const pw.IconData(0xe5cd),
                                                size: 6.0,
                                                color:
                                                    PdfColor.fromHex('#ab240c'),
                                              )
                                            : pw.Text('-',
                                                style: const pw.TextStyle(
                                                    fontSize: 6.0)),
                                  ),
                                ),
                              ))
                          .toList() // Convert to List<Widget>
                      ),
                )
              ],
            ),
          ),
        );
      });
    });

    return rows;
  }

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
                    style: const pw.TextStyle(fontSize: 8.0))),
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
                    style: const pw.TextStyle(fontSize: 8.0))),
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
                    style: const pw.TextStyle(fontSize: 8.0))),
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
                    'Effective Date: ${DateFormat('d MMM yyyy').format(reportMonth)}',
                    style: const pw.TextStyle(fontSize: 8.0))),
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
                    style: const pw.TextStyle(fontSize: 8.0))),
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
                    style: const pw.TextStyle(fontSize: 8.0))),
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
        orientation: pw.PageOrientation.landscape,
        margin: const pw.EdgeInsets.all(10),
        maxPages: 99,
        build: (context) {
          return [
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(2),
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pdfHeader(imageBytes),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Checklist Report',
                    style: pw.TextStyle(
                        color: pdfPrimaryColor,
                        fontSize: pdfFontSizeTitle,
                        fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    DateFormat('MMMM yyyy').format(reportMonth),
                    style: pw.TextStyle(
                        color: pdfPrimaryColor,
                        fontSize: 8.0,
                        fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    children: [
                      pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                              color: PdfColor.fromHex('#000'), width: 0.5),
                          color: pdfAccentColor,
                        ),
                        padding: const pw.EdgeInsets.all(2.0),
                        width: 100,
                        height: 20,
                        alignment: pw.Alignment.center as pw.Alignment?,
                        child: pw.Text(
                          'Item Description',
                          textAlign: pw.TextAlign.center as pw.TextAlign?,
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 6.0),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Row(
                            children: getDaysOfMonth()
                                .map((day) => pw.Expanded(
                                      child: pw.Container(
                                        decoration: pw.BoxDecoration(
                                          border: pw.Border.all(
                                              color: PdfColor.fromHex('#000'),
                                              width: 0.5),
                                          color: pdfAccentColor,
                                        ),
                                        alignment: pw.Alignment.center
                                            as pw.Alignment?,
                                        padding: const pw.EdgeInsets.all(2.0),
                                        height: 20,
                                        child: pw.Text(
                                          day,
                                          textAlign: pw.TextAlign.center
                                              as pw.TextAlign?,
                                          style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold,
                                              fontSize: 6.0),
                                        ),
                                      ),
                                    ))
                                .toList() // Convert to List<Widget>
                            ),
                      )
                    ],
                  ),
                  ...areaRows()
                ],
              ),
            )
          ];
        }));

    ExportHelper helper = ExportHelper();
    String filePath = await helper.savePDFFile(pdf, 'Checklist.pdf');
    print("File saved at: $filePath");
  }
}
