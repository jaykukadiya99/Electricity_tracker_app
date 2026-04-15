import 'dart:io';
import 'package:flutter/material.dart' hide TableBorder;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PdfService {
  static Future<void> generateAndShareReport({
    required String title,
    required List<String> headers,
    required List<List<String>> data,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    title,
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blueGrey900,
                    ),
                  ),
                  pw.Text(
                    'Generated: ${DateTime.now().toString().split(' ')[0]}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: headers,
              data: data,
              border: pw.TableBorder.all(color: PdfColors.blueGrey200, width: 0.5),
              headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.blueGrey800),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft, // Date / Label
                for (int i = 1; i < headers.length; i++) i: pw.Alignment.centerRight,
              },
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'End of Report',
              style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey500,
                  fontStyle: pw.FontStyle.italic),
            ),
          ];
        },
      ),
    );

    try {
      final dir = await getApplicationDocumentsDirectory();
      // Clean filename
      final cleanTitle = title.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_').toLowerCase();
      final file = File('${dir.path}/${cleanTitle}_report.pdf');
      
      await file.writeAsBytes(await pdf.save());

      // Share the file
      await Share.shareXFiles([XFile(file.path)], text: 'Here is your $title export.');
    } catch (e) {
      debugPrint('Error generating PDF: $e');
      rethrow;
    }
  }
}
