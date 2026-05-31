import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../auth/data/models/cust_requests_trip.dart';
import '../../auth/data/models/cust_request_trip_by_id.dart' as detail_model;
import '../../auth/bloc/commonScreen/customer_request_trip_by_id/cust_request_trip_by_id_bloc.dart';
import '../../auth/bloc/commonScreen/customer_request_trip_by_id/cust_request_trip_by_id_event.dart';
import '../../auth/bloc/commonScreen/customer_request_trip_by_id/cust_request_trip_by_id_state.dart';
import '../../auth/bloc/commonScreen/support_pickme_request/support_pickme_request_bloc.dart';
import '../../auth/bloc/commonScreen/support_pickme_request/support_pickme_request_event.dart';
import '../../auth/bloc/commonScreen/support_pickme_request/support_pickme_request_state.dart';
import 'package:geolocator/geolocator.dart';
import '../screens/searching_main_driver_screen.dart';

class TicketDetailScreen extends StatefulWidget {
  final TripData? ticket;
  final String ticketId;

  const TicketDetailScreen({
    super.key,
    this.ticket,
    this.ticketId = "PKM-2847",
  });

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  bool _isSendingRequest = false;

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
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Trip?"),
        content: const Text("Are you sure you want to cancel this trip?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (result == true) {
      if (!mounted) return true;
      Navigator.pushNamedAndRemoveUntil(context, '/support_driver_dashboard', (route) => false);
      return true;
    }
    return false;
  }

  Future<void> _handlePickMe(BuildContext context, detail_model.TripData? tripData) async {
    final storage = context.read<SecureStorageService>();
    final supportDriverId = await storage.getDriverId() ?? tripData?.drivers?.raw?['supportDriver']?['id']?.toString() ?? "7d403d9e-354b-4645-a68a-87cab77c6b50";

    if (!mounted) return;

    double pickupLat = tripData?.pickup?.latitude ?? 105222.2223;
    double pickupLng = tripData?.pickup?.longitude ?? 12555.666;
    final String pickupAddress = tripData?.pickup?.googleMapsAddress ?? widget.ticket?.pickupLocation ?? "Chennai";

    try {
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (isServiceEnabled) {
        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          // Attempt to retrieve last known cached position first for instant speed
          Position? position = await Geolocator.getLastKnownPosition();
          
          // If no cached position is found, poll the GPS hardware with medium accuracy
          position ??= await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 4),
          );
          
          pickupLat = position.latitude;
          pickupLng = position.longitude;
          debugPrint("📍 Dynamic GPS Location Resolved: $pickupLat, $pickupLng");
        }
      }
    } catch (e) {
      debugPrint("⚠️ Geolocator Error, using fallback coordinates: $e");
    }

    context.read<SupportPickMeRequestBloc>().add(
      FetchSupportPickMeRequestEvent(
        ticketId: tripData?.ticketId ?? widget.ticket?.ticketId ?? widget.ticketId,
        supportDriverId: supportDriverId,
        pickupLocation: pickupAddress,
        pickupLatitude: pickupLat,
        pickupLongitude: pickupLng,
        pickupGoogleMapsAddress: pickupAddress,
        dropLocation: tripData?.pickup?.location ?? widget.ticket?.pickupLocation ?? "Chennai,tata",
        dropLatitude: tripData?.pickup?.latitude ?? -90.0,
        dropLongitude: tripData?.pickup?.longitude ?? -180.0,
        dropGoogleMapsAddress: tripData?.pickup?.googleMapsAddress ?? widget.ticket?.pickupLocation ?? "Chennai,tata",
        notes: "Support driver requesting Main Driver pickup",
        sameVendorOnly: false,
        targetMainDriverId: "6fd4d4a8-0a6f-4979-991f-785f4da3625b",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CustRequestTripByIdBloc(
            repository: CustomerRequestTripByIdRepository(
              apiClient: context.read<ApiClient>(),
            ),
          )..add(
              FetchCustRequestTripByIdEvent(
                tripId: widget.ticketId.isNotEmpty && widget.ticketId != "PKM-2847"
                    ? widget.ticketId
                    : (widget.ticket?.ticketId ?? widget.ticketId),
              ),
            ),
        ),
        BlocProvider(
          create: (context) => SupportPickMeRequestBloc(
            repository: SupportPickMeRepository(
              apiClient: context.read<ApiClient>(),
            ),
          ),
        ),
      ],
      child: BlocListener<SupportPickMeRequestBloc, SupportPickMeRequestState>(
        listener: (context, state) {
          final resolvedTicketId = widget.ticketId.isNotEmpty && widget.ticketId != "PKM-2847"
              ? widget.ticketId
              : (widget.ticket?.ticketId ?? widget.ticketId);

          if (state is SupportPickMeRequestLoading) {
            setState(() => _isSendingRequest = true);
          } else if (state is SupportPickMeRequestSuccess) {
            setState(() => _isSendingRequest = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.requestDetails.message ?? "Request sent successfully!"),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SearchingMainDriverScreen(ticketId: resolvedTicketId),
              ),
            );
          } else if (state is SupportPickMeRequestError) {
            setState(() => _isSendingRequest = false);
            if (state.message.startsWith("409:")) {
              final cleanMsg = state.message.replaceFirst("409:", "").trim();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(cleanMsg.isNotEmpty ? cleanMsg : "Pickup request already active. Resuming search..."),
                  backgroundColor: AppColors.warning,
                ),
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SearchingMainDriverScreen(ticketId: resolvedTicketId),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Error: ${state.message}"),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        },
        child: BlocBuilder<CustRequestTripByIdBloc, CustRequestTripByIdState>(
          builder: (context, state) {
          if (state is CustRequestTripByIdLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (state is CustRequestTripByIdError) {
            return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: true,
                title: const Text("Error Loading Details"),
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.error,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Failed to load details",
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(200, 48),
                        ),
                        onPressed: () {
                          context.read<CustRequestTripByIdBloc>().add(
                                FetchCustRequestTripByIdEvent(
                                  tripId: widget.ticketId.isNotEmpty && widget.ticketId != "PKM-2847"
                                      ? widget.ticketId
                                      : (widget.ticket?.ticketId ?? widget.ticketId),
                                ),
                              );
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          detail_model.TripData? tripData;
          if (state is CustRequestTripByIdSuccess) {
            tripData = state.tripDetails.data;
          }

          final ticket = widget.ticket;
          final ticketNum = tripData?.ticketNumber ?? tripData?.ticketId ?? ticket?.ticketNumber ?? ticket?.ticketId ?? widget.ticketId;
          final customerName = tripData?.customer?.name ?? ticket?.customerName ?? "Ahmed Al-Rashid";
          final customerPhone = tripData?.customer?.contact ?? ticket?.customerPhone ?? "+971 50 123 4567";
          final customerEmail = tripData?.customer?.email ?? "ahmed@example.ae";
          final pickupLoc = tripData?.pickup?.location ?? ticket?.pickupLocation ?? "Dubai Marina, Tower B";
          final dropLoc = tripData?.drop?.location ?? ticket?.dropLocation ?? "Al Quoz Auto Service";
          final priorityStr = (tripData?.priority ?? ticket?.priority ?? "HIGH").toUpperCase();
          final statusStr = tripData?.status ?? ticket?.status ?? "Accepted";
          final vehiclePlate = tripData?.vehicle?.number ?? ticket?.vehiclePlate ?? "M72528";
          final vehicleName = tripData?.vehicle?.name ?? ticket?.vehicle ?? (ticket != null ? "Premium Vehicle" : "BMW 3 Series · Blue");
          final vehicleSub = tripData != null ? "Plate: $vehiclePlate" : (ticket != null ? "Plate: $vehiclePlate" : "2022 · Plate: M72528");
          final createdAt = tripData?.createdAt != null 
              ? _formatTime(tripData!.createdAt) 
              : (ticket?.assignedAt != null ? _formatTime(ticket!.assignedAt) : "10:30 AM");


          return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _onBackPressed(context);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            "Ticket #$ticketNum",
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          centerTitle: false,
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
                      subtitle: "Assigned · $createdAt · $customerName",
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
                      icon: Icons.factory_outlined,
                      iconColor: colorScheme.onSurface.withOpacity(0.6),
                      title: dropLoc,
                      subtitle: "Preferred delivery: Today",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, "CAR DETAILS"),
              const SizedBox(height: 12),
              _buildInfoCard(
                context: context,
                bgColor: colorScheme.primary.withOpacity(0.05),
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
                          vehicleSub,
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
              const SizedBox(height: 24),
              _buildSectionHeader(context, "SERVICE OPTIONS"),
              const SizedBox(height: 12),
              _buildInfoCard(
                context: context,
                bgColor: colorScheme.secondary.withOpacity(0.05),
                child: Column(
                  children: [
                    _buildDetailRow(
                      context: context,
                      icon: Icons.build_outlined,
                      iconColor: colorScheme.onSurface.withOpacity(0.4),
                      title: "Full Service",
                      subtitle: "Oil change, filters, inspection",
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      context: context,
                      icon: Icons.money,
                      iconColor: AppColors.warning,
                      title: "Pricing: AED 280",
                      subtitle: "Peak-time + High priority",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Notes: Please handle with care – premium vehicle",
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.5),
                  fontStyle: FontStyle.italic,
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
              onPressed: _isSendingRequest ? null : () => _handlePickMe(context, tripData),
              child: _isSendingRequest
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text("Request sending..."),
                      ],
                    )
                  : const Text("Pick Me"),
            ),
          ),
        ),
      ),
    );
        },
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
