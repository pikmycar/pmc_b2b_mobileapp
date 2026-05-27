import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/bloc/commonScreen/driver_location/trip_bloc.dart';
import '../../../auth/bloc/commonScreen/driver_location/trip_event.dart';
import '../../../auth/bloc/commonScreen/driver_location/trip_state.dart';
import '../../../../core/models/trip_models.dart';
import '../../../auth/data/datasource/driver_api.dart';

class MainDriverTicketDetailScreen extends StatefulWidget {
  final String? requestId;

  const MainDriverTicketDetailScreen({
    super.key,
    this.requestId,
  });

  @override
  State<MainDriverTicketDetailScreen> createState() => _MainDriverTicketDetailScreenState();
}

class _MainDriverTicketDetailScreenState extends State<MainDriverTicketDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _ticketDetails = {};

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final tripBloc = context.read<TripBloc>();
    final reqId = widget.requestId ?? tripBloc.state.activeTrip?.requestId;

    if (reqId == null || reqId.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Task notification error"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final driverApi = context.read<DriverApi>();
      final response = await driverApi.getMainDriverTicketDetails(reqId);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        setState(() {
          _ticketDetails = (data is Map && data.containsKey('data')) ? data['data'] : data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Task notification error"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Task notification error",
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "N/A";
    try {
      final dateTime = DateTime.parse(dateStr).toLocal();
      final hour = dateTime.hour;
      final minute = dateTime.minute;
      final ampm = hour >= 12 ? 'PM' : 'AM';
      final formattedHour = hour % 12 == 0 ? 12 : hour % 12;
      final formattedMinute = minute.toString().padLeft(2, '0');
      return "$formattedHour:$formattedMinute $ampm";
    } catch (_) {
      if (dateStr.length >= 16) {
        return dateStr.substring(11, 16);
      }
      return dateStr;
    }
  }

  Future<bool> _onBackPressed(BuildContext context) async {
    // Since trip is already accepted, they can't simply back out without completing.
    // They can just view the details and start navigation.
    Navigator.pushNamedAndRemoveUntil(context, '/main_driver_dashboard', (route) => false);
    return true;
  }

  void _handleStartNavigation() {
    context.read<TripBloc>().add(NextTripStep());
    Navigator.pushReplacementNamed(context, '/main_driver_transport');
  }

  @override
  @override
  Widget build(BuildContext context) {
    return BlocListener<TripBloc, TripState>(
      listener: (context, state) {
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
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/driver_home',
                      (route) => false,
                    );
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      },
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }



    // Extraction with robust fallback logic
    final ticketNum = _ticketDetails['ticketUuid'] ?? _ticketDetails['ticketId'] ?? 'N/A';
    final customer = _ticketDetails['customer'] ?? {};
    final customerName = customer['name'] ?? 'N/A';
    final customerPhone = customer['contact'] ?? 'N/A';
    final customerEmail = customer['email'] ?? 'N/A';

    final pickup = _ticketDetails['pickup'] ?? {};
    final drop = _ticketDetails['drop'] ?? {};
    final pickupLoc = pickup['location'] ?? 'N/A';
    final dropLoc = drop['location'] ?? 'N/A';
    
    final priorityStr = (_ticketDetails['priority'] ?? 'HIGH').toString().toUpperCase();
    final statusStr = _ticketDetails['status'] ?? 'Accepted';
    
    final vehicle = _ticketDetails['vehicle'] ?? {};
    final vehicleName = vehicle['name'] ?? 'Premium Vehicle';
    final vehiclePlate = vehicle['number'] ?? 'N/A';

    final drivers = _ticketDetails['drivers'] ?? {};
    final supportDriver = drivers['supportDriver'] ?? {};
    final supportDriverName = supportDriver['name'] ?? 'N/A';
    final supportDriverPhone = (supportDriver['contact'] != null) ? (supportDriver['contact']['phone'] ?? 'N/A') : 'N/A';
    final supportDriverRating = (supportDriver['rating'] != null) ? supportDriver['rating'].toString() : '4.8';
    
    final supportDriverVehicle = supportDriver['vehicle'] ?? {};
    final sdVehicleModel = supportDriverVehicle['model'] ?? 'N/A';
    final sdVehiclePlate = supportDriverVehicle['plateNumber'] ?? 'N/A';
    
    final supportDriverVendor = supportDriver['vendor'] ?? {};
    final sdVendorName = supportDriverVendor['name'] ?? 'N/A';

    final createdAt = _ticketDetails['createdAt'] != null 
        ? _formatTime(_ticketDetails['createdAt']) 
        : '10:30 AM';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _onBackPressed(context);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _onBackPressed(context),
          ),
          title: Text(
            "Ticket #$ticketNum",
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildStatusBadge(
                    context: context,
                    icon: Icons.check,
                    label: statusStr,
                    bgColor: AppColors.success,
                    textColor: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "$priorityStr priority",
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // SUPPORT DRIVER INFO
              _buildSectionHeader(context, "SUPPORT DRIVER DETAILS"),
              const SizedBox(height: 12),
              _buildInfoCard(
                context: context,
                bgColor: colorScheme.primary.withOpacity(0.03),
                child: Column(
                  children: [
                    _buildDetailRow(
                      context: context,
                      icon: Icons.person,
                      iconColor: colorScheme.primary,
                      title: supportDriverName,
                      subtitle: "Contact: $supportDriverPhone\nRating: $supportDriverRating ⭐",
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      context: context,
                      icon: Icons.local_taxi,
                      iconColor: colorScheme.secondary,
                      title: "Vehicle: $sdVehicleModel",
                      subtitle: "Plate Number: $sdVehiclePlate\nVendor: $sdVendorName",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // CUSTOMER INFO
              _buildSectionHeader(context, "CUSTOMER INFO"),
              const SizedBox(height: 12),
              _buildInfoCard(
                context: context,
                child: Column(
                  children: [
                    _buildDetailRow(
                      context: context,
                      icon: Icons.person,
                      iconColor: colorScheme.primary,
                      title: customerName,
                      subtitle: customerPhone,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      context: context,
                      icon: Icons.email,
                      iconColor: colorScheme.secondary,
                      title: customerEmail,
                      subtitle: "",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // PICKUP DETAILS
              _buildSectionHeader(context, "PICKUP DETAILS"),
              const SizedBox(height: 12),
              _buildInfoCard(
                context: context,
                child: Column(
                  children: [
                    _buildDetailRow(
                      context: context,
                      icon: Icons.location_on,
                      iconColor: AppColors.error,
                      title: pickupLoc,
                      subtitle: "Pickup · $createdAt · $customerName",
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(left: 20),
                        height: 30,
                        width: 2,
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: colorScheme.outlineVariant,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context: context,
                      icon: Icons.flag,
                      iconColor: colorScheme.onSurface.withOpacity(0.6),
                      title: dropLoc,
                      subtitle: "Drop-off Destination",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // CAR DETAILS
              _buildSectionHeader(context, "CUSTOMER CAR DETAILS"),
              const SizedBox(height: 12),
              _buildInfoCard(
                context: context,
                bgColor: colorScheme.secondary.withOpacity(0.05),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicleName,
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Plate: $vehiclePlate",
                          style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
                        ),
                      ],
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colorScheme.onSurface, width: 1.5),
                        ),
                        child: Text(
                          vehiclePlate,
                          style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -10),
              )
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleStartNavigation,
              child: const Text("Start Navigation"),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Text(
      title,
      style: textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface.withOpacity(0.5),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildInfoCard({required BuildContext context, required Widget child, Color? bgColor}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.05),
            blurRadius: 10,
            spreadRadius: isDark ? 0.5 : 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildDetailRow({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    height: 1.4,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
