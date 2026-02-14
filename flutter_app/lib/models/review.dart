class Review {
  final int reviewId;
  final int tripId;
  final int passengerId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Optional passenger info (from join)
  final String? passengerName;
  final String? passengerEmail;

  Review({
    required this.reviewId,
    required this.tripId,
    required this.passengerId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.updatedAt,
    this.passengerName,
    this.passengerEmail,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json['review_id'] as int,
      tripId: json['trip_id'] as int,
      passengerId: json['passenger_id'] as int,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      passengerName: json['passenger']?['Full_Name'] as String?,
      passengerEmail: json['passenger']?['Email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'review_id': reviewId,
      'trip_id': tripId,
      'passenger_id': passengerId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class TripRatingSummary {
  final int tripId;
  final int totalReviews;
  final double averageRating;
  final int fiveStar;
  final int fourStar;
  final int threeStar;
  final int twoStar;
  final int oneStar;

  TripRatingSummary({
    required this.tripId,
    required this.totalReviews,
    required this.averageRating,
    required this.fiveStar,
    required this.fourStar,
    required this.threeStar,
    required this.twoStar,
    required this.oneStar,
  });

  factory TripRatingSummary.fromJson(Map<String, dynamic> json) {
    return TripRatingSummary(
      tripId: json['trip_id'] as int,
      totalReviews: json['total_reviews'] as int,
      averageRating: (json['average_rating'] as num).toDouble(),
      fiveStar: json['five_star'] as int,
      fourStar: json['four_star'] as int,
      threeStar: json['three_star'] as int,
      twoStar: json['two_star'] as int,
      oneStar: json['one_star'] as int,
    );
  }

  // Get percentage for each rating
  double getPercentage(int stars) {
    if (totalReviews == 0) return 0;
    switch (stars) {
      case 5:
        return (fiveStar / totalReviews) * 100;
      case 4:
        return (fourStar / totalReviews) * 100;
      case 3:
        return (threeStar / totalReviews) * 100;
      case 2:
        return (twoStar / totalReviews) * 100;
      case 1:
        return (oneStar / totalReviews) * 100;
      default:
        return 0;
    }
  }
}
