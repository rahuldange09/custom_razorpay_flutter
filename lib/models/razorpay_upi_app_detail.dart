import 'dart:convert';
import 'dart:typed_data';

class RazorpayUpiAppDetailModel {
  List<RazorpayUpiAppDetail> upiAppDetailList = [];

  RazorpayUpiAppDetailModel.fromJson(List list,
      {bool shouldConvertToUint8List = false}) {
    for (final v in list) {
      upiAppDetailList.add(RazorpayUpiAppDetail.fromJson(v,
          shouldConvertToUint8List: shouldConvertToUint8List));
    }
  }
}

class RazorpayUpiAppDetail {
  late String appName;
  late String packageName;
  late String iconBase64;
  Uint8List? iconBytes;

  RazorpayUpiAppDetail.fromJson(Map<String, dynamic> json,
      {bool shouldConvertToUint8List = false}) {
    appName = json['app_name'] ?? "";
    packageName = json['package_name'] ?? "";
    iconBase64 = json['icon_base64'] ?? "";
    iconBytes = shouldConvertToUint8List
        ? _convertBase64ToUint8List(iconBase64.split("base64,")[1])
        : null;
  }

  Uint8List _convertBase64ToUint8List(String base64String) {
    return base64Decode(base64String);
  }
}
