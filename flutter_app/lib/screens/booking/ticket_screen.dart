import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../services/pdf_ticket_service.dart';
import 'package:go_router/go_router.dart';

class TicketScreen extends StatefulWidget {
  final Map<String, dynamic> args;
  const TicketScreen({super.key, required this.args});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  final PdfTicketService _pdfService = PdfTicketService();
  bool _isGeneratingPdf = false;
  String _generateQRData({
    required String bookingReference,
    required Map<String, dynamic> args,
  }) {
    return '''
Booking Reference: $bookingReference
Seats: ${args['numberOfSeats'] ?? '1'}
''';
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;

    print('🎫 TicketScreen Debug: Received args: ${args.keys.toList()}');

    final booking = args['booking'];
    final trip = args['trip'] ?? {};

    // Support multiple naming conventions for the booking reference
    String bookingReference =
        'REF-GEN-${DateTime.now().millisecondsSinceEpoch}';
    if (booking is Map<String, dynamic>) {
      bookingReference = (booking['booking_reference'] ??
              booking['bookingReference'] ??
              booking['Booking_ID'] ??
              booking['id'] ??
              bookingReference)
          .toString();
      if (!bookingReference.startsWith('REF'))
        bookingReference = 'REF-$bookingReference';
    } else if (args['tripId'] != null) {
      bookingReference = 'REF-${args['tripId']}';
    }

    print('🎫 Booking Reference resolved: $bookingReference');

    // Safe extraction of trip details
    final trainName =
        trip['trainName'] ?? trip['trainNumber'] ?? 'Express Train';
    final origin = trip['origin'] ?? 'Origin Station';
    final destination = trip['destination'] ?? 'Destination Station';

    DateTime? departure;
    try {
      departure = DateTime.tryParse(trip['departureTime']?.toString() ?? '');
    } catch (_) {}
    departure ??= DateTime.now();

    DateTime? arrival;
    try {
      arrival = DateTime.tryParse(trip['arrivalTime']?.toString() ?? '');
    } catch (_) {}
    arrival ??= departure.add(const Duration(hours: 2));

    final seatClass = args['seatClass']?.toString() ?? 'Standard';
    final seats = args['numberOfSeats']?.toString() ?? '1';
    final price = (args['totalPrice'] ?? args['price'] ?? 0.0).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Ticket'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Success Message
            Container(
              width: double.infinity,
              color: AppTheme.successColor.withOpacity(0.1),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppTheme.successColor,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Booking Confirmed!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Your ticket has been sent to your email'),
                ],
              ),
            ),

            // Ticket Card
            Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      decoration: const BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            trainName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            trip['trainNumber'] ?? 'Unknown Train',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Booking Reference
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.amber.shade50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.confirmation_number, size: 20),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Booking Ref: $bookingReference',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Journey Details
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _TicketRow(
                            icon: Icons.location_on,
                            label: 'From',
                            value: origin,
                          ),
                          const SizedBox(height: 16),
                          _TicketRow(
                            icon: Icons.flag,
                            label: 'To',
                            value: destination,
                          ),
                          const Divider(height: 32),
                          _TicketRow(
                            icon: Icons.departure_board,
                            label: 'Departure',
                            value: DateFormat('EEE, MMM d, y - HH:mm')
                                .format(departure),
                          ),
                          const SizedBox(height: 16),
                          _TicketRow(
                            icon: Icons.location_on,
                            label: 'Arrival',
                            value: DateFormat('EEE, MMM d, y - HH:mm')
                                .format(arrival),
                          ),
                          const Divider(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: _TicketRow(
                                  icon: Icons.airline_seat_recline_normal,
                                  label: 'Class',
                                  value: seatClass,
                                ),
                              ),
                              Expanded(
                                child: _TicketRow(
                                  icon: Icons.people,
                                  label: 'Seats',
                                  value: seats,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _TicketRow(
                                  icon: Icons.train,
                                  label: 'Train Type',
                                  value: trip['trainType'] ?? 'Express',
                                ),
                              ),
                              Expanded(
                                child: _TicketRow(
                                  icon: Icons.payment,
                                  label: 'Total Paid',
                                  value: '\$${price.toStringAsFixed(2)}',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // QR Code
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Scan QR Code at Station',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: QrImageView(
                              data: _generateQRData(
                                bookingReference: bookingReference,
                                args: args,
                              ),
                              version: QrVersions.auto,
                              size: 200,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Download PDF Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isGeneratingPdf
                          ? null
                          : () async {
                              setState(() => _isGeneratingPdf = true);
                              try {
                                final pdfBytes =
                                    await _pdfService.generateTicketPdf(
                                  bookingReference: bookingReference,
                                  bookingData: args,
                                  tripData: trip,
                                );

                                await _pdfService.sharePdf(
                                  pdfBytes,
                                  'ticket_$bookingReference.pdf',
                                );

                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          '✅ Ticket PDF generated successfully!'),
                                      backgroundColor: AppTheme.successColor,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('❌ Error generating PDF: $e'),
                                      backgroundColor: AppTheme.dangerColor,
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setState(() => _isGeneratingPdf = false);
                                }
                              }
                            },
                      icon: _isGeneratingPdf
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.download),
                      label: Text(_isGeneratingPdf
                          ? 'Generating PDF...'
                          : 'Download Ticket PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/my-bookings'),
                      icon: const Icon(Icons.list_alt),
                      label: const Text('View All Bookings'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/home'),
                      icon: const Icon(Icons.home),
                      label: const Text('Go to Home'),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _TicketRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.grayColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.grayColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
