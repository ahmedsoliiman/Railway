import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../config/theme.dart';
import '../../models/station.dart';
import '../../models/carriage.dart';
import '../../models/train.dart';
import '../../models/trip.dart';
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
      adminProvider.loadCarriages();
      adminProvider.loadTrains();
      adminProvider.loadTrips();
    });
  }

  final List<Widget> _pages = [
    const AdminStationsPage(),
    const AdminCarriagesPage(),
    const AdminTrainsPage(),
    const AdminTripsPage(),
    const AdminDeparturesPage(),
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
                icon: Icon(Icons.location_on_outlined),
                selectedIcon: Icon(Icons.location_on),
                label: Text('Stations'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.view_carousel_outlined),
                selectedIcon: Icon(Icons.view_carousel),
                label: Text('Carriages'),
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
                icon: Icon(Icons.schedule_outlined),
                selectedIcon: Icon(Icons.schedule),
                label: Text('Departures'),
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
                      'Active Trips',
                      '${stats?['active_trips'] ?? 0}',
                      Icons.route,
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
    final codeController = TextEditingController(text: station?.code);
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
                controller: codeController,
                label: 'Station Code *',
                hint: 'e.g., NYC',
                icon: Icons.code,
                validator: (v) => v?.isEmpty ?? true ? 'Station code is required' : null,
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
                      code: codeController.text,
                      city: cityController.text,
                      address: addressController.text.isEmpty ? null : addressController.text,
                      facilities: facilitiesController.text.isEmpty ? null : facilitiesController.text,
                    )
                  : await adminProvider.updateStation(
                      id: station.id,
                      name: nameController.text,
                      code: codeController.text,
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
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                    ),
                    child: SingleChildScrollView(
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

// Carriages Management Page
class AdminCarriagesPage extends StatelessWidget {
  const AdminCarriagesPage({super.key});

  void _showCarriageDialog(BuildContext context, {Carriage? carriage}) {
    final nameController = TextEditingController(text: carriage?.name);
    final seatsCountController = TextEditingController(text: carriage?.seatsCount.toString());
    final modelController = TextEditingController(text: carriage?.model);
    final descriptionController = TextEditingController(text: carriage?.description);
    
    String selectedClassType = carriage?.classType ?? 'first';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => EnhancedDialog(
          title: carriage == null ? 'Add New Carriage' : 'Edit Carriage',
          subtitle: carriage == null ? 'Fill in carriage details' : 'Update carriage information',
          icon: Icons.view_carousel,
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Carriage Name *',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., First Class A1',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedClassType,
                    decoration: const InputDecoration(
                      labelText: 'Class Type *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'first', child: Text('First Class')),
                      DropdownMenuItem(value: 'second', child: Text('Second Class')),
                      DropdownMenuItem(value: 'economic', child: Text('Economic Class')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedClassType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: seatsCountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Number of Seats *',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., 40',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: modelController,
                    decoration: const InputDecoration(
                      labelText: 'Model',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., Modern Luxury',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      hintText: 'Optional description...',
                    ),
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
                if (nameController.text.isEmpty || seatsCountController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }

                final adminProvider = Provider.of<AdminProvider>(context, listen: false);
                final result = carriage == null
                    ? await adminProvider.createCarriage(
                        name: nameController.text,
                        classType: selectedClassType,
                        seatsCount: int.parse(seatsCountController.text),
                        model: modelController.text.isEmpty ? null : modelController.text,
                        description: descriptionController.text.isEmpty ? null : descriptionController.text,
                      )
                    : await adminProvider.updateCarriage(
                        id: carriage.id,
                        name: nameController.text,
                        classType: selectedClassType,
                        seatsCount: int.parse(seatsCountController.text),
                        model: modelController.text.isEmpty ? null : modelController.text,
                        description: descriptionController.text.isEmpty ? null : descriptionController.text,
                      );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message']),
                      backgroundColor: result['success'] ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              child: Text(carriage == null ? 'Add' : 'Save'),
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
                'Carriages Management',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showCarriageDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Carriage'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, adminProvider, child) {
                if (adminProvider.isLoadingCarriages) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (adminProvider.carriages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.view_carousel_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No carriages found',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _showCarriageDialog(context),
                          child: const Text('Add First Carriage'),
                        ),
                      ],
                    ),
                  );
                }

                return Card(
                  elevation: 2,
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                    ),
                    child: SingleChildScrollView(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
                          columns: const [
                            DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Class Type', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Seats', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Model', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: adminProvider.carriages.map((carriage) {
                        Color classColor;
                        switch (carriage.classType) {
                          case 'first':
                            classColor = Colors.purple;
                            break;
                          case 'second':
                            classColor = Colors.blue;
                            break;
                          case 'economic':
                            classColor = Colors.green;
                            break;
                          default:
                            classColor = Colors.grey;
                        }

                        return DataRow(cells: [
                          DataCell(Text(carriage.id.toString())),
                          DataCell(Text(carriage.name)),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: classColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: classColor),
                              ),
                              child: Text(
                                carriage.classTypeDisplay,
                                style: TextStyle(color: classColor, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          DataCell(Text(carriage.seatsCount.toString())),
                          DataCell(Text(carriage.model ?? '-')),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                  onPressed: () => _showCarriageDialog(context, carriage: carriage),
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Carriage'),
                                        content: Text('Are you sure you want to delete "${carriage.name}"?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true && context.mounted) {
                                      final result = await adminProvider.deleteCarriage(carriage.id);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(result['message']),
                                            backgroundColor: result['success'] ? Colors.green : Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  tooltip: 'Delete',
                                ),
                              ],
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                      ),
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
    final facilitiesController = TextEditingController(text: train?.facilities);
    String selectedType = train?.type ?? 'express';
    String selectedStatus = train?.status ?? 'active';
    final formKey = GlobalKey<FormState>();
    
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    
    // Selected carriages: Map<carriageId, quantity>
    Map<int, int> selectedCarriages = {};
    int? selectedCarriageToAdd; // Track the dropdown selection
    if (train?.carriages != null) {
      for (var tc in train!.carriages!) {
        selectedCarriages[tc.carriageId] = tc.quantity;
      }
    }

    // Calculate total seats
    int calculateTotalSeats() {
      int total = 0;
      for (var entry in selectedCarriages.entries) {
        final carriage = adminProvider.carriages.firstWhere((c) => c.id == entry.key);
        total += carriage.seatsCount * entry.value;
      }
      return total;
    }

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
                    const DropdownMenuItem(value: 'express', child: Text('Express')),
                    const DropdownMenuItem(value: 'ordinary', child: Text('Ordinary')),
                    const DropdownMenuItem(value: 'VIP', child: Text('VIP')),
                    const DropdownMenuItem(value: 'tahya masr', child: Text('Tahya Masr')),
                    const DropdownMenuItem(value: 'sleeper', child: Text('Sleeper')),
                  ],
                  onChanged: (value) => setState(() => selectedType = value!),
                ),
                const SizedBox(height: 16),
                // Carriages Section
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.view_carousel, size: 20),
                            const SizedBox(width: 8),
                            const Text('Carriages Configuration', style: TextStyle(fontWeight: FontWeight.bold)),
                            const Spacer(),
                            if (calculateTotalSeats() > 0)
                              Chip(
                                label: Text('Total: ${calculateTotalSeats()} seats'),
                                backgroundColor: Colors.green.shade100,
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...selectedCarriages.entries.map((entry) {
                          final carriage = adminProvider.carriages.firstWhere((c) => c.id == entry.key);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text('${carriage.name} (${carriage.seatsCount} seats each)'),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          if (entry.value > 1) {
                                            selectedCarriages[entry.key] = entry.value - 1;
                                          } else {
                                            selectedCarriages.remove(entry.key);
                                          }
                                        });
                                      },
                                    ),
                                    Text('${entry.value}x'),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          selectedCarriages[entry.key] = entry.value + 1;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      selectedCarriages.remove(entry.key);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        if (adminProvider.carriages.where((c) => !selectedCarriages.containsKey(c.id)).isNotEmpty)
                          DropdownButtonFormField<int>(
                            key: ValueKey(selectedCarriages.length),
                            value: selectedCarriageToAdd,
                            decoration: const InputDecoration(
                              labelText: 'Add Carriage',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem<int>(
                                value: null,
                                child: Text('Select a carriage'),
                              ),
                              ...adminProvider.carriages
                                  .where((c) => !selectedCarriages.containsKey(c.id))
                                  .map((c) => DropdownMenuItem(
                                        value: c.id,
                                        child: Text('${c.name} (${c.classTypeDisplay}, ${c.seatsCount} seats)'),
                                      ))
                            ],
                            onChanged: (carriageId) {
                              setState(() {
                                selectedCarriageToAdd = null; // Reset FIRST to avoid duplicate value error
                                if (carriageId != null) {
                                  selectedCarriages[carriageId] = 1;
                                }
                              });
                            },
                          ),
                        if (selectedCarriages.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('No carriages selected. Please add at least one carriage.', 
                              style: TextStyle(color: Colors.red, fontSize: 12)),
                          ),
                      ],
                    ),
                  ),
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
                
                if (selectedCarriages.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please add at least one carriage'), backgroundColor: Colors.red),
                  );
                  return;
                }

                final adminProvider = Provider.of<AdminProvider>(context, listen: false);
                
                // Convert selectedCarriages to API format
                final carriages = selectedCarriages.entries
                    .map((e) => {'carriageId': e.key, 'quantity': e.value})
                    .toList();
                
                final response = train == null
                    ? await adminProvider.createTrain(
                        trainNumber: trainNumberController.text,
                        name: nameController.text,
                        type: selectedType,
                        carriages: carriages,
                        facilities: facilitiesController.text.isEmpty ? null : facilitiesController.text,
                        status: selectedStatus,
                      )
                    : await adminProvider.updateTrain(
                        id: train.id,
                        trainNumber: trainNumberController.text,
                        name: nameController.text,
                        type: selectedType,
                        carriages: carriages,
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
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                    ),
                    child: SingleChildScrollView(
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

  void _showTripDialog(BuildContext context, AdminProvider adminProvider, {Trip? trip}) {
    final firstClassPriceController = TextEditingController(text: trip?.firstClassPrice?.toString());
    final secondClassPriceController = TextEditingController(text: trip?.secondClassPrice?.toString());
    final economicPriceController = TextEditingController(text: trip?.economicPrice?.toString());
    final quantitiesController = TextEditingController(text: trip?.quantities.toString());
    int? selectedTrainId = trip?.trainId;
    int? selectedOriginId = trip?.originStationId;
    int? selectedDestinationId = trip?.destinationStationId;
    DateTime departure = trip?.departure ?? DateTime.now().add(const Duration(days: 1));
    DateTime departureTime = trip?.departureTime ?? DateTime.now().add(const Duration(days: 1));
    DateTime arrivalTime = trip?.arrivalTime ?? DateTime.now().add(const Duration(days: 1, hours: 4));
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(trip == null ? 'Add Trip' : 'Edit Trip'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: selectedTrainId,
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
                    initialValue: selectedOriginId,
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
                    initialValue: selectedDestinationId,
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
                    title: const Text('Departure Date'),
                    subtitle: Text(DateFormat('yyyy-MM-dd').format(departure)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: departure,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          departure = date;
                        });
                      }
                    },
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
                    controller: economicPriceController,
                    decoration: const InputDecoration(labelText: 'Economic Class Price'),
                    keyboardType: TextInputType.number,
                    validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null,
                  ),
                  TextFormField(
                    controller: quantitiesController,
                    decoration: const InputDecoration(labelText: 'Quantities'),
                    keyboardType: TextInputType.number,
                    validator: (v) => int.tryParse(v ?? '') == null ? 'Invalid' : null,
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

                final response = trip == null
                    ? await adminProvider.createTrip(
                        trainId: selectedTrainId!,
                        originStationId: selectedOriginId!,
                        destinationStationId: selectedDestinationId!,
                        departure: departure,
                        departureTime: departureTime,
                        arrivalTime: arrivalTime,
                        firstClassPrice: double.parse(firstClassPriceController.text),
                        secondClassPrice: double.parse(secondClassPriceController.text),
                        economicPrice: double.parse(economicPriceController.text),
                        quantities: int.parse(quantitiesController.text),
                      )
                    : await adminProvider.updateTrip(
                        id: trip.id,
                        trainId: selectedTrainId,
                        originStationId: selectedOriginId,
                        destinationStationId: selectedDestinationId,
                        departure: departure,
                        departureTime: departureTime,
                        arrivalTime: arrivalTime,
                        firstClassPrice: double.parse(firstClassPriceController.text),
                        secondClassPrice: double.parse(secondClassPriceController.text),
                        economicPrice: double.parse(economicPriceController.text),
                        quantities: int.parse(quantitiesController.text),
                      );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(response['message'] ?? 'Success')),
                  );
                }
              },
              child: Text(trip == null ? 'Add' : 'Update'),
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
        print('DEBUG UI: Building AdminTripsPage - trips count: ${adminProvider.trips.length}, isLoading: ${adminProvider.isLoadingTrips}');
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
                child: adminProvider.isLoadingTrips
                    ? const Center(child: CircularProgressIndicator())
                    : adminProvider.trips.isEmpty
                        ? const Center(child: Text('No trips yet'))
                        : Card(
                            child: Container(
                              constraints: BoxConstraints(
                                maxHeight: MediaQuery.of(context).size.height * 0.6,
                              ),
                              child: SingleChildScrollView(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columns: const [
                                      DataColumn(label: Text('Train')),
                                      DataColumn(label: Text('Route')),
                                      DataColumn(label: Text('Departure Date')),
                                      DataColumn(label: Text('Departure Time')),
                                      DataColumn(label: Text('1st Class')),
                                  DataColumn(label: Text('2nd Class')),
                                  DataColumn(label: Text('Quantities')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: adminProvider.trips.map((trip) {
                                  return DataRow(cells: [
                                    DataCell(Text(trip.trainName)),
                                    DataCell(Text('${trip.originCity} → ${trip.destinationCity}')),
                                    DataCell(Text(DateFormat('MMM dd, yyyy').format(trip.departure))),
                                    DataCell(Text(DateFormat('HH:mm').format(trip.departureTime))),
                                    DataCell(Text('\$${trip.firstClassPrice?.toStringAsFixed(2)}')),
                                    DataCell(Text('\$${trip.secondClassPrice?.toStringAsFixed(2)}')),
                                    DataCell(Text('${trip.quantities}')),
                                    DataCell(Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, size: 20),
                                          onPressed: () => _showTripDialog(context, adminProvider, trip: trip),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Delete Trip'),
                                                content: Text('Delete trip from ${trip.originCity} to ${trip.destinationCity}?'),
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
                                              final response = await adminProvider.deleteTrip(trip.id);
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
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Edit Departure Time Dialog
void _showEditDepartureTimeDialog(BuildContext context, Trip trip, AdminProvider adminProvider) {
  TimeOfDay departureTime = TimeOfDay.fromDateTime(trip.departureTime);
  TimeOfDay arrivalTime = TimeOfDay.fromDateTime(trip.arrivalTime);

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => EnhancedDialog(
        title: 'Edit Departure Times',
        subtitle: '${trip.trainName} - ${trip.originCity} → ${trip.destinationCity}',
        icon: Icons.access_time,
        headerGradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade800],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.departure_board, color: AppTheme.primaryColor),
              title: const Text('Departure Time'),
              subtitle: Text(
                '${departureTime.hour.toString().padLeft(2, '0')}:${departureTime.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              trailing: ElevatedButton.icon(
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: departureTime,
                  );
                  if (time != null) {
                    setState(() => departureTime = time);
                  }
                },
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Change'),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.green),
              title: const Text('Arrival Time'),
              subtitle: Text(
                '${arrivalTime.hour.toString().padLeft(2, '0')}:${arrivalTime.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              trailing: ElevatedButton.icon(
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: arrivalTime,
                  );
                  if (time != null) {
                    setState(() => arrivalTime = time);
                  }
                },
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Change'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              // Create new DateTime objects with updated times
              final newDepartureTime = DateTime(
                trip.departureTime.year,
                trip.departureTime.month,
                trip.departureTime.day,
                departureTime.hour,
                departureTime.minute,
              );

              final newArrivalTime = DateTime(
                trip.arrivalTime.year,
                trip.arrivalTime.month,
                trip.arrivalTime.day,
                arrivalTime.hour,
                arrivalTime.minute,
              );

              // Validate that arrival is after departure
              if (newArrivalTime.isBefore(newDepartureTime) || newArrivalTime.isAtSameMomentAs(newDepartureTime)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Arrival time must be after departure time'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context);

              final response = await adminProvider.updateTrip(
                id: trip.id,
                departureTime: newDepartureTime,
                arrivalTime: newArrivalTime,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(response['message'] ?? 'Success'),
                    backgroundColor: response['success'] ? Colors.green : Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            icon: const Icon(Icons.check),
            label: const Text('Update Times'),
          ),
        ],
      ),
    ),
  );
}

// Departures Management Page
class AdminDeparturesPage extends StatelessWidget {
  const AdminDeparturesPage({super.key});

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
                    'Trip Departures',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => adminProvider.loadTrips(),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: adminProvider.isLoadingTrips
                    ? const Center(child: CircularProgressIndicator())
                    : adminProvider.trips.isEmpty
                        ? const Center(child: Text('No trips scheduled'))
                        : Card(
                            child: Container(
                              constraints: BoxConstraints(
                                maxHeight: MediaQuery.of(context).size.height * 0.6,
                              ),
                              child: SingleChildScrollView(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columns: const [
                                      DataColumn(label: Text('Departure Date')),
                                      DataColumn(label: Text('Departure Time')),
                                      DataColumn(label: Text('Train')),
                                      DataColumn(label: Text('Route')),
                                      DataColumn(label: Text('Arrival Time')),
                                      DataColumn(label: Text('Duration')),
                                      DataColumn(label: Text('Quantities')),
                                      DataColumn(label: Text('Status')),
                                      DataColumn(label: Text('Actions')),
                                    ],
                                rows: adminProvider.trips.map((trip) {
                                  final duration = trip.arrivalTime.difference(trip.departureTime);
                                  final hours = duration.inHours;
                                  final minutes = duration.inMinutes.remainder(60);
                                  
                                  return DataRow(cells: [
                                    DataCell(Text(DateFormat('MMM dd, yyyy').format(trip.departure))),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          DateFormat('HH:mm').format(trip.departureTime),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(Text('${trip.trainName} (${trip.trainNumber})')),
                                    DataCell(Text('${trip.originCity} → ${trip.destinationCity}')),
                                    DataCell(Text(DateFormat('HH:mm').format(trip.arrivalTime))),
                                    DataCell(Text('${hours}h ${minutes}m')),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: trip.quantities < 10 ? Colors.red.shade100 : Colors.green.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${trip.quantities} seats',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: trip.quantities < 10 ? Colors.red.shade900 : Colors.green.shade900,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: trip.departure.isAfter(DateTime.now()) 
                                              ? Colors.green.shade100 
                                              : Colors.orange.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          trip.departure.isAfter(DateTime.now()) ? 'SCHEDULED' : 'DEPARTED',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: trip.departure.isAfter(DateTime.now()) 
                                                ? Colors.green.shade900 
                                                : Colors.orange.shade900,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 20),
                                        onPressed: () => _showEditDepartureTimeDialog(context, trip, adminProvider),
                                        tooltip: 'Edit Times',
                                      ),
                                    ),
                                  ]);
                                }).toList(),
                              ),
                                ),
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
              DataCell(Text(user['fullName'] ?? user['full_name'] ?? 'N/A')),
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
              DataCell(Text((user['isVerified'] ?? user['is_verified']) == true ? '✅' : '❌')),
              DataCell(Text((user['createdAt'] ?? user['created_at']) != null 
                  ? DateFormat('MMM dd, yyyy').format(DateTime.parse(user['createdAt'] ?? user['created_at']))
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
