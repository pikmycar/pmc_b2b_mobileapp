class GetBankResponse {
  bool? success;
  String? message;
  List<BankData>? data;

  GetBankResponse({this.success, this.message, this.data});

  GetBankResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];

    if (json['data'] != null && json['data'] is List) {
      data = (json['data'] as List)
          .map((e) => BankData.fromJson(e))
          .toList();
    } else {
      data = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = {};
    dataMap['success'] = success;
    dataMap['message'] = message;

    if (data != null) {
      dataMap['data'] = data!.map((e) => e.toJson()).toList();
    }
    return dataMap;
  }
}

class BankData {
  String? bankId;
  String? accountHolderName;
  String? bankName;
  String? branchName;
  bool? isDefault;

  BankData({
    this.bankId,
    this.accountHolderName,
    this.bankName,
    this.branchName,
    this.isDefault,
  });

  BankData.fromJson(Map<String, dynamic> json) {
    bankId = json['bank_id'] ?? json['bankId'];
    accountHolderName =
        json['account_holder_name'] ?? json['accountHolderName'];
    bankName = json['bank_name'] ?? json['bankName'];
    branchName = json['branch_name'] ?? json['branchName'];

    final defaultValue = json['is_default'] ?? json['isDefault'];
    if (defaultValue is bool) {
      isDefault = defaultValue;
    } else if (defaultValue is int) {
      isDefault = defaultValue == 1;
    } else if (defaultValue is String) {
      isDefault = defaultValue.toLowerCase() == 'true';
    } else {
      isDefault = false;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['bank_id'] = bankId;
    data['account_holder_name'] = accountHolderName;
    data['bank_name'] = bankName;
    data['branch_name'] = branchName;
    data['is_default'] = isDefault;
    return data;
  }
}