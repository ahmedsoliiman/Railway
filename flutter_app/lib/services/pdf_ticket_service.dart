import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfTicketService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Generate PDF ticket and return bytes
  Future<Uint8List> generateTicketPdf({
    required String bookingReference,
    required Map<String, dynamic> bookingData,
    required Map<String, dynamic> tripData,
  }) async {
    final pdf = pw.Document();

    // Extract data
    final trainName =
        tripData['trainName'] ?? tripData['trainNumber'] ?? 'Express Train';
    final origin = tripData['origin'] ?? 'Origin';
    final destination = tripData['destination'] ?? 'Destination';

    DateTime departure;
    try {
      departure = DateTime.parse(
          tripData['departureTime']?.toString() ?? DateTime.now().toString());
    } catch (_) {
      departure = DateTime.now();
    }

    DateTime arrival;
    try {
      arrival = DateTime.parse(tripData['arrivalTime']?.toString() ??
          departure.add(const Duration(hours: 2)).toString());
    } catch (_) {
      arrival = departure.add(const Duration(hours: 2));
    }

    final seatClass = bookingData['seatClass']?.toString() ?? 'Standard';
    final seats = bookingData['numberOfSeats']?.toString() ?? '1';
    final price =
        (bookingData['totalPrice'] ?? bookingData['price'] ?? 0.0).toDouble();

    // QR Code data
    final qrData = '''
Booking Reference: $bookingReference
Train: $trainName
From: $origin
To: $destination
Departure: ${DateFormat('yyyy-MM-dd HH:mm').format(departure)}
Class: $seatClass
Seats: $seats
''';

    // Build PDF page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue800,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'TRAIN BOOKING TICKET',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      trainName,
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Booking Reference
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.amber100,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Center(
                  child: pw.Text(
                    'Booking Reference: $bookingReference',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              pw.SizedBox(height: 30),

              // Journey Details
              _buildPdfRow('From:', origin),
              pw.SizedBox(height: 12),
              _buildPdfRow('To:', destination),
              pw.SizedBox(height: 12),
              _buildPdfRow('Departure:',
                  DateFormat('EEE, MMM d, y - HH:mm').format(departure)),
              pw.SizedBox(height: 12),
              _buildPdfRow('Arrival:',
                  DateFormat('EEE, MMM d, y - HH:mm').format(arrival)),
              pw.SizedBox(height: 12),
              _buildPdfRow('Class:', seatClass),
              pw.SizedBox(height: 12),
              _buildPdfRow('Number of Seats:', seats),
              pw.SizedBox(height: 12),
              _buildPdfRow('Total Paid:', '\$${price.toStringAsFixed(2)}'),

              pw.SizedBox(height: 30),

              // QR Code
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Scan QR Code at Station',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 16),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(16),
                      decoration: pw.BoxDecoration(
                        border:
                            pw.Border.all(color: PdfColors.grey400, width: 2),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.BarcodeWidget(
                        data: qrData,
                        barcode: pw.Barcode.qrCode(),
                        width: 200,
                        height: 200,
                      ),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // Footer
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'Thank you for choosing our service!',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'Generated on ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey500,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return await pdf.save();
  }

  /// Helper to build a row in the PDF
  pw.Widget _buildPdfRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 120,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: const pw.TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  /// Share/Download PDF ticket
  Future<void> sharePdf(Uint8List pdfBytes, String filename) async {
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: filename,
    );
  }

  /// Print PDF ticket
  Future<void> printPdf(Uint8List pdfBytes) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }

  /// Upload PDF to Supabase Storage (optional)
  Future<String?> uploadPdfToSupabase({
    required Uint8List pdfBytes,
    required String bookingReference,
  }) async {
    try {
      final fileName = 'tickets/$bookingReference.pdf';
      await _supabase.storage.from('tickets').uploadBinary(fileName, pdfBytes);

      final publicUrl =
          _supabase.storage.from('tickets').getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      print('Error uploading PDF to Supabase: $e');
      return null;
    }
  }
}
