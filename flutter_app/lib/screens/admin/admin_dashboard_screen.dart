import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../config/theme.dart';
import '../../models/station.dart';
import '../../models/train.dart';
import '../../models/trip.dart';
import '../../models/trip_departure.dart';
import '../../models/carriage.dart';
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
      // Lazy load only the first tab (Stations)
      if (adminProvider.stations.isEmpty) {
        adminProvider.loadStations();
      }
    });
  }

  final Set<int> _loadedPages = {0};

  List<Widget> get _pages {
    return [
      const AdminStationsPage(),
      _loadedPages.contains(1)
          ? const AdminTrainsPage()
          : const SizedBox.shrink(),
      _loadedPages.contains(2)
          ? const AdminTripsPage()
          : const SizedBox.shrink(),
      _loadedPages.contains(3)
          ? const AdminTripDeparturesPage()
          : const SizedBox.shrink(),
      _loadedPages.contains(4)
          ? const AdminCarriageTypesPage()
          : const SizedBox.shrink(),
      _loadedPages.contains(5)
          ? const AdminUsersPage()
          : const SizedBox.shrink(),
    ];
  }

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
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.yellow),
            tooltip: 'Generate Test Trip for Today',
            onPressed: () async {
              final adminProvider =
                  Provider.of<AdminProvider>(context, listen: false);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );

              try {
                // 1. Create Stations
                await adminProvider.createStation(
                    name: 'Cairo', code: 'CAI', city: 'Cairo');
                await adminProvider.createStation(
                    name: 'Alexandria', code: 'ALX', city: 'Alexandria');

                // 2. Create Train
                final trainRes = await adminProvider.createTrain(
                    trainNumber: 'EXP-101', type: 'Express');
                final trainId = trainRes['data']?.id ?? 1;

                // 3. Create Trip for Today
                final today = DateTime.now();
                if (adminProvider.stations.length >= 2) {
                  final fromStation = adminProvider.stations.first.code;
                  final toStation = adminProvider.stations.last.code;

                  await adminProvider.createTrip(
                    trainId: trainId,
                    originStationId: fromStation,
                    destinationStationId: toStation,
                    departure: today,
                    departureTime:
                        DateTime(today.year, today.month, today.day, 10, 0),
                    arrivalTime:
                        DateTime(today.year, today.month, today.day, 13, 0),
                    firstClassPrice: 150.0,
                    secondClassPrice: 100.0,
                    economicPrice: 50.0,
                    quantities: 100,
                  );
                } else {
                  // Fallback if no stations exist
                  await adminProvider.createTrip(
                    trainId: trainId,
                    originStationId: 'CAI',
                    destinationStationId: 'ALX',
                    departure: today,
                    departureTime:
                        DateTime(today.year, today.month, today.day, 10, 0),
                    arrivalTime:
                        DateTime(today.year, today.month, today.day, 13, 0),
                    firstClassPrice: 150.0,
                    secondClassPrice: 100.0,
                    economicPrice: 50.0,
                    quantities: 100,
                  );
                }

                Navigator.pop(context); // Close loading
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          '✅ Test Trip generated for Today! Cairo -> Alex')),
                );
              } catch (e) {
                Navigator.pop(context); // Close loading
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
          ),
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
                context.go('/login');
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
                _loadedPages.add(index);
              });

              final adminProvider =
                  Provider.of<AdminProvider>(context, listen: false);

              if (index == 0 && adminProvider.stations.isEmpty) {
                adminProvider.loadStations();
              } else if (index == 1 && adminProvider.trains.isEmpty) {
                adminProvider.loadTrains();
              } else if (index == 2 && adminProvider.trips.isEmpty) {
                adminProvider.loadTrips();
              } else if (index == 3 && adminProvider.tripDepartures.isEmpty) {
                adminProvider.loadTripDepartures();
              } else if (index == 4 && adminProvider.carriageTypes.isEmpty) {
                adminProvider.loadCarriageTypes();
              }
              // Index 5 (Users) handles its own loading in its initState
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
                icon: Icon(Icons.departure_board_outlined),
                selectedIcon: Icon(Icons.departure_board),
                label: Text('Departures'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.airline_seat_recline_extra_outlined),
                selectedIcon: Icon(Icons.airline_seat_recline_extra),
                label: Text('Carriage Types'),
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
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
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
        subtitle: station == null
            ? 'Create a new train station'
            : 'Update station information',
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
                validator: (v) =>
                    v?.isEmpty ?? true ? 'Station name is required' : null,
              ),
              const SizedBox(height: 16),
              EnhancedTextField(
                controller: codeController,
                label: 'Station Code *',
                hint: 'e.g., NYC',
                icon: Icons.code,
                validator: (v) =>
                    v?.isEmpty ?? true ? 'Station code is required' : null,
                enabled: station == null, // Code is PK, usually not editable
              ),
              const SizedBox(height: 16),
              EnhancedTextField(
                controller: cityController,
                label: 'City *',
                hint: 'e.g., New York',
                icon: Icons.location_on,
                validator: (v) =>
                    v?.isEmpty ?? true ? 'City is required' : null,
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

              final adminProvider =
                  Provider.of<AdminProvider>(context, listen: false);

              final response = station == null
                  ? await adminProvider.createStation(
                      name: nameController.text,
                      code: codeController.text,
                      city: cityController.text,
                      address: addressController.text.isEmpty
                          ? null
                          : addressController.text,
                    )
                  : await adminProvider.updateStation(
                      code: station.code,
                      name: nameController.text,
                      city: cityController.text,
                      address: addressController.text.isEmpty
                          ? null
                          : addressController.text,
                    );

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(response['message'] ?? 'Success'),
                    backgroundColor:
                        response['success'] ? Colors.green : Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            icon: Icon(station == null ? Icons.add : Icons.check),
            label: Text(station == null ? 'Add Station' : 'Update Station'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
              Expanded(
                child: Text(
                  'Manage Stations',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  overflow: TextOverflow.ellipsis,
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
                                    onPressed: () => _showStationDialog(context,
                                        station: station),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        size: 20, color: Colors.red),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Station'),
                                          content:
                                              Text('Delete ${station.name}?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red),
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true && context.mounted) {
                                        final response = await adminProvider
                                            .deleteStation(station.code);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    response['message'] ??
                                                        'Deleted')),
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

// Trains Management Page
class AdminTrainsPage extends StatelessWidget {
  const AdminTrainsPage({super.key});

  void _showTrainDialog(BuildContext context, {Train? train}) {
    final trainNameController = TextEditingController(text: train?.name);
    String selectedType = train?.type ?? 'Express';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => EnhancedDialog(
          title: train == null ? 'Add New Train' : 'Edit Train',
          subtitle: train == null
              ? 'Configure train specifications'
              : 'Update train details',
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
                  controller: trainNameController,
                  label: 'Train Name *',
                  hint: 'e.g., Express 101',
                  icon: Icons.train,
                  validator: (v) =>
                      v?.isEmpty ?? true ? 'Train name is required' : null,
                ),
                const SizedBox(height: 16),
                EnhancedDropdown<String>(
                  value: selectedType,
                  label: 'Train Type *',
                  icon: Icons.category,
                  items: [
                    const DropdownMenuItem(
                        value: 'Express', child: Text('Express')),
                    const DropdownMenuItem(
                        value: 'Ordinary', child: Text('Ordinary')),
                    const DropdownMenuItem(value: 'VIP', child: Text('VIP')),
                    const DropdownMenuItem(
                        value: 'Sleeper', child: Text('Sleeper')),
                  ],
                  onChanged: (value) => setState(() => selectedType = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final adminProvider =
                    Provider.of<AdminProvider>(context, listen: false);

                final response = train == null
                    ? await adminProvider.createTrain(
                        trainNumber: trainNameController.text,
                        type: selectedType,
                      )
                    : await adminProvider.updateTrain(
                        id: train.id,
                        trainNumber: trainNameController.text,
                        type: selectedType,
                      );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response['message'] ?? 'Success'),
                      backgroundColor:
                          response['success'] ? Colors.green : Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              icon: Icon(train == null ? Icons.add : Icons.check),
              label: Text(train == null ? 'Add Train' : 'Update Train'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
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
              Expanded(
                child: Text(
                  'Manage Trains',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  overflow: TextOverflow.ellipsis,
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

                // If loading failed or empty
                if (adminProvider.trains.isEmpty) {
                  // Show empty state
                  return const Center(child: Text('No trains found. Add one!'));
                }

                return Card(
                  elevation: 0,
                  color: Colors.transparent,
                  child: ListView.builder(
                    itemCount: adminProvider.trains.length,
                    itemBuilder: (context, index) {
                      final train = adminProvider.trains[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                AppTheme.primaryColor.withOpacity(0.1),
                            child: const Icon(Icons.train,
                                color: AppTheme.primaryColor),
                          ),
                          title: Text(train.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(train.type),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () =>
                                    _showTrainDialog(context, train: train),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Train'),
                                      content: Text('Delete ${train.name}?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red),
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true && context.mounted) {
                                    final response = await adminProvider
                                        .deleteTrain(train.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(response['message'] ??
                                                'Deleted')),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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

class AdminTripsPage extends StatelessWidget {
  const AdminTripsPage({super.key});

  void _showTripDialog(BuildContext context, {Trip? trip}) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    // Ensure data is loaded for dropdowns
    if (adminProvider.stations.isEmpty) adminProvider.loadStations();
    if (adminProvider.trains.isEmpty) adminProvider.loadTrains();

    // Controllers
    int? selectedTrainId = trip?.trainId;
    String? selectedFrom = trip?.fromStationCode;
    String? selectedTo = trip?.toStationCode;
    DateTime selectedDate =
        trip != null ? DateTime.parse(trip.date) : DateTime.now();
    TimeOfDay selectedTime = trip != null
        ? TimeOfDay.fromDateTime(DateTime.parse('${trip.date} ${trip.time}'))
        : const TimeOfDay(hour: 12, minute: 0);
    final priceController =
        TextEditingController(text: trip?.basePrice.toString() ?? '100.0');

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => EnhancedDialog(
          title: trip == null ? 'Schedule New Trip' : 'Edit Trip',
          subtitle: 'Create a trip schedule for a train',
          icon: Icons.schedule,
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Consumer<AdminProvider>(
                    builder: (context, provider, child) {
                      if (provider.trains.isEmpty ||
                          provider.stations.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return Column(
                        children: [
                          DropdownButtonFormField<int>(
                            value: selectedTrainId,
                            decoration: const InputDecoration(
                                labelText: 'Select Train'),
                            items: provider.trains
                                .map((t) => DropdownMenuItem(
                                      value: t.id,
                                      child: Text('${t.name} (${t.type})'),
                                    ))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => selectedTrainId = v),
                            validator: (v) => v == null ? 'Required' : null,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: selectedFrom,
                            decoration: const InputDecoration(
                                labelText: 'From Station'),
                            items: provider.stations
                                .map((s) => DropdownMenuItem(
                                      value: s.code,
                                      child: Text('${s.name} (${s.code})'),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() => selectedFrom = v),
                            validator: (v) => v == null ? 'Required' : null,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: selectedTo,
                            decoration:
                                const InputDecoration(labelText: 'To Station'),
                            items: provider.stations
                                .map((s) => DropdownMenuItem(
                                      value: s.code,
                                      child: Text('${s.name} (${s.code})'),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() => selectedTo = v),
                            validator: (v) => v == null ? 'Required' : null,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: Text(
                              'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () async {
                            final d = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)));
                            if (d != null) setState(() => selectedDate = d);
                          },
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: Text('Time: ${selectedTime.format(context)}'),
                          trailing: const Icon(Icons.access_time),
                          onTap: () async {
                            final t = await showTimePicker(
                                context: context, initialTime: selectedTime);
                            if (t != null) setState(() => selectedTime = t);
                          },
                        ),
                      ),
                    ],
                  ),
                  EnhancedTextField(
                    controller: priceController,
                    label: 'Base Price',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final adminProvider =
                    Provider.of<AdminProvider>(context, listen: false);

                // Combine date and time
                final dt = DateTime(selectedDate.year, selectedDate.month,
                    selectedDate.day, selectedTime.hour, selectedTime.minute);

                final response = await adminProvider.createTrip(
                    trainId: selectedTrainId!,
                    originStationId: selectedFrom,
                    destinationStationId: selectedTo,
                    departure: selectedDate, // Used for 'Date' column
                    departureTime: dt, // Used for 'Time' column
                    arrivalTime:
                        dt.add(const Duration(hours: 3)), // Mock arrival
                    firstClassPrice: 0,
                    secondClassPrice: 0,
                    economicPrice: double.parse(priceController.text),
                    quantities: 100);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(response['message'] ?? 'Success')));
                }
              },
              child: const Text('Save Trip'),
            )
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
              Expanded(
                child: Text(
                  'Manage Trips',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showTripDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Schedule Trip'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, adminProvider, child) {
                if (adminProvider.isLoadingTrips)
                  return const Center(child: CircularProgressIndicator());
                if (adminProvider.trips.isEmpty)
                  return const Center(child: Text('No scheduled trips'));

                return Card(
                  elevation: 0,
                  color: Colors.transparent,
                  child: ListView.builder(
                    itemCount: adminProvider.trips.length,
                    itemBuilder: (context, index) {
                      final trip = adminProvider.trips[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.route,
                              color: AppTheme.primaryColor),
                          title: Text(
                              '${trip.originCity ?? trip.originName} ➝ ${trip.destinationCity ?? trip.destinationName}'),
                          subtitle: Text(
                              '${trip.date} • ${trip.time} • ${trip.trainName} • \$${trip.basePrice}'),
                          trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                // Implement delete
                              }),
                        ),
                      );
                    },
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
      final reservationsData = await adminProvider
          .getAllBookings(); // Assuming this method exists now
      setState(() {
        users = usersData;
        reservations = reservationsData;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      // Ignore error for now
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
              Expanded(
                child: Text(
                  'Manage Users & Reservations',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  overflow: TextOverflow.ellipsis,
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
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
          ],
          rows: users.map<DataRow>((user) {
            return DataRow(cells: [
              DataCell(Text('#${user['PassengerID']}')),
              DataCell(Text(user['Full_Name'] ?? 'N/A')),
              DataCell(Text(user['Email'] ?? 'N/A')),
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
            DataColumn(label: Text('Passenger')),
            DataColumn(label: Text('Route')),
            DataColumn(label: Text('Date')),
          ],
          rows: reservations.map<DataRow>((res) {
            final trip = res['trip'];
            final passenger = res['passenger'];

            // Safe access assuming joins work, fallback nicely
            final passengerName =
                passenger != null ? passenger['Full_Name'] : 'N/A';
            final route =
                trip != null ? '${trip['From']} -> ${trip['To']}' : 'N/A';
            final date =
                trip != null ? '${trip['Date']} ${trip['Time']}' : 'N/A';

            return DataRow(cells: [
              DataCell(Text('#${res['Booking_ID']}')),
              DataCell(Text(passengerName ?? 'N/A')),
              DataCell(Text(route)),
              DataCell(Text(date)),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

class AdminTripDeparturesPage extends StatelessWidget {
  const AdminTripDeparturesPage({super.key});

  void _showDepartureDialog(BuildContext context, {TripDeparture? departure}) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    if (adminProvider.trips.isEmpty) adminProvider.loadTrips();

    int? selectedTripId = departure?.tripId;
    DateTime selectedDepartureTime = departure?.departureTime ?? DateTime.now();
    DateTime selectedArrivalTime =
        departure?.arrivalTime ?? DateTime.now().add(const Duration(hours: 3));
    final seatsController = TextEditingController(
        text: departure?.availableSeats.toString() ?? '100');

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => EnhancedDialog(
          title: departure == null ? 'Add Departure' : 'Edit Departure',
          subtitle: 'Schedule a specific departure for a trip',
          icon: Icons.departure_board,
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<AdminProvider>(
                  builder: (context, provider, child) =>
                      DropdownButtonFormField<int>(
                    value: selectedTripId,
                    decoration: const InputDecoration(labelText: 'Select Trip'),
                    items: provider.trips
                        .map((t) => DropdownMenuItem(
                              value: t.id,
                              child: Text(
                                  '${t.originName} -> ${t.destinationName} (${t.trainName})'),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => selectedTripId = v),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                      'Departure: ${DateFormat('yyyy-MM-dd HH:mm').format(selectedDepartureTime)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: selectedDepartureTime,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (d != null) {
                      final t = await showTimePicker(
                        context: context,
                        initialTime:
                            TimeOfDay.fromDateTime(selectedDepartureTime),
                      );
                      if (t != null) {
                        setState(() => selectedDepartureTime =
                            DateTime(d.year, d.month, d.day, t.hour, t.minute));
                      }
                    }
                  },
                ),
                ListTile(
                  title: Text(
                      'Arrival: ${DateFormat('yyyy-MM-dd HH:mm').format(selectedArrivalTime)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: selectedArrivalTime,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (d != null) {
                      final t = await showTimePicker(
                        context: context,
                        initialTime:
                            TimeOfDay.fromDateTime(selectedArrivalTime),
                      );
                      if (t != null) {
                        setState(() => selectedArrivalTime =
                            DateTime(d.year, d.month, d.day, t.hour, t.minute));
                      }
                    }
                  },
                ),
                EnhancedTextField(
                  controller: seatsController,
                  label: 'Available Seats',
                  icon: Icons.event_seat,
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final response = departure == null
                    ? await adminProvider.createTripDeparture(
                        tripId: selectedTripId!,
                        departureTime: selectedDepartureTime,
                        arrivalTime: selectedArrivalTime,
                        availableSeats: int.parse(seatsController.text),
                      )
                    : await adminProvider.updateTripDeparture(
                        id: departure.id,
                        tripId: selectedTripId!,
                        departureTime: selectedDepartureTime,
                        arrivalTime: selectedArrivalTime,
                        availableSeats: int.parse(seatsController.text),
                      );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(response['message'] ?? 'Success')));
                }
              },
              child: const Text('Save'),
            )
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
              Expanded(
                child: Text(
                  'Trip Departures',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showDepartureDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Departure'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, adminProvider, child) {
                if (adminProvider.isLoadingTripDepartures)
                  return const Center(child: CircularProgressIndicator());
                if (adminProvider.tripDepartures.isEmpty)
                  return const Center(child: Text('No departures scheduled'));

                return ListView.builder(
                  itemCount: adminProvider.tripDepartures.length,
                  itemBuilder: (context, index) {
                    final d = adminProvider.tripDepartures[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.departure_board,
                            color: AppTheme.primaryColor),
                        title: Text('Trip #${d.tripId}'),
                        subtitle: Text(
                            'Dep: ${DateFormat('MM/dd HH:mm').format(d.departureTime)} | Arr: ${DateFormat('MM/dd HH:mm').format(d.arrivalTime)}\nSeats: ${d.availableSeats}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showDepartureDialog(context,
                                    departure: d)),
                            IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Departure'),
                                      content: const Text('Are you sure?'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Cancel')),
                                        ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red),
                                            child: const Text('Delete')),
                                      ],
                                    ),
                                  );
                                  if (confirm == true)
                                    await adminProvider
                                        .deleteTripDeparture(d.id);
                                }),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AdminCarriageTypesPage extends StatelessWidget {
  const AdminCarriageTypesPage({super.key});

  void _showCarriageTypeDialog(BuildContext context, {CarriageType? type}) {
    final typeController = TextEditingController(text: type?.type);
    final capacityController =
        TextEditingController(text: type?.capacity.toString() ?? '80');
    final priceController =
        TextEditingController(text: type?.price.toString() ?? '100.0');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => EnhancedDialog(
        title: type == null ? 'Add Carriage Type' : 'Edit Carriage Type',
        subtitle: 'Define carriage specifications and pricing',
        icon: Icons.airline_seat_recline_extra,
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              EnhancedTextField(
                controller: typeController,
                label: 'Type (e.g. first class)',
                icon: Icons.category,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              EnhancedTextField(
                controller: capacityController,
                label: 'Capacity',
                icon: Icons.people,
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              EnhancedTextField(
                controller: priceController,
                label: 'Base Price',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final adminProvider =
                  Provider.of<AdminProvider>(context, listen: false);

              final response = type == null
                  ? await adminProvider.createCarriageType(
                      type: typeController.text,
                      capacity: int.parse(capacityController.text),
                      price: double.parse(priceController.text),
                    )
                  : await adminProvider.updateCarriageType(
                      id: type.id,
                      type: typeController.text,
                      capacity: int.parse(capacityController.text),
                      price: double.parse(priceController.text),
                    );

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(response['message'] ?? 'Success')));
              }
            },
            child: const Text('Save'),
          )
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
              Expanded(
                child: Text(
                  'Carriage Types',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showCarriageTypeDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Type'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, adminProvider, child) {
                if (adminProvider.isLoadingCarriageTypes)
                  return const Center(child: CircularProgressIndicator());
                if (adminProvider.carriageTypes.isEmpty)
                  return const Center(child: Text('No carriage types defined'));

                return ListView.builder(
                  itemCount: adminProvider.carriageTypes.length,
                  itemBuilder: (context, index) {
                    final t = adminProvider.carriageTypes[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.airline_seat_recline_extra,
                            color: AppTheme.primaryColor),
                        title: Text(t.typeDisplay),
                        subtitle: Text(
                            'Capacity: ${t.capacity} | Base Price: \$${t.price}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () =>
                                    _showCarriageTypeDialog(context, type: t)),
                            IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Carriage Type'),
                                      content: const Text('Are you sure?'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Cancel')),
                                        ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red),
                                            child: const Text('Delete')),
                                      ],
                                    ),
                                  );
                                  if (confirm == true)
                                    await adminProvider
                                        .deleteCarriageType(t.id);
                                }),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
