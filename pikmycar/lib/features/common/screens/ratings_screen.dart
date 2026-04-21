import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class RatingsScreen extends StatelessWidget {
  const RatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.primary, // Header background color
      body: SafeArea(
        child: Column(
          children: [
            _buildRatingHeader(context),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "RECENT REVIEWS",
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.5),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildReviewCard(
                        context,
                        "Ahmed A.",
                        "Very professional and careful with my car. Highly recommended!",
                        5,
                      ),
                      const SizedBox(height: 16),
                      _buildReviewCard(
                        context,
                        "Fatima K.",
                        "On time, polite, great service overall.",
                        5,
                      ),
                      const SizedBox(height: 16),
                      _buildReviewCard(
                        context,
                        "John D.",
                        "Good driver, knows the routes well.",
                        4,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
      child: Column(
        children: [
          Text(
            "4.9",
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
            "Based on 340 trips",
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onPrimary.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 30),
          // Progress Bars
          _buildRatingBar(context, 5, 0.82, "82%"),
          const SizedBox(height: 8),
          _buildRatingBar(context, 4, 0.12, "12%"),
          const SizedBox(height: 8),
          _buildRatingBar(context, 3, 0.04, "4%"),
          const SizedBox(height: 8),
          _buildRatingBar(context, 2, 0.01, "1%"),
          const SizedBox(height: 8),
          _buildRatingBar(context, 1, 0.00, "0%"),
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
