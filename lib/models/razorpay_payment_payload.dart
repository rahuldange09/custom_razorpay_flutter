import 'package:custom_razorpay_flutter/enums/upi_flow.dart';

class RazorpayPaymentPayload {
  String currency;
  int amount;
  String orderId;
  String? subscriptionId;
  String customerId;
  String contact;
  String email;
  String method;
  String? desciption;
  bool shouldSaveCardDetails;
  CardDetails? cardDetails;
  NetbankingDetails? netbankingDetails;
  UpiDetails? upiDetails;
  WalletDetails? walletDetails;

  RazorpayPaymentPayload({
    required this.currency,
    required this.amount,
    required this.orderId,
    this.subscriptionId,
    required this.customerId,
    required this.contact,
    required this.email,
    this.desciption,
    required this.method,
    this.shouldSaveCardDetails = false,
    this.cardDetails,
    this.netbankingDetails,
    this.upiDetails,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['currency'] = currency;
    data['amount'] = amount;
    data['order_id'] = orderId;
    data['subscription_id'] = subscriptionId ?? "";
    data['customer_id'] = customerId;
    data['contact'] = contact;
    data['email'] = email;
    data['desciption'] = desciption;
    data['method'] = method;
    data['save'] = shouldSaveCardDetails ? 1 : 0;
    data['card'] = cardDetails?.toJson();
    data['netbanking'] = netbankingDetails?.toJson();
    data['upi'] = upiDetails?.toJson();
    data['wallet'] = walletDetails?.toJson();
    return data;
  }
}

class CardDetails {
  String? name;
  int? number;
  String? expiryMonth;
  String? expiryYear;
  String? cvv;
  String? token;
  String? bankCode;

  CardDetails({
     this.name,
     this.number,
     this.expiryMonth,
     this.expiryYear,
     this.cvv,
    this.token,
    this.bankCode,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['number'] = number;
    data['expiry_month'] = expiryMonth;
    data['expiry_year'] = expiryYear;
    data['cvv'] = cvv;
    if (token != null) {
      data['token'] = token;
    }
    return data;
  }
}

class NetbankingDetails {
  String bankCode;

  NetbankingDetails({required this.bankCode});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bank_code'] = bankCode;
    return data;
  }
}

class WalletDetails {
  String walletCode;

  WalletDetails({required this.walletCode});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['wallet_code'] = walletCode;
    return data;
  }
}

class UpiDetails {
  UPIFlow flow;
  String? vpa;
  String? upiAppPackageName;

  UpiDetails({required this.flow, this.vpa, this.upiAppPackageName});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['vpa'] = vpa;
    data['flow'] = flow == UPIFlow.INTENT ? "intent" : "collect";
    data['upi_app_package_name'] = upiAppPackageName;
    return data;
  }
}
