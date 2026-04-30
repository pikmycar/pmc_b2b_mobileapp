import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../auth/bloc/commonScreen/driver_location/trip_bloc.dart';
import '../../auth/bloc/commonScreen/driver_location/trip_event.dart';
import '../../auth/bloc/commonScreen/driver_location/trip_state.dart';
import '../../../core/models/trip_models.dart';
import '../../common/widgets/app_drawer.dart';
import '../../../app/main_wrapper.dart';
import '../../common/widgets/modern_home_dashboard.dart';
import '../../common/widgets/custom_top_header_bar.dart';
import '../../common/widgets/offline_screen_body.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
        _toggleOnline(true);
      }
    });
  }

  Future<void> _toggleOnline(bool val) async {
    if (val) {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        showDialog(
          context: context, 
          builder: (_) => AlertDialog(
            title: const Text("Location Service OFF"),
            content: const Text("Location service is OFF. Please enable GPS to go online."),
            actions: [
              TextButton(child: const Text("Cancel"), onPressed: () => Navigator.pop(context)),
              TextButton(child: const Text("Open Settings"), onPressed: () {
                 Geolocator.openLocationSettings();
                 Navigator.pop(context);
              }),
            ]
          )
        );
        return;
      }
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        showDialog(
          context: context, 
          builder: (_) => AlertDialog(
            title: const Text("Permission Denied"),
            content: const Text("Location permission permanently denied. Please enable it from settings."),
            actions: [
              TextButton(child: const Text("Cancel"), onPressed: () => Navigator.pop(context)),
              TextButton(child: const Text("Open App Settings"), onPressed: () {
                 Geolocator.openAppSettings();
                 Navigator.pop(context);
              }),
            ]
          )
        );
        return;
      }

      if (mounted) {
        context.read<TripBloc>().add(GoOnline());
      }
    } else {
      context.read<TripBloc>().add(GoOffline());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TripBloc, TripState>(
      listener: (context, state) {
        MainWrapper.isOnlineNotifier.value = state.status != TripStatus.offline;
        
        if (state.error != null && state.error!.isNotEmpty) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
        }

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
          body: Stack(
            children: [
              SafeArea(
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
              if (state.isLoading)
                Container(
                  color: Colors.black45,
                  child: Center(
                    child: SpinKitCircle(
                      color: Theme.of(context).colorScheme.primary,
                      size: 50.0,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
