import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/trip_provider.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  bool _isBooking = true;
  String? _bookingReference;
  Map<String, dynamic>? _reservationData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isBooking) {
      _createBooking();
    }
  }

  Future<void> _createBooking() async {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final tripProvider = Provider.of<TripProvider>(context, listen: false);

    final response = await tripProvider.createReservation(
      tripId: args['tripId'],
      seatClass: args['seatClass'].toString().toLowerCase(),
      numberOfSeats: args['numberOfSeats'],
    );

    setState(() {
      _isBooking = false;
      if (response['success'] == true) {
        _bookingReference = response['data']['reservation']['booking_reference'] ??
            response['data']['booking_reference'] ??
            'BK${DateTime.now().millisecondsSinceEpoch}';
        _reservationData = response['data'];
      }
    });
  }

  String _generateQRData() {
    if (_bookingReference == null) return '';
    
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final trip = args['trip'];
    
    return '''
Booking Reference: $_bookingReference
Train: ${trip['trainName']}
From: ${trip['origin']}
To: ${trip['destination']}
Departure: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(trip['departureTime']))}
Class: ${args['seatClass']}
Seats: ${args['numberOfSeats']}
''';
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (_isBooking) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                'Processing your booking...',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    if (_bookingReference == null || args == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppTheme.dangerColor),
              const SizedBox(height: 16),
              const Text('Booking failed. Please try again.'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      );
    }

    final trip = args['trip'];
    final departureTime = DateTime.parse(trip['departureTime']);
    final arrivalTime = DateTime.parse(trip['arrivalTime']);

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
                            trip['trainName'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            trip['trainNumber'],
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
                          Text(
                            'Booking Ref: $_bookingReference',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
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
                            value: '${trip['origin']} (${trip['originCity']})',
                          ),
                          const SizedBox(height: 16),
                          _TicketRow(
                            icon: Icons.flag,
                            label: 'To',
                            value: '${trip['destination']} (${trip['destinationCity']})',
                          ),
                          const Divider(height: 32),
                          _TicketRow(
                            icon: Icons.departure_board,
                            label: 'Departure',
                            value: DateFormat('EEE, MMM d, y - HH:mm').format(departureTime),
                          ),
                          const SizedBox(height: 16),
                          _TicketRow(
                            icon: Icons.location_on,
                            label: 'Arrival',
                            value: DateFormat('EEE, MMM d, y - HH:mm').format(arrivalTime),
                          ),
                          const Divider(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: _TicketRow(
                                  icon: Icons.airline_seat_recline_normal,
                                  label: 'Class',
                                  value: args['seatClass'],
                                ),
                              ),
                              Expanded(
                                child: _TicketRow(
                                  icon: Icons.people,
                                  label: 'Seats',
                                  value: '${args['numberOfSeats']}',
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
                                  value: trip['trainType'],
                                ),
                              ),
                              Expanded(
                                child: _TicketRow(
                                  icon: Icons.payment,
                                  label: 'Total Paid',
                                  value: '\$${args['totalPrice'].toStringAsFixed(2)}',
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
                              data: _generateQRData(),
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(context, '/my-bookings', (route) => false);
                      },
                      icon: const Icon(Icons.list_alt),
                      label: const Text('View All Bookings'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                      },
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
