import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/trip_provider.dart';

import 'package:go_router/go_router.dart';

class BookingScreen extends StatefulWidget {
  final int tripId;
  const BookingScreen({super.key, required this.tripId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String _selectedClass = 'first';
  int _numberOfSeats = 1;

  @override
  void initState() {
    super.initState();
    _loadTripDetails(widget.tripId);
  }

  Future<void> _loadTripDetails(int tripId) async {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    await tripProvider.loadTripDetails(tripId);
  }

  Future<void> _handleBooking() async {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    final trip = tripProvider.selectedTrip!;

    final pricePerSeat = _selectedClass == 'first'
        ? (trip.firstClassPrice ?? 0)
        : _selectedClass == 'second'
            ? (trip.secondClassPrice ?? 0)
            : (trip.economicPrice ?? 0);
    final totalPrice = pricePerSeat * _numberOfSeats;

    // Navigate to payment screen using GoRouter
    context.push(
      '/payment',
      extra: {
        'tripId': trip.id,
        'seatClass': _selectedClass,
        'numberOfSeats': _numberOfSeats,
        'pricePerSeat': pricePerSeat,
        'totalPrice': totalPrice,
        'trip': {
          'id': trip.id,
          'trainName': trip.trainNumber,
          'trainNumber': trip.trainNumber,
          'trainType': trip.trainType,
          'origin': trip.originName,
          'destination': trip.destinationName,
          'originCity': trip.originCity,
          'destinationCity': trip.destinationCity,
          'departureTime': trip.effectiveDepartureTime?.toIso8601String() ?? '',
          'arrivalTime': trip.effectiveArrivalTime?.toIso8601String() ?? '',
        },
      },
    );
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

          final pricePerSeat = _selectedClass == 'first'
              ? (trip.firstClassPrice ?? 0)
              : _selectedClass == 'second'
                  ? (trip.secondClassPrice ?? 0)
                  : (trip.economicPrice ?? 0);
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
                          trip.trainNumber,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${trip.originName} → ${trip.destinationName}',
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
                if (trip.firstClassPrice > 0)
                  RadioListTile<String>(
                    value: 'first',
                    groupValue: _selectedClass,
                    onChanged: (value) =>
                        setState(() => _selectedClass = value!),
                    title: const Text('First Class'),
                    subtitle: Text(
                        '\$${trip.firstClassPrice.toStringAsFixed(2)} per seat'),
                    secondary: const Icon(Icons.airline_seat_recline_extra),
                  ),
                if (trip.secondClassPrice > 0)
                  RadioListTile<String>(
                    value: 'second',
                    groupValue: _selectedClass,
                    onChanged: (value) =>
                        setState(() => _selectedClass = value!),
                    title: const Text('Second Class'),
                    subtitle: Text(
                        '\$${trip.secondClassPrice.toStringAsFixed(2)} per seat'),
                    secondary: const Icon(Icons.event_seat),
                  ),
                if (trip.economicPrice > 0)
                  RadioListTile<String>(
                    value: 'economic',
                    groupValue: _selectedClass,
                    onChanged: (value) =>
                        setState(() => _selectedClass = value!),
                    title: const Text('Economic Class'),
                    subtitle: Text(
                        '\$${trip.economicPrice.toStringAsFixed(2)} per seat'),
                    secondary: const Icon(Icons.airline_seat_recline_normal),
                  ),
                if (trip.firstClassPrice <= 0 &&
                    trip.secondClassPrice <= 0 &&
                    trip.economicPrice <= 0)
                  Card(
                    color: AppTheme.warningColor.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber,
                              color: AppTheme.warningColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No seat classes available for booking. Pricing not configured.',
                              style: TextStyle(color: AppTheme.warningColor),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                          onPressed: _numberOfSeats < trip.quantities
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
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(
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
      bottomNavigationBar: Consumer<TripProvider>(
        builder: (context, tripProvider, child) {
          final trip = tripProvider.selectedTrip;
          if (trip == null) return const SizedBox.shrink();

          // Check if any seat class is available with valid pricing
          final bool hasAvailableClasses = trip.firstClassPrice > 0 ||
              trip.secondClassPrice > 0 ||
              trip.economicPrice > 0;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: hasAvailableClasses ? _handleBooking : null,
                child: Text(hasAvailableClasses
                    ? 'Continue to Payment'
                    : 'No Classes Available'),
              ),
            ),
          );
        },
      ),
    );
  }
}
