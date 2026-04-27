import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../common/widgets/app_drawer.dart';
import '../../../app/main_wrapper.dart';
import '../../common/widgets/modern_home_dashboard.dart';
import '../../common/widgets/custom_top_header_bar.dart';
import '../../common/widgets/offline_screen_body.dart';
import 'dart:async';

class SupportDriverDashboard extends StatefulWidget {
  const SupportDriverDashboard({super.key});

  @override
  State<SupportDriverDashboard> createState() => _SupportDriverDashboardState();
}

class _SupportDriverDashboardState extends State<SupportDriverDashboard> {
  bool _isOnline = MainWrapper.isOnlineNotifier.value;
  bool _showRequestPopup = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _popupTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MainWrapper.isOnlineNotifier.value = _isOnline;
      _startPopupTimer();
    });
  }

  void _startPopupTimer() {
    _popupTimer?.cancel();
    _popupTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isOnline) {
        setState(() => _showRequestPopup = true);
      }
    });
  }

  @override
  void dispose() {
    _popupTimer?.cancel();
    super.dispose();
  }

  void _toggleOnline(bool val) {
    setState(() {
      _isOnline = val;
      if (!val) _showRequestPopup = false;
    });
    MainWrapper.isOnlineNotifier.value = val;
    if (val) _startPopupTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.designForestGreen,
      drawer: const AppDrawer(),
      body: SafeArea(
        bottom: false,
        child: _isOnline
            ? ModernHomeDashboard(
                isOnline: _isOnline,
                onToggleOnline: _toggleOnline,
                onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
              )
            : Column(
                children: [
                  CustomTopHeaderBar(
                    isOnline: _isOnline,
                    onOnlineStatusChanged: _toggleOnline,
                    onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  Expanded(
                    child: OfflineScreenBody(
                      tripsCount: "15",
                      rating: "4.9",
                      onToggleOnline: () => _toggleOnline(true),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
