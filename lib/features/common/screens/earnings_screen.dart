import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/network/api_client.dart';
import '../../auth/bloc/commonScreen/earnings/get_earnings_bloc.dart';
import '../../auth/bloc/commonScreen/earnings/get_earnings_event.dart';
import '../../auth/bloc/commonScreen/earnings/get_earnings_state.dart';
import '../../auth/bloc/commonScreen/profile/get_profile_bloc.dart';
import '../../auth/bloc/commonScreen/profile/get_profile_event.dart';
import '../../auth/bloc/commonScreen/profile/get_profile_state.dart';
import '../../../core/theme/app_theme.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => GetEarningsBloc(
            repository: EarningsRepository(
              apiClient: ApiClient(context.read<SecureStorageService>()),
            ),
          )..add(FetchEarningsEvent()),
        ),
        BlocProvider(
          create: (context) => GetProfileBloc(
            repository: ProfileRepository(
              apiClient: ApiClient(context.read<SecureStorageService>()),
            ),
          )..add(FetchProfileEvent()),
        ),
      ],
      child: Builder(
        builder: (innerContext) {
          return Scaffold(
            backgroundColor: colorScheme.primary, // Dark header area
            body: SafeArea(
              child: BlocBuilder<GetEarningsBloc, GetEarningsState>(
                builder: (context, state) {
                  if (state is GetEarningsLoading || state is GetEarningsInitial) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  } else if (state is GetEarningsError) {
                    return Center(
                      child: Text('Error loading earnings: ${state.message}',
                        style: const TextStyle(color: Colors.white)),
                    );
                  }

                  double todayEarning = 0.0;
                  double weekEarning = 0.0;
                  double walletBalance = 0.0;

                  if (state is GetEarningsSuccess) {
                    final data = state.earnings.data;
                    todayEarning = data?.todayEarning ?? 0.0;
                    weekEarning = data?.weekEarning ?? 0.0;
                    walletBalance = data?.walletBalance ?? 0.0;
                  }

                  return Column(
                    children: [
                      _buildHeader(innerContext),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _balanceCard(innerContext, weekEarning),
                                const SizedBox(height: 20),
                                _tabs(innerContext),
                                const SizedBox(height: 20),
                                _stats(innerContext, todayEarning),
                                const SizedBox(height: 20),
                                _car(innerContext),
                                const SizedBox(height: 20),
                                _payout(innerContext, walletBalance),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<GetProfileBloc, GetProfileState>(
      builder: (context, state) {
        final name = state is GetProfileSuccess
            ? (state.profileDetails.data?.name ?? "Driver")
            : "Driver";
        final imageUrl = state is GetProfileSuccess
            ? state.profileDetails.data?.profileImageUrl
            : null;

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                    ? NetworkImage(imageUrl)
                    : null,
                backgroundColor: colorScheme.onPrimary.withOpacity(0.2),
                child: imageUrl == null || imageUrl.isEmpty
                    ? Icon(Icons.person, color: colorScheme.onPrimary, size: 22)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      "Earnings Overview",
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.account_balance_wallet, color: colorScheme.onPrimary, size: 22),
            ],
          ),
        );
      },
    );
  }

  Widget _balanceCard(BuildContext context, double weekEarning) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cardColor = theme.brightness == Brightness.light ? AppColors.designYellow : colorScheme.primaryContainer;
    final onCardColor = theme.brightness == Brightness.light ? Colors.black : colorScheme.onPrimaryContainer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "AED ${weekEarning.toStringAsFixed(2)}",
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: onCardColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Total This Week",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: onCardColor.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.trending_up, color: AppColors.success, size: 16),
              const SizedBox(width: 4),
              Text(
                "+18% vs last week",
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _tabs(BuildContext context) {
    return Row(
      children: [
        _tab(context, "Today", true),
        const SizedBox(width: 10),
        _tab(context, "Week", false),
        const SizedBox(width: 10),
        _tab(context, "Month", false),
      ],
    );
  }

  Widget _tab(BuildContext context, String text, bool active) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? colorScheme.primary : colorScheme.outlineVariant),
        ),
        child: Text(
          text,
          style: theme.textTheme.labelLarge?.copyWith(
            color: active ? colorScheme.onPrimary : colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _stats(BuildContext context, double todayEarning) {
    return BlocBuilder<GetProfileBloc, GetProfileState>(
      builder: (context, state) {
        final totalTrips = state is GetProfileSuccess
            ? (state.profileDetails.data?.totalTrips?.toString() ?? "--")
            : "--";
        final rating = state is GetProfileSuccess
            ? (state.profileDetails.data?.rating?.toStringAsFixed(1) ?? "--")
            : "--";

        return Row(
          children: [
            Expanded(child: _stat(context, totalTrips, "Trips")),
            const SizedBox(width: 10),
            Expanded(child: _rating(context, rating)),
            const SizedBox(width: 10),
            Expanded(child: _stat(context, "AED ${todayEarning.toStringAsFixed(0)}", "Today", isPositive: true)),
          ],
        );
      },
    );
  }

  Widget _stat(BuildContext context, String value, String label, {bool isPositive = false}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: isPositive ? AppColors.success : colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall,
          )
        ],
      ),
    );
  }

  Widget _rating(BuildContext context, String ratingValue) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                ratingValue,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.star, color: Colors.amber, size: 18),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Rating",
            style: theme.textTheme.labelSmall,
          )
        ],
      ),
    );
  }

  Widget _car(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Center(
        child: Text(
          "BMW • Active Vehicle",
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _payout(BuildContext context, double walletBalance) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet, color: AppColors.success),
          const SizedBox(width: 10),

          Expanded(
            child: Text(
              "Payout: AED ${walletBalance.toStringAsFixed(2)}",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/withdraw'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              minimumSize: const Size(0, 36),
            ),
            child: const Text("Withdraw"),
          )
        ],
      ),
    );
  }
}