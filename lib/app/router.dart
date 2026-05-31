import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/models/user_role.dart';
import '../core/storage/secure_storage_service.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/pin_login_screen.dart';
import '../features/auth/screens/thank_you_screen.dart';
import '../features/auth/screens/create_pin_screen.dart';
import '../features/common/widgets/splash_screen.dart';
import '../features/common/trip_history/trip_history_screen.dart';
import 'main_wrapper.dart';
import '../features/support_driver/dashboard/support_driver_dashboard.dart';
import '../features/support_driver/inspection/inspection_screen.dart';
import '../features/support_driver/handover/handover_screen.dart';
import '../features/support_driver/screens/drive_to_garage_screen.dart';
import '../features/support_driver/screens/arrived_at_garage_screen.dart';
import '../features/support_driver/screens/garage_handover_screen.dart';
import '../features/support_driver/screens/ride_summary_screen.dart';
import '../features/support_driver/garage_delivery/garage_delivery_screen.dart';
import '../features/support_driver/screens/driver_arrived_screen.dart';
import '../features/support_driver/screens/ride_to_customer_screen.dart';
import '../features/support_driver/screens/arrived_at_pickup_screen.dart';
import '../features/main_driver/dashboard/main_driver_dashboard.dart';
import '../features/main_driver/transport_trip/transport_trip_screen.dart';
import '../features/main_driver/transport_trip/trip_completion_screen.dart';
import '../features/main_driver/home/driver_home_screen.dart';
import '../features/main_driver/transport_trip/screens/navigate_to_pickup_screen.dart';
import '../features/main_driver/transport_trip/screens/pickup_reached_screen.dart';
import '../features/main_driver/transport_trip/screens/in_trip_screen.dart';
import '../features/main_driver/transport_trip/screens/main_driver_ticket_detail_screen.dart';
import '../features/main_driver/settings/screens/settings_screen.dart';
import '../features/main_driver/settings/screens/profile_details_screen.dart';
import '../features/main_driver/settings/screens/documents_screen.dart';
import '../features/main_driver/settings/screens/bank_screen.dart';
import '../features/main_driver/settings/screens/withdraw_screen.dart';
import '../features/main_driver/settings/screens/support_screen.dart';
import '../features/main_driver/settings/screens/reset_pin_screen.dart';
import '../features/main_driver/settings/screens/notifications_screen.dart';
import '../features/common/screens/ratings_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    print("DEBUG: [Router] Navigating to: ${settings.name}");
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/thank_you':
        return MaterialPageRoute(builder: (_) => const ThankYouScreen());
      case '/create_pin':
        return MaterialPageRoute(builder: (_) => const CreatePinScreen());

      case '/pin_login':
        return MaterialPageRoute(builder: (_) => const PinLoginScreen());
      case '/trip_history':
        return MaterialPageRoute(builder: (_) => const TripHistoryScreen());
      // SUPPORT DRIVER ROUTES
      case '/support_driver_dashboard':
        return MaterialPageRoute(
          builder: (_) => const RoleProtectedRoute(
            allowedRoles: [UserRole.supportDriver],
            child: MainWrapper(child: SupportDriverDashboard()),
          ),
        );
      case '/support_driver_inspection':
        return MaterialPageRoute(
          builder: (_) => const RoleProtectedRoute(
            allowedRoles: [UserRole.supportDriver],
            child: SupportDriverInspectionScreen(),
          ),
        );
      case '/support_driver_garage_delivery':
        return MaterialPageRoute(
          builder: (_) => const RoleProtectedRoute(
            allowedRoles: [UserRole.supportDriver],
            child: SupportDriverGarageDeliveryScreen(),
          ),
        );
      case '/support_driver_arrived':
        return MaterialPageRoute(
          builder: (_) => const RoleProtectedRoute(
            allowedRoles: [UserRole.supportDriver],
            child: DriverArrivedScreen(),
          ),
        );
      case '/support_driver_ride_to_customer':
        return MaterialPageRoute(
          builder: (_) => const RoleProtectedRoute(
            allowedRoles: [UserRole.supportDriver],
            child: RideToCustomerScreen(),
          ),
        );
      case '/support_driver_arrived_at_pickup':
        return MaterialPageRoute(
          builder: (_) => const RoleProtectedRoute(
            allowedRoles: [UserRole.supportDriver],
            child: ArrivedAtPickupScreen(),
          ),
        );
      case '/support_driver_handover':
        return MaterialPageRoute(
          builder: (_) => const RoleProtectedRoute(
            allowedRoles: [UserRole.supportDriver],
            child: HandoverScreen(),
          ),
        );
      case '/support_driver_drive_to_garage':
        return MaterialPageRoute(
          builder: (_) => const RoleProtectedRoute(
            allowedRoles: [UserRole.supportDriver],
            child: DriveToGarageScreen(),
          ),
        );
      case '/support_driver_arrived_at_garage':
        return MaterialPageRoute(
          builder: (_) => const RoleProtectedRoute(
            allowedRoles: [UserRole.supportDriver],
            child: ArrivedAtGarageScreen(),
          ),
        );
      case '/support_driver_garage_handover':
        return MaterialPageRoute(
          builder: (_) => const RoleProtectedRoute(
            allowedRoles: [UserRole.supportDriver],
            child: GarageHandoverScreen(),
          ),
        );
      case '/support_driver_ride_summary':
        return MaterialPageRoute(
          builder: (_) => const RoleProtectedRoute(
            allowedRoles: [UserRole.supportDriver],
            child: RideSummaryScreen(),
          ),
        );

      // MAIN DRIVER ROUTES
      case '/main_driver_dashboard':
        return MaterialPageRoute(
          builder: (_) => const RoleProtectedRoute(
            allowedRoles: [UserRole.mainDriver],
            child: MainWrapper(child: MainDriverDashboard()),
          ),
        );
      case '/driver_home':
        return MaterialPageRoute(
          builder: (_) => const RoleProtectedRoute(
            allowedRoles: [UserRole.mainDriver],
            child: MainWrapper(child: MainDriverDashboard()),
          ),
        );
      case '/main_driver_transport':
        return MaterialPageRoute(
          builder: (_) => const RoleProtectedRoute(
            allowedRoles: [UserRole.mainDriver],
            child: MainDriverTransportScreen(),
          ),
        );
      case '/main_driver_ticket_details':
        return MaterialPageRoute(
          builder: (context) {
            final args = settings.arguments as Map<String, dynamic>?;
            final reqId = args?['requestId'] as String?;
            return RoleProtectedRoute(
              allowedRoles: const [UserRole.mainDriver],
              child: MainDriverTicketDetailScreen(requestId: reqId),
            );
          },
        );
      case '/navigate_to_pickup':
        return MaterialPageRoute(
          builder: (_) => const RoleProtectedRoute(
            allowedRoles: [UserRole.mainDriver],
            child: NavigateToPickupScreen(),
          ),
        );
      case '/pickup_reached':
        return MaterialPageRoute(
          builder: (_) => const RoleProtectedRoute(
            allowedRoles: [UserRole.mainDriver],
            child: PickupReachedScreen(),
          ),
        );
      case '/in_trip':
        return MaterialPageRoute(
          builder: (_) => const RoleProtectedRoute(
            allowedRoles: [UserRole.mainDriver],
            child: InTripScreen(),
          ),
        );
      case '/settings':
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
        );
      case '/profile_details':
        return MaterialPageRoute(
          builder: (_) => const ProfileDetailsScreen(),
        );
      case '/documents':
        return MaterialPageRoute(
          builder: (_) => const DocumentsScreen(),
        );
      case '/bank_account':
        return MaterialPageRoute(
          builder: (_) => const BankAccountScreen(),
        );
      case '/withdraw':
        return MaterialPageRoute(
          builder: (_) => const WithdrawScreen(),
        );
      case '/support':
        return MaterialPageRoute(
          builder: (_) => const SupportScreen(),
        );
      case '/reset_pin':
        return MaterialPageRoute(
          builder: (_) => const ResetPinScreen(),
        );
      case '/notifications':
        return MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
        );
      case '/ratings':
        return MaterialPageRoute(
          builder: (_) => const RatingsScreen(),
        );
      case '/main_driver_trip_completion':
      case '/trip_completed':
        return MaterialPageRoute(
          builder: (_) => const RoleProtectedRoute(
            allowedRoles: [UserRole.mainDriver],
            child: TripCompletionScreen(),
          ),
        );
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}

class RoleProtectedRoute extends StatefulWidget {
  final Widget child;
  final List<UserRole> allowedRoles;

  const RoleProtectedRoute({
    super.key,
    required this.child,
    required this.allowedRoles,
  });

  @override
  State<RoleProtectedRoute> createState() => _RoleProtectedRouteState();
}

class _RoleProtectedRouteState extends State<RoleProtectedRoute> {
  bool _isLoading = true;
  bool _isAuthorized = false;

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    try {
      final storage = context.read<SecureStorageService>();
      final roleStr = await storage.getUserRole();
      final currentRole = (roleStr == "support_driver" ||
              roleStr == UserRole.supportDriver.toString())
          ? UserRole.supportDriver
          : UserRole.mainDriver;

      if (mounted) {
        setState(() {
          _isAuthorized = widget.allowedRoles.contains(currentRole);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAuthorized = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isAuthorized) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Access Denied"),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.gpp_bad_outlined,
                    size: 80,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Restricted Area",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "You do not have the required permissions to access this screen. Please verify your role and try again.",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.errorContainer,
                        foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "Go Back",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}
