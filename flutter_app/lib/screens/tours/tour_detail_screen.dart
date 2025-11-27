import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/tour_provider.dart';

class TourDetailScreen extends StatefulWidget {
  const TourDetailScreen({super.key});

  @override
  State<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends State<TourDetailScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tourId = ModalRoute.of(context)!.settings.arguments as int;
    _loadTourDetails(tourId);
  }

  Future<void> _loadTourDetails(int tourId) async {
    final tourProvider = Provider.of<TourProvider>(context, listen: false);
    await tourProvider.loadTourDetails(tourId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tour Details'),
      ),
      body: Consumer<TourProvider>(
        builder: (context, tourProvider, child) {
          if (tourProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final tour = tourProvider.selectedTour;
          if (tour == null) {
            return const Center(child: Text('Tour not found'));
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
                        tour.trainName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${tour.trainNumber} • ${tour.trainType}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
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
                                city: tour.originCity,
                                station: tour.originName,
                                time: DateFormat('HH:mm - MMM dd').format(tour.departureTime),
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
                                      tour.durationFormatted,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.grayColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _JourneyPoint(
                                city: tour.destinationCity,
                                station: tour.destinationName,
                                time: DateFormat('HH:mm - MMM dd').format(tour.arrivalTime),
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
                      if (tour.firstClassPrice != null)
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.airline_seat_recline_extra, color: AppTheme.primaryColor),
                            title: const Text('First Class'),
                            subtitle: const Text('Premium seats with extra legroom'),
                            trailing: Text(
                              '\$${tour.firstClassPrice!.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      if (tour.secondClassPrice != null)
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.event_seat, color: AppTheme.secondaryColor),
                            title: const Text('Second Class'),
                            subtitle: const Text('Standard comfortable seats'),
                            trailing: Text(
                              '\$${tour.secondClassPrice!.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppTheme.secondaryColor,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Availability
                      Card(
                        color: tour.availableSeats < 10 ? AppTheme.dangerColor.withOpacity(0.1) : AppTheme.successColor.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                tour.availableSeats < 10 ? Icons.warning_amber : Icons.check_circle,
                                color: tour.availableSeats < 10 ? AppTheme.dangerColor : AppTheme.successColor,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${tour.availableSeats} seats available',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: tour.availableSeats < 10 ? AppTheme.dangerColor : AppTheme.successColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Facilities
                      if (tour.trainFacilities != null) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Facilities',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(tour.trainFacilities!),
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
      bottomNavigationBar: Consumer<TourProvider>(
        builder: (context, tourProvider, child) {
          final tour = tourProvider.selectedTour;
          if (tour == null || tour.availableSeats == 0) return const SizedBox.shrink();

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/booking',
                  arguments: tour.id,
                ),
                child: const Text('Book This Tour'),
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
