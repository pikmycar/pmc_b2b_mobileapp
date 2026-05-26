class CustRequestTrip {
  String? status;
  String? message;
  Data? data;

  CustRequestTrip({this.status, this.message, this.data});

  factory CustRequestTrip.fromJson(Map<String, dynamic> json) {
    return CustRequestTrip(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'message': message, 'data': data?.toJson()};
  }
}

class Data {
  FiltersApplied? filtersApplied;
  Summary? summary;
  List<Tickets>? tickets;

  Data({this.filtersApplied, this.summary, this.tickets});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      filtersApplied:
          json['filtersApplied'] != null
              ? FiltersApplied.fromJson(json['filtersApplied'])
              : null,
      summary:
          json['summary'] != null ? Summary.fromJson(json['summary']) : null,
      tickets:
          json['tickets'] != null
              ? (json['tickets'] as List)
                  .map((e) => Tickets.fromJson(e))
                  .toList()
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filtersApplied': filtersApplied?.toJson(),
      'summary': summary?.toJson(),
      'tickets': tickets?.map((e) => e.toJson()).toList(),
    };
  }
}

class FiltersApplied {
  String? userId;

  FiltersApplied({this.userId});

  factory FiltersApplied.fromJson(Map<String, dynamic> json) {
    return FiltersApplied(userId: json['userId']);
  }

  Map<String, dynamic> toJson() {
    return {'userId': userId};
  }
}

class Summary {
  int? totalRecords;
  int? pageNumber;
  int? pageSize;
  int? totalPages;

  Summary({this.totalRecords, this.pageNumber, this.pageSize, this.totalPages});

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalRecords: json['totalRecords'],
      pageNumber: json['pageNumber'],
      pageSize: json['pageSize'],
      totalPages: json['totalPages'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRecords': totalRecords,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      'totalPages': totalPages,
    };
  }
}

class Tickets {
  String? ticketId;
  String? ticketNumber;
  String? ticketStatus;
  String? rawStatus;
  String? priority;
  B2bClient? b2bClient;
  String? createdAt;
  String? createdBy;
  dynamic mainDriver;
  SupportDriver? supportDriver;
  String? customerName;
  String? vehiclePlate;
  String? pickupLocation;
  String? dropLocation;

  Tickets({
    this.ticketId,
    this.ticketNumber,
    this.ticketStatus,
    this.rawStatus,
    this.priority,
    this.b2bClient,
    this.createdAt,
    this.createdBy,
    this.mainDriver,
    this.supportDriver,
    this.customerName,
    this.vehiclePlate,
    this.pickupLocation,
    this.dropLocation,
  });

  factory Tickets.fromJson(Map<String, dynamic> json) {
    return Tickets(
      ticketId: json['ticketId'],
      ticketNumber: json['ticketNumber'],
      ticketStatus: json['ticketStatus'],
      rawStatus: json['rawStatus'],
      priority: json['priority'],
      b2bClient:
          json['b2bClient'] != null
              ? B2bClient.fromJson(json['b2bClient'])
              : null,
      createdAt: json['createdAt'],
      createdBy: json['createdBy'],
      mainDriver: json['mainDriver'],
      supportDriver:
          json['supportDriver'] != null
              ? SupportDriver.fromJson(json['supportDriver'])
              : null,
      customerName: json['customerName'],
      vehiclePlate: json['vehiclePlate'],
      pickupLocation: json['pickupLocation'],
      dropLocation: json['dropLocation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticketId': ticketId,
      'ticketNumber': ticketNumber,
      'ticketStatus': ticketStatus,
      'rawStatus': rawStatus,
      'priority': priority,
      'b2bClient': b2bClient?.toJson(),
      'createdAt': createdAt,
      'createdBy': createdBy,
      'mainDriver': mainDriver,
      'supportDriver': supportDriver?.toJson(),
      'customerName': customerName,
      'vehiclePlate': vehiclePlate,
      'pickupLocation': pickupLocation,
      'dropLocation': dropLocation,
    };
  }
}

class B2bClient {
  String? userId;
  String? name;
  String? email;
  String? phone;
  String? companyName;
  String? companyType;

  B2bClient({
    this.userId,
    this.name,
    this.email,
    this.phone,
    this.companyName,
    this.companyType,
  });

  factory B2bClient.fromJson(Map<String, dynamic> json) {
    return B2bClient(
      userId: json['userId'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      companyName: json['companyName'],
      companyType: json['companyType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'companyName': companyName,
      'companyType': companyType,
    };
  }
}

class SupportDriver {
  String? driverId;
  String? name;
  String? contact;
  double? rating;
  String? availability;
  String? assignmentStatus;
  String? assignedAt;

  SupportDriver({
    this.driverId,
    this.name,
    this.contact,
    this.rating,
    this.availability,
    this.assignmentStatus,
    this.assignedAt,
  });

  factory SupportDriver.fromJson(Map<String, dynamic> json) {
    return SupportDriver(
      driverId: json['driverId'],
      name: json['name'],
      contact: json['contact'],
      rating: (json['rating'] as num?)?.toDouble(),
      availability: json['availability'],
      assignmentStatus: json['assignmentStatus'],
      assignedAt: json['assignedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driverId': driverId,
      'name': name,
      'contact': contact,
      'rating': rating,
      'availability': availability,
      'assignmentStatus': assignmentStatus,
      'assignedAt': assignedAt,
    };
  }
}
