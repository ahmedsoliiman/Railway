import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/trip_provider.dart';

class TripDetailScreen extends StatefulWidget {
  const TripDetailScreen({super.key});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
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

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Container(
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.trainName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            trip.trainNumber,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Text(
                              trip.trainType,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Journey Details
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Journey Details',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _JourneyPoint(
                                city: trip.originCity,
                                station: trip.originName,
                                time: DateFormat('HH:mm - MMM dd').format(trip.departureTime),
                                isOrigin: true,
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.primaryGradient,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      trip.durationFormatted,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.grayColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _JourneyPoint(
                                city: trip.destinationCity,
                                station: trip.destinationName,
                                time: DateFormat('HH:mm - MMM dd').format(trip.arrivalTime),
                                isOrigin: false,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Pricing
                      Text(
                        'Select Class',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      if (trip.firstClassPrice != null)
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.airline_seat_recline_extra, color: AppTheme.primaryColor),
                            title: const Text('First Class'),
                            subtitle: const Text('Premium seats with extra legroom'),
                            trailing: Text(
                              '\$${trip.firstClassPrice!.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      if (trip.secondClassPrice != null)
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.event_seat, color: AppTheme.secondaryColor),
                            title: const Text('Second Class'),
                            subtitle: const Text('Standard comfortable seats'),
                            trailing: Text(
                              '\$${trip.secondClassPrice!.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppTheme.secondaryColor,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Availability
                      Card(
                        color: trip.availableSeats < 10 ? AppTheme.dangerColor.withOpacity(0.1) : AppTheme.successColor.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                trip.availableSeats < 10 ? Icons.warning_amber : Icons.check_circle,
                                color: trip.availableSeats < 10 ? AppTheme.dangerColor : AppTheme.successColor,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${trip.availableSeats} seats available',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: trip.availableSeats < 10 ? AppTheme.dangerColor : AppTheme.successColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Facilities
                      if (trip.trainFacilities != null) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Facilities',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(trip.trainFacilities!),
                          ),
                        ),
                      ],
                    ],
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
          if (trip == null || trip.availableSeats == 0) return const SizedBox.shrink();

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/booking',
                  arguments: trip.id,
                ),
                child: const Text('Book This Trip'),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _JourneyPoint extends StatelessWidget {
  final String city;
  final String station;
  final String time;
  final bool isOrigin;

  const _JourneyPoint({
    required this.city,
    required this.station,
    required this.time,
    required this.isOrigin,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: isOrigin ? AppTheme.primaryColor : AppTheme.secondaryColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                city,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                station,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.grayColor,
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
