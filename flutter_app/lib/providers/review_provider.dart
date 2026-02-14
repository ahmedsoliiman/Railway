import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/review_service.dart';

class ReviewProvider with ChangeNotifier {
  final ReviewService _reviewService = ReviewService();

  List<Review> _reviews = [];
  TripRatingSummary? _ratingSummary;
  bool _isLoading = false;
  String? _error;

  List<Review> get reviews => _reviews;
  TripRatingSummary? get ratingSummary => _ratingSummary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load reviews for a specific trip
  Future<void> loadTripReviews(int tripId) async {
    _setLoading(true);
    _setError(null);

    final response = await _reviewService.getTripReviews(tripId);

    _setLoading(false);

    if (response['success']) {
      _reviews = response['data'] as List<Review>;
    } else {
      _setError(response['message']);
    }
  }

  /// Load rating summary for a trip
  Future<void> loadRatingSummary(int tripId) async {
    final response = await _reviewService.getTripRatingSummary(tripId);

    if (response['success']) {
      _ratingSummary = response['data'] as TripRatingSummary;
      notifyListeners();
    }
  }

  /// Create a new review
  Future<Map<String, dynamic>> createReview({
    required int tripId,
    required int passengerId,
    required int rating,
    String? comment,
  }) async {
    _setLoading(true);
    _setError(null);

    final response = await _reviewService.createReview(
      tripId: tripId,
      passengerId: passengerId,
      rating: rating,
      comment: comment,
    );

    _setLoading(false);

    if (response['success']) {
      // Reload reviews and rating summary
      await loadTripReviews(tripId);
      await loadRatingSummary(tripId);
    } else {
      _setError(response['message']);
    }

    return response;
  }

  /// Update an existing review
  Future<Map<String, dynamic>> updateReview({
    required int reviewId,
    required int passengerId,
    required int tripId,
    required int rating,
    String? comment,
  }) async {
    _setLoading(true);
    _setError(null);

    final response = await _reviewService.updateReview(
      reviewId: reviewId,
      passengerId: passengerId,
      rating: rating,
      comment: comment,
    );

    _setLoading(false);

    if (response['success']) {
      await loadTripReviews(tripId);
      await loadRatingSummary(tripId);
    } else {
      _setError(response['message']);
    }

    return response;
  }

  /// Delete a review
  Future<Map<String, dynamic>> deleteReview({
    required int reviewId,
    required int passengerId,
    required int tripId,
  }) async {
    _setLoading(true);
    _setError(null);

    final response = await _reviewService.deleteReview(
      reviewId: reviewId,
      passengerId: passengerId,
    );

    _setLoading(false);

    if (response['success']) {
      await loadTripReviews(tripId);
      await loadRatingSummary(tripId);
    } else {
      _setError(response['message']);
    }

    return response;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
