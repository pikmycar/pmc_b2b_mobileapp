import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../transport_trip/bloc/trip_bloc.dart';
import '../transport_trip/bloc/trip_event.dart';
import '../transport_trip/bloc/trip_state.dart';
import '../../../core/models/trip_models.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../common/widgets/app_drawer.dart';
import '../../../app/main_wrapper.dart';
import '../../common/widgets/modern_home_dashboard.dart';
import '../../common/widgets/custom_top_header_bar.dart';
import '../../common/widgets/offline_screen_body.dart';
import 'dart:async';

class MainDriverDashboard extends StatefulWidget {
  const MainDriverDashboard({super.key});

  @override
  State<MainDriverDashboard> createState() => _MainDriverDashboardState();
}

class _MainDriverDashboardState extends State<MainDriverDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Auto Go Online on login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<TripBloc>().state;
      if (state.status == TripStatus.accepted || 
          state.status == TripStatus.navigatingToPickup ||
          state.status == TripStatus.pickupReached ||
          state.status == TripStatus.inTrip) {
        Navigator.pushReplacementNamed(context, '/main_driver_transport');
      } else {
        context.read<TripBloc>().add(GoOnline());
      }
    });
  }

  void _toggleOnline(bool val) {
    if (val) {
      context.read<TripBloc>().add(GoOnline());
    } else {
      context.read<TripBloc>().add(GoOffline());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TripBloc, TripState>(
      listener: (context, state) {
        MainWrapper.isOnlineNotifier.value = state.status != TripStatus.offline;
        
        // 🔥 REDIRECT IF TRIP ACTIVE
        if (state.status == TripStatus.accepted || 
            state.status == TripStatus.navigatingToPickup ||
            state.status == TripStatus.pickupReached ||
            state.status == TripStatus.inTrip) {
          Navigator.pushReplacementNamed(context, '/main_driver_transport');
        }
      },
      builder: (context, state) {
        final isOnline = state.status != TripStatus.offline;
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          drawer: const AppDrawer(),
          body: SafeArea(
            bottom: false,
            child: isOnline
                ? ModernHomeDashboard(
                    isOnline: isOnline,
                    onToggleOnline: _toggleOnline,
                    onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                  )
                : Column(
                    children: [
                      CustomTopHeaderBar(
                        isOnline: isOnline,
                        onOnlineStatusChanged: _toggleOnline,
                        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                      ),
                      Expanded(
                        child: OfflineScreenBody(
                          tripsCount: "20",
                          rating: "4.8",
                          onToggleOnline: () => _toggleOnline(true),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
