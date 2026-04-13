import 'package:flutter/material.dart';
import '../features/common/widgets/custom_bottom_navigation_bar.dart';
import '../features/common/screens/earnings_screen.dart';
import '../features/common/screens/placeholder_screens.dart';
import '../features/common/trip_history/trip_history_screen.dart';
import '../features/common/screens/ratings_screen.dart';
import '../features/common/screens/profile_screen.dart';

class MainWrapper extends StatefulWidget {
  final Widget child;
  
  const MainWrapper({Key? key, required this.child}) : super(key: key);

  // static access to toggle bottom bar visibility for demo purposes
  static final ValueNotifier<bool> isOnlineNotifier = ValueNotifier<bool>(true);

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: MainWrapper.isOnlineNotifier,
      builder: (context, isOnline, _) {
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: [
              widget.child, // Home (0)
              const EarningsScreen(), // Earnings (1)
              const RatingsScreen(), // Ratings (2)
              const TripHistoryScreen(), // History (3)
              const ProfileScreen(), // Profile (4)
            ],
          ),
          bottomNavigationBar: isOnline 
            ? CustomBottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              )
            : null,
        );
      },
    );
  }
}
