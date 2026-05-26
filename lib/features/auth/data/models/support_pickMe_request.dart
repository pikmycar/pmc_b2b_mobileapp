class SupportPickmeRequest {
  bool? success;
  String? message;
  RequestData? data;

  SupportPickmeRequest({this.success, this.message, this.data});

  factory SupportPickmeRequest.fromJson(Map<String, dynamic> json) {
    return SupportPickmeRequest(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? RequestData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data?.toJson()};
  }
}

class RequestData {
  bool? success;
  String? message;
  String? ticketId;
  String? requestStatus;
  int? broadcastCount;
  List<String>? requestIds;
  LocationData? pickup;
  LocationData? drop;

  RequestData({
    this.success,
    this.message,
    this.ticketId,
    this.requestStatus,
    this.broadcastCount,
    this.requestIds,
    this.pickup,
    this.drop,
  });

  factory RequestData.fromJson(Map<String, dynamic> json) {
    return RequestData(
      success: json['success'],
      message: json['message'],
      ticketId: json['ticketId'],
      requestStatus: json['requestStatus'],
      broadcastCount: json['broadcastCount'],
      requestIds:
          json['requestIds'] != null
              ? List<String>.from(json['requestIds'])
              : [],
      pickup:
          json['pickup'] != null ? LocationData.fromJson(json['pickup']) : null,
      drop: json['drop'] != null ? LocationData.fromJson(json['drop']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'ticketId': ticketId,
      'requestStatus': requestStatus,
      'broadcastCount': broadcastCount,
      'requestIds': requestIds,
      'pickup': pickup?.toJson(),
      'drop': drop?.toJson(),
    };
  }
}

class LocationData {
  String? location;
  double? latitude;
  double? longitude;
  String? googleMapsAddress;

  LocationData({
    this.location,
    this.latitude,
    this.longitude,
    this.googleMapsAddress,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      location: json['location'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      googleMapsAddress: json['googleMapsAddress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'googleMapsAddress': googleMapsAddress,
    };
  }
}
