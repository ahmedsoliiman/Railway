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
                    )
                  : await adminProvider.updateStation(
                      id: station.id,
                      name: nameController.text,
                      code: codeController.text,
                      city: cityController.text,
                      address: addressController.text.isEmpty ? null : addressController.text,
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
                            DataColumn(label: Text('Code')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: adminProvider.stations.map((station) {
                            return DataRow(cells: [
                              DataCell(Text(station.name)),
                              DataCell(Text(station.city)),
                              DataCell(Text(station.code)),
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

  void _showCarriageDialog(BuildContext context, {Carriage? carriage}) async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    
    // Load carriage types if not already loaded
    if (adminProvider.carriageTypes.isEmpty) {
      await adminProvider.loadCarriageTypes();
    }
    
    final carriageNumberController = TextEditingController(text: carriage?.carriageNumber);
    int? selectedCarriageTypeId = carriage?.carriageTypeId ?? (adminProvider.carriageTypes.isNotEmpty ? adminProvider.carriageTypes.first.id : null);

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
                    controller: carriageNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Carriage Number *',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., A1, B2, C3',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: selectedCarriageTypeId,
                    decoration: const InputDecoration(
                      labelText: 'Carriage Type *',
                      border: OutlineInputBorder(),
                    ),
                    items: adminProvider.carriageTypes.map((type) {
                      return DropdownMenuItem<int>(
                        value: type.id,
                        child: Text('${type.typeDisplay} (${type.capacity} seats - EGP ${type.price})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCarriageTypeId = value;
                      });
                    },
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
                if (carriageNumberController.text.isEmpty || selectedCarriageTypeId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }

                final result = carriage == null
                    ? await adminProvider.createCarriage(
                        carriageNumber: carriageNumberController.text,
                        carriageTypeId: selectedCarriageTypeId!,
                      )
                    : await adminProvider.updateCarriage(
                        id: carriage.id,
                        carriageNumber: carriageNumberController.text,
                        carriageTypeId: selectedCarriageTypeId!,
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
                            DataColumn(label: Text('Carriage Number', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Capacity', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: adminProvider.carriages.map((carriage) {
                        final classType = carriage.carriageType?.type.toLowerCase() ?? 'third class';
                        Color classColor;
                        switch (classType) {
                          case 'first class':
                            classColor = Colors.purple;
                            break;
                          case 'second class':
                            classColor = Colors.blue;
                            break;
                          case 'third class':
                            classColor = Colors.green;
                            break;
                          case 'sleeper':
                            classColor = Colors.orange;
                            break;
                          default:
                            classColor = Colors.grey;
                        }

                        return DataRow(cells: [
                          DataCell(Text(carriage.id.toString())),
                          DataCell(Text(carriage.carriageNumber)),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: classColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: classColor),
                              ),
                              child: Text(
                                carriage.carriageType?.typeDisplay ?? 'Unknown',
                                style: TextStyle(color: classColor, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          DataCell(Text((carriage.carriageType?.capacity ?? 0).toString())),
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
        total += (carriage.carriageType?.capacity ?? 0) * entry.value;
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
                                        child: Text('${c.carriageNumber} (${c.carriageType?.typeDisplay ?? 'Unknown'}, ${c.carriageType?.capacity ?? 0} seats)'),
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
                        type: selectedType,
                        carriages: carriages,
                        status: selectedStatus,
                      )
                    : await adminProvider.updateTrain(
                        id: train.id,
                        trainNumber: trainNumberController.text,
                        type: selectedType,
                        carriages: carriages,
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
                            DataColumn(label: Text('Type')),
                            DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: adminProvider.trains.map((train) {
                        return DataRow(cells: [
                          DataCell(Text(train.trainNumber)),
                          DataCell(Text(train.type)),
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
                                      content: Text('Delete ${train.trainNumber}?'),
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
    DateTime departureTime = trip?.departureTime ?? trip?.departure ?? DateTime.now().add(const Duration(days: 1));
    DateTime arrivalTime = trip?.arrivalTime ?? trip?.departure?.add(const Duration(hours: 4)) ?? DateTime.now().add(const Duration(days: 1, hours: 4));
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
                        child: Text('${train.trainNumber} - ${train.trainNumber}'),
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
                                      DataColumn(label: Text('First Departure Date')),
                                      DataColumn(label: Text('First Departure Time')),
                                      DataColumn(label: Text('Prices (1st/2nd/Econ)')),
                                      DataColumn(label: Text('Departures')),
                                      DataColumn(label: Text('Capacity')),
                                      DataColumn(label: Text('Actions')),
                                ],
                                rows: adminProvider.trips.map((trip) {
                                  final firstDeparture = trip.effectiveDepartureTime;
                                  return DataRow(cells: [
                                    DataCell(Text(trip.trainNumber)),
                                    DataCell(Text('${trip.originCity} → ${trip.destinationCity}')),
                                    DataCell(Text(firstDeparture != null ? DateFormat('MMM dd, yyyy').format(firstDeparture) : 'N/A')),
                                    DataCell(Text(firstDeparture != null ? DateFormat('HH:mm').format(firstDeparture) : 'N/A')),
                                    DataCell(Text('${trip.firstClassPrice?.toStringAsFixed(0) ?? '0'} / ${trip.secondClassPrice?.toStringAsFixed(0) ?? '0'} / ${trip.economicPrice?.toStringAsFixed(0) ?? '0'} EGP')),
                                    DataCell(Text('${trip.departuresCount} departures')),
                                    DataCell(Text('${trip.quantities} seats')),
                                    DataCell(Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.schedule, size: 20, color: Colors.blue),
                                          tooltip: 'Manage Departures',
                                          onPressed: () => _showDeparturesDialog(context, adminProvider, trip),
                                        ),
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
  if (trip.departureTime == null || trip.arrivalTime == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This trip does not have departure/arrival times set')),
    );
    return;
  }
  
  TimeOfDay departureTime = TimeOfDay.fromDateTime(trip.departureTime!);
  TimeOfDay arrivalTime = TimeOfDay.fromDateTime(trip.arrivalTime!);

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => EnhancedDialog(
        title: 'Edit Departure Times',
        subtitle: '${trip.trainNumber} - ${trip.originCity} → ${trip.destinationCity}',
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
                trip.departureTime!.year,
                trip.departureTime!.month,
                trip.departureTime!.day,
                departureTime.hour,
                departureTime.minute,
              );

              final newArrivalTime = DateTime(
                trip.arrivalTime!.year,
                trip.arrivalTime!.month,
                trip.arrivalTime!.day,
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
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _showSelectTripForDepartureDialog(context, adminProvider),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Departure'),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => adminProvider.loadTrips(),
                        tooltip: 'Refresh',
                      ),
                    ],
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
                                  final duration = trip.duration;
                                  final hours = duration?.inHours ?? 0;
                                  final minutes = duration?.inMinutes.remainder(60) ?? 0;
                                  final depTime = trip.effectiveDepartureTime;
                                  final arrTime = trip.effectiveArrivalTime;
                                  
                                  return DataRow(cells: [
                                    DataCell(Text(depTime != null ? DateFormat('MMM dd, yyyy').format(depTime) : 'N/A')),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          depTime != null ? DateFormat('HH:mm').format(depTime) : 'N/A',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(Text('${trip.trainNumber} (${trip.trainNumber})')),
                                    DataCell(Text('${trip.originCity} → ${trip.destinationCity}')),
                                    DataCell(Text(arrTime != null ? DateFormat('HH:mm').format(arrTime) : 'N/A')),
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
                                          color: (trip.departure?.isAfter(DateTime.now()) ?? false)
                                              ? Colors.green.shade100 
                                              : Colors.orange.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          (trip.departure?.isAfter(DateTime.now()) ?? false) ? 'SCHEDULED' : 'DEPARTED',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: (trip.departure?.isAfter(DateTime.now()) ?? false)
                                                ? Colors.green.shade900 
                                                : Colors.orange.shade900,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      IconButton(
                                        icon: const Icon(Icons.schedule, size: 20),
                                        onPressed: () => _showDeparturesDialog(context, adminProvider, trip),
                                        tooltip: 'Manage Departures',
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
      final reservationsData = await adminProvider.getAllBookings();
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
                              // Extract nested data
                              final user = reservation['user'];
                              final tripDeparture = reservation['tripDeparture'];
                              final trip = tripDeparture?['trip'];
                              final train = trip?['train'];
                              final departureStation = trip?['departureStation'];
                              final arrivalStation = trip?['arrivalStation'];
                              final carriageType = reservation['carriageType'];
                              
                              return DataRow(cells: [
                                DataCell(Text('#${reservation['id']}')),
                                DataCell(Text(user?['fullName'] ?? 'N/A')),
                                DataCell(Text(user?['email'] ?? 'N/A')),
                                DataCell(Text(train?['trainNumber'] ?? 'N/A')),
                                DataCell(Text('${departureStation?['city'] ?? 'null'} → ${arrivalStation?['city'] ?? 'null'}')),
                                DataCell(Text(tripDeparture?['departureTime'] != null 
                                    ? DateFormat('MMM dd, HH:mm').format(DateTime.parse(tripDeparture['departureTime']))
                                    : 'N/A')),
                                DataCell(Text(
                                  carriageType?['type'] ?? 'N/A',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: carriageType?['type'] == 'first class' ? Colors.amber[700] : Colors.blue[700],
                                  ),
                                )),
                                DataCell(Text('${reservation['numberOfSeats'] ?? reservation['number_of_seats'] ?? 0}')),
                                DataCell(Text('EGP ${double.tryParse(reservation['totalPrice']?.toString() ?? reservation['total_price']?.toString() ?? '0')?.toStringAsFixed(2)}')),
                                DataCell(Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(_getStatusColor(reservation['status'] ?? '')),
                                    const SizedBox(width: 4),
                                    Text((reservation['status'] ?? 'pending').toUpperCase()),
                                  ],
                                )),
                                DataCell(Text((reservation['createdAt'] ?? reservation['created_at']) != null 
                                    ? DateFormat('MMM dd').format(DateTime.parse(reservation['createdAt'] ?? reservation['created_at']))
                                    : 'N/A')),
                              ]);
                            }).toList(),
        ),
      ),
    );
  }
}

// Show Departures Dialog
void _showDeparturesDialog(BuildContext context, AdminProvider adminProvider, Trip trip) async {
  try {
    final departures = await adminProvider.getTripDepartures(trip.id);
    
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Departures for ${trip.trainNumber}: ${trip.originCity} → ${trip.destinationCity}'),
        content: SizedBox(
          width: 600,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showAddDepartureDialog(context, adminProvider, trip);
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Departure'),
              ),
              const SizedBox(height: 16),
              if (departures.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('No departures yet'),
                )
              else
                Flexible(
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Departure Time')),
                        DataColumn(label: Text('Arrival Time')),
                        DataColumn(label: Text('Duration')),
                        DataColumn(label: Text('Available Seats')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: departures.map((dep) {
                        final depTimeStr = dep['departureTime'] ?? dep['departure_time'];
                        final arrTimeStr = dep['arrivalTime'] ?? dep['arrival_time'];
                        
                        if (depTimeStr == null || arrTimeStr == null) {
                          return DataRow(cells: [
                            const DataCell(Text('N/A')),
                            const DataCell(Text('N/A')),
                            const DataCell(Text('N/A')),
                            DataCell(Text('${dep['availableSeats'] ?? dep['available_seats'] ?? 0}')),
                            const DataCell(Text('-')),
                          ]);
                        }
                        
                        final depTime = DateTime.parse(depTimeStr);
                        final arrTime = DateTime.parse(arrTimeStr);
                        final duration = arrTime.difference(depTime);
                        final hours = duration.inHours;
                        final minutes = duration.inMinutes.remainder(60);
                        
                        return DataRow(cells: [
                          DataCell(Text(DateFormat('MMM dd, yyyy HH:mm').format(depTime))),
                          DataCell(Text(DateFormat('MMM dd, yyyy HH:mm').format(arrTime))),
                          DataCell(Text('${hours}h ${minutes}m')),
                          DataCell(Text('${dep['availableSeats'] ?? dep['available_seats'] ?? 0}')),
                          DataCell(Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showEditDepartureDialog(context, adminProvider, trip, dep);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete Departure'),
                                      content: const Text('Are you sure you want to delete this departure?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                          onPressed: () => Navigator.pop(ctx, true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true && context.mounted) {
                                    final response = await adminProvider.deleteTripDeparture(dep['id']);
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(response['message'] ?? 'Deleted')),
                                      );
                                      _showDeparturesDialog(context, adminProvider, trip);
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading departures: $e')),
      );
    }
  }
}

// Select Train for Managing Departures
void _showSelectTripForDepartureDialog(BuildContext context, AdminProvider adminProvider) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Select Train'),
      content: SizedBox(
        width: 500,
        height: 400,
        child: adminProvider.trains.isEmpty
            ? const Center(child: Text('No trains available'))
            : ListView.builder(
                itemCount: adminProvider.trains.length,
                itemBuilder: (context, index) {
                  final train = adminProvider.trains[index];
                  // Count trips for this train
                  final trainTrips = adminProvider.trips.where((t) => t.trainId == train.id).toList();
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(train.trainNumber),
                    ),
                    title: Text('Train ${train.trainNumber}'),
                    subtitle: Text('${train.type} - ${trainTrips.length} routes'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.pop(context);
                      _showTrainTripsDialog(context, adminProvider, train, trainTrips);
                    },
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}

// Show trips for selected train
void _showTrainTripsDialog(BuildContext context, AdminProvider adminProvider, dynamic train, List<Trip> trainTrips) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Train ${train.trainNumber} - Routes & Departures'),
      content: SizedBox(
        width: 700,
        height: 500,
        child: trainTrips.isEmpty
            ? const Center(child: Text('No routes for this train'))
            : ListView.builder(
                itemCount: trainTrips.length,
                itemBuilder: (context, index) {
                  final trip = trainTrips[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      leading: const Icon(Icons.route),
                      title: Text('${trip.originCity} → ${trip.destinationCity}'),
                      subtitle: Text('${trip.departuresCount} departures'),
                      trailing: ElevatedButton.icon(
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Departure'),
                        onPressed: () {
                          Navigator.pop(context);
                          _showAddDepartureDialog(context, adminProvider, trip);
                        },
                      ),
                      children: [
                        if (trip.departures != null && trip.departures!.isNotEmpty)
                          ...trip.departures!.map((dep) => ListTile(
                                dense: true,
                                leading: const Icon(Icons.schedule, size: 20),
                                title: Text(
                                  '${DateFormat('MMM dd, HH:mm').format(dep.departureTime)} → ${DateFormat('HH:mm').format(dep.arrivalTime)}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                                subtitle: Text('${dep.availableSeats} seats available'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 18),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _showEditDepartureDialog(context, adminProvider, trip, {
                                          'id': dep.id,
                                          'departureTime': dep.departureTime.toIso8601String(),
                                          'arrivalTime': dep.arrivalTime.toIso8601String(),
                                          'availableSeats': dep.availableSeats,
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Delete Departure'),
                                            content: const Text('Are you sure?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(ctx, false),
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                onPressed: () => Navigator.pop(ctx, true),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await adminProvider.deleteTripDeparture(dep.id);
                                          if (context.mounted) {
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Departure deleted')),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ))
                        else
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No departures yet', style: TextStyle(fontStyle: FontStyle.italic)),
                          ),
                      ],
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

// Add Departure Dialog
void _showAddDepartureDialog(BuildContext context, AdminProvider adminProvider, Trip trip) {
  DateTime selectedDepartureDate = DateTime.now();
  TimeOfDay selectedDepartureTime = TimeOfDay.now();
  DateTime selectedArrivalDate = DateTime.now();
  TimeOfDay selectedArrivalTime = TimeOfDay(hour: TimeOfDay.now().hour + 2, minute: TimeOfDay.now().minute);
  final availableSeatsController = TextEditingController(text: trip.quantities.toString());

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('Add Departure for ${trip.trainNumber}'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Route: ${trip.originCity} → ${trip.destinationCity}', 
                  style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                
                // Departure Date & Time
                const Text('Departure', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDepartureDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() => selectedDepartureDate = date);
                          }
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: Text(DateFormat('MMM dd, yyyy').format(selectedDepartureDate)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: selectedDepartureTime,
                          );
                          if (time != null) {
                            setState(() => selectedDepartureTime = time);
                          }
                        },
                        icon: const Icon(Icons.access_time),
                        label: Text(selectedDepartureTime.format(context)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Arrival Date & Time
                const Text('Arrival', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedArrivalDate,
                            firstDate: selectedDepartureDate,
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() => selectedArrivalDate = date);
                          }
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: Text(DateFormat('MMM dd, yyyy').format(selectedArrivalDate)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: selectedArrivalTime,
                          );
                          if (time != null) {
                            setState(() => selectedArrivalTime = time);
                          }
                        },
                        icon: const Icon(Icons.access_time),
                        label: Text(selectedArrivalTime.format(context)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Available Seats
                TextField(
                  controller: availableSeatsController,
                  decoration: const InputDecoration(
                    labelText: 'Available Seats',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
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
              final departureDateTime = DateTime(
                selectedDepartureDate.year,
                selectedDepartureDate.month,
                selectedDepartureDate.day,
                selectedDepartureTime.hour,
                selectedDepartureTime.minute,
              );
              
              final arrivalDateTime = DateTime(
                selectedArrivalDate.year,
                selectedArrivalDate.month,
                selectedArrivalDate.day,
                selectedArrivalTime.hour,
                selectedArrivalTime.minute,
              );

              if (arrivalDateTime.isBefore(departureDateTime)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Arrival time must be after departure time')),
                );
                return;
              }

              final seats = int.tryParse(availableSeatsController.text) ?? 0;
              if (seats <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Available seats must be greater than 0')),
                );
                return;
              }

              Navigator.pop(context);

              final response = await adminProvider.createTripDeparture(
                tripId: trip.id,
                departureTime: departureDateTime,
                arrivalTime: arrivalDateTime,
                availableSeats: seats,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(response['message'] ?? 'Departure added')),
                );
                if (response['success']) {
                  _showDeparturesDialog(context, adminProvider, trip);
                }
              }
            },
            child: const Text('Add Departure'),
          ),
        ],
      ),
    ),
  );
}

// Edit Departure Dialog
void _showEditDepartureDialog(BuildContext context, AdminProvider adminProvider, Trip trip, Map<String, dynamic> departure) {
  final depTime = DateTime.parse(departure['departureTime'] ?? departure['departure_time']);
  final arrTime = DateTime.parse(departure['arrivalTime'] ?? departure['arrival_time']);
  
  DateTime selectedDepartureDate = DateTime(depTime.year, depTime.month, depTime.day);
  TimeOfDay selectedDepartureTime = TimeOfDay(hour: depTime.hour, minute: depTime.minute);
  DateTime selectedArrivalDate = DateTime(arrTime.year, arrTime.month, arrTime.day);
  TimeOfDay selectedArrivalTime = TimeOfDay(hour: arrTime.hour, minute: arrTime.minute);
  final availableSeatsController = TextEditingController(
    text: (departure['availableSeats'] ?? departure['available_seats'] ?? 0).toString()
  );

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('Edit Departure for ${trip.trainNumber}'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Route: ${trip.originCity} → ${trip.destinationCity}', 
                  style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                
                // Departure Date & Time
                const Text('Departure', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDepartureDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() => selectedDepartureDate = date);
                          }
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: Text(DateFormat('MMM dd, yyyy').format(selectedDepartureDate)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: selectedDepartureTime,
                          );
                          if (time != null) {
                            setState(() => selectedDepartureTime = time);
                          }
                        },
                        icon: const Icon(Icons.access_time),
                        label: Text(selectedDepartureTime.format(context)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Arrival Date & Time
                const Text('Arrival', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedArrivalDate,
                            firstDate: selectedDepartureDate,
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() => selectedArrivalDate = date);
                          }
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: Text(DateFormat('MMM dd, yyyy').format(selectedArrivalDate)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: selectedArrivalTime,
                          );
                          if (time != null) {
                            setState(() => selectedArrivalTime = time);
                          }
                        },
                        icon: const Icon(Icons.access_time),
                        label: Text(selectedArrivalTime.format(context)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Available Seats
                TextField(
                  controller: availableSeatsController,
                  decoration: const InputDecoration(
                    labelText: 'Available Seats',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
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
              final departureDateTime = DateTime(
                selectedDepartureDate.year,
                selectedDepartureDate.month,
                selectedDepartureDate.day,
                selectedDepartureTime.hour,
                selectedDepartureTime.minute,
              );
              
              final arrivalDateTime = DateTime(
                selectedArrivalDate.year,
                selectedArrivalDate.month,
                selectedArrivalDate.day,
                selectedArrivalTime.hour,
                selectedArrivalTime.minute,
              );

              if (arrivalDateTime.isBefore(departureDateTime)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Arrival time must be after departure time')),
                );
                return;
              }

              final seats = int.tryParse(availableSeatsController.text) ?? 0;
              if (seats <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Available seats must be greater than 0')),
                );
                return;
              }

              Navigator.pop(context);

              final response = await adminProvider.updateTripDeparture(
                id: departure['id'],
                departureTime: departureDateTime,
                arrivalTime: arrivalDateTime,
                availableSeats: seats,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(response['message'] ?? 'Departure updated')),
                );
                if (response['success']) {
                  _showDeparturesDialog(context, adminProvider, trip);
                }
              }
            },
            child: const Text('Update Departure'),
          ),
        ],
      ),
    ),
  );
}
