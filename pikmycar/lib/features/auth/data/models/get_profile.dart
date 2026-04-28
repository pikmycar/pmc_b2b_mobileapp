class GetProfileDetails {
  bool? success;
  String? message;
  ProfileData? data;

  GetProfileDetails({this.success, this.message, this.data});

  GetProfileDetails.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? ProfileData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class ProfileData {
  String? driverId;
  String? name;
  String? phoneNumber;
  String? email;
  String? profileImageUrl;
  String? role;
  bool? isActive;
  bool? isDocumentVerified;
  double? rating;
  int? totalTrips;
  double? driverAcceptance;

  ProfileData({
    this.driverId,
    this.name,
    this.phoneNumber,
    this.email,
    this.profileImageUrl,
    this.role,
    this.isActive,
    this.isDocumentVerified,
    this.rating,
    this.totalTrips,
    this.driverAcceptance,
  });

  ProfileData.fromJson(Map<String, dynamic> json) {
    driverId = json['driver_id'] ?? json['driverId'];
    name = json['name'] ?? json['user_name'];
    phoneNumber = json['phone_number'] ?? json['phoneNumber'];
    email = json['email'];
    profileImageUrl = json['profile_image_url'] ?? json['profileImageUrl'];
    role = json['role'];
    isActive = json['is_active'] ?? json['isActive'];
    isDocumentVerified =
        json['is_document_verified'] ?? json['isDocumentVerified'];
    rating = (json['rating'] as num?)?.toDouble();
    totalTrips = (json['total_trips'] ?? json['totalTrips'] as num?)?.toInt();
    driverAcceptance =
        (json['driver_acceptance'] ?? json['driverAcceptance'] as num?)
            ?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['driver_id'] = driverId;
    data['name'] = name;
    data['phone_number'] = phoneNumber;
    data['email'] = email;
    data['profile_image_url'] = profileImageUrl;
    data['role'] = role;
    data['is_active'] = isActive;
    data['is_document_verified'] = isDocumentVerified;
    data['rating'] = rating;
    data['total_trips'] = totalTrips;
    data['driver_acceptance'] = driverAcceptance;
    return data;
  }
}
