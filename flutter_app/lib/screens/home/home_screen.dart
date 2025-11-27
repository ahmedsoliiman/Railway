import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tour_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final tourProvider = Provider.of<TourProvider>(context, listen: false);
    await tourProvider.searchTours();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _searchTours() async {
    final tourProvider = Provider.of<TourProvider>(context, listen: false);
    String? dateString;
    if (_selectedDate != null) {
      dateString = '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
    }
    
    await tourProvider.searchTours(date: dateString);
    
    if (mounted) {
      Navigator.pushNamed(context, '/tours');
    }
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome back,',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.fullName ?? 'Guest',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.person_outline, color: Colors.white),
                          onPressed: () => Navigator.pushNamed(context, '/profile'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '🚂 Book Your Journey',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Search Form
              Padding(
                padding: const EdgeInsets.all(24),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TextField(
                          controller: _originController,
                          decoration: const InputDecoration(
                            labelText: 'From (Origin)',
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _destinationController,
                          decoration: const InputDecoration(
                            labelText: 'To (Destination)',
                            prefixIcon: Icon(Icons.flag_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Travel Date',
                              prefixIcon: Icon(Icons.calendar_today_outlined),
                            ),
                            child: Text(
                              _selectedDate == null
                                  ? 'Select date'
                                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _searchTours,
                            icon: const Icon(Icons.search),
                            label: const Text('Search Trains'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Quick Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.confirmation_number_outlined,
                            title: 'My Bookings',
                            color: AppTheme.primaryColor,
                            onTap: () => Navigator.pushNamed(context, '/my-bookings'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.train_outlined,
                            title: 'All Tours',
                            color: AppTheme.successColor,
                            onTap: () => Navigator.pushNamed(context, '/tours'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
