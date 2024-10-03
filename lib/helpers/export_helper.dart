import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_html/html.dart' as html;

class ExportHelper {
  Future<String> saveExcelFile(Excel excel, String fileName) async {
    if (kIsWeb) {
      // Convert the Excel document to bytes
      List<int> bytes = excel.encode()!;

      // Convert to Uint8List
      Uint8List excelBytes = Uint8List.fromList(bytes);

      // Create a Blob containing the data
      final blob = html.Blob([excelBytes]);

      // Create a URL for the Blob
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Create an anchor element with the URL
      html.AnchorElement(href: url)
        ..setAttribute("download", fileName)
        ..click(); // Simulate a click to trigger the download

      // Clean up by revoking the object URL
      html.Url.revokeObjectUrl(url);

      return 'downloads';
    } else {
      // Get the directory for saving the file
      Directory? directory = await getDownloadsDirectory();

      if (directory != null) {
        // Create the file path
        String filePath = '${directory.path}/$fileName';

        // Save the Excel file
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(excel.save()!);

        return filePath;
      }
    }

    return '';
  }

  Future<String> savePDFFile(Document pdf, String fileName) async {
    if (kIsWeb) {
      var savedFile = await pdf.save();

      // Convert the file document to bytes
      List<int> bytes = List.from(savedFile);

      // Convert to Uint8List
      Uint8List excelBytes = Uint8List.fromList(bytes);

      // Create a Blob containing the data
      final blob = html.Blob([excelBytes]);

      // Create a URL for the Blob
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Create an anchor element with the URL
      html.AnchorElement(href: url)
        ..setAttribute("download", fileName)
        ..click(); // Simulate a click to trigger the download

      // Clean up by revoking the object URL
      html.Url.revokeObjectUrl(url);

      return 'downloads';
    } else {
      // Get the directory for saving the file
      Directory? directory = await getDownloadsDirectory();

      if (directory != null) {
        // Create the file path
        String filePath = '${directory.path}/$fileName';

        // Save the file
        final file = File(filePath);
        await file.writeAsBytes(await pdf.save());

        return filePath;
      }
    }

    return '';
  }

// Function to request storage permission
  Future<bool> _requestPermission(Permission permission) async {
    //ignore if it is on web or macos
    if (kIsWeb == true || Platform.isMacOS == true) {
      return true;
    } else {
      if (await permission.isGranted) {
        return true;
      } else {
        var result = await permission.request();
        return result == PermissionStatus.granted;
      }
    }
  }
}
