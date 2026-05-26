import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/bloc/commonScreen/customer_requests_trip/cust_requests_trip_bloc.dart';
import '../../auth/bloc/commonScreen/customer_requests_trip/cust_requests_trip_event.dart';
import '../../auth/bloc/commonScreen/customer_requests_trip/cust_requests_trip_state.dart';
import '../../auth/data/models/cust_requests_trip.dart';
import '../../../../core/network/api_client.dart';
import 'ticket_detail_screen.dart';

class AssignedTripsScreen extends StatelessWidget {
  const AssignedTripsScreen({super.key});

  /// Custom lightweight date formatter to convert ISO string to time with zero package dependencies
  String _formatTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "N/A";
    try {
      // Expects ISO String: "2026-05-26T14:36:10.000Z"
      final dateTime = DateTime.parse(dateStr).toLocal();
      final hour = dateTime.hour;
      final minute = dateTime.minute;
      final ampm = hour >= 12 ? 'PM' : 'AM';
      final formattedHour = hour % 12 == 0 ? 12 : hour % 12;
      final formattedMinute = minute.toString().padLeft(2, '0');
      return "$formattedHour:$formattedMinute $ampm";
    } catch (_) {
      // Substring fallback
      if (dateStr.length >= 16) {
        return dateStr.substring(11, 16);
      }
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return BlocProvider(
      create: (context) => CustRequestsTripBloc(
        repository: CustomerRequestsTripRepository(
          apiClient: context.read<ApiClient>(),
        ),
      )..add(const FetchCustRequestsTripEvent()),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            "Assigned Trips",
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          centerTitle: false,
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () {
                  context.read<CustRequestsTripBloc>().add(
                    const FetchCustRequestsTripEvent(),
                  );
                },
              ),
            ),
          ],
        ),
        body: BlocBuilder<CustRequestsTripBloc, CustRequestsTripState>(
          builder: (context, state) {
            if (state is CustRequestsTripLoading ||
                state is CustRequestsTripInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CustRequestsTripError) {
              return Center(
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
                        "Failed to load trips",
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
                          context.read<CustRequestsTripBloc>().add(
                            const FetchCustRequestsTripEvent(),
                          );
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is CustRequestsTripSuccess) {
              final tickets = state.tripData.data?.tickets ?? [];

              if (tickets.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<CustRequestsTripBloc>().add(
                      const FetchCustRequestsTripEvent(),
                    );
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.assignment_turned_in_outlined,
                                color: colorScheme.primary,
                                size: 48,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No Assigned Trips",
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "You don't have any active requested trips assigned.",
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<CustRequestsTripBloc>().add(
                    const FetchCustRequestsTripEvent(),
                  );
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    return _buildTripCard(context, ticket);
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, Tickets ticket) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Get color for Priority
    Color priorityColor;
    final priorityStr = (ticket.priority ?? "MEDIUM").toUpperCase();
    switch (priorityStr) {
      case "HIGH":
        priorityColor = AppColors.error;
        break;
      case "MEDIUM":
        priorityColor = AppColors.warning;
        break;
      default:
        priorityColor = AppColors.info;
    }

    // Get color for Status
    Color statusBgColor;
    Color statusTextColor;
    final statusStr = (ticket.ticketStatus ?? "ASSIGNED").toLowerCase();
    switch (statusStr) {
      case "accepted":
      case "active":
        statusBgColor = AppColors.success.withOpacity(0.1);
        statusTextColor = AppColors.success;
        break;
      case "pending":
      case "pending pickup":
        statusBgColor = AppColors.warning.withOpacity(0.1);
        statusTextColor = AppColors.warning;
        break;
      default:
        statusBgColor = colorScheme.onSurface.withOpacity(0.05);
        statusTextColor = colorScheme.onSurface.withOpacity(0.6);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.premiumCardDecoration(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => TicketDetailScreen(
                        ticket: ticket,
                      ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Ticket Number & Status Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 18,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "#${ticket.ticketNumber ?? ticket.ticketId ?? 'N/A'}",
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          (ticket.ticketStatus ?? 'ASSIGNED').toUpperCase(),
                          style: textTheme.labelSmall?.copyWith(
                            color: statusTextColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Customer details
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticket.customerName ?? 'Guest Customer',
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ticket.b2bClient?.phone ?? 'No contact',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Priority Badge on the right
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: priorityColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          "$priorityStr PRIORITY",
                          style: textTheme.labelSmall?.copyWith(
                            color: priorityColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 8.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Pickup details
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, size: 18, color: AppColors.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pickup Location",
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.4),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ticket.pickupLocation ?? 'N/A',
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Car details
                  Row(
                    children: [
                      Icon(
                        Icons.directions_car_outlined,
                        size: 18,
                        color: colorScheme.onSurface.withOpacity(0.4),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ticket.vehiclePlate ?? 'Plate: N/A',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Footer: Assigned time & "View Details" prompt
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: colorScheme.onSurface.withOpacity(0.4),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Assigned at ${_formatTime(ticket.createdAt)}",
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "View Details",
                            style: textTheme.labelMedium?.copyWith(
                              color:
                                  colorScheme.primary == AppColors.primary
                                      ? AppColors.primaryDark
                                      : colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color:
                                colorScheme.primary == AppColors.primary
                                    ? AppColors.primaryDark
                                    : colorScheme.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
