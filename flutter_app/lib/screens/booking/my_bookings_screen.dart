import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/tour_provider.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final tourProvider = Provider.of<TourProvider>(context, listen: false);
    await tourProvider.loadReservations();
  }

  Future<void> _cancelBooking(int reservationId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerColor),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final tourProvider = Provider.of<TourProvider>(context, listen: false);
    final response = await tourProvider.cancelReservation(reservationId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response['message'] ?? 'Booking cancelled'),
        backgroundColor: response['success'] == true ? AppTheme.successColor : AppTheme.dangerColor,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: Consumer<TourProvider>(
        builder: (context, tourProvider, child) {
          if (tourProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildBookingsList(tourProvider.upcomingReservations, true),
              _buildBookingsList(tourProvider.pastReservations, false),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookingsList(List reservations, bool canCancel) {
    if (reservations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppTheme.grayColor),
            SizedBox(height: 16),
            Text('No bookings found'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reservations.length,
        itemBuilder: (context, index) {
          final reservation = reservations[index];
          final departureTime = DateTime.parse(reservation.tour.departureTime.toString());
          
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ref: ${reservation.bookingReference}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      _StatusBadge(status: reservation.status),
                    ],
                  ),
                  const Divider(height: 16),
                  Text(
                    reservation.tour.trainName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          reservation.tour.originName,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const Icon(Icons.arrow_forward, size: 20),
                      Expanded(
                        child: Text(
                          reservation.tour.destinationName,
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('MMM dd, yyyy • HH:mm').format(departureTime),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${reservation.seatClass} Class • ${reservation.numberOfSeats} seat(s)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '\$${double.parse(reservation.totalPrice.toString()).toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  if (canCancel && reservation.canCancel) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _cancelBooking(reservation.id),
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Cancel Booking'),
                        style: OutlinedButton.styleFrom(foregroundColor: AppTheme.dangerColor),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'confirmed':
        color = AppTheme.successColor;
        break;
      case 'cancelled':
        color = AppTheme.dangerColor;
        break;
      default:
        color = AppTheme.grayColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
