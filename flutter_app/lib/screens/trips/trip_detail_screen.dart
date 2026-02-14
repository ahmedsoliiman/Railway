import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/trip_provider.dart';
import '../../providers/review_provider.dart';
import 'package:go_router/go_router.dart';

class TripDetailScreen extends StatefulWidget {
  final int tripId;
  const TripDetailScreen({super.key, required this.tripId});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadTripDetails(widget.tripId);
  }

  Future<void> _loadTripDetails(int tripId) async {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);

    await Future.wait([
      tripProvider.loadTripDetails(tripId),
      reviewProvider.loadRatingSummary(tripId),
    ]);
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
                        trip.trainNumber,
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3)),
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
                                city: trip.originCity ?? 'N/A',
                                station: trip.originName,
                                time: trip.effectiveDepartureTime != null
                                    ? DateFormat('HH:mm - MMM dd')
                                        .format(trip.effectiveDepartureTime!)
                                    : 'N/A',
                                isOrigin: true,
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 16),
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppTheme.grayColor,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              _JourneyPoint(
                                city: trip.destinationCity ?? 'N/A',
                                station: trip.destinationName,
                                time: trip.effectiveArrivalTime != null
                                    ? DateFormat('HH:mm - MMM dd')
                                        .format(trip.effectiveArrivalTime!)
                                    : 'N/A',
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
                      if (trip.availableSeatClasses != null &&
                          trip.availableSeatClasses!.isNotEmpty)
                        ...trip.availableSeatClasses!.map((classInfo) {
                          final String classValue =
                              classInfo['value'] as String;
                          final String classLabel =
                              classInfo['label'] as String;
                          final double classPrice =
                              (classInfo['price'] as num).toDouble();

                          // Determine icon and color based on class type
                          IconData iconData;
                          Color iconColor;
                          String subtitle;

                          if (classValue == 'first') {
                            iconData = Icons.airline_seat_recline_extra;
                            iconColor = AppTheme.primaryColor;
                            subtitle = 'Premium seats with extra legroom';
                          } else if (classValue == 'second') {
                            iconData = Icons.event_seat;
                            iconColor = AppTheme.secondaryColor;
                            subtitle = 'Standard comfortable seats';
                          } else {
                            iconData = Icons.airline_seat_recline_normal;
                            iconColor = AppTheme.warningColor;
                            subtitle = 'Budget-friendly seats';
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Card(
                              child: ListTile(
                                leading: Icon(iconData, color: iconColor),
                                title: Text(classLabel),
                                subtitle: Text(subtitle),
                                trailing: Text(
                                  '\$${classPrice.toStringAsFixed(2)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: iconColor,
                                      ),
                                ),
                              ),
                            ),
                          );
                        }).toList()
                      else if ((trip.firstClassPrice != null &&
                              trip.firstClassPrice! > 0) ||
                          (trip.secondClassPrice != null &&
                              trip.secondClassPrice! > 0) ||
                          (trip.economicPrice != null &&
                              trip.economicPrice! > 0))
                        // Fallback to old pricing display if availableSeatClasses is not provided
                        ...[
                        if (trip.firstClassPrice != null &&
                            trip.firstClassPrice! > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Card(
                              child: ListTile(
                                leading: const Icon(
                                    Icons.airline_seat_recline_extra,
                                    color: AppTheme.primaryColor),
                                title: const Text('First Class'),
                                subtitle: const Text(
                                    'Premium seats with extra legroom'),
                                trailing: Text(
                                  '\$${trip.firstClassPrice!.toStringAsFixed(2)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: AppTheme.primaryColor,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        if (trip.secondClassPrice != null &&
                            trip.secondClassPrice! > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Card(
                              child: ListTile(
                                leading: const Icon(Icons.event_seat,
                                    color: AppTheme.secondaryColor),
                                title: const Text('Second Class'),
                                subtitle:
                                    const Text('Standard comfortable seats'),
                                trailing: Text(
                                  '\$${trip.secondClassPrice!.toStringAsFixed(2)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: AppTheme.secondaryColor,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        if (trip.economicPrice != null &&
                            trip.economicPrice! > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Card(
                              child: ListTile(
                                leading: const Icon(
                                    Icons.airline_seat_recline_normal,
                                    color: AppTheme.warningColor),
                                title: const Text('Economic Class'),
                                subtitle: const Text('Budget-friendly seats'),
                                trailing: Text(
                                  '\$${trip.economicPrice!.toStringAsFixed(2)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: AppTheme.warningColor,
                                      ),
                                ),
                              ),
                            ),
                          ),
                      ] else
                        // No pricing configured for this trip
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
                                    'Pricing not configured for this trip. Please contact support.',
                                    style:
                                        TextStyle(color: AppTheme.warningColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Availability
                      Card(
                        color: trip.quantities < 10
                            ? AppTheme.dangerColor.withOpacity(0.1)
                            : AppTheme.successColor.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                trip.quantities < 10
                                    ? Icons.warning_amber
                                    : Icons.check_circle,
                                color: trip.quantities < 10
                                    ? AppTheme.dangerColor
                                    : AppTheme.successColor,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${trip.quantities} seats available',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: trip.quantities < 10
                                          ? AppTheme.dangerColor
                                          : AppTheme.successColor,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Reviews Summary
                      Consumer<ReviewProvider>(
                        builder: (context, reviewProvider, child) {
                          final summary = reviewProvider.ratingSummary;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Reviews',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                  ),
                                  TextButton(
                                    onPressed: () => context.push(
                                      '/trip-reviews',
                                      extra: {
                                        'tripId': trip.id,
                                        'tripName': trip.trainNumber,
                                      },
                                    ),
                                    child: const Text('See All'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Card(
                                child: ListTile(
                                  leading: const Icon(Icons.star,
                                      color: Colors.amber, size: 32),
                                  title: Text(
                                    summary != null && summary.totalReviews > 0
                                        ? '${summary.averageRating.toStringAsFixed(1)} / 5.0'
                                        : 'No ratings yet',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    summary != null
                                        ? 'Based on ${summary.totalReviews} reviews'
                                        : 'Be the first to review',
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => context.push(
                                    '/trip-reviews',
                                    extra: {
                                      'tripId': trip.id,
                                      'tripName': trip.trainNumber,
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 32),
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
          if (trip == null || trip.quantities == 0)
            return const SizedBox.shrink();

          // Check if any seat class is available with valid pricing
          final bool hasAvailableClasses = (trip.availableSeatClasses != null &&
                  trip.availableSeatClasses!.isNotEmpty) ||
              (trip.firstClassPrice != null && trip.firstClassPrice! > 0) ||
              (trip.secondClassPrice != null && trip.secondClassPrice! > 0) ||
              (trip.economicPrice != null && trip.economicPrice! > 0);

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: hasAvailableClasses
                    ? () => context.push(
                          '/booking',
                          extra: trip.id,
                        )
                    : null,
                child: Text(hasAvailableClasses
                    ? 'Book This Trip'
                    : 'Booking Not Available'),
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
