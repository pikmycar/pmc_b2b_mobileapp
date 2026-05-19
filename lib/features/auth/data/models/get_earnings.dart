class GetEarningsResponse {
  bool? success;
  String? message;
  EarningsData? data;

  GetEarningsResponse({this.success, this.message, this.data});

  GetEarningsResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null
        ? EarningsData.fromJson(json['data'])
        : null;
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

class EarningsData {
  String? driverId;
  double? todayEarning;
  double? weekEarning;
  double? monthEarning;
  double? totalEarning;
  double? walletBalance;

  EarningsData({
    this.driverId,
    this.todayEarning,
    this.weekEarning,
    this.monthEarning,
    this.totalEarning,
    this.walletBalance,
  });

  EarningsData.fromJson(Map<String, dynamic> json) {
    driverId = json['driver_id'] ?? json['driverId'];

    todayEarning = (json['today_earning'] ?? json['todayEarning'] as num?)?.toDouble();
    weekEarning = (json['week_earning'] ?? json['weekEarning'] as num?)?.toDouble();
    monthEarning = (json['month_earning'] ?? json['monthEarning'] as num?)?.toDouble();
    totalEarning = (json['total_earning'] ?? json['totalEarning'] as num?)?.toDouble();
    walletBalance = (json['wallet_balance'] ?? json['walletBalance'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['driver_id'] = driverId;
    data['today_earning'] = todayEarning;
    data['week_earning'] = weekEarning;
    data['month_earning'] = monthEarning;
    data['total_earning'] = totalEarning;
    data['wallet_balance'] = walletBalance;
    return data;
  }
}