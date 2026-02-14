import 'package:flutter/material.dart';
import '../services/manager_service.dart';

class ManagerProvider with ChangeNotifier {
  final ManagerService _managerService = ManagerService();

  // Fetch Stations for dropdown
  Future<List<Map<String, dynamic>>> fetchStationsList() async {
    return await _managerService.getStations();
  }

  // Report 1 Data
  List<Map<String, dynamic>> _trainPopularity = [];
  List<Map<String, dynamic>> get trainPopularity => _trainPopularity;

  // Report 2 Data
  List<Map<String, dynamic>> _busiestDays = [];
  List<Map<String, dynamic>> get busiestDays => _busiestDays;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> generateTrainPopularityReport({
    required String stationCode,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _managerService.getMostReservedTrains(
      stationCode: stationCode,
      startDate: startDate,
      endDate: endDate,
    );

    _isLoading = false;

    if (response['success']) {
      _trainPopularity = List<Map<String, dynamic>>.from(response['data']);
    } else {
      _error = response['message'];
      _trainPopularity = [];
    }
    notifyListeners();
  }

  Future<void> generateBusiestDaysReport({
    required int month,
    required int year,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _managerService.getBusiestTravelDays(
      month: month,
      year: year,
    );

    _isLoading = false;

    if (response['success']) {
      _busiestDays = List<Map<String, dynamic>>.from(response['data']);
    } else {
      _error = response['message'];
      _busiestDays = [];
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
