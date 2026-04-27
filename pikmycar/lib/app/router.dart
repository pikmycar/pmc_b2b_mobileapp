import 'package:flutter/material.dart';
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
import '../features/main_driver/settings/screens/settings_screen.dart';
import '../features/main_driver/settings/screens/profile_screen.dart';
import '../features/main_driver/settings/screens/documents_screen.dart';
import '../features/main_driver/settings/screens/bank_screen.dart';
import '../features/main_driver/settings/screens/withdraw_screen.dart';
import '../features/main_driver/settings/screens/support_screen.dart';
import '../features/main_driver/settings/screens/reset_pin_screen.dart';
import '../features/main_driver/settings/screens/notifications_screen.dart';

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
          builder: (_) => const MainWrapper(child: SupportDriverDashboard()),
        );
      case '/support_driver_inspection':
        return MaterialPageRoute(
          builder: (_) => const SupportDriverInspectionScreen(),
        );
      case '/support_driver_garage_delivery':
        return MaterialPageRoute(
          builder: (_) => const SupportDriverGarageDeliveryScreen(),
        );
      case '/support_driver_arrived':
        return MaterialPageRoute(
          builder: (_) => const DriverArrivedScreen(),
        );
      case '/support_driver_ride_to_customer':
        return MaterialPageRoute(
          builder: (_) => const RideToCustomerScreen(),
        );
      case '/support_driver_arrived_at_pickup':
        return MaterialPageRoute(
          builder: (_) => const ArrivedAtPickupScreen(),
        );
      case '/support_driver_handover':
        return MaterialPageRoute(
          builder: (_) => const HandoverScreen(),
        );
      case '/support_driver_drive_to_garage':
        return MaterialPageRoute(
          builder: (_) => const DriveToGarageScreen(),
        );
      case '/support_driver_arrived_at_garage':
        return MaterialPageRoute(
          builder: (_) => const ArrivedAtGarageScreen(),
        );
      case '/support_driver_garage_handover':
        return MaterialPageRoute(
          builder: (_) => const GarageHandoverScreen(),
        );
      case '/support_driver_ride_summary':
        return MaterialPageRoute(
          builder: (_) => const RideSummaryScreen(),
        );

      // MAIN DRIVER ROUTES
      case '/main_driver_dashboard':
        return MaterialPageRoute(
          builder: (_) => const MainWrapper(child: MainDriverDashboard()),
        );
      case '/driver_home':
        return MaterialPageRoute(
          builder: (_) => const MainWrapper(child: MainDriverDashboard()),
        );
      case '/main_driver_transport':
        return MaterialPageRoute(
          builder: (_) => const MainDriverTransportScreen(),
        );
      case '/navigate_to_pickup':
        return MaterialPageRoute(
          builder: (_) => const NavigateToPickupScreen(),
        );
      case '/pickup_reached':
        return MaterialPageRoute(
          builder: (_) => const PickupReachedScreen(),
        );
      case '/in_trip':
        return MaterialPageRoute(
          builder: (_) => const InTripScreen(),
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
      case '/main_driver_trip_completion':
      case '/trip_completed':
        return MaterialPageRoute(
          builder: (_) => const TripCompletionScreen(), // 🔥 RESTORED
        );
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for \${settings.name}'),
                ),
              ),
        );
    }
  }
}
