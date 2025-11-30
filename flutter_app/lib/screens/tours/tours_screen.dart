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
  int? _selectedOriginId;
  int? _selectedDestinationId;
  DateTime? _selectedDate;
  String? _selectedClass;
  String? _selectedTrainType;

  @override
  void initState() {
    super.initState();
    _loadTours();
  }

  Future<void> _loadTours() async {
    final tourProvider = Provider.of<TourProvider>(context, listen: false);
    await tourProvider.loadTours(
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
                      _loadTours();
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
                    _loadTours();
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
        title: const Text('Available Tours'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter Tours',
          ),
        ],
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
                                    Row(
                                      children: [
                                        Text(
                                          tour.trainNumber,
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: tour.trainType == 'Premium' 
                                                ? Colors.amber.shade100
                                                : tour.trainType == 'Express'
                                                    ? Colors.blue.shade100
                                                    : Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            tour.trainType,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: tour.trainType == 'Premium'
                                                  ? Colors.amber.shade900
                                                  : tour.trainType == 'Express'
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
