class authLogin {
  String? status;
  String? message;
  Data? data;

  authLogin({this.status, this.message, this.data});

  authLogin.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? userId;
  String? driverId;
  Null? pmcId;
  String? name;
  String? email;
  String? mobileNumber;
  Null? profileImage;
  String? vendorId;
  Null? b2bClientId;
  String? status;
  Role? role;
  List<String>? permissions;
  String? accessToken;
  String? refreshToken;
  String? tokenExpiry;

  Data({
    this.userId,
    this.driverId,
    this.pmcId,
    this.name,
    this.email,
    this.mobileNumber,
    this.profileImage,
    this.vendorId,
    this.b2bClientId,
    this.status,
    this.role,
    this.permissions,
    this.accessToken,
    this.refreshToken,
    this.tokenExpiry,
  });

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    driverId = json['driverId'];
    pmcId = json['pmcId'];
    name = json['name'];
    email = json['email'];
    mobileNumber = json['mobileNumber'];
    profileImage = json['profileImage'];
    vendorId = json['vendorId'];
    b2bClientId = json['b2bClientId'];
    status = json['status'];
    role = json['role'] != null ? new Role.fromJson(json['role']) : null;
    permissions = json['permissions'].cast<String>();
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
    tokenExpiry = json['tokenExpiry'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['driverId'] = this.driverId;
    data['pmcId'] = this.pmcId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['mobileNumber'] = this.mobileNumber;
    data['profileImage'] = this.profileImage;
    data['vendorId'] = this.vendorId;
    data['b2bClientId'] = this.b2bClientId;
    data['status'] = this.status;
    if (this.role != null) {
      data['role'] = this.role!.toJson();
    }
    data['permissions'] = this.permissions;
    data['accessToken'] = this.accessToken;
    data['refreshToken'] = this.refreshToken;
    data['tokenExpiry'] = this.tokenExpiry;
    return data;
  }
}

class Role {
  String? roleId;
  String? roleCode;
  String? roleName;

  Role({this.roleId, this.roleCode, this.roleName});

  Role.fromJson(Map<String, dynamic> json) {
    roleId = json['roleId'];
    roleCode = json['roleCode'];
    roleName = json['roleName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['roleId'] = this.roleId;
    data['roleCode'] = this.roleCode;
    data['roleName'] = this.roleName;
    return data;
  }
}

typedef LoginResponse = authLogin;
