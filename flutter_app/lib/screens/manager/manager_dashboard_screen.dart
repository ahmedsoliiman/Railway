import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/manager_provider.dart';
import 'package:go_router/go_router.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  int _selectedIndex = 0;
  final Set<int> _loadedPages = {0};

  List<Widget> get _pages => [
        const ManagerTrainStatsPage(),
        _loadedPages.contains(1)
            ? const ManagerBusiestDaysPage()
            : const SizedBox.shrink(),
      ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Dashboard'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.tealAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.manage_accounts, size: 20),
                const SizedBox(width: 8),
                Text(
                  user?.fullName ?? 'Manager',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (idx) => setState(() {
              _selectedIndex = idx;
              _loadedPages.add(idx);
            }),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.train),
                label: Text('Popular Trains'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_month),
                label: Text('Busiest Days'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }
}

class ManagerTrainStatsPage extends StatefulWidget {
  const ManagerTrainStatsPage({super.key});

  @override
  State<ManagerTrainStatsPage> createState() => _ManagerTrainStatsPageState();
}

class _ManagerTrainStatsPageState extends State<ManagerTrainStatsPage> {
  String? _selectedStationCode;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  @override
  Widget build(BuildContext context) {
    final managerProvider = Provider.of<ManagerProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Most Reserved Trains by Station',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          // Filters
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Station Dropdown
                  FutureBuilder<List<Map<String, dynamic>>>(
                    // Quick fetch
                    future: Provider.of<ManagerProvider>(context, listen: false)
                        .fetchStationsList(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return const SizedBox(
                            width: 150, child: LinearProgressIndicator());
                      return SizedBox(
                        width: 200,
                        child: DropdownButtonFormField<String>(
                          value: _selectedStationCode,
                          decoration: const InputDecoration(
                              labelText: 'Select Station',
                              border: OutlineInputBorder()),
                          items: snapshot.data!
                              .map((s) => DropdownMenuItem(
                                    value: s['code'] as String,
                                    child: Text(s['name']),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedStationCode = v),
                        ),
                      );
                    },
                  ),
                  // Date Range
                  ElevatedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(
                        '${DateFormat('MM/dd').format(_startDate)} - ${DateFormat('MM/dd').format(_endDate)}'),
                    onPressed: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        initialDateRange:
                            DateTimeRange(start: _startDate, end: _endDate),
                      );
                      if (picked != null) {
                        setState(() {
                          _startDate = picked.start;
                          _endDate = picked.end;
                        });
                      }
                    },
                  ),
                  // Generate Button
                  ElevatedButton(
                    onPressed: _selectedStationCode == null
                        ? null
                        : () {
                            managerProvider.generateTrainPopularityReport(
                              stationCode: _selectedStationCode!,
                              startDate: _startDate,
                              endDate: _endDate,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white),
                    child: const Text('Generate Report'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Results
          Expanded(
            child: managerProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : managerProvider.trainPopularity.isEmpty
                    ? const Center(child: Text('No data found for criteria'))
                    : ListView.builder(
                        itemCount: managerProvider.trainPopularity.length,
                        itemBuilder: (context, index) {
                          final item = managerProvider.trainPopularity[index];
                          // item: {trainName, bookings}
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.teal.shade100,
                                child: Text('${index + 1}'),
                              ),
                              title: Text(item['trainName'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              trailing: Chip(
                                label: Text('${item['bookings']} Bookings',
                                    style:
                                        const TextStyle(color: Colors.white)),
                                backgroundColor: Colors.teal,
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

class ManagerBusiestDaysPage extends StatefulWidget {
  const ManagerBusiestDaysPage({super.key});

  @override
  State<ManagerBusiestDaysPage> createState() => _ManagerBusiestDaysPageState();
}

class _ManagerBusiestDaysPageState extends State<ManagerBusiestDaysPage> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final managerProvider = Provider.of<ManagerProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Busiest Travel Days',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          // Filters
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  DropdownButton<int>(
                    value: _selectedMonth,
                    items: List.generate(
                        12,
                        (i) => DropdownMenuItem(
                              value: i + 1,
                              child: Text(DateFormat('MMMM')
                                  .format(DateTime(2022, i + 1))),
                            )),
                    onChanged: (v) => setState(() => _selectedMonth = v!),
                  ),
                  DropdownButton<int>(
                    value: _selectedYear,
                    items: [2024, 2025, 2026, 2027]
                        .map((y) =>
                            DropdownMenuItem(value: y, child: Text('$y')))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedYear = v!),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      managerProvider.generateBusiestDaysReport(
                          month: _selectedMonth, year: _selectedYear);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white),
                    child: const Text('Generate'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Results
          Expanded(
            child: managerProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : managerProvider.busiestDays.isEmpty
                    ? const Center(child: Text('No data found'))
                    : ListView.builder(
                        itemCount: managerProvider.busiestDays.length,
                        itemBuilder: (context, index) {
                          final item = managerProvider
                              .busiestDays[index]; // {date, passengers}
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const Icon(Icons.date_range,
                                  color: Colors.teal),
                              title: Text(item['date']),
                              trailing: Text(
                                '${item['passengers']} Passengers',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.teal),
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
