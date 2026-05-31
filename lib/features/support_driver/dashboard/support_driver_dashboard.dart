import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../common/widgets/app_drawer.dart';
import '../../../app/main_wrapper.dart';
import '../../common/widgets/modern_home_dashboard.dart';
import '../../common/widgets/custom_top_header_bar.dart';
import '../../common/widgets/offline_screen_body.dart';
import 'dart:async';

// 🔥 ADD THESE IMPORTS
import '../../auth/bloc/commonScreen/driver_location/trip_bloc.dart';
import '../../auth/bloc/commonScreen/driver_location/trip_event.dart';
import '../../auth/bloc/commonScreen/driver_location/trip_state.dart';
import '../../../core/models/trip_models.dart';

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
      // Support driver is always online by default. Trigger GoOnline immediately.
      context.read<TripBloc>().add(GoOnline());
      _isOnline = true;
      MainWrapper.isOnlineNotifier.value = true;
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
    // Toggle is disabled for Support Driver role
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TripBloc, TripState>(
      listener: (context, state) {
        // Keep Support Driver always online
        _isOnline = true;
        MainWrapper.isOnlineNotifier.value = true;

        if (state.error != null && state.error!.isNotEmpty) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.designForestGreen,
        drawer: const AppDrawer(),
        body: SafeArea(
          bottom: false,
          child: ModernHomeDashboard(
            isOnline: true,
            onToggleOnline: _toggleOnline,
            onMenuTap: () =>
                _scaffoldKey.currentState?.openDrawer(),
          ),
        ),
      ),
    );
  }
}