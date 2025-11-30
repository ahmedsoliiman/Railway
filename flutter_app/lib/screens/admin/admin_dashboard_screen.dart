import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../config/theme.dart';
import '../../models/station.dart';
import '../../models/train.dart';
import '../../models/tour.dart';
import '../../widgets/enhanced_dialog.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      adminProvider.loadDashboardStats();
      adminProvider.loadStations();
      adminProvider.loadTrains();
      adminProvider.loadTours();
    });
  }

  final List<Widget> _pages = [
    const AdminOverviewPage(),
    const AdminStationsPage(),
    const AdminTrainsPage(),
    const AdminTripsPage(),
    const AdminUsersPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.admin_panel_settings, size: 20),
                const SizedBox(width: 8),
                Text(
                  user?.fullName ?? 'Admin',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirm == true && mounted) {
                await authProvider.logout();
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar Navigation
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.grey[100],
            selectedIconTheme: const IconThemeData(
              color: AppTheme.primaryColor,
              size: 28,
            ),
            selectedLabelTextStyle: const TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Overview'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.location_on_outlined),
                selectedIcon: Icon(Icons.location_on),
                label: Text('Stations'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.train_outlined),
                selectedIcon: Icon(Icons.train),
                label: Text('Trains'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.route_outlined),
                selectedIcon: Icon(Icons.route),
                label: Text('Trips'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Users'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Main Content
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

// Overview Page
class AdminOverviewPage extends StatelessWidget {
  const AdminOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dashboard Overview',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  Provider.of<AdminProvider>(context, listen: false).loadDashboardStats();
                },
                tooltip: 'Refresh Stats',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, adminProvider, child) {
                if (adminProvider.isLoadingStats) {
                  return const Center(child: CircularProgressIndicator());
                }

                final stats = adminProvider.dashboardStats;
                
                return GridView.count(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildStatCard(
                      context,
                      'Total Users',
                      '${stats?['total_users'] ?? 0}',
                      Icons.people,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      context,
                      'Active Tours',
                      '${stats?['active_tours'] ?? 0}',
                      Icons.tour,
                      Colors.green,
                    ),
                    _buildStatCard(
                      context,
                      'Total Bookings',
                      '${stats?['total_reservations'] ?? 0}',
                      Icons.book_online,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      context,
                      'Revenue',
                      '\$${(stats?['total_revenue'] ?? 0).toString()}',
                      Icons.attach_money,
                      Colors.purple,
                    ),
                    _buildStatCard(
                      context,
                      'Total Stations',
                      '${stats?['total_stations'] ?? 0}',
                      Icons.location_on,
                      Colors.red,
                    ),
                    _buildStatCard(
                      context,
                      'Total Trains',
                      '${stats?['total_trains'] ?? 0}',
                      Icons.train,
                      Colors.indigo,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Stations Management Page
class AdminStationsPage extends StatelessWidget {
  const AdminStationsPage({super.key});

  void _showStationDialog(BuildContext context, {Station? station}) {
    final nameController = TextEditingController(text: station?.name);
    final cityController = TextEditingController(text: station?.city);
    final addressController = TextEditingController(text: station?.address);
    final facilitiesController = TextEditingController(text: station?.facilities);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => EnhancedDialog(
        title: station == null ? 'Add New Station' : 'Edit Station',
        subtitle: station == null ? 'Create a new train station' : 'Update station information',
        icon: Icons.train_outlined,
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              EnhancedTextField(
                controller: nameController,
                label: 'Station Name *',
                hint: 'e.g., Central Station',
                icon: Icons.location_city,
                validator: (v) => v?.isEmpty ?? true ? 'Station name is required' : null,
              ),
              const SizedBox(height: 16),
              EnhancedTextField(
                controller: cityController,
                label: 'City *',
                hint: 'e.g., New York',
                icon: Icons.location_on,
                validator: (v) => v?.isEmpty ?? true ? 'City is required' : null,
              ),
              const SizedBox(height: 16),
              EnhancedTextField(
                controller: addressController,
                label: 'Address',
                hint: 'Full station address',
                icon: Icons.place,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              EnhancedTextField(
                controller: facilitiesController,
                label: 'Facilities',
                hint: 'WiFi, Waiting Room, Parking, Restaurant',
                icon: Icons.local_convenience_store,
                maxLines: 2,
                helperText: 'Separate multiple facilities with commas',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final adminProvider = Provider.of<AdminProvider>(context, listen: false);
              
              final response = station == null
                  ? await adminProvider.createStation(
                      name: nameController.text,
                      city: cityController.text,
                      address: addressController.text.isEmpty ? null : addressController.text,
                      facilities: facilitiesController.text.isEmpty ? null : facilitiesController.text,
                    )
                  : await adminProvider.updateStation(
                      id: station.id,
                      name: nameController.text,
                      city: cityController.text,
                      address: addressController.text.isEmpty ? null : addressController.text,
                      facilities: facilitiesController.text.isEmpty ? null : facilitiesController.text,
                    );

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(response['message'] ?? 'Success'),
                    backgroundColor: response['success'] ? Colors.green : Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            icon: Icon(station == null ? Icons.add : Icons.check),
            label: Text(station == null ? 'Add Station' : 'Update Station'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Manage Stations',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showStationDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Station'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, adminProvider, child) {
                if (adminProvider.isLoadingStations) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (adminProvider.stations.isEmpty) {
                  return const Center(child: Text('No stations yet'));
                }

                return Card(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('City')),
                        DataColumn(label: Text('Address')),
                        DataColumn(label: Text('Facilities')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: adminProvider.stations.map((station) {
                        return DataRow(cells: [
                          DataCell(Text(station.name)),
                          DataCell(Text(station.city)),
                          DataCell(Text(station.address ?? 'N/A')),
                          DataCell(Text(station.facilities ?? 'N/A')),
                          DataCell(Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _showStationDialog(context, station: station),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Station'),
                                      content: Text('Delete ${station.name}?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true && context.mounted) {
                                    final response = await adminProvider.deleteStation(station.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(response['message'] ?? 'Deleted')),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Trains Management Page
class AdminTrainsPage extends StatelessWidget {
  const AdminTrainsPage({super.key});

  void _showTrainDialog(BuildContext context, {Train? train}) {
    final trainNumberController = TextEditingController(text: train?.trainNumber);
    final nameController = TextEditingController(text: train?.name);
    final totalSeatsController = TextEditingController(text: train?.totalSeats.toString());
    final firstClassSeatsController = TextEditingController(text: train?.firstClassSeats.toString());
    final secondClassSeatsController = TextEditingController(text: train?.secondClassSeats.toString());
    final facilitiesController = TextEditingController(text: train?.facilities);
    String selectedType = train?.type ?? 'Standard';
    String selectedStatus = train?.status ?? 'active';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => EnhancedDialog(
          title: train == null ? 'Add New Train' : 'Edit Train',
          subtitle: train == null ? 'Configure train specifications' : 'Update train details',
          icon: Icons.directions_train,
          headerGradient: LinearGradient(
            colors: [Colors.purple.shade600, Colors.purple.shade800],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                EnhancedTextField(
                  controller: trainNumberController,
                  label: 'Train Number *',
                  hint: 'e.g., TR-001',
                  icon: Icons.confirmation_number,
                  validator: (v) => v?.isEmpty ?? true ? 'Train number is required' : null,
                ),
                const SizedBox(height: 16),
                EnhancedTextField(
                  controller: nameController,
                  label: 'Train Name *',
                  hint: 'e.g., Express Eagle',
                  icon: Icons.train,
                  validator: (v) => v?.isEmpty ?? true ? 'Train name is required' : null,
                ),
                const SizedBox(height: 16),
                EnhancedDropdown<String>(
                  value: selectedType,
                  label: 'Train Type *',
                  icon: Icons.category,
                  items: [
                    const DropdownMenuItem(value: 'Premium', child: Text('Premium (Luxury)')),
                    const DropdownMenuItem(value: 'Express', child: Text('Express (Fast)')),
                    const DropdownMenuItem(value: 'Standard', child: Text('Standard (Economic)')),
                  ],
                  onChanged: (value) => setState(() => selectedType = value!),
                ),
                const SizedBox(height: 16),
                EnhancedTextField(
                  controller: totalSeatsController,
                  label: 'Total Seats *',
                  hint: 'Total capacity',
                  icon: Icons.event_seat,
                  keyboardType: TextInputType.number,
                  validator: (v) => int.tryParse(v ?? '') == null ? 'Must be a number' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: EnhancedTextField(
                        controller: firstClassSeatsController,
                        label: '1st Class Seats *',
                        hint: 'Premium',
                        icon: Icons.airline_seat_flat,
                        keyboardType: TextInputType.number,
                        validator: (v) => int.tryParse(v ?? '') == null ? 'Invalid' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: EnhancedTextField(
                        controller: secondClassSeatsController,
                        label: '2nd Class Seats *',
                        hint: 'Economy',
                        icon: Icons.event_seat,
                        keyboardType: TextInputType.number,
                        validator: (v) => int.tryParse(v ?? '') == null ? 'Invalid' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                EnhancedTextField(
                  controller: facilitiesController,
                  label: 'Facilities',
                  hint: 'AC, WiFi, Food Service, Entertainment',
                  icon: Icons.stars,
                  maxLines: 2,
                  helperText: 'Comma-separated list of onboard amenities',
                ),
                const SizedBox(height: 16),
                EnhancedDropdown<String>(
                  value: selectedStatus,
                  label: 'Status',
                  icon: Icons.info,
                  items: ['active', 'maintenance', 'retired'].map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedStatus = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final adminProvider = Provider.of<AdminProvider>(context, listen: false);
                
                final response = train == null
                    ? await adminProvider.createTrain(
                        trainNumber: trainNumberController.text,
                        name: nameController.text,
                        type: selectedType,
                        totalSeats: int.parse(totalSeatsController.text),
                        firstClassSeats: int.parse(firstClassSeatsController.text),
                        secondClassSeats: int.parse(secondClassSeatsController.text),
                        facilities: facilitiesController.text.isEmpty ? null : facilitiesController.text,
                        status: selectedStatus,
                      )
                    : await adminProvider.updateTrain(
                        id: train.id,
                        trainNumber: trainNumberController.text,
                        name: nameController.text,
                        type: selectedType,
                        totalSeats: int.parse(totalSeatsController.text),
                        firstClassSeats: int.parse(firstClassSeatsController.text),
                        secondClassSeats: int.parse(secondClassSeatsController.text),
                        facilities: facilitiesController.text.isEmpty ? null : facilitiesController.text,
                        status: selectedStatus,
                      );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response['message'] ?? 'Success'),
                      backgroundColor: response['success'] ? Colors.green : Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              icon: Icon(train == null ? Icons.add : Icons.check),
              label: Text(train == null ? 'Add Train' : 'Update Train'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Manage Trains',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showTrainDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Train'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, adminProvider, child) {
                if (adminProvider.isLoadingTrains) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (adminProvider.trains.isEmpty) {
                  return const Center(child: Text('No trains yet'));
                }

                return Card(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Number')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('Total Seats')),
                        DataColumn(label: Text('First Class')),
                        DataColumn(label: Text('Second Class')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: adminProvider.trains.map((train) {
                        return DataRow(cells: [
                          DataCell(Text(train.trainNumber)),
                          DataCell(Text(train.name)),
                          DataCell(Text(train.type)),
                          DataCell(Text('${train.totalSeats}')),
                          DataCell(Text('${train.firstClassSeats}')),
                          DataCell(Text('${train.secondClassSeats}')),
                          DataCell(Text(train.status.toUpperCase())),
                          DataCell(Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _showTrainDialog(context, train: train),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Train'),
                                      content: Text('Delete ${train.name}?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true && context.mounted) {
                                    final response = await adminProvider.deleteTrain(train.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(response['message'] ?? 'Deleted')),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Trips Management Page
class AdminTripsPage extends StatelessWidget {
  const AdminTripsPage({super.key});

  void _showTripDialog(BuildContext context, AdminProvider adminProvider, {Tour? tour}) {
    final firstClassPriceController = TextEditingController(text: tour?.firstClassPrice?.toString());
    final secondClassPriceController = TextEditingController(text: tour?.secondClassPrice?.toString());
    final availableSeatsController = TextEditingController(text: tour?.availableSeats.toString());
    int? selectedTrainId = tour?.trainId;
    int? selectedOriginId = tour?.originStationId;
    int? selectedDestinationId = tour?.destinationStationId;
    DateTime departureTime = tour?.departureTime ?? DateTime.now().add(const Duration(days: 1));
    DateTime arrivalTime = tour?.arrivalTime ?? DateTime.now().add(const Duration(days: 1, hours: 4));
    String selectedStatus = tour?.status ?? 'scheduled';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(tour == null ? 'Add Trip' : 'Edit Trip'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: selectedTrainId,
                    decoration: const InputDecoration(labelText: 'Train'),
                    items: adminProvider.trains.map((train) {
                      return DropdownMenuItem(
                        value: train.id,
                        child: Text('${train.trainNumber} - ${train.name}'),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => selectedTrainId = value),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                  DropdownButtonFormField<int>(
                    value: selectedOriginId,
                    decoration: const InputDecoration(labelText: 'Origin Station'),
                    items: adminProvider.stations.map((station) {
                      return DropdownMenuItem(
                        value: station.id,
                        child: Text('${station.name} (${station.city})'),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => selectedOriginId = value),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                  DropdownButtonFormField<int>(
                    value: selectedDestinationId,
                    decoration: const InputDecoration(labelText: 'Destination Station'),
                    items: adminProvider.stations.map((station) {
                      return DropdownMenuItem(
                        value: station.id,
                        child: Text('${station.name} (${station.city})'),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => selectedDestinationId = value),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                  ListTile(
                    title: const Text('Departure Time'),
                    subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(departureTime)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: departureTime,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(departureTime),
                        );
                        if (time != null) {
                          setState(() {
                            departureTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                          });
                        }
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('Arrival Time'),
                    subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(arrivalTime)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: arrivalTime,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(arrivalTime),
                        );
                        if (time != null) {
                          setState(() {
                            arrivalTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                          });
                        }
                      }
                    },
                  ),
                  TextFormField(
                    controller: firstClassPriceController,
                    decoration: const InputDecoration(labelText: 'First Class Price'),
                    keyboardType: TextInputType.number,
                    validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null,
                  ),
                  TextFormField(
                    controller: secondClassPriceController,
                    decoration: const InputDecoration(labelText: 'Second Class Price'),
                    keyboardType: TextInputType.number,
                    validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null,
                  ),
                  TextFormField(
                    controller: availableSeatsController,
                    decoration: const InputDecoration(labelText: 'Available Seats'),
                    keyboardType: TextInputType.number,
                    validator: (v) => int.tryParse(v ?? '') == null ? 'Invalid' : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: ['scheduled', 'boarding', 'departed', 'arrived', 'cancelled'].map((status) {
                      return DropdownMenuItem(value: status, child: Text(status.toUpperCase()));
                    }).toList(),
                    onChanged: (value) => setState(() => selectedStatus = value!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final response = tour == null
                    ? await adminProvider.createTour(
                        trainId: selectedTrainId!,
                        originStationId: selectedOriginId!,
                        destinationStationId: selectedDestinationId!,
                        departureTime: departureTime,
                        arrivalTime: arrivalTime,
                        firstClassPrice: double.parse(firstClassPriceController.text),
                        secondClassPrice: double.parse(secondClassPriceController.text),
                        availableSeats: int.parse(availableSeatsController.text),
                        status: selectedStatus,
                      )
                    : await adminProvider.updateTour(
                        id: tour.id,
                        trainId: selectedTrainId,
                        originStationId: selectedOriginId,
                        destinationStationId: selectedDestinationId,
                        departureTime: departureTime,
                        arrivalTime: arrivalTime,
                        firstClassPrice: double.parse(firstClassPriceController.text),
                        secondClassPrice: double.parse(secondClassPriceController.text),
                        availableSeats: int.parse(availableSeatsController.text),
                        status: selectedStatus,
                      );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(response['message'] ?? 'Success')),
                  );
                }
              },
              child: Text(tour == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Manage Trips',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showTripDialog(context, adminProvider),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Trip'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: adminProvider.isLoadingTours
                    ? const Center(child: CircularProgressIndicator())
                    : adminProvider.tours.isEmpty
                        ? const Center(child: Text('No trips yet'))
                        : Card(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Train')),
                                  DataColumn(label: Text('Route')),
                                  DataColumn(label: Text('Departure')),
                                  DataColumn(label: Text('1st Class')),
                                  DataColumn(label: Text('2nd Class')),
                                  DataColumn(label: Text('Seats')),
                                  DataColumn(label: Text('Status')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: adminProvider.tours.map((tour) {
                                  return DataRow(cells: [
                                    DataCell(Text(tour.trainName)),
                                    DataCell(Text('${tour.originCity} → ${tour.destinationCity}')),
                                    DataCell(Text(DateFormat('MMM dd, HH:mm').format(tour.departureTime))),
                                    DataCell(Text('\$${tour.firstClassPrice?.toStringAsFixed(2)}')),
                                    DataCell(Text('\$${tour.secondClassPrice?.toStringAsFixed(2)}')),
                                    DataCell(Text('${tour.availableSeats}')),
                                    DataCell(Text(tour.status.toUpperCase())),
                                    DataCell(Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, size: 20),
                                          onPressed: () => _showTripDialog(context, adminProvider, tour: tour),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Delete Trip'),
                                                content: Text('Delete trip from ${tour.originCity} to ${tour.destinationCity}?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, false),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                    onPressed: () => Navigator.pop(context, true),
                                                    child: const Text('Delete'),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (confirm == true && context.mounted) {
                                              final response = await adminProvider.deleteTour(tour.id);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text(response['message'] ?? 'Deleted')),
                                                );
                                              }
                                            }
                                          },
                                        ),
                                      ],
                                    )),
                                  ]);
                                }).toList(),
                              ),
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Users Management Page
class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  List<dynamic> users = [];
  List<dynamic> reservations = [];
  bool isLoading = false;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      final usersData = await adminProvider.getAllUsers();
      final reservationsData = await adminProvider.getAllReservations();
      setState(() {
        users = usersData;
        reservations = reservationsData;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return '🟢';
      case 'cancelled':
        return '🔴';
      case 'completed':
        return '🔵';
      default:
        return '⚪';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Manage Users & Reservations',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadData,
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tabs
          Row(
            children: [
              ChoiceChip(
                label: Text('Users (${users.length})'),
                selected: _selectedTab == 0,
                onSelected: (selected) => setState(() => _selectedTab = 0),
              ),
              const SizedBox(width: 12),
              ChoiceChip(
                label: Text('Reservations (${reservations.length})'),
                selected: _selectedTab == 1,
                onSelected: (selected) => setState(() => _selectedTab = 1),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _selectedTab == 0
                    ? _buildUsersTable()
                    : _buildReservationsTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTable() {
    if (users.isEmpty) {
      return const Center(child: Text('No users yet'));
    }
    
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Phone')),
            DataColumn(label: Text('Role')),
            DataColumn(label: Text('Verified')),
            DataColumn(label: Text('Joined')),
          ],
          rows: users.map<DataRow>((user) {
            return DataRow(cells: [
              DataCell(Text('#${user['id']}')),
              DataCell(Text(user['full_name'] ?? 'N/A')),
              DataCell(Text(user['email'] ?? 'N/A')),
              DataCell(Text(user['phone'] ?? 'N/A')),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: user['role'] == 'admin' ? Colors.red[100] : Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    (user['role'] ?? 'user').toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: user['role'] == 'admin' ? Colors.red[900] : Colors.blue[900],
                    ),
                  ),
                ),
              ),
              DataCell(Text(user['is_verified'] == true ? '✅' : '❌')),
              DataCell(Text(user['created_at'] != null 
                  ? DateFormat('MMM dd, yyyy').format(DateTime.parse(user['created_at']))
                  : 'N/A')),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildReservationsTable() {
    if (reservations.isEmpty) {
      return const Center(child: Text('No reservations yet'));
    }
    
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
                            columns: const [
                              DataColumn(label: Text('ID')),
                              DataColumn(label: Text('User')),
                              DataColumn(label: Text('Email')),
                              DataColumn(label: Text('Train')),
                              DataColumn(label: Text('Route')),
                              DataColumn(label: Text('Date')),
                              DataColumn(label: Text('Class')),
                              DataColumn(label: Text('Seats')),
                              DataColumn(label: Text('Total')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Booked')),
                            ],
                            rows: reservations.map((reservation) {
                              return DataRow(cells: [
                                DataCell(Text('#${reservation['id']}')),
                                DataCell(Text(reservation['user_name'] ?? 'N/A')),
                                DataCell(Text(reservation['user_email'] ?? 'N/A')),
                                DataCell(Text(reservation['train_name'] ?? 'N/A')),
                                DataCell(Text('${reservation['origin_city']} → ${reservation['destination_city']}')),
                                DataCell(Text(reservation['departure_time'] != null 
                                    ? DateFormat('MMM dd, HH:mm').format(DateTime.parse(reservation['departure_time']))
                                    : 'N/A')),
                                DataCell(Text(
                                  reservation['seat_class'] == 'first' ? '1st Class' : '2nd Class',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: reservation['seat_class'] == 'first' ? Colors.amber[700] : Colors.blue[700],
                                  ),
                                )),
                                DataCell(Text('${reservation['number_of_seats']}')),
                                DataCell(Text('\$${double.tryParse(reservation['total_price']?.toString() ?? '0')?.toStringAsFixed(2)}')),
                                DataCell(Text(
                                  '${_getStatusColor(reservation['status'] ?? '')} ${(reservation['status'] ?? '').toUpperCase()}',
                                )),
                                DataCell(Text(reservation['created_at'] != null 
                                    ? DateFormat('MMM dd').format(DateTime.parse(reservation['created_at']))
                                    : 'N/A')),
                              ]);
                            }).toList(),
        ),
      ),
    );
  }
}
