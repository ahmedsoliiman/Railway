import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/review_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/review.dart';

class TripReviewsScreen extends StatefulWidget {
  final int tripId;
  final String tripName;

  const TripReviewsScreen({
    super.key,
    required this.tripId,
    required this.tripName,
  });

  @override
  State<TripReviewsScreen> createState() => _TripReviewsScreenState();
}

class _TripReviewsScreenState extends State<TripReviewsScreen> {
  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    await Future.wait([
      reviewProvider.loadTripReviews(widget.tripId),
      reviewProvider.loadRatingSummary(widget.tripId),
    ]);
  }

  void _showAddReviewDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add a review')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddReviewSheet(
        tripId: widget.tripId,
        passengerId: authProvider.user!.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews - ${widget.tripName}'),
      ),
      body: Consumer<ReviewProvider>(
        builder: (context, reviewProvider, child) {
          if (reviewProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (reviewProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: AppTheme.dangerColor),
                  const SizedBox(height: 16),
                  Text(reviewProvider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadReviews,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final summary = reviewProvider.ratingSummary;
          final reviews = reviewProvider.reviews;

          return RefreshIndicator(
            onRefresh: _loadReviews,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Rating Summary Card
                if (summary != null) _buildRatingSummary(summary),
                const SizedBox(height: 24),

                // Reviews Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reviews (${reviews.length})',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton.icon(
                      onPressed: _showAddReviewDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Write Review'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Reviews List
                if (reviews.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.rate_review_outlined,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No reviews yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Be the first to review this trip!',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...reviews.map((review) => _buildReviewCard(review)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRatingSummary(TripRatingSummary summary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                // Average Rating
                Column(
                  children: [
                    Text(
                      summary.averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildStars(summary.averageRating),
                    const SizedBox(height: 4),
                    Text(
                      '${summary.totalReviews} reviews',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(width: 32),
                // Rating Bars
                Expanded(
                  child: Column(
                    children: [
                      _buildRatingBar(
                          5, summary.fiveStar, summary.totalReviews),
                      _buildRatingBar(
                          4, summary.fourStar, summary.totalReviews),
                      _buildRatingBar(
                          3, summary.threeStar, summary.totalReviews),
                      _buildRatingBar(2, summary.twoStar, summary.totalReviews),
                      _buildRatingBar(1, summary.oneStar, summary.totalReviews),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBar(int stars, int count, int total) {
    final percentage = total > 0 ? (count / total) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$stars'),
          const SizedBox(width: 4),
          const Icon(Icons.star, size: 16, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation(Colors.amber),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            child: Text(
              count.toString(),
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(
                    (review.passengerName ?? 'U')[0].toUpperCase(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.passengerName ?? 'Anonymous',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateFormat('MMM d, yyyy').format(review.createdAt),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                _buildStars(review.rating.toDouble()),
              ],
            ),
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(review.comment!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor()
              ? Icons.star
              : (index < rating ? Icons.star_half : Icons.star_border),
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }
}

class _AddReviewSheet extends StatefulWidget {
  final int tripId;
  final int passengerId;

  const _AddReviewSheet({
    required this.tripId,
    required this.passengerId,
  });

  @override
  State<_AddReviewSheet> createState() => _AddReviewSheetState();
}

class _AddReviewSheetState extends State<_AddReviewSheet> {
  int _rating = 5;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    final response = await reviewProvider.createReview(
      tripId: widget.tripId,
      passengerId: widget.passengerId,
      rating: _rating,
      comment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (response['success']) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Review submitted successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${response['message']}'),
          backgroundColor: AppTheme.dangerColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Write a Review',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Rating Stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 40,
                ),
                onPressed: () => setState(() => _rating = index + 1),
              );
            }),
          ),
          const SizedBox(height: 16),

          // Comment TextField
          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Share your experience... (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Submit Button
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitReview,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit Review'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
