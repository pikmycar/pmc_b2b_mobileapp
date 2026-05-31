class CustRequestTrip {
  String? status;
  String? message;
  List<TripData>? data;

  CustRequestTrip({this.status, this.message, this.data});

  factory CustRequestTrip.fromJson(Map<String, dynamic> json) {
    return CustRequestTrip(
      status: json['status'],
      message: json['message'],
      data:
          json['data'] != null
              ? List<TripData>.from(
                json['data'].map((x) => TripData.fromJson(x)),
              )
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.map((x) => x.toJson()).toList(),
    };
  }
}

class TripData {
  String? ticketId;
  String? ticketNumber;
  String? status;
  String? priority;
  String? customerName;
  String? customerPhone;
  String? vehicle;
  String? vehiclePlate;
  String? pickupLocation;
  String? dropLocation;
  String? assignedAt;

  TripData({
    this.ticketId,
    this.ticketNumber,
    this.status,
    this.priority,
    this.customerName,
    this.customerPhone,
    this.vehicle,
    this.vehiclePlate,
    this.pickupLocation,
    this.dropLocation,
    this.assignedAt,
  });

  factory TripData.fromJson(Map<String, dynamic> json) {
    return TripData(
      ticketId: json['ticketid']?.toString() ?? json['ticketId']?.toString(),
      ticketNumber: json['ticketnumber']?.toString() ?? json['ticketNumber']?.toString(),
      status: json['status']?.toString(),
      priority: json['priority']?.toString(),
      customerName: json['customername']?.toString() ?? json['customerName']?.toString(),
      customerPhone: json['customerphone']?.toString() ?? json['customerPhone']?.toString(),
      vehicle: json['vehicle']?.toString(),
      vehiclePlate: json['vehicleplate']?.toString() ?? json['vehiclePlate']?.toString(),
      pickupLocation: json['pickuplocation']?.toString() ?? json['pickupLocation']?.toString(),
      dropLocation: json['droplocation']?.toString() ?? json['dropLocation']?.toString(),
      assignedAt: json['assignedat']?.toString() ?? json['assignedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticketid': ticketId,
      'ticketnumber': ticketNumber,
      'status': status,
      'priority': priority,
      'customername': customerName,
      'customerphone': customerPhone,
      'vehicle': vehicle,
      'vehicleplate': vehiclePlate,
      'pickuplocation': pickupLocation,
      'droplocation': dropLocation,
      'assignedat': assignedAt,
    };
  }
}
