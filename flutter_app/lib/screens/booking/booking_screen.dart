import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/trip_provider.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String _selectedClass = 'First';
  int _numberOfSeats = 1;
  bool _isProcessing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tripId = ModalRoute.of(context)!.settings.arguments as int;
    _loadTripDetails(tripId);
  }

  Future<void> _loadTripDetails(int tripId) async {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    await tripProvider.loadTripDetails(tripId);
  }

  Future<void> _handleBooking() async {
    setState(() => _isProcessing = true);

    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    final trip = tripProvider.selectedTrip!;

    final response = await tripProvider.createReservation(
      tripId: trip.id,
      seatClass: _selectedClass.toLowerCase(), // Convert to lowercase for backend
      numberOfSeats: _numberOfSeats,
    );

    setState(() => _isProcessing = false);

    if (!mounted) return;

    if (response['success'] == true) {
      final bookingRef = response['data']['reservation']['booking_reference'] ?? 
                        response['data']['booking_reference'] ?? 
                        'N/A';
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: AppTheme.successColor, size: 64),
          title: const Text('Booking Confirmed!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Reference: $bookingRef'),
              const SizedBox(height: 8),
              const Text('Check your email for details.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
              },
              child: const Text('Go to Home'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/my-bookings');
              },
              child: const Text('View Bookings'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Booking failed'),
          backgroundColor: AppTheme.dangerColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Trip'),
      ),
      body: Consumer<TripProvider>(
        builder: (context, tripProvider, child) {
          if (tripProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final trip = tripProvider.selectedTrip;
          if (trip == null) {
            return const Center(child: Text('Trip not found'));
          }

          final pricePerSeat = _selectedClass == 'First' 
              ? (trip.firstClassPrice ?? 0) 
              : (trip.secondClassPrice ?? 0);
          final totalPrice = pricePerSeat * _numberOfSeats;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trip Summary
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.trainName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${trip.originName} → ${trip.destinationName}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Select Class
                Text(
                  'Select Class',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                if (trip.firstClassPrice != null)
                  RadioListTile<String>(
                    value: 'First',
                    groupValue: _selectedClass,
                    onChanged: (value) => setState(() => _selectedClass = value!),
                    title: const Text('First Class'),
                    subtitle: Text('\$${trip.firstClassPrice!.toStringAsFixed(2)} per seat'),
                    secondary: const Icon(Icons.airline_seat_recline_extra),
                  ),
                if (trip.secondClassPrice != null)
                  RadioListTile<String>(
                    value: 'Second',
                    groupValue: _selectedClass,
                    onChanged: (value) => setState(() => _selectedClass = value!),
                    title: const Text('Second Class'),
                    subtitle: Text('\$${trip.secondClassPrice!.toStringAsFixed(2)} per seat'),
                    secondary: const Icon(Icons.event_seat),
                  ),
                const SizedBox(height: 24),

                // Number of Seats
                Text(
                  'Number of Seats',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: _numberOfSeats > 1
                              ? () => setState(() => _numberOfSeats--)
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                          iconSize: 32,
                        ),
                        Text(
                          '$_numberOfSeats',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        IconButton(
                          onPressed: _numberOfSeats < trip.availableSeats
                              ? () => setState(() => _numberOfSeats++)
                              : null,
                          icon: const Icon(Icons.add_circle_outline),
                          iconSize: 32,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Price Summary
                Card(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Price per seat',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              '\$${pricePerSeat.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Number of seats',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              '$_numberOfSeats',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Price',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              '\$${totalPrice.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _handleBooking,
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Confirm Booking'),
          ),
        ),
      ),
    );
  }
}
