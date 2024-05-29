import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';

Future<void> generateAndPrintReport(
  CloudRent rent,
  CloudProfile profile,
  CloudReports report,
) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Padding(
          padding: const pw.EdgeInsets.all(32.0),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'NBR Building\nN.B.R.BUILDING',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    report.reportDate,
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  profile.companyName.isNotEmpty
                      ? profile.companyName
                      : '${profile.firstName} ${profile.lastName}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 32),
              pw.Text(
                'To: ${profile.firstName} ${profile.lastName}',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 16),
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  report.reportTitle,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                report.reportContent,
                style: pw.TextStyle(fontSize: 14),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 32),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'CC: ${report.carbonCopy}',
                  style: pw.TextStyle(fontSize: 12),
                ),
              ),
              pw.SizedBox(height: 32),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'NBR Regards\nManagement',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Divider(),
              pw.Text(
                'Address: ${profile.address}',
                style: pw.TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}
