import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class RatingsScreen extends StatelessWidget {
  const RatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.designYellow, // Header background color
      body: SafeArea(
        child: Column(
          children: [
            _buildRatingHeader(),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "RECENT REVIEWS",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildReviewCard(
                        "Ahmed A.",
                        "Very professional and careful with my car. Highly recommended!",
                        5,
                      ),
                      const SizedBox(height: 16),
                      _buildReviewCard(
                        "Fatima K.",
                        "On time, polite, great service overall.",
                        5,
                      ),
                      const SizedBox(height: 16),
                      _buildReviewCard(
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

  Widget _buildRatingHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
      child: Column(
        children: [
          const Text(
            "4.9",
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w900,
              color: Colors.black,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => const Icon(Icons.star, color: Colors.black, size: 28),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Based on 340 trips",
            style: TextStyle(
              color: Colors.black54,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 30),
          // Progress Bars
          _buildRatingBar(5, 0.82, "82%"),
          const SizedBox(height: 8),
          _buildRatingBar(4, 0.12, "12%"),
          const SizedBox(height: 8),
          _buildRatingBar(3, 0.04, "4%"),
          const SizedBox(height: 8),
          _buildRatingBar(2, 0.01, "1%"),
          const SizedBox(height: 8),
          _buildRatingBar(1, 0.00, "0%"),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int star, double progress, String percentage) {
    return Row(
      children: [
        Text(
          "$star",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.black12,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
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
            style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(String name, String comment, int rating) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star,
                    color: index < rating ? Colors.amber : Colors.grey.shade300,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "\"$comment\"",
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 15,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
