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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      width: double.infinity,
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Warning Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.warning.withOpacity(0.3), width: 1),
              ),
              child: Row(
                children: [
                   const Icon(
                    Icons.error_outline,
                    color: AppColors.warning,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Turn on availability to receive trip assignments',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
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
                  child: _buildStatCard(context, tripsCount, "Trips This Week"),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(context, rating, "Rating"),
                ),
              ],
            ),
          ),
          
          const Spacer(),

          // Offline Text
          Text(
            "You're offline",
            style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Turn On "Go Online" To Receive Trip Assignments.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
            ),
          ),
          const SizedBox(height: 24),
          // Go Online Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ElevatedButton(
              onPressed: onToggleOnline != null ? () => onToggleOnline!() : null,
              child: const Text("Go Online"),
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
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}
