import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/tour_provider.dart';

class ToursScreen extends StatefulWidget {
  const ToursScreen({super.key});

  @override
  State<ToursScreen> createState() => _ToursScreenState();
}

class _ToursScreenState extends State<ToursScreen> {
  @override
  void initState() {
    super.initState();
    _loadTours();
  }

  Future<void> _loadTours() async {
    final tourProvider = Provider.of<TourProvider>(context, listen: false);
    await tourProvider.loadTours();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Tours'),
      ),
      body: Consumer<TourProvider>(
        builder: (context, tourProvider, child) {
          if (tourProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (tourProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppTheme.dangerColor),
                  const SizedBox(height: 16),
                  Text(
                    tourProvider.error!,
                    style: const TextStyle(color: AppTheme.dangerColor),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadTours,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (tourProvider.tours.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.train_outlined, size: 64, color: AppTheme.grayColor),
                  SizedBox(height: 16),
                  Text('No tours available'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadTours,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tourProvider.tours.length,
              itemBuilder: (context, index) {
                final tour = tourProvider.tours[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/tour-detail',
                      arguments: tour.id,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.train, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tour.trainName,
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    Text(
                                      tour.trainNumber,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tour.originName,
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    Text(
                                      DateFormat('HH:mm').format(tour.departureTime),
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward, color: AppTheme.grayColor),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      tour.destinationName,
                                      style: Theme.of(context).textTheme.titleMedium,
                                      textAlign: TextAlign.end,
                                    ),
                                    Text(
                                      DateFormat('HH:mm').format(tour.arrivalTime),
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Duration: ${tour.durationFormatted}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                '${tour.availableSeats} seats left',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: tour.availableSeats < 10 ? AppTheme.dangerColor : AppTheme.successColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'From \$${tour.firstClassPrice}',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  '/tour-detail',
                                  arguments: tour.id,
                                ),
                                child: const Text('Book Now'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
