import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';

class MockInterceptor extends Interceptor {
  final SecureStorageService? storageService;

  // Track declined requests globally to prevent infinite loops when refreshing pending request list
  static final Set<String> declinedRequestIds = {};

  MockInterceptor({this.storageService});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final path = options.path;

    // Get current role persistently
    final savedRole = await storageService?.getRole();
    final role = savedRole ?? "main_driver";

    if (path.contains('/driver/auth/login')) {
      final data = options.data;
      String loggedInRole = "main_driver";
      String name = "Alex Johnson";

      if (data is Map) {
        final emailOrPhone = (data['emailOrPhone'] ?? '').toString();
        if (emailOrPhone.contains('support') || emailOrPhone.endsWith('2')) {
          loggedInRole = "support_driver";
          name = "Rahul Kumar";
        }
      }

      // Persist the state in secure storage so the app recognizes the active role
      await storageService?.saveRole(loggedInRole);
      await storageService?.saveUserName(name);
      await storageService?.saveDriverId("mock_driver_id");

      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          "token": "mock_token",
          "refresh_token": "mock_refresh_token",
          "driver_id": "mock_driver_id",
          "user_name": name,
          "role": loggedInRole,
          "is_document_verified": true
        },
      ));
      return;
    }

    if (path.contains('/auth/refresh-token')) {
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          "token": "mock_token",
          "refresh_token": "mock_refresh_token",
          "access_token": "mock_token"
        },
      ));
      return;
    }

    if (path.contains('/driver/availability')) {
      // Clear declined request IDs if going offline to allow testing the simulation again
      final data = options.data;
      if (data is Map) {
        final isOnline = data['isOnline'];
        if (isOnline == false) {
          declinedRequestIds.clear();
        }
      }

      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          "success": true,
          "message": "Availability updated successfully"
        },
      ));
      return;
    }

    if (path.contains('/drivers/location/update')) {
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          "success": true,
          "message": "Location updated successfully"
        },
      ));
      return;
    }

    if (path.contains('/driver/profile')) {
      final name = role == "support_driver" ? "Rahul Kumar" : "Alex Johnson";
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          "success": true,
          "message": "Profile fetched successfully",
          "data": {
            "driver_id": "mock_driver_id",
            "name": name,
            "phone_number": role == "support_driver" ? "+919999999992" : "+919999999991",
            "email": role == "support_driver" ? "rahul.kumar@pikmycar.com" : "alex.johnson@pikmycar.com",
            "profile_image_url": role == "support_driver" ? "https://i.pravatar.cc/150?img=11" : "https://i.pravatar.cc/150?img=12",
            "role": role,
            "is_active": true,
            "is_document_verified": true,
            "rating": role == "support_driver" ? 4.8 : 4.9,
            "total_trips": role == "support_driver" ? 64 : 128,
            "driver_acceptance": 98.5
          }
        },
      ));
      return;
    }

    if (path.contains('/driver/ratings')) {
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          "success": true,
          "message": "Ratings fetched successfully",
          "data": {
            "averageRating": role == "support_driver" ? 4.8 : 4.9,
            "totalReviews": 3,
            "reviews": [
              { "review": "Excellent service and extremely polite!", "rating": 5.0 },
              { "review": "Punctual, friendly, and very helpful.", "rating": 5.0 },
              { "review": "Great driving and clean vehicle.", "rating": 4.7 }
            ]
          }
        },
      ));
      return;
    }

    if (path.contains('/driver/earnings')) {
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          "success": true,
          "message": "Earnings fetched successfully",
          "data": {
            "driver_id": "mock_driver_id",
            "today_earning": role == "support_driver" ? 90.00 : 120.00,
            "week_earning": role == "support_driver" ? 580.00 : 750.00,
            "month_earning": role == "support_driver" ? 2400.00 : 3200.00,
            "total_earning": role == "support_driver" ? 9200.00 : 12450.00,
            "wallet_balance": role == "support_driver" ? 310.00 : 450.00
          }
        },
      ));
      return;
    }

    if (path.contains('/driver/bank')) {
      if (options.method == 'GET') {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            "success": true,
            "message": "Bank details fetched successfully",
            "data": [
              {
                "bank_id": "bank_01",
                "account_holder_name": role == "support_driver" ? "Rahul Kumar" : "Alex Johnson",
                "bank_name": "Emirates NBD",
                "branch_name": "Downtown Dubai",
                "is_default": true
              }
            ]
          },
        ));
      } else {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            "success": true,
            "message": "Bank details added successfully"
          },
        ));
      }
      return;
    }

    if (path.contains('/web/tickets/fetch-by-id') || path.contains('/ticket-details')) {
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          "status": "success",
          "message": "Ticket details fetched successfully",
          "data": {
            "ticketId": "TK-1001",
            "ticketUuid": "tk-1001-uuid",
            "priority": "High",
            "customer": {
              "name": "John Doe",
              "contact": "+971555555555",
              "email": "john.doe@gmail.com",
              "vip": true,
              "customerType": "B2B"
            },
            "vehicle": {
              "name": "Tesla Model Y (White)",
              "number": "DXB-A-12345"
            },
            "createdAt": "2026-05-31T08:00:00Z",
            "createBy": "system",
            "reviewAt": null,
            "pickupLocationArrivedAt": null,
            "completedAt": null,
            "status": "Driver Assigned",
            "driverStatus": "driverAssigned",
            "drivers": {
              "mainDriver": null,
              "supportDriver": {
                "id": "mock_driver_id",
                "name": role == "support_driver" ? "Rahul Kumar" : "Alex Johnson",
                "assignmentStatus": true,
                "rating": role == "support_driver" ? 4.8 : 4.9,
                "status": "ACCEPTED",
                "assignmentAt": "2026-05-31T08:15:00Z",
                "contact": {
                  "phone": role == "support_driver" ? "+919999999992" : "+919999999991",
                  "email": role == "support_driver" ? "rahul.kumar@pikmycar.com" : "alex.johnson@pikmycar.com"
                },
                "vendor": {
                  "name": "Fleet Partners",
                  "contact": "+97140000000",
                  "email": "info@fleetpartners.com",
                  "address": "Al Quoz, Dubai"
                },
                "vehicle": {
                  "type": "Sedan",
                  "model": "Toyota Camry 2024",
                  "plateNumber": "DXB-T-98765",
                  "seatingCount": 4
                },
                "locationTracking": []
              }
            },
            "travel": null,
            "arrival": null,
            "inspection": null,
            "garage": null,
            "pickup": {
              "location": "Burj Khalifa, Downtown Dubai",
              "latitude": 25.1972,
              "longitude": 55.2744,
              "googleMapsAddress": "Burj Khalifa, Downtown Dubai",
              "estTime": "15 mins",
              "actualTime": null
            },
            "drop": {
              "location": "Dubai Marina Mall, Dubai",
              "latitude": 25.0772,
              "longitude": 55.1408,
              "googleMapsAddress": "Dubai Marina Mall, Dubai",
              "time": "30 mins",
              "actualTime": null
            },
            "pricing": null,
            "customerFeedback": null
          }
        },
      ));
      return;
    }

    if (path.contains('/web/tickets/fetch')) {
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          "status": "success",
          "message": "Tickets fetched successfully",
          "data": {
            "filtersApplied": {
              "userId": "mock_driver_id"
            },
            "summary": {
              "totalRecords": 2,
              "pageNumber": 1,
              "pageSize": 20,
              "totalPages": 1
            },
            "tickets": [
              {
                "ticketId": "TK-1001",
                "ticketNumber": "PMC-2026-1001",
                "ticketStatus": "Driver Assigned",
                "rawStatus": "driverAssigned",
                "priority": "High",
                "b2bClient": {
                  "userId": "client_01",
                  "name": "Jane Smith",
                  "email": "jane@abc-logistics.com",
                  "phone": "+971501234567",
                  "companyName": "ABC Logistics",
                  "companyType": "Logistics & Transport"
                },
                "createdAt": "2026-05-31T08:00:00Z",
                "createdBy": "system",
                "mainDriver": null,
                "supportDriver": {
                  "driverId": "mock_driver_id",
                  "name": role == "support_driver" ? "Rahul Kumar" : "Alex Johnson",
                  "contact": role == "support_driver" ? "+919999999992" : "+919999999991",
                  "rating": role == "support_driver" ? 4.8 : 4.9,
                  "availability": "Available",
                  "assignmentStatus": "Assigned",
                  "assignedAt": "2026-05-31T08:15:00Z"
                },
                "customerName": "John Doe",
                "vehiclePlate": "DXB-A-12345",
                "pickupLocation": "Burj Khalifa, Downtown Dubai",
                "dropLocation": "Dubai Marina Mall, Dubai"
              },
              {
                "ticketId": "TK-1002",
                "ticketNumber": "PMC-2026-1002",
                "ticketStatus": "New Request",
                "rawStatus": "newRequests",
                "priority": "Medium",
                "b2bClient": {
                  "userId": "client_02",
                  "name": "Sarah Miller",
                  "email": "sarah@millers.com",
                  "phone": "+971509876543",
                  "companyName": "Miller Co",
                  "companyType": "Retail"
                },
                "createdAt": "2026-05-31T09:00:00Z",
                "createdBy": "system",
                "mainDriver": null,
                "supportDriver": null,
                "customerName": "Robert Brown",
                "vehiclePlate": "SHJ-B-54321",
                "pickupLocation": "Sharjah City Center, Sharjah",
                "dropLocation": "Deira City Center, Dubai"
              }
            ]
          }
        },
      ));
      return;
    }

    if (path.contains('/main-driver-requests/pending')) {
      final hasDeclined = declinedRequestIds.contains('REQ-2026-01');

      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          "status": "success",
          "message": "Pending requests fetched successfully",
          "data": hasDeclined ? [] : [
            {
              "id": "REQ-2026-01",
              "requestId": "REQ-2026-01",
              "ticketId": "TK-1001",
              "mainDriverId": "mock_driver_id",
              "status": "requestReceived",
              "availableSeats": 4,
              "selectedSeats": 1,
              "currentStep": 0,
              "currentTargetDriverId": "SD-99",
              "totalDistance": 8.5,
              "totalEarnings": 45.0,
              "supportDriver": {
                "id": "SD-99",
                "name": "Rahul Kumar",
                "rating": 4.8,
                "photo": "https://i.pravatar.cc/150?img=11",
                "pickupLocation": "Burj Khalifa, Downtown Dubai",
                "dropLocation": "Dubai Marina Mall, Dubai",
                "pickupLat": 25.1972,
                "pickupLng": 55.2744,
                "dropLat": 25.0772,
                "dropLng": 55.1408,
                "distance": 8.5,
                "eta": "12 mins",
                "seatsRequired": 1,
                "status": "REQUESTED"
              }
            }
          ]
        },
      ));
      return;
    }

    if (path.contains('accept') || path.contains('decline') || path.contains('complete') || path.contains('reject') || path.contains('update')) {
      if (path.contains('decline') || path.contains('reject')) {
        declinedRequestIds.add('REQ-2026-01');
      }

      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          "success": true,
          "message": "Request processed successfully"
        },
      ));
      return;
    }

    if (path.contains('/driver/send-main-driver-request')) {
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          "success": true,
          "message": "Pick Me request sent successfully",
          "data": {
            "request_id": "REQ-PICKME-01",
            "ticket_id": "TK-1001",
            "status": "pending",
            "priority": "medium",
            "expires_at": "2026-05-31T12:00:00Z",
            "recipient_count": 1,
            "recipients": ["MD-001"],
            "next_step": {
              "name": "check_status",
              "method": "GET",
              "path": "/driver/main-driver-request/REQ-PICKME-01"
            }
          }
        },
      ));
      return;
    }

    // Default fallback so we don't throw unexpected errors
    handler.resolve(Response(
      requestOptions: options,
      statusCode: 200,
      data: {
        "success": true,
        "message": "Mock default response"
      },
    ));
  }
}
