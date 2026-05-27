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
import '../widgets/main_driver_request_popup.dart';

class MainDriverDashboard extends StatefulWidget {
  const MainDriverDashboard({super.key});

  @override
  State<MainDriverDashboard> createState() => _MainDriverDashboardState();
}

class _MainDriverDashboardState extends State<MainDriverDashboard> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isPopupOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Only redirect if a trip is already active (e.g. app restart mid-trip)
    // Driver stays OFFLINE by default — they must manually toggle to go online
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tripBloc = context.read<TripBloc>();
      final state = tripBloc.state;
      if (state.status == TripStatus.accepted) {
        Navigator.pushReplacementNamed(
          context,
          '/main_driver_ticket_details',
          arguments: {'requestId': state.activeTrip?.requestId},
        );
      } else if (state.status == TripStatus.navigatingToPickup ||
          state.status == TripStatus.pickupReached ||
          state.status == TripStatus.inTrip ||
          state.status == TripStatus.support_driver_pickup ||
          state.status == TripStatus.support_driver_drop) {
        Navigator.pushReplacementNamed(context, '/main_driver_transport');
      } else if (state.status == TripStatus.cancelled) {
        tripBloc.add(ResetToSearching());
      } else if (state.status == TripStatus.searching) {
        tripBloc.add(FetchPendingRequests());
      }
      // ✅ No auto-online: driver decides when to go online
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final tripBloc = context.read<TripBloc>();
      if (tripBloc.state.status == TripStatus.searching ||
          tripBloc.state.status == TripStatus.requestReceived) {
        tripBloc.add(FetchPendingRequests());
      }
    }
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

        print("========== UI LISTENER ==========");
        print("CURRENT STATUS => ${state.status}");
        print("ACTIVE TRIP => ${state.activeTrip?.requestId}");
        print("================================");

        if (state.status == TripStatus.requestReceived &&
            state.activeTrip != null) {
          if (!_isPopupOpen) {
            print("========== POPUP CHECK ==========");
            print("STATUS => ${state.status}");
            print("ACTIVE TRIP => ${state.activeTrip}");
            print("SHOWING POPUP");
            _isPopupOpen = true;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => MainDriverRequestPopup(
                trip: state.activeTrip!,
              ),
            ).then((_) {
              _isPopupOpen = false;
            });
          }
        } else {
          if (_isPopupOpen) {
            Navigator.of(context).pop();
            _isPopupOpen = false;
          }
        }

        // 🔥 REDIRECT IF TRIP ACTIVE
        if (state.status == TripStatus.cancelled) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text("Trip Cancelled"),
              content: const Text("This trip has been cancelled."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.read<TripBloc>().add(ResetToSearching());
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        } else if (state.status == TripStatus.accepted) {
          Navigator.pushReplacementNamed(
            context,
            '/main_driver_ticket_details',
            arguments: {'requestId': state.activeTrip?.requestId},
          );
        } else if (state.status == TripStatus.navigatingToPickup ||
            state.status == TripStatus.pickupReached ||
            state.status == TripStatus.inTrip ||
            state.status == TripStatus.support_driver_pickup ||
            state.status == TripStatus.support_driver_drop) {
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
                child: Stack(
                  children: [
                    ModernHomeDashboard(
                      isOnline: isOnline,
                      onToggleOnline: _toggleOnline,
                      onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    AnimatedOpacity(
                      opacity: isOnline ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: IgnorePointer(
                        ignoring: isOnline,
                        child: Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: Column(
                            children: [
                              CustomTopHeaderBar(
                                isOnline: isOnline,
                                onOnlineStatusChanged: _toggleOnline,
                                onMenuTap: () =>
                                    _scaffoldKey.currentState?.openDrawer(),
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
