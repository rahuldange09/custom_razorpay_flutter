class RazorpayPaymentMethodDetails {
  late bool card;
  late bool debitCard;
  late bool creditCard;
  late bool prepaidCard;
  CardNetworks? cardNetworks;
  late bool upi;
  late bool nach;
  late bool upiIntent;

  late Map<String, dynamic> netbankingJson;
  late Map<String, dynamic> walletsJson;

  RazorpayPaymentMethodDetails();
  RazorpayPaymentMethodDetails.fromJson(Map<String, dynamic> json) {
    card = json['card'] ?? false;
    debitCard = json['debit_card'] ?? false;
    creditCard = json['credit_card'] ?? false;
    prepaidCard = json['prepaid_card'] ?? false;
    cardNetworks = json['card_networks'] != null
        ? CardNetworks.fromJson(json['card_networks'])
        : null;

    netbankingJson =
        (json['netbanking'] ?? {}) is Map ? json['netbanking'] : {};
    walletsJson = (json['wallet'] ?? {}) is Map ? json['wallet'] : {};

    upi = json['upi'] ?? false;
    nach = json['nach'] ?? false;
    upiIntent = json['upi_intent'] ?? false;
  }
}

class CardNetworks {
  late bool AMEX;
  late bool DICL;
  late bool MC;
  late bool MAES;
  late bool VISA;
  late bool JCB;
  late bool RUPAY;
  late bool BAJAJ;

  CardNetworks.fromJson(Map<String, dynamic> json) {
    AMEX = _convertIntToBool(json['AMEX']);
    DICL = _convertIntToBool(json['DICL']);
    MC = _convertIntToBool(json['MC']);
    MAES = _convertIntToBool(json['MAES']);
    VISA = _convertIntToBool(json['VISA']);
    JCB = _convertIntToBool(json['JCB']);
    RUPAY = _convertIntToBool(json['RUPAY']);
    BAJAJ = _convertIntToBool(json['BAJAJ']);
  }
}

bool _convertIntToBool(int? value) {
  if ((value ?? 0) == 0) {
    return false;
  } else {
    return true;
  }
}
