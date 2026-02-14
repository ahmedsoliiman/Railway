import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedOriginId;
  String? _selectedDestinationId;
  DateTime? _selectedDate;
  String? _selectedClass;
  double? _maxPrice;
  TimeOfDay? _selectedDepartureTime;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final tripProvider = Provider.of<TripProvider>(context, listen: false);

      // 1. Sync Stations and Auth (only if needed)
      await Future.wait([
        tripProvider.loadStations(),
        authProvider.loadUser(),
      ]);
    } catch (e) {
      print('❌ Error in _loadData: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error loading data: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
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

  Future<void> _searchTrips() async {
    if (_selectedOriginId == null || _selectedDestinationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select both origin and destination stations'),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (_selectedOriginId == _selectedDestinationId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Origin and destination must be different'),
            backgroundColor: Colors.red),
      );
      return;
    }

    final tripProvider = Provider.of<TripProvider>(context, listen: false);

    await tripProvider.loadTrips(
      originStationCode: _selectedOriginId,
      destinationStationCode: _selectedDestinationId,
      date: _selectedDate,
      seatClass: _selectedClass,
      maxPrice: _maxPrice,
      departureTime: _selectedDepartureTime,
    );

    if (mounted) {
      if (tripProvider.trips.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No trips found for the selected route'),
              backgroundColor: Colors.orange),
        );
      } else {
        context.push('/trips');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth > 600;
            final horizontalPadding =
                isWide ? constraints.maxWidth * 0.1 : 24.0;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32)),
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding, vertical: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Welcome back,',
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Text(user?.fullName ?? 'Guest',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.person_outline,
                                  color: Colors.white),
                              onPressed: () => context.push('/profile'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text('🚂 Book Your Journey',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding, vertical: 24),
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Consumer<TripProvider>(
                          builder: (context, tripProvider, child) {
                            return Column(
                              children: [
                                // 1. From (Origin)
                                DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  value: _selectedOriginId,
                                  decoration: const InputDecoration(
                                      isDense: true,
                                      labelText: 'From (Origin)',
                                      prefixIcon: Icon(
                                          Icons.location_on_outlined,
                                          size: 20)),
                                  items: [
                                    const DropdownMenuItem<String>(
                                        value: null,
                                        child: Text('Select origin station')),
                                    ...tripProvider.stations
                                        .map((station) => DropdownMenuItem<
                                                String>(
                                            value: station.code,
                                            child: Text(
                                                '${station.name} (${station.city})',
                                                overflow:
                                                    TextOverflow.ellipsis)))
                                        .toList(),
                                  ],
                                  onChanged: (value) =>
                                      setState(() => _selectedOriginId = value),
                                ),
                                const SizedBox(height: 16),
                                // 2. To (Destination)
                                DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  value: _selectedDestinationId,
                                  decoration: const InputDecoration(
                                      isDense: true,
                                      labelText: 'To (Destination)',
                                      prefixIcon: Icon(
                                          Icons.location_on_outlined,
                                          size: 20)),
                                  items: [
                                    const DropdownMenuItem<String>(
                                        value: null,
                                        child:
                                            Text('Select destination station')),
                                    ...{
                                      for (var s in tripProvider.stations)
                                        if (s.code.isNotEmpty) s.name: s
                                    }.values.map((station) => DropdownMenuItem<
                                            String>(
                                        value: station.code,
                                        child: Text(
                                            '${station.name} (${station.city})',
                                            overflow: TextOverflow.ellipsis))),
                                  ],
                                  onChanged: (value) => setState(
                                      () => _selectedDestinationId = value),
                                ),
                                const SizedBox(height: 16),
                                InkWell(
                                  onTap: () => _selectDate(context),
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                        labelText: 'Travel Date',
                                        prefixIcon: Icon(
                                            Icons.calendar_today_outlined)),
                                    child: Text(_selectedDate == null
                                        ? 'Select date'
                                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // --- Advanced Filters ---
                                Theme(
                                  data: Theme.of(context).copyWith(
                                      dividerColor: Colors.transparent),
                                  child: ExpansionTile(
                                    leading: const Icon(Icons.filter_list),
                                    title: const Text('Advanced Filters',
                                        style: TextStyle(fontSize: 14)),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Column(
                                          children: [
                                            // Seat Class
                                            DropdownButtonFormField<String>(
                                              isExpanded: true,
                                              value: _selectedClass,
                                              decoration: const InputDecoration(
                                                isDense: true,
                                                labelText: 'Preferred Class',
                                                prefixIcon: Icon(
                                                    Icons
                                                        .airline_seat_recline_extra,
                                                    size: 20),
                                              ),
                                              items: const [
                                                DropdownMenuItem(
                                                    value: null,
                                                    child: Text('Any Class')),
                                                DropdownMenuItem(
                                                    value: 'first',
                                                    child: Text('First Class')),
                                                DropdownMenuItem(
                                                    value: 'second',
                                                    child:
                                                        Text('Second Class')),
                                                DropdownMenuItem(
                                                    value: 'economic',
                                                    child: Text('Economic')),
                                              ],
                                              onChanged: (val) => setState(
                                                  () => _selectedClass = val),
                                            ),
                                            const SizedBox(height: 16),
                                            // Max Price
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    'Max Price: ${_maxPrice?.toInt() ?? 500} EGP',
                                                    style: const TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                                Slider(
                                                  value: _maxPrice ?? 500,
                                                  min: 50,
                                                  max: 1000,
                                                  divisions: 19,
                                                  label:
                                                      '${_maxPrice?.toInt() ?? 500}',
                                                  onChanged: (val) => setState(
                                                      () => _maxPrice = val),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            // Departure Time
                                            InkWell(
                                              onTap: () async {
                                                final time =
                                                    await showTimePicker(
                                                  context: context,
                                                  initialTime:
                                                      _selectedDepartureTime ??
                                                          TimeOfDay.now(),
                                                );
                                                if (time != null)
                                                  setState(() =>
                                                      _selectedDepartureTime =
                                                          time);
                                              },
                                              child: InputDecorator(
                                                decoration:
                                                    const InputDecoration(
                                                  labelText: 'Departure After',
                                                  prefixIcon:
                                                      Icon(Icons.access_time),
                                                ),
                                                child: Text(
                                                    _selectedDepartureTime ==
                                                            null
                                                        ? 'Any Time'
                                                        : _selectedDepartureTime!
                                                            .format(context)),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            // Clear Filters
                                            TextButton.icon(
                                              onPressed: () => setState(() {
                                                _selectedClass = null;
                                                _maxPrice = null;
                                                _selectedDepartureTime = null;
                                              }),
                                              icon: const Icon(Icons.clear_all,
                                                  size: 18),
                                              label:
                                                  const Text('Clear Filters'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _searchTrips,
                                    icon: const Icon(Icons.search),
                                    label: const Text('Search Trains'),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quick Actions',
                            style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 16),
                        _QuickActionCard(
                          icon: Icons.confirmation_number_outlined,
                          title: 'My Bookings',
                          color: AppTheme.primaryColor,
                          onTap: () => context.push('/my-bookings'),
                        ),
                        const SizedBox(height: 16),
                        Consumer<AuthProvider>(
                          builder: (context, auth, _) {
                            final List<Widget> roleActions = [];

                            if (auth.isAdmin) {
                              roleActions.add(_QuickActionCard(
                                icon: Icons.admin_panel_settings,
                                title: 'Admin Dashboard',
                                color: Colors.orange,
                                onTap: () => context.push('/admin'),
                              ));
                              roleActions.add(const SizedBox(height: 16));
                            }

                            if (auth.isManager) {
                              roleActions.add(_QuickActionCard(
                                icon: Icons.analytics,
                                title: 'Manager Reporting',
                                color: Colors.teal,
                                onTap: () => context.push('/manager'),
                              ));
                              roleActions.add(const SizedBox(height: 16));
                            }

                            return Column(children: roleActions);
                          },
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
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

  const _QuickActionCard(
      {required this.icon,
      required this.title,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(width: 16),
              Expanded(
                child: Text(title,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
