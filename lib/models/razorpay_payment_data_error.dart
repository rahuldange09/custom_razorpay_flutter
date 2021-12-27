class RazorpayPaymentDataError {
  late String code;
  String? description;
  String? source;
  String? step;
  String? reason;
  // Metadata metadata;

  RazorpayPaymentDataError({
    required this.code,
    required this.description,
    this.reason,
    this.source,
    this.step,
    /* this.metadata*/
  });

  RazorpayPaymentDataError.fromJson(Map<String, dynamic> json) {
    code = json['code'] ?? "";
    description = json['description'];
    reason = json['reason'];
    source = json['source'];
    step = json['step'];
    /*  metadata = json['metadata'] != null
        ? new Metadata.fromJson(json['metadata'])
        : null;*/
  }

  @override
  String toString() {
    return "code:$code, description:$description, reason:$reason, source:$source, step: $step";
  }
}

/*
class Metadata {
  String orderId;

  Metadata({this.orderId});

  Metadata.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order_id'] = this.orderId;
    return data;
  }
}
*/
