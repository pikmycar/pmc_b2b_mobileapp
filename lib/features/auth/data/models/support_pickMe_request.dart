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
  String? requestId;
  String? ticketId;
  String? status;
  String? priority;
  String? expiresAt;
  int? recipientCount;
  List<String>? recipients;
  NextStep? nextStep;

  RequestData({
    this.requestId,
    this.ticketId,
    this.status,
    this.priority,
    this.expiresAt,
    this.recipientCount,
    this.recipients,
    this.nextStep,
  });

  factory RequestData.fromJson(Map<String, dynamic> json) {
    return RequestData(
      requestId: json['request_id'],
      ticketId: json['ticket_id'],
      status: json['status'],
      priority: json['priority'],
      expiresAt: json['expires_at'],
      recipientCount: json['recipient_count'],
      recipients:
          json['recipients'] != null
              ? List<String>.from(json['recipients'])
              : [],
      nextStep:
          json['next_step'] != null
              ? NextStep.fromJson(json['next_step'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'ticket_id': ticketId,
      'status': status,
      'priority': priority,
      'expires_at': expiresAt,
      'recipient_count': recipientCount,
      'recipients': recipients,
      'next_step': nextStep?.toJson(),
    };
  }
}

class NextStep {
  String? name;
  String? method;
  String? path;

  NextStep({this.name, this.method, this.path});

  factory NextStep.fromJson(Map<String, dynamic> json) {
    return NextStep(
      name: json['name'],
      method: json['method'],
      path: json['path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'method': method, 'path': path};
  }
}
