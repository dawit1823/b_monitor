import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:file_selector/file_selector.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';

Future<void> generateAndSaveReport(
  CloudRent rent,
  CloudProfile profile,
  CloudReports report,
  CloudCompany company,
) async {
  // Create a PDF document.
  final PdfDocument document = PdfDocument();

  // Add a page and draw text.
  final PdfPage page = document.pages.add();
  final PdfGraphics graphics = page.graphics;
  final Size pageSize = page.getClientSize();

  // Drawing text on the PDF page.
  graphics.drawString(
    company.companyName, // Use the passed companyName
    PdfStandardFont(PdfFontFamily.timesRoman, 20, style: PdfFontStyle.bold),
    bounds: Rect.fromLTWH(0, 0, pageSize.width, 20),
  );

  graphics.drawString(
    report.reportDate,
    PdfStandardFont(PdfFontFamily.timesRoman, 12),
    bounds: Rect.fromLTWH(pageSize.width - 100, 0, 100, 20),
    format: PdfStringFormat(alignment: PdfTextAlignment.right),
  );

  // Profile information
  graphics.drawString(
    profile.companyName.isNotEmpty
        ? profile.companyName
        : '${profile.firstName} ${profile.lastName}',
    PdfStandardFont(PdfFontFamily.timesRoman, 16, style: PdfFontStyle.bold),
    bounds: Rect.fromLTWH(0, 40, pageSize.width, 16),
    format: PdfStringFormat(alignment: PdfTextAlignment.right),
  );

  graphics.drawString(
    'To: ${profile.firstName} ${profile.lastName}',
    PdfStandardFont(PdfFontFamily.timesRoman, 12),
    bounds: Rect.fromLTWH(0, 80, pageSize.width, 16),
  );

  graphics.drawString(
    report.reportTitle,
    PdfStandardFont(PdfFontFamily.timesRoman, 24, style: PdfFontStyle.bold),
    bounds: Rect.fromLTWH(0, 120, pageSize.width, 24),
    format: PdfStringFormat(alignment: PdfTextAlignment.center),
  );

  graphics.drawString(
    report.reportContent,
    PdfStandardFont(PdfFontFamily.timesRoman, 14),
    bounds: Rect.fromLTWH(0, 160, pageSize.width, pageSize.height - 160),
    format: PdfStringFormat(alignment: PdfTextAlignment.justify),
  );

  graphics.drawString(
    'CC: ${report.carbonCopy}',
    PdfStandardFont(PdfFontFamily.timesRoman, 12),
    bounds: Rect.fromLTWH(0, pageSize.height - 100, pageSize.width, 16),
    format: PdfStringFormat(alignment: PdfTextAlignment.right),
  );

  graphics.drawString(
    'NBR Regards\nManagement',
    PdfStandardFont(PdfFontFamily.timesRoman, 12, style: PdfFontStyle.bold),
    bounds: Rect.fromLTWH(0, pageSize.height - 60, pageSize.width, 20),
    format: PdfStringFormat(alignment: PdfTextAlignment.right),
  );

  graphics.drawString(
    'Address: ${profile.address}',
    PdfStandardFont(PdfFontFamily.timesRoman, 12),
    bounds: Rect.fromLTWH(0, pageSize.height - 40, pageSize.width, 16),
  );

  // Save the document to a file.
  final List<int> bytes = document.saveSync();
  document.dispose();

  // Convert the bytes to Uint8List for saving.
  final Uint8List byteList = Uint8List.fromList(bytes);

  // Open file selector to save the PDF file.
  final String? path = await getSavePath(
    suggestedName: 'report.pdf',
    confirmButtonText: 'Save',
  );

  if (path != null) {
    final XFile file = XFile.fromData(byteList,
        name: 'report.pdf', mimeType: 'application/pdf');
    await file.saveTo(path);
  }
}

// Function to open save dialog
Future<String?> getSavePath(
    {required String suggestedName, required String confirmButtonText}) async {
  final XFile? file = await getSavePathForXFile(
      suggestedName: suggestedName, confirmButtonText: confirmButtonText);
  return file?.path;
}

// Helper function to get the file path
Future<XFile?> getSavePathForXFile(
    {required String suggestedName, required String confirmButtonText}) async {
  final XFile? file = await getSavePathForXFile(
    suggestedName: suggestedName,
    confirmButtonText: confirmButtonText,
  );
  return file;
}
