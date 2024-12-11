import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/helpers/export_helper.dart';
import 'package:advancedcleaning/models/chemical_models/chemical_log_model.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ChemicalLogPdf {
  ChemicalLogPdf({
    required this.chemicalLogs,
    required this.siteTitle,
    required this.startDate,
  });

  final Map<String, List<ChemicalLog>> chemicalLogs;
  final String siteTitle;
  final DateTime startDate;

  // Define fixed column widths for uniform layout
  static const List<int> columnFlexValues = [2, 2, 2, 2, 2, 2, 2, 2, 2, 2];
  static const double cellPadding = 4.0;
  static const double headerHeight = 30.0;

  List<pw.Widget> headerRows() {
    List<pw.Widget> rows = [];
    chemicalLogs.forEach((chemicalName, logs) {
      rows.add(
        pw.Container(
          color: pdfSecondaryColor,
          child: pw.Row(
            children: [
              cellItem(
                chemicalName,
                20, // Full width for chemical name header
                bold: true,
                whiteText: true,
              ),
            ],
          ),
        ),
      );

      for (var log in logs) {
        rows.add(itemRow(log));
      }
    });

    return rows;
  }

  pw.Widget itemRow(ChemicalLog log) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    return pw.Row(
      children: [
        cellItem(dateFormat.format(log.createdAt), columnFlexValues[0]),
        cellItem(log.chemicalAmount, columnFlexValues[1]),
        cellItem(log.batchNumber, columnFlexValues[2]),
        cellItem(log.expiryDate, columnFlexValues[3]),
        cellItem(log.waterAmount, columnFlexValues[4]),
        cellItem(log.numberOfDrops ?? '', columnFlexValues[5]),
        cellItem(log.issuedTo, columnFlexValues[6]),
        cellItem(log.factor ?? '', columnFlexValues[7]),
        cellItem(log.verification ?? '', columnFlexValues[8]),
        cellItem(log.correctiveAction ?? '', columnFlexValues[9]),
      ],
    );
  }

  pw.Widget cellItem(
    String title,
    int flex, {
    bool bold = false,
    double fontSize = pdfFontSizeGeneral,
    PdfColor? color,
    bool whiteText = false,
  }) =>
      pw.Expanded(
        flex: flex,
        child: pw.Container(
          padding: const pw.EdgeInsets.all(cellPadding),
          height: 30, // Fixed height for uniform rows
          decoration: pw.BoxDecoration(
            color: color,
            border: pw.Border.all(
              color: PdfColor.fromHex('#000000'),
              width: 0.5,
            ),
          ),
          child: pw.Center(
            child: pw.Text(
              title,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                color: whiteText ? PdfColor.fromHex('#FFFFFF') : null,
                fontWeight: bold ? pw.FontWeight.bold : null,
                fontSize: fontSize,
              ),
            ),
          ),
        ),
      );

  pw.Widget pdfHeader(Uint8List imageBytes) {
    return pw.Container(
      height: 90,
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 1,
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColor.fromHex('#000000')),
              ),
              child: pw.Center(
                child: pw.Image(
                  pw.MemoryImage(imageBytes),
                  fit: pw.BoxFit.contain,
                  height: 80,
                ),
              ),
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Column(
              children: [
                _headerInfoRow('Site', siteTitle),
                _headerInfoRow('Issued By', 'QA Manager'),
                _headerInfoRow('Document Number', 'V01'),
              ],
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Column(
              children: [
                _headerInfoRow('Effective Date',
                    DateFormat('d MMM yyyy').format(startDate)),
                _headerInfoRow('Approved By', 'Operations Director'),
                _headerInfoRow('Revision Number', '01'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _headerInfoRow(String label, String value) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8.0),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColor.fromHex('#000000')),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              label,
              style: const pw.TextStyle(fontSize: pdfFontSizeGeneral),
            ),
            pw.Text(
              value,
              style: const pw.TextStyle(fontSize: pdfFontSizeGeneral),
            ),
          ],
        ),
      ),
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
      icons: await PdfGoogleFonts.materialIcons(),
    );

    final pdf = pw.Document(theme: myTheme);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        maxPages: 99,
        build: (context) => [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(2),
            child: pw.Column(
              children: [
                pdfHeader(imageBytes),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Chemical Log Report',
                  style: pw.TextStyle(
                    color: PdfColor.fromHex('#0c19ab'),
                    fontSize: pdfFontSizeTitle,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Column(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Row(
                      children: [
                        cellItem('Date', columnFlexValues[0],
                            bold: true, color: pdfAccentColor),
                        cellItem('Amount Of Chemical', columnFlexValues[1],
                            bold: true, color: pdfAccentColor),
                        cellItem('Batch Number', columnFlexValues[2],
                            bold: true, color: pdfAccentColor),
                        cellItem('Chemical Expire Date', columnFlexValues[3],
                            bold: true, color: pdfAccentColor),
                        cellItem('Water Amount', columnFlexValues[4],
                            bold: true, color: pdfAccentColor),
                        cellItem('Number Of Drops', columnFlexValues[5],
                            bold: true, color: pdfAccentColor),
                        cellItem('Issued To', columnFlexValues[6],
                            bold: true, color: pdfAccentColor),
                        cellItem('Factor', columnFlexValues[7],
                            bold: true, color: pdfAccentColor),
                        cellItem('Verification', columnFlexValues[8],
                            bold: true, color: pdfAccentColor),
                        cellItem('Corrective Action', columnFlexValues[9],
                            bold: true, color: pdfAccentColor),
                      ],
                    ),
                    ...headerRows(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    ExportHelper helper = ExportHelper();
    String filePath = await helper.savePDFFile(pdf, 'ChemicalLogReport.pdf');
    print("File saved at: $filePath");
  }
}
