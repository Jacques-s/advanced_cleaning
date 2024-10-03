import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';

const String appTitle = "Advanced Cleaning Solutions";

const Color appPrimaryColor = Color(0xFF004693);
const Color appSecondaryColor = Color(0xFF00A9E8);
const Color appAccentColor = Color(0xFFC5C5C5);
const Color appDangerColor = Color(0xFFD44343);
const Color appSuccessColor = Color(0xFF04AD23);

//Charts
const Color appChartHeaderColor = Colors.blueAccent;
//

//Email validation
const emailPattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
    r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
    r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
    r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
    r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
    r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
    r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';

ThemeData appThemeData = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
    useMaterial3: true);

const appSnackBarDuration = Duration(seconds: 5);
const appSnackBarColor = Color.fromARGB(255, 255, 255, 255);

//PDF settings
const double pdfFontSizeTitle = 12.0;
const double pdfFontSizeHeader = 8.0;
const double pdfFontSizeGeneral = 6.0;

const PdfColor pdfPrimaryColor = PdfColor.fromInt(0xFF004693);
const PdfColor pdfSecondaryColor = PdfColor.fromInt(0xFF00A9E8);
const PdfColor pdfAccentColor = PdfColor.fromInt(0xFFC5C5C5);
const PdfColor pdfDangerColor = PdfColor.fromInt(0xFFD44343);
const PdfColor pdfSuccessColor = PdfColor.fromInt(0xFF04AD23);

//


