import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/trip_provider.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  int? _selectedOriginId;
  int? _selectedDestinationId;
  DateTime? _selectedDate;
  String? _selectedClass;
  String? _selectedTrainType;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    await tripProvider.loadTrips(
      originStationId: _selectedOriginId,
      destinationStationId: _selectedDestinationId,
      date: _selectedDate,
      seatClass: _selectedClass,
      trainType: _selectedTrainType,
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filters', style: Theme.of(context).textTheme.titleLarge),
                  TextButton(
                    onPressed: () {
                      this.setState(() {
                        _selectedOriginId = null;
                        _selectedDestinationId = null;
                        _selectedDate = null;
                        _selectedClass = null;
                        _selectedTrainType = null;
                      });
                      Navigator.pop(context);
                      _loadTrips();
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedTrainType,
                decoration: const InputDecoration(
                  labelText: 'Train Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.train),
                ),
                items: const [
                  DropdownMenuItem(value: 'Express', child: Text('Express')),
                  DropdownMenuItem(value: 'Premium', child: Text('Premium')),
                  DropdownMenuItem(value: 'Standard', child: Text('Standard')),
                ],
                onChanged: (value) => this.setState(() => _selectedTrainType = value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedClass,
                decoration: const InputDecoration(
                  labelText: 'Seat Class',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.airline_seat_recline_normal),
                ),
                items: const [
                  DropdownMenuItem(value: 'first', child: Text('First Class')),
                  DropdownMenuItem(value: 'second', child: Text('Second Class')),
                ],
                onChanged: (value) => this.setState(() => _selectedClass = value),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(_selectedDate == null 
                    ? 'Select Date' 
                    : DateFormat('MMM dd, yyyy').format(_selectedDate!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    this.setState(() => _selectedDate = date);
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _loadTrips();
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Trips'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter Trips',
          ),
        ],
      ),
      body: Consumer<TripProvider>(
        builder: (context, tripProvider, child) {
          if (tripProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (tripProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppTheme.dangerColor),
                  const SizedBox(height: 16),
                  Text(
                    tripProvider.error!,
                    style: const TextStyle(color: AppTheme.dangerColor),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadTrips,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (tripProvider.trips.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.train_outlined, size: 64, color: AppTheme.grayColor),
                  SizedBox(height: 16),
                  Text('No trips available'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadTrips,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tripProvider.trips.length,
              itemBuilder: (context, index) {
                final trip = tripProvider.trips[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/trip-detail',
                      arguments: trip.id,
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
                                      trip.trainName,
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          trip.trainNumber,
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: trip.trainType == 'Premium' 
                                                ? Colors.amber.shade100
                                                : trip.trainType == 'Express'
                                                    ? Colors.blue.shade100
                                                    : Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            trip.trainType,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: trip.trainType == 'Premium'
                                                  ? Colors.amber.shade900
                                                  : trip.trainType == 'Express'
                                                      ? Colors.blue.shade900
                                                      : Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
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
                                      trip.originName,
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    Text(
                                      DateFormat('HH:mm').format(trip.departureTime),
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
                                      trip.destinationName,
                                      style: Theme.of(context).textTheme.titleMedium,
                                      textAlign: TextAlign.end,
                                    ),
                                    Text(
                                      DateFormat('HH:mm').format(trip.arrivalTime),
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
                                'Duration: ${trip.durationFormatted}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                '${trip.quantities} seats left',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: trip.quantities < 10 ? AppTheme.dangerColor : AppTheme.successColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'From \$${trip.firstClassPrice}',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  '/trip-detail',
                                  arguments: trip.id,
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
