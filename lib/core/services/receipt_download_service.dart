import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:washgo/models/booking_model.dart';

class ReceiptDownloadService {
  /// Saves a PDF receipt. Returns the saved file path, or null if cancelled.
  static Future<String?> downloadReceipt({
    required BookingModel booking,
    required String qrPayload,
  }) async {
    final safeId = booking.id.replaceAll(RegExp(r'[^\w\-]'), '_');
    final suggestedName = 'WashGo-Receipt-$safeId.pdf';

    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Receipt',
      fileName: suggestedName,
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );

    if (savePath == null || savePath.isEmpty) return null;

    final filePath = savePath.toLowerCase().endsWith('.pdf') ? savePath : '$savePath.pdf';
    final bytes = await _buildPdfBytes(booking: booking, qrPayload: qrPayload);

    await File(filePath).writeAsBytes(bytes, flush: true);
    return filePath;
  }

  static Future<Uint8List> _buildPdfBytes({
    required BookingModel booking,
    required String qrPayload,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          pw.Center(
            child: pw.Text(
              'WashGo Digital Receipt',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text(
              booking.id,
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ),
          pw.SizedBox(height: 24),
          pw.Divider(),
          pw.SizedBox(height: 16),
          _pdfRow('Customer', booking.userName),
          _pdfRow('Service', booking.serviceName),
          _pdfRow('Vehicle', booking.vehicleType),
          _pdfRow('Plate No.', booking.plateNumber),
          _pdfRow('Date & Time', '${booking.bookingDate} • ${booking.bookingTime}'),
          _pdfRow('Queue No.', '#${booking.queueNumber}'),
          _pdfRow('Status', booking.status),
          pw.SizedBox(height: 16),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.teal50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Total Amount',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  '₱${booking.price.toStringAsFixed(0)}',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),
          pw.Text(
            'QR check-in data',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            qrPayload,
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 24),
          pw.Center(
            child: pw.Text(
              'Thank you for choosing WashGo!',
              style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 110,
            child: pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
