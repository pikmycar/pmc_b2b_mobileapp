class UpdateProfile {
  String? status;
  String? message;
  ProfileData? data;

  UpdateProfile({this.status, this.message, this.data});

  factory UpdateProfile.fromJson(Map<String, dynamic> json) {
    return UpdateProfile(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? ProfileData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'message': message, 'data': data?.toJson()};
  }
}

class ProfileData {
  String? driverId;
  String? userId;
  String? driverCode;
  String? name;
  String? contact;
  String? email;
  Login? login;
  String? driverType;
  String? availability;
  int? rating;
  int? trips;
  bool? isRtaEligible;
  String? rtaNumber;
  String? licenseNumber;
  String? emiratesId;
  String? licenseExpiry;
  String? profileImage;
  String? vehicleNumber;
  String? vehicle;
  List<String>? assignedZones;
  bool? isVerified;
  String? status;
  int? acceptanceRate;
  int? totalEarnings;
  dynamic lastActivityAt;
  Vendor? vendor;
  Tracking? tracking;
  List<dynamic>? currentTickets;
  Timeline? timeline;

  ProfileData({
    this.driverId,
    this.userId,
    this.driverCode,
    this.name,
    this.contact,
    this.email,
    this.login,
    this.driverType,
    this.availability,
    this.rating,
    this.trips,
    this.isRtaEligible,
    this.rtaNumber,
    this.licenseNumber,
    this.emiratesId,
    this.licenseExpiry,
    this.profileImage,
    this.vehicleNumber,
    this.vehicle,
    this.assignedZones,
    this.isVerified,
    this.status,
    this.acceptanceRate,
    this.totalEarnings,
    this.lastActivityAt,
    this.vendor,
    this.tracking,
    this.currentTickets,
    this.timeline,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      driverId: json['driverId'],
      userId: json['userId'],
      driverCode: json['driverCode'],
      name: json['name'],
      contact: json['contact'],
      email: json['email'],
      login: json['login'] != null ? Login.fromJson(json['login']) : null,
      driverType: json['driverType'],
      availability: json['availability'],
      rating: json['rating'],
      trips: json['trips'],
      isRtaEligible: json['isRtaEligible'],
      rtaNumber: json['rtaNumber'],
      licenseNumber: json['licenseNumber'],
      emiratesId: json['emiratesId'],
      licenseExpiry: json['licenseExpiry'],
      profileImage: json['profileImage'],
      vehicleNumber: json['vehicleNumber'],
      vehicle: json['vehicle'] is List
          ? (json['vehicle'] as List).join(', ')
          : json['vehicle']?.toString(),
      assignedZones: json['assignedZones'] is List
          ? List<String>.from((json['assignedZones'] as List).map((x) => x.toString()))
          : [],
      isVerified: json['isVerified'],
      status: json['status'],
      acceptanceRate: json['acceptanceRate'],
      totalEarnings: json['totalEarnings'],
      lastActivityAt: json['lastActivityAt'],
      vendor: json['vendor'] != null ? Vendor.fromJson(json['vendor']) : null,
      tracking:
          json['tracking'] != null ? Tracking.fromJson(json['tracking']) : null,
      currentTickets: json['currentTickets'] is List
          ? List<dynamic>.from(json['currentTickets'])
          : [],
      timeline:
          json['timeline'] != null ? Timeline.fromJson(json['timeline']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driverId': driverId,
      'userId': userId,
      'driverCode': driverCode,
      'name': name,
      'contact': contact,
      'email': email,
      'login': login?.toJson(),
      'driverType': driverType,
      'availability': availability,
      'rating': rating,
      'trips': trips,
      'isRtaEligible': isRtaEligible,
      'rtaNumber': rtaNumber,
      'licenseNumber': licenseNumber,
      'emiratesId': emiratesId,
      'licenseExpiry': licenseExpiry,
      'profileImage': profileImage,
      'vehicleNumber': vehicleNumber,
      'vehicle': vehicle,
      'assignedZones': assignedZones,
      'isVerified': isVerified,
      'status': status,
      'acceptanceRate': acceptanceRate,
      'totalEarnings': totalEarnings,
      'lastActivityAt': lastActivityAt,
      'vendor': vendor?.toJson(),
      'tracking': tracking?.toJson(),
      'currentTickets': currentTickets,
      'timeline': timeline?.toJson(),
    };
  }
}

class Login {
  String? userId;
  String? email;
  String? roleCode;

  Login({this.userId, this.email, this.roleCode});

  factory Login.fromJson(Map<String, dynamic> json) {
    return Login(
      userId: json['userId'],
      email: json['email'],
      roleCode: json['roleCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'email': email, 'roleCode': roleCode};
  }
}

class Vendor {
  String? vendorId;
  String? vendorName;
  String? contactPerson;
  String? email;
  String? mobileNumber;
  String? address;
  String? city;
  String? state;
  String? status;

  Vendor({
    this.vendorId,
    this.vendorName,
    this.contactPerson,
    this.email,
    this.mobileNumber,
    this.address,
    this.city,
    this.state,
    this.status,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      vendorId: json['vendorId'],
      vendorName: json['vendorName'],
      contactPerson: json['contactPerson'],
      email: json['email'],
      mobileNumber: json['mobileNumber'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendorId': vendorId,
      'vendorName': vendorName,
      'contactPerson': contactPerson,
      'email': email,
      'mobileNumber': mobileNumber,
      'address': address,
      'city': city,
      'state': state,
      'status': status,
    };
  }
}

class Tracking {
  double? latitude;
  double? longitude;
  int? totalSeats;
  int? availableSeats;
  int? currentPassengers;
  String? updatedAt;

  Tracking({
    this.latitude,
    this.longitude,
    this.totalSeats,
    this.availableSeats,
    this.currentPassengers,
    this.updatedAt,
  });

  factory Tracking.fromJson(Map<String, dynamic> json) {
    return Tracking(
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      totalSeats: json['totalSeats'],
      availableSeats: json['availableSeats'],
      currentPassengers: json['currentPassengers'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
      'currentPassengers': currentPassengers,
      'updatedAt': updatedAt,
    };
  }
}

class Timeline {
  String? createdAt;
  String? updatedAt;

  Timeline({this.createdAt, this.updatedAt});

  factory Timeline.fromJson(Map<String, dynamic> json) {
    return Timeline(createdAt: json['createdAt'], updatedAt: json['updatedAt']);
  }

  Map<String, dynamic> toJson() {
    return {'createdAt': createdAt, 'updatedAt': updatedAt};
  }
}
