class UpdateProfileResponse {
  bool? success;
  String? message;
  UpdateProfileData? data;

  UpdateProfileResponse({this.success, this.message, this.data});

  UpdateProfileResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data =
        json['data'] != null ? UpdateProfileData.fromJson(json['data']) : null;
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

class UpdateProfileData {
  bool? success;
  String? message;

  UpdateProfileData({this.success, this.message});

  UpdateProfileData.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['success'] = success;
    data['message'] = message;
    return data;
  }
}
