import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/common/widgets/custom_bottom_navigation_bar.dart';
import '../features/common/screens/earnings_screen.dart';
import '../features/common/screens/placeholder_screens.dart';
import '../features/common/trip_history/trip_history_screen.dart';
import '../features/common/screens/ratings_screen.dart';
import '../features/common/screens/profile_screen.dart';
import '../features/support_driver/screens/assigned_trips_screen.dart';
import '../core/models/user_role.dart';
import '../core/storage/secure_storage_service.dart';

class MainWrapper extends StatefulWidget {
  final Widget child;
  
  const MainWrapper({super.key, required this.child});

  // static access to toggle bottom bar visibility for demo purposes
  static final ValueNotifier<bool> isOnlineNotifier = ValueNotifier<bool>(true);

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  UserRole _role = UserRole.mainDriver;
  bool _isLoadingRole = true;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    try {
      final storage = context.read<SecureStorageService>();
      final roleStr = await storage.getUserRole();
      if (mounted) {
        setState(() {
          _role = (roleStr == "support_driver" ||
                  roleStr == UserRole.supportDriver.toString())
              ? UserRole.supportDriver
              : UserRole.mainDriver;
          _isLoadingRole = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRole = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingRole) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          widget.child, // Home (0)
          const EarningsScreen(), // Earnings (1)
          _role == UserRole.supportDriver
              ? const AssignedTripsScreen() // Assigned Trips (2)
              : const RatingsScreen(), // Ratings (2)
          const TripHistoryScreen(), // History (3)
          const ProfileScreen(), // Profile (4)
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        userRole: _role,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
