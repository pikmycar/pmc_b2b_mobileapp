import 'dart:convert';

class GetTripMainDriverStatus {
  String? status;
  String? message;
  TripMainDriverData? data;

  GetTripMainDriverStatus({this.status, this.message, this.data});

  GetTripMainDriverStatus.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data =
        json['data'] != null ? TripMainDriverData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.toJson(),
  };
}

class TripMainDriverData {
  String? ticketId;
  String? ticketNumber;
  String? status;
  String? pickupOtp;
  String? mainDriver;

  TripMainDriverData({
    this.ticketId,
    this.ticketNumber,
    this.status,
    this.pickupOtp,
    this.mainDriver,
  });

  TripMainDriverData.fromJson(Map<String, dynamic> json) {
    ticketId = json['ticketid'];
    ticketNumber = json['ticketnumber'];
    status = json['status'];
    pickupOtp = json['pickupotp'];
    mainDriver = json['maindriver'];
  }

  Map<String, dynamic> toJson() => {
    'ticketid': ticketId,
    'ticketnumber': ticketNumber,
    'status': status,
    'pickupotp': pickupOtp,
    'maindriver': mainDriver,
  };
}

class GetTripMainDriverStatusHelper {
  static Map<String, dynamic> resolveDriverInfo(GetTripMainDriverStatus? statusDetails) {
    final Map<String, dynamic> info = {
      'name': 'Khalid Al-Ameri',
      'phone': '+971 50 123 4567',
      'avatar': '',
      'rating': '4.9',
      'vehicleType': '2020 Toyota Camry',
      'vehicleNumber': 'White · AB 12345',
      'eta': '4 min',
      'pickupLocation': 'Dubai Marina, Tower B',
      'status': statusDetails?.data?.status ?? 'main_driver_assigned',
    };

    final rawMainDriver = statusDetails?.data?.mainDriver;
    if (rawMainDriver != null && rawMainDriver.isNotEmpty) {
      try {
        if (rawMainDriver.trim().startsWith('{')) {
          final dynamic decoded = jsonDecode(rawMainDriver);
          if (decoded is Map<String, dynamic>) {
            info['name'] = decoded['name'] ?? decoded['driverName'] ?? decoded['driver_name'] ?? info['name'];
            info['phone'] = decoded['phone'] ?? decoded['contact'] ?? decoded['driverPhone'] ?? decoded['driver_phone'] ?? info['phone'];
            info['avatar'] = decoded['avatar'] ?? decoded['profileImage'] ?? decoded['profile_image'] ?? info['avatar'];
            info['rating'] = (decoded['rating'] ?? decoded['driverRating'] ?? decoded['driver_rating'] ?? info['rating']).toString();
            
            final vehicle = decoded['vehicle'];
            if (vehicle is Map) {
              info['vehicleType'] = vehicle['name'] ?? vehicle['type'] ?? info['vehicleType'];
              info['vehicleNumber'] = vehicle['number'] ?? vehicle['plate'] ?? info['vehicleNumber'];
            } else {
              info['vehicleType'] = decoded['vehicleType'] ?? decoded['vehicle_type'] ?? decoded['vehicle'] ?? info['vehicleType'];
              info['vehicleNumber'] = decoded['vehicleNumber'] ?? decoded['vehicle_number'] ?? decoded['plate'] ?? info['vehicleNumber'];
            }
            info['eta'] = decoded['eta'] ?? decoded['estTime'] ?? decoded['arrival_time'] ?? info['eta'];
            info['pickupLocation'] = decoded['pickupLocation'] ?? decoded['pickup_location'] ?? decoded['pickup'] ?? info['pickupLocation'];
          } else {
            info['name'] = rawMainDriver;
          }
        } else {
          info['name'] = rawMainDriver;
        }
      } catch (_) {
        info['name'] = rawMainDriver;
      }
    }
    return info;
  }
}
