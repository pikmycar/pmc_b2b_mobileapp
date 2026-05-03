class CreateBankResponse {
  bool? success;
  String? message;
  CreateBankData? data;

  CreateBankResponse({this.success, this.message, this.data});

  CreateBankResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null
        ? CreateBankData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = {};
    dataMap['success'] = success;
    dataMap['message'] = message;

    if (data != null) {
      dataMap['data'] = data!.toJson();
    }
    return dataMap;
  }
}

class CreateBankData {
  bool? success;
  String? bankId;

  CreateBankData({this.success, this.bankId});

  CreateBankData.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    bankId = json['bank_id'] ?? json['bankId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['success'] = success;
    data['bank_id'] = bankId;
    return data;
  }
}