// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
// import 'package:path_provider/path_provider.dart';

// class PdfPreviewScreen extends StatefulWidget {
//   final pw.Document pdf;

//   PdfPreviewScreen({required this.pdf});

//   @override
//   _PdfPreviewScreenState createState() => _PdfPreviewScreenState();
// }

// class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
//   PDFDocument? _pdfDocument;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadPdf();
//   }

//   Future<void> _loadPdf() async {
//     final output = await getTemporaryDirectory();
//     final file = File('${output.path}/preview.pdf');
//     await file.writeAsBytes(await widget.pdf.save());
//     final pdfDocument = await PDFDocument.fromFile(file);

//     setState(() {
//       _pdfDocument = pdfDocument;
//       _isLoading = false;
//     });
//   }

//   Future<void> _savePdfPermanent() async {
//     final output = await getExternalStorageDirectory();
//     final file = File('${output!.path}/rent_report.pdf');
//     await file.writeAsBytes(await widget.pdf.save());
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('PDF saved successfully.')),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('PDF Preview'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.download),
//             onPressed: _savePdfPermanent,
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : PDFViewer(document: _pdfDocument!),
//     );
//   }
// }
