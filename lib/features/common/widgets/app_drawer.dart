import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/models/user_role.dart';
import '../../auth/bloc/commonScreen/profile/get_profile_bloc.dart';
import '../../auth/bloc/commonScreen/profile/get_profile_event.dart';
import '../../auth/bloc/commonScreen/profile/get_profile_state.dart';
import '../../auth/bloc/commonScreen/driver_location/trip_bloc.dart';
import '../../auth/bloc/commonScreen/driver_location/trip_event.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetProfileBloc(
        repository: ProfileRepository(
          apiClient: ApiClient(context.read<SecureStorageService>()),
        ),
      )..add(FetchProfileEvent()),
      child: const _AppDrawerContent(),
    );
  }
}

class _AppDrawerContent extends StatelessWidget {
  const _AppDrawerContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // Drawer Header with real profile data
          BlocBuilder<GetProfileBloc, GetProfileState>(
            builder: (context, state) {
              final name = state is GetProfileSuccess
                  ? (state.profileDetails.data?.name ?? 'Driver')
                  : 'Driver';
              final email = state is GetProfileSuccess
                  ? (state.profileDetails.data?.email ?? '')
                  : '';
              final rating = state is GetProfileSuccess
                  ? (state.profileDetails.data?.rating?.toStringAsFixed(1) ?? '—')
                  : '—';
              final imageUrl = state is GetProfileSuccess
                  ? state.profileDetails.data?.profileImageUrl
                  : null;

              return DrawerHeader(
                margin: EdgeInsets.zero,
                decoration: BoxDecoration(color: colorScheme.primary),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile avatar
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimary.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: colorScheme.onPrimary, width: 2),
                      ),
                      child: ClipOval(
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.person,
                                  color: colorScheme.onPrimary,
                                  size: 32,
                                ),
                              )
                            : state is GetProfileLoading
                                ? const CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white)
                                : Icon(Icons.person,
                                    color: colorScheme.onPrimary, size: 32),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (email.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              email,
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onPrimary.withOpacity(0.75),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.star_rounded,
                                  color: colorScheme.secondary, size: 15),
                              const SizedBox(width: 4),
                              Text(
                                '$rating Rating',
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onPrimary.withOpacity(0.85),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Menu Items
          ListTile(
            leading: Icon(Icons.home_outlined, color: colorScheme.primary),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.history, color: colorScheme.primary),
            title: const Text('My Trips'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/trip_history');
            },
          ),
          ListTile(
            leading: Icon(Icons.settings_outlined, color: colorScheme.primary),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),

          const Divider(),

          // Theme Selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme Mode',
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, currentMode) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _themeIcon(context, Icons.brightness_auto, "Auto",
                            ThemeMode.system, currentMode),
                        _themeIcon(context, Icons.light_mode, "Light",
                            ThemeMode.light, currentMode),
                        _themeIcon(context, Icons.dark_mode, "Dark",
                            ThemeMode.dark, currentMode),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.help_outline, color: AppColors.info),
            title: const Text('Help & Support'),
            onTap: () => Navigator.pop(context),
          ),
          const Spacer(),

          const Divider(),

          // Logout Button
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: Text(
              'Logout',
              style: textTheme.labelLarge?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to logout? All local cache will be cleared."),
                  actions: [
                    TextButton(
                      child: const Text("Cancel"),
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                    TextButton(
                      child: const Text("Logout", style: TextStyle(color: Colors.red)),
                      onPressed: () async {
                        Navigator.pop(dialogContext);
                        final storage = context.read<SecureStorageService>();
                        await storage.logout();
                        if (context.mounted) {
                          context.read<TripBloc>().add(LogoutReset());
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/login', (route) => false);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _themeIcon(BuildContext context, IconData icon, String label,
      ThemeMode mode, ThemeMode currentMode) {
    final isSelected = mode == currentMode;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () => context.read<ThemeCubit>().updateTheme(mode),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
