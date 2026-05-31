class CustRequestTripById {
  String? status;
  String? message;
  TripData? data;

  CustRequestTripById({this.status, this.message, this.data});

  CustRequestTripById.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? TripData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.toJson(),
  };
}

class TripData {
  String? ticketId;
  String? ticketNumber;
  String? priority;
  B2BClient? b2BClient;
  Customer? customer;
  VehicleInfo? vehicle;
  String? createdAt;
  String? createdBy;
  dynamic reviewAt;
  dynamic pickupLocationArrivedAt;
  dynamic completedAt;
  String? status;
  Drivers? drivers;
  Arrival? arrival;
  Inspection? inspection;
  Garage? garage;
  Pickup? pickup;
  Pickup? drop;
  Pricing? pricing;
  CustomerFeedback? customerFeedback;

  TripData({
    this.ticketId,
    this.ticketNumber,
    this.priority,
    this.b2BClient,
    this.customer,
    this.vehicle,
    this.createdAt,
    this.createdBy,
    this.reviewAt,
    this.pickupLocationArrivedAt,
    this.completedAt,
    this.status,
    this.drivers,
    this.arrival,
    this.inspection,
    this.garage,
    this.pickup,
    this.drop,
    this.pricing,
    this.customerFeedback,
  });

  TripData.fromJson(Map<String, dynamic> json) {
    ticketId = json['ticketId']?.toString() ?? json['ticketid']?.toString();
    ticketNumber = json['ticketNumber']?.toString() ?? json['ticketnumber']?.toString();
    priority = json['priority']?.toString();

    b2BClient =
        json['b2BClient'] != null
            ? B2BClient.fromJson(json['b2BClient'])
            : (json['b2bclient'] != null ? B2BClient.fromJson(json['b2bclient']) : null);

    customer =
        json['customer'] != null 
            ? Customer.fromJson(json['customer']) 
            : (json['customername'] != null || json['customerphone'] != null
                ? Customer(name: json['customername']?.toString(), contact: json['customerphone']?.toString())
                : null);

    vehicle =
        json['vehicle'] != null 
            ? VehicleInfo.fromJson(json['vehicle']) 
            : (json['vehicleplate'] != null || json['vehicle'] != null
                ? VehicleInfo(name: json['vehicle']?.toString(), number: json['vehicleplate']?.toString())
                : null);

    createdAt = json['createdAt']?.toString() ?? json['createdat']?.toString() ?? json['assignedat']?.toString() ?? json['assignedAt']?.toString();
    createdBy = json['createdBy']?.toString() ?? json['createdby']?.toString();
    reviewAt = json['reviewAt'] ?? json['reviewat'];
    pickupLocationArrivedAt = json['pickupLocationArrivedAt'] ?? json['pickuplocationarrivedat'];

    completedAt = json['completedAt'] ?? json['completedat'];
    status = json['status']?.toString();

    drivers =
        json['drivers'] != null ? Drivers.fromJson(json['drivers']) : null;

    arrival =
        json['arrival'] != null ? Arrival.fromJson(json['arrival']) : null;

    inspection =
        json['inspection'] != null
            ? Inspection.fromJson(json['inspection'])
            : null;

    garage = json['garage'] != null ? Garage.fromJson(json['garage']) : null;

    pickup = json['pickup'] != null 
        ? Pickup.fromJson(json['pickup']) 
        : (json['pickuplocation'] != null ? Pickup(location: json['pickuplocation']?.toString()) : null);

    drop = json['drop'] != null 
        ? Pickup.fromJson(json['drop']) 
        : (json['droplocation'] != null ? Pickup(location: json['droplocation']?.toString()) : null);

    pricing =
        json['pricing'] != null ? Pricing.fromJson(json['pricing']) : null;

    customerFeedback =
        json['customerFeedback'] != null
            ? CustomerFeedback.fromJson(json['customerFeedback'])
            : null;
  }

  Map<String, dynamic> toJson() => {
    'ticketId': ticketId,
    'ticketNumber': ticketNumber,
    'priority': priority,
    'b2BClient': b2BClient?.toJson(),
    'customer': customer?.toJson(),
    'vehicle': vehicle?.toJson(),
    'createdAt': createdAt,
    'createdBy': createdBy,
    'reviewAt': reviewAt,
    'pickupLocationArrivedAt': pickupLocationArrivedAt,
    'completedAt': completedAt,
    'status': status,
    'drivers': drivers?.toJson(),
    'arrival': arrival?.toJson(),
    'inspection': inspection?.toJson(),
    'garage': garage?.toJson(),
    'pickup': pickup?.toJson(),
    'drop': drop?.toJson(),
    'pricing': pricing?.toJson(),
    'customerFeedback': customerFeedback?.toJson(),
  };
}

class Customer {
  String? name;
  String? contact;
  String? email;
  bool? vip;
  String? customerType;

  Customer({this.name, this.contact, this.email, this.vip, this.customerType});

  Customer.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    contact = json['contact'];
    email = json['email'];
    vip = json['vip'];
    customerType = json['customerType'];
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'contact': contact,
    'email': email,
    'vip': vip,
    'customerType': customerType,
  };
}

class VehicleInfo {
  String? name;
  String? number;
  String? color;

  VehicleInfo({this.name, this.number, this.color});

  VehicleInfo.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    number = json['number'];
    color = json['color'];
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'number': number,
    'color': color,
  };
}

class Pickup {
  String? location;
  double? latitude;
  double? longitude;
  String? googleMapsAddress;
  dynamic estTime;
  dynamic actualTime;

  Pickup({
    this.location,
    this.latitude,
    this.longitude,
    this.googleMapsAddress,
    this.estTime,
    this.actualTime,
  });

  Pickup.fromJson(Map<String, dynamic> json) {
    location = json['location'];

    latitude = (json['latitude'] as num?)?.toDouble();

    longitude = (json['longitude'] as num?)?.toDouble();

    googleMapsAddress = json['googleMapsAddress'];

    estTime = json['estTime'];
    actualTime = json['actualTime'];
  }

  Map<String, dynamic> toJson() => {
    'location': location,
    'latitude': latitude,
    'longitude': longitude,
    'googleMapsAddress': googleMapsAddress,
    'estTime': estTime,
    'actualTime': actualTime,
  };
}

class B2BClient {
  Map<String, dynamic>? raw;

  B2BClient({this.raw});

  B2BClient.fromJson(Map<String, dynamic> json) {
    raw = json;
  }

  Map<String, dynamic> toJson() => raw ?? {};
}

class Drivers {
  Map<String, dynamic>? raw;

  Drivers({this.raw});

  Drivers.fromJson(Map<String, dynamic> json) {
    raw = json;
  }

  Map<String, dynamic> toJson() => raw ?? {};
}

class Arrival {
  Map<String, dynamic>? raw;

  Arrival({this.raw});

  Arrival.fromJson(Map<String, dynamic> json) {
    raw = json;
  }

  Map<String, dynamic> toJson() => raw ?? {};
}

class Inspection {
  Map<String, dynamic>? raw;

  Inspection({this.raw});

  Inspection.fromJson(Map<String, dynamic> json) {
    raw = json;
  }

  Map<String, dynamic> toJson() => raw ?? {};
}

class Garage {
  Map<String, dynamic>? raw;

  Garage({this.raw});

  Garage.fromJson(Map<String, dynamic> json) {
    raw = json;
  }

  Map<String, dynamic> toJson() => raw ?? {};
}

class Pricing {
  Map<String, dynamic>? raw;

  Pricing({this.raw});

  Pricing.fromJson(Map<String, dynamic> json) {
    raw = json;
  }

  Map<String, dynamic> toJson() => raw ?? {};
}

class CustomerFeedback {
  Map<String, dynamic>? raw;

  CustomerFeedback({this.raw});

  CustomerFeedback.fromJson(Map<String, dynamic> json) {
    raw = json;
  }

  Map<String, dynamic> toJson() => raw ?? {};
}
