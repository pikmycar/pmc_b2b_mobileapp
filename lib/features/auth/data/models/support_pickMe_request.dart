class SupportPickmeRequest {
  String? status;
  String? message;
  SupportPickmeData? data;

  SupportPickmeRequest({this.status, this.message, this.data});

  SupportPickmeRequest.fromJson(Map<String, dynamic> json) {
    status = json['status']?.toString();
    message = json['message']?.toString();
    data =
        json['data'] != null ? SupportPickmeData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.toJson(),
  };
}

class SupportPickmeData {
  String? requestId;
  String? driverId;
  String? driverName;

  SupportPickmeData({this.requestId, this.driverId, this.driverName});

  SupportPickmeData.fromJson(Map<String, dynamic> json) {
    requestId = (json['requestId'] ?? json['requestid'] ?? json['request_id'] ?? json['id'])?.toString();
    driverId = (json['driverId'] ?? json['driverid'] ?? json['driver_id'])?.toString();
    driverName = (json['driverName'] ?? json['drivername'] ?? json['driver_name'])?.toString();
  }

  Map<String, dynamic> toJson() => {
    'requestId': requestId,
    'driverId': driverId,
    'driverName': driverName,
  };
}
