# Customer Requests Trip BLoC Integration Guide

This guide shows you how to integrate and use the newly created `CustRequestsTripBloc` in your Flutter UI using standard `flutter_bloc` components.

---

## 🛠️ 1. Providing the BLoC (`BlocProvider`)

To access the BLoC in your screens, wrap the parent widget or page with a `BlocProvider`. This injects the BLoC and its required repository (which runs on the app's shared `ApiClient`).

### Example Integration in a Screen Router/Builder:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import 'customer_requests_trip/cust_requests_trip_bloc.dart';
import 'customer_requests_trip/cust_requests_trip_event.dart';

class CustomerRequestsPage extends StatelessWidget {
  const CustomerRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CustRequestsTripBloc(
        repository: CustomerRequestsTripRepository(
          apiClient: context.read<ApiClient>(),
        ),
      )..add(const FetchCustRequestsTripEvent()), // Auto-fetch on screen open
      child: const CustomerRequestsView(),
    );
  }
}
```

---

## 🔄 2. Responding to State Changes (`BlocListener`)

Use a `BlocListener` for navigation, showing SnackBar alerts, or dialog triggers that should only happen **once** when a state transition occurs (side-effects).

### Example for showing notifications or popping screens:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'customer_requests_trip/cust_requests_trip_bloc.dart';
import 'customer_requests_trip/cust_requests_trip_state.dart';

class CustomerRequestsView extends StatelessWidget {
  const CustomerRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pickup Requests")),
      body: BlocListener<CustRequestsTripBloc, CustRequestsTripState>(
        listener: (context, state) {
          if (state is CustRequestsTripAccepted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Trip accepted successfully! ID: ${state.tripId}"),
                backgroundColor: Colors.green,
              ),
            );
            // Navigate to active trip screen
            Navigator.pushNamed(context, '/support_driver_ride_to_customer');
          } else if (state is CustRequestsTripDeclined) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Trip request declined."),
                backgroundColor: Colors.redAccent,
              ),
            );
          } else if (state is CustRequestsTripError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: const CustomerRequestsList(),
      ),
    );
  }
}
```

---

## 🎨 3. Rendering the UI (`BlocBuilder`)

Use a `BlocBuilder` to rebuild your UI components dynamically as the state of the trip requests changes.

### Example for displaying loading, list, and empty screens:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'customer_requests_trip/cust_requests_trip_bloc.dart';
import 'customer_requests_trip/cust_requests_trip_state.dart';
import 'customer_requests_trip/cust_requests_trip_event.dart';

class CustomerRequestsList extends StatelessWidget {
  const CustomerRequestsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustRequestsTripBloc, CustRequestsTripState>(
      builder: (context, state) {
        if (state is CustRequestsTripLoading || state is CustRequestsTripInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CustRequestsTripError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Error: ${state.message}", style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<CustRequestsTripBloc>().add(const FetchCustRequestsTripEvent());
                  },
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }

        if (state is CustRequestsTripSuccess) {
          final tickets = state.tripData.data?.tickets ?? [];

          if (tickets.isEmpty) {
            return const Center(child: Text("No requested trips available."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return Card(
                child: ListTile(
                  title: Text("Ticket: ${ticket.ticketNumber ?? 'N/A'}"),
                  subtitle: Text("Customer: ${ticket.customerName ?? 'Unknown'}\nPickup: ${ticket.pickupLocation ?? ''}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          context.read<CustRequestsTripBloc>().add(
                            DeclineCustRequestsTripEvent(tripId: ticket.ticketId ?? ''),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () {
                          context.read<CustRequestsTripBloc>().add(
                            AcceptCustRequestsTripEvent(tripId: ticket.ticketId ?? ''),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
```
