import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../core/theme/app_theme.dart';

class OfflineScreenBody extends StatelessWidget {
  final String tripsCount;
  final String rating;
  final VoidCallback? onToggleOnline;

  const OfflineScreenBody({
    super.key,
    required this.tripsCount,
    required this.rating,
    this.onToggleOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Warning Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF4ED),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF7D1BA), width: 1),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Color(0xFFB35C31),
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Turn on availability to receive trip assignments',
                      style: TextStyle(
                        color: Color(0xFFB35C31),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Stats Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(tripsCount, "Trips This Week"),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(rating, "Rating"),
                ),
              ],
            ),
          ),
          
          const Spacer(),

          // Offline Text
          const Text(
            "You're offline",
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Turn On "Go Online" To Receive Trip Assignments.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Go Online Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onToggleOnline != null ? () => onToggleOnline!() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.designDarkGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Go Online",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          
          const Spacer(flex: 3),
          // Illustration
          SvgPicture.asset(
            'assets/Svg/HomepageIcons/TaxiBhaiMadeInDubai.svg',
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.fitWidth,
            alignment: Alignment.bottomCenter,
            placeholderBuilder: (context) => const SizedBox(height: 180),
            // Added error builder fallback
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
