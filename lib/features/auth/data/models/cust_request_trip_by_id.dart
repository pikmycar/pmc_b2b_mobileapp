class CustRequestTripById {
  String? status;
  String? message;
  TripData? data;

  CustRequestTripById({this.status, this.message, this.data});

  factory CustRequestTripById.fromJson(Map<String, dynamic> json) {
    return CustRequestTripById(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? TripData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'message': message, 'data': data?.toJson()};
  }
}

class TripData {
  String? ticketId;
  String? ticketUuid;
  String? priority;
  Customer? customer;
  VehicleInfo? vehicle;
  String? createdAt;
  String? createBy;
  dynamic reviewAt;
  dynamic pickupLocationArrivedAt;
  dynamic completedAt;
  String? status;
  String? driverStatus;
  Drivers? drivers;
  dynamic travel;
  dynamic arrival;
  dynamic inspection;
  dynamic garage;
  Pickup? pickup;
  Drop? drop;
  dynamic pricing;
  CustomerFeedback? customerFeedback;

  TripData({
    this.ticketId,
    this.ticketUuid,
    this.priority,
    this.customer,
    this.vehicle,
    this.createdAt,
    this.createBy,
    this.reviewAt,
    this.pickupLocationArrivedAt,
    this.completedAt,
    this.status,
    this.driverStatus,
    this.drivers,
    this.travel,
    this.arrival,
    this.inspection,
    this.garage,
    this.pickup,
    this.drop,
    this.pricing,
    this.customerFeedback,
  });

  factory TripData.fromJson(Map<String, dynamic> json) {
    return TripData(
      ticketId: json['ticketId'],
      ticketUuid: json['ticketUuid'],
      priority: json['priority'],
      customer:
          json['customer'] != null ? Customer.fromJson(json['customer']) : null,
      vehicle:
          json['vehicle'] != null
              ? VehicleInfo.fromJson(json['vehicle'])
              : null,
      createdAt: json['createdAt'],
      createBy: json['createBy'],
      reviewAt: json['reviewAt'],
      pickupLocationArrivedAt: json['pickupLocationArrivedAt'],
      completedAt: json['completedAt'],
      status: json['status'],
      driverStatus: json['driverStatus'],
      drivers:
          json['drivers'] != null ? Drivers.fromJson(json['drivers']) : null,
      travel: json['travel'],
      arrival: json['arrival'],
      inspection: json['inspection'],
      garage: json['garage'],
      pickup: json['pickup'] != null ? Pickup.fromJson(json['pickup']) : null,
      drop: json['drop'] != null ? Drop.fromJson(json['drop']) : null,
      pricing: json['pricing'],
      customerFeedback:
          json['customerFeedback'] != null
              ? CustomerFeedback.fromJson(json['customerFeedback'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticketId': ticketId,
      'ticketUuid': ticketUuid,
      'priority': priority,
      'customer': customer?.toJson(),
      'vehicle': vehicle?.toJson(),
      'createdAt': createdAt,
      'createBy': createBy,
      'reviewAt': reviewAt,
      'pickupLocationArrivedAt': pickupLocationArrivedAt,
      'completedAt': completedAt,
      'status': status,
      'driverStatus': driverStatus,
      'drivers': drivers?.toJson(),
      'travel': travel,
      'arrival': arrival,
      'inspection': inspection,
      'garage': garage,
      'pickup': pickup?.toJson(),
      'drop': drop?.toJson(),
      'pricing': pricing,
      'customerFeedback': customerFeedback?.toJson(),
    };
  }
}

class Customer {
  String? name;
  String? contact;
  String? email;
  bool? vip;
  String? customerType;

  Customer({this.name, this.contact, this.email, this.vip, this.customerType});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      name: json['name'],
      contact: json['contact'],
      email: json['email'],
      vip: json['vip'],
      customerType: json['customerType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'contact': contact,
      'email': email,
      'vip': vip,
      'customerType': customerType,
    };
  }
}

class VehicleInfo {
  String? name;
  String? number;

  VehicleInfo({this.name, this.number});

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(name: json['name'], number: json['number']);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'number': number};
  }
}

class Drivers {
  dynamic mainDriver;
  SupportDriver? supportDriver;

  Drivers({this.mainDriver, this.supportDriver});

  factory Drivers.fromJson(Map<String, dynamic> json) {
    return Drivers(
      mainDriver: json['mainDriver'],
      supportDriver:
          json['supportDriver'] != null
              ? SupportDriver.fromJson(json['supportDriver'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'mainDriver': mainDriver, 'supportDriver': supportDriver?.toJson()};
  }
}

class SupportDriver {
  String? id;
  String? name;
  bool? assignmentStatus;
  double? rating;
  String? status;
  String? assignmentAt;
  Contact? contact;
  Vendor? vendor;
  DriverVehicle? vehicle;
  List<LocationTracking>? locationTracking;

  SupportDriver({
    this.id,
    this.name,
    this.assignmentStatus,
    this.rating,
    this.status,
    this.assignmentAt,
    this.contact,
    this.vendor,
    this.vehicle,
    this.locationTracking,
  });

  factory SupportDriver.fromJson(Map<String, dynamic> json) {
    return SupportDriver(
      id: json['id'],
      name: json['name'],
      assignmentStatus: json['assignmentStatus'],
      rating: (json['rating'] as num?)?.toDouble(),
      status: json['status'],
      assignmentAt: json['assignmentAt'],
      contact:
          json['contact'] != null ? Contact.fromJson(json['contact']) : null,
      vendor: json['vendor'] != null ? Vendor.fromJson(json['vendor']) : null,
      vehicle:
          json['vehicle'] != null
              ? DriverVehicle.fromJson(json['vehicle'])
              : null,
      locationTracking:
          json['locationTracking'] != null
              ? (json['locationTracking'] as List)
                  .map((e) => LocationTracking.fromJson(e))
                  .toList()
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'assignmentStatus': assignmentStatus,
      'rating': rating,
      'status': status,
      'assignmentAt': assignmentAt,
      'contact': contact?.toJson(),
      'vendor': vendor?.toJson(),
      'vehicle': vehicle?.toJson(),
      'locationTracking': locationTracking?.map((e) => e.toJson()).toList(),
    };
  }
}

class Contact {
  String? phone;
  String? email;

  Contact({this.phone, this.email});

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(phone: json['phone'], email: json['email']);
  }

  Map<String, dynamic> toJson() {
    return {'phone': phone, 'email': email};
  }
}

class Vendor {
  String? name;
  String? contact;
  String? email;
  String? address;

  Vendor({this.name, this.contact, this.email, this.address});

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      name: json['name'],
      contact: json['contact'],
      email: json['email'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'contact': contact,
      'email': email,
      'address': address,
    };
  }
}

class DriverVehicle {
  String? type;
  String? model;
  String? plateNumber;
  int? seatingCount;

  DriverVehicle({this.type, this.model, this.plateNumber, this.seatingCount});

  factory DriverVehicle.fromJson(Map<String, dynamic> json) {
    return DriverVehicle(
      type: json['type'],
      model: json['model'],
      plateNumber: json['plateNumber'],
      seatingCount: json['seatingCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'model': model,
      'plateNumber': plateNumber,
      'seatingCount': seatingCount,
    };
  }
}

class LocationTracking {
  String? time;
  String? date;
  double? latitude;
  double? longitude;

  LocationTracking({this.time, this.date, this.latitude, this.longitude});

  factory LocationTracking.fromJson(Map<String, dynamic> json) {
    return LocationTracking(
      time: json['time'],
      date: json['date'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'date': date,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class Pickup {
  String? location;
  double? latitude;
  double? longitude;
  String? googleMapsAddress;
  String? estTime;
  dynamic actualTime;

  Pickup({
    this.location,
    this.latitude,
    this.longitude,
    this.googleMapsAddress,
    this.estTime,
    this.actualTime,
  });

  factory Pickup.fromJson(Map<String, dynamic> json) {
    return Pickup(
      location: json['location'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      googleMapsAddress: json['googleMapsAddress'],
      estTime: json['estTime'],
      actualTime: json['actualTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'googleMapsAddress': googleMapsAddress,
      'estTime': estTime,
      'actualTime': actualTime,
    };
  }
}

class Drop {
  String? location;
  double? latitude;
  double? longitude;
  String? googleMapsAddress;
  String? time;
  dynamic actualTime;

  Drop({
    this.location,
    this.latitude,
    this.longitude,
    this.googleMapsAddress,
    this.time,
    this.actualTime,
  });

  factory Drop.fromJson(Map<String, dynamic> json) {
    return Drop(
      location: json['location'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      googleMapsAddress: json['googleMapsAddress'],
      time: json['time'],
      actualTime: json['actualTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'googleMapsAddress': googleMapsAddress,
      'time': time,
      'actualTime': actualTime,
    };
  }
}

class CustomerFeedback {
  dynamic rating;
  bool? status;
  dynamic comments;

  CustomerFeedback({this.rating, this.status, this.comments});

  factory CustomerFeedback.fromJson(Map<String, dynamic> json) {
    return CustomerFeedback(
      rating: json['rating'],
      status: json['status'],
      comments: json['comments'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'rating': rating, 'status': status, 'comments': comments};
  }
}
