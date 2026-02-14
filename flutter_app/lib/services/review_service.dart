import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/review.dart';

class ReviewService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all reviews for a specific trip
  Future<Map<String, dynamic>> getTripReviews(int tripId) async {
    try {
      final List<dynamic> response = await _supabase
          .from('trip_reviews')
          .select('*')
          .eq('trip_id', tripId)
          .order('created_at', ascending: false);

      final List<Review> reviews = [];
      for (var r in response) {
        final Map<String, dynamic> reviewMap = Map.from(r);
        final passengerId =
            reviewMap['passenger_id'] ?? reviewMap['PassengerID'];

        if (passengerId != null) {
          final pData = await _supabase
              .from('passenger')
              .select('Full_Name, Email')
              .eq('PassengerID', passengerId)
              .maybeSingle();

          if (pData != null) {
            reviewMap['passenger'] = pData;
          }
        }
        reviews.add(Review.fromJson(reviewMap));
      }
      return {'success': true, 'data': reviews};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  /// Get rating summary for a trip
  Future<Map<String, dynamic>> getTripRatingSummary(int tripId) async {
    try {
      final response = await _supabase
          .from('trip_ratings_summary')
          .select()
          .eq('trip_id', tripId)
          .maybeSingle();

      if (response == null) {
        // No reviews yet
        return {
          'success': true,
          'data': TripRatingSummary(
            tripId: tripId,
            totalReviews: 0,
            averageRating: 0,
            fiveStar: 0,
            fourStar: 0,
            threeStar: 0,
            twoStar: 0,
            oneStar: 0,
          ),
        };
      }

      return {
        'success': true,
        'data': TripRatingSummary.fromJson(response),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  /// Create a new review
  Future<Map<String, dynamic>> createReview({
    required int tripId,
    required int passengerId,
    required int rating,
    String? comment,
  }) async {
    try {
      // Check if user already reviewed this trip
      final existing = await _supabase
          .from('trip_reviews')
          .select()
          .eq('trip_id', tripId)
          .eq('passenger_id', passengerId)
          .maybeSingle();

      if (existing != null) {
        return {
          'success': false,
          'message': 'You have already reviewed this trip',
        };
      }

      final response = await _supabase
          .from('trip_reviews')
          .insert({
            'trip_id': tripId,
            'passenger_id': passengerId,
            'rating': rating,
            'comment': comment,
          })
          .select()
          .single();

      return {
        'success': true,
        'message': 'Review submitted successfully',
        'data': Review.fromJson(response),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  /// Update an existing review
  Future<Map<String, dynamic>> updateReview({
    required int reviewId,
    required int passengerId,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await _supabase
          .from('trip_reviews')
          .update({
            'rating': rating,
            'comment': comment,
          })
          .eq('review_id', reviewId)
          .eq('passenger_id', passengerId)
          .select()
          .single();

      return {
        'success': true,
        'message': 'Review updated successfully',
        'data': Review.fromJson(response),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  /// Delete a review
  Future<Map<String, dynamic>> deleteReview({
    required int reviewId,
    required int passengerId,
  }) async {
    try {
      await _supabase
          .from('trip_reviews')
          .delete()
          .eq('review_id', reviewId)
          .eq('passenger_id', passengerId);

      return {
        'success': true,
        'message': 'Review deleted successfully',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  /// Get all reviews by a specific passenger
  Future<Map<String, dynamic>> getPassengerReviews(int passengerId) async {
    try {
      final List<dynamic> response = await _supabase
          .from('trip_reviews')
          .select('*')
          .eq('passenger_id', passengerId)
          .order('created_at', ascending: false);

      final reviews = response.map((r) => Review.fromJson(r)).toList();
      return {'success': true, 'data': reviews};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  /// Get all reviews (for admin)
  Future<Map<String, dynamic>> getAllReviews() async {
    try {
      final List<dynamic> response = await _supabase
          .from('trip_reviews')
          .select('*')
          .order('created_at', ascending: false);

      final List<Review> reviews = [];
      for (var r in response) {
        final Map<String, dynamic> reviewMap = Map.from(r);
        final passengerId =
            reviewMap['passenger_id'] ?? reviewMap['PassengerID'];

        if (passengerId != null) {
          final pData = await _supabase
              .from('passenger')
              .select('Full_Name, Email')
              .eq('PassengerID', passengerId)
              .maybeSingle();

          if (pData != null) {
            reviewMap['passenger'] = pData;
          }
        }
        reviews.add(Review.fromJson(reviewMap));
      }
      return {'success': true, 'data': reviews};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }
}
