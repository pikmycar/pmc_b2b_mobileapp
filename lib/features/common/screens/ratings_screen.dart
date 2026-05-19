import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../auth/bloc/commonScreen/ratings/get_ratings_bloc.dart';
import '../../auth/bloc/commonScreen/ratings/get_ratings_event.dart';
import '../../auth/bloc/commonScreen/ratings/get_ratings_state.dart';

class RatingsScreen extends StatelessWidget {
  const RatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return BlocProvider(
      create: (context) => GetRatingsBloc(
        repository: RatingsRepository(
          apiClient: ApiClient(context.read<SecureStorageService>()),
        ),
      )..add(const FetchRatingsEvent()),
      child: Scaffold(
        backgroundColor: colorScheme.primary, // Header background color
        body: SafeArea(
          child: BlocBuilder<GetRatingsBloc, GetRatingsState>(
            builder: (context, state) {
              if (state is GetRatingsLoading || state is GetRatingsInitial) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              } else if (state is GetRatingsError) {
                return Center(
                  child: Text(
                    'Error loading ratings: ${state.message}',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }

              final ratingsData = (state as GetRatingsSuccess).ratingsData.data;
              final averageRating = ratingsData?.averageRating?.toStringAsFixed(1) ?? "0.0";
              final totalReviews = ratingsData?.totalReviews ?? 0;
              final reviews = ratingsData?.reviews ?? [];

              return Column(
                children: [
                  _buildRatingHeader(context, averageRating, totalReviews, reviews),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: reviews.isEmpty
                          ? Center(
                              child: Text(
                                "No reviews yet.",
                                style: textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                              itemCount: reviews.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    child: Text(
                                      "RECENT REVIEWS",
                                      style: textTheme.labelLarge?.copyWith(
                                        color: colorScheme.onSurface.withOpacity(0.5),
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  );
                                }
                                final review = reviews[index - 1];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildReviewCard(
                                    context,
                                    "User", // Map real name if backend adds it later
                                    review.review ?? "No comment",
                                    review.rating ?? 0,
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRatingHeader(BuildContext context, String averageRating, int totalReviews, List reviews) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Calculate rating distribution dynamically
    int count5 = 0, count4 = 0, count3 = 0, count2 = 0, count1 = 0;
    
    for (var review in reviews) {
      if (review.rating == 5) count5++;
      else if (review.rating == 4) count4++;
      else if (review.rating == 3) count3++;
      else if (review.rating == 2) count2++;
      else if (review.rating == 1) count1++;
    }

    final totalCount = reviews.isNotEmpty ? reviews.length : 1; // Prevent division by zero
    
    double p5 = count5 / totalCount;
    double p4 = count4 / totalCount;
    double p3 = count3 / totalCount;
    double p2 = count2 / totalCount;
    double p1 = count1 / totalCount;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
      child: Column(
        children: [
          Text(
            averageRating,
            style: textTheme.displayLarge?.copyWith(
              fontSize: 64,
              fontWeight: FontWeight.w900,
              color: colorScheme.onPrimary,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => Icon(Icons.star, color: colorScheme.onPrimary, size: 28),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Based on $totalReviews trips",
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onPrimary.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 30),
          // Dynamic Progress Bars
          _buildRatingBar(context, 5, p5, "${(p5 * 100).toInt()}%"),
          const SizedBox(height: 8),
          _buildRatingBar(context, 4, p4, "${(p4 * 100).toInt()}%"),
          const SizedBox(height: 8),
          _buildRatingBar(context, 3, p3, "${(p3 * 100).toInt()}%"),
          const SizedBox(height: 8),
          _buildRatingBar(context, 2, p2, "${(p2 * 100).toInt()}%"),
          const SizedBox(height: 8),
          _buildRatingBar(context, 1, p1, "${(p1 * 100).toInt()}%"),
        ],
      ),
    );
  }

  Widget _buildRatingBar(BuildContext context, int star, double progress, String percentage) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Text(
          "$star",
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: colorScheme.onPrimary.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
              minHeight: 12,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 40,
          child: Text(
            percentage,
            textAlign: TextAlign.right,
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.onPrimary.withOpacity(0.7),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(BuildContext context, String name, String comment, int rating) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star,
                    color: index < rating ? Colors.amber : colorScheme.onSurface.withOpacity(0.1),
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "\"$comment\"",
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
