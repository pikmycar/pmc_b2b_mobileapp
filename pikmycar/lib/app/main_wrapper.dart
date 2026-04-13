import 'package:flutter/material.dart';

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
          body: widget.child,
          bottomNavigationBar: isOnline 
            ? NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.account_balance_wallet_outlined),
                    selectedIcon: Icon(Icons.account_balance_wallet),
                    label: 'Earnings',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.star_outline),
                    selectedIcon: Icon(Icons.star),
                    label: 'Ratings',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.history_outlined),
                    selectedIcon: Icon(Icons.history),
                    label: 'History',
                  ),
                ],
              )
            : null,
        );
      },
    );
  }
}
