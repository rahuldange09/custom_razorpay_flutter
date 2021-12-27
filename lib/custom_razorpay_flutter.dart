import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:custom_razorpay_flutter/models/razorpay_payment_method_details.dart';
import 'package:flutter/services.dart';

import 'models/razorpay_payment_data_error.dart';
import 'models/razorpay_payment_payload.dart';
import 'models/razorpay_upi_app_detail.dart';

class CustomRazorpayFlutter {
  static const MethodChannel _channel =
      MethodChannel('rbdevs/custom_razorpay_flutter');

  Future initialize({required String razorpayKey}) {
    return _channel.invokeMethod("initRazorpay", razorpayKey);
  }

// Get available payment methods
  Future<RazorpayPaymentMethodDetails> getPaymentMethods(
      /*{String? subscriptionId}*/) async {
    final response = await _channel.invokeMethod('getPaymentMethods', "");
    final Map<String, dynamic> paymentMethods = Platform.isAndroid
        ? json.decode(response)
        : json.decode(json.encode(response));
    return RazorpayPaymentMethodDetails.fromJson(paymentMethods);
  }

  ///Card Utils
  // Get Card Network like visa, mastercard
  // if not known return unknown
  Future<String> getCardNetwork({required String cardNumber}) async {
    return await _channel.invokeMethod(
        'getCardNetwork', cardNumber.replaceAll(" ", ""));
  }

  // Get Card Network length to validate else -1
  Future<int> getCardNetworkLength({required String cardNetwork}) async {
    return await _channel.invokeMethod('getCardNetworkLength', cardNetwork);
  }

  // Check whether card number is valid or not
  Future<bool> isValidCardNumber({required String cardNumber}) async {
    return await _channel.invokeMethod(
        'isValidCardNumber', cardNumber.replaceAll(" ", ""));
  }

// get Apps in device which has supports upi
  Future<List<RazorpayUpiAppDetail>> getAppsWhichSupportUpi(
      {bool shouldConvertToUint8List = false}) async {
    final response = await _channel.invokeMethod('getAppsWhichSupportUpi');
    final List paymentMethodList = Platform.isAndroid
        ? json.decode(response)
        : json.decode(json.encode(response));
    return RazorpayUpiAppDetailModel.fromJson(paymentMethodList,
            shouldConvertToUint8List: shouldConvertToUint8List)
        .upiAppDetailList;
  }

  // Get logos
  Future<String> getBankLogoUrl({required String bankCode}) async {
    return await _channel.invokeMethod('getBankLogoUrl', bankCode);
  }

  Future<String> getWalletLogoUrl({required String walletName}) async {
    return await _channel.invokeMethod('getWalletLogoUrl', walletName);
  }

  Future<String> getWalletSqLogoUrl({required String walletName}) async {
    return await _channel.invokeMethod('getWalletSqLogoUrl', walletName);
  }

  // Check whether vpa is valid or not only available for Android even from Razorpay side
  Future<bool> isValidVpa({required String vpa}) async {
    if (Platform.isAndroid) {
      return await _channel.invokeMethod('isValidVpa', vpa);
    } else {
      return true;
    }
  }

  // Check whether fields are valid or not only available for Android even from Razorpay side
  Future<bool> validateFields(
      {required RazorpayPaymentPayload razorpayPayload}) async {
    if (Platform.isAndroid) {
      return await _channel.invokeMethod(
          'validateFields', razorpayPayload.toJson());
    } else {
      return true;
    }
  }

// Finally submit payload
  Future<Map<String, dynamic>> submit(
      {required RazorpayPaymentPayload razorpayPayload}) async {
    try {
      final response = await _channel.invokeMethod(
        "submit",
        razorpayPayload.toJson(),
      );
      final responseJSON =
          Platform.isAndroid ? json.decode(response) : response;
      return responseJSON;
    } catch (e) {
      if (e is PlatformException) {
        if (Platform.isAndroid) {
          final jsonDecoded = json.decode(e.message!);
          if (jsonDecoded['error'] != null) {
            final paymentDataError =
                RazorpayPaymentDataError.fromJson(jsonDecoded['error']);
            throw paymentDataError;
          }
        } else if (Platform.isIOS) {
          final paymentDataError =
              RazorpayPaymentDataError(code: e.code, description: e.message);
          throw paymentDataError;
        } else {
          rethrow;
        }
      }
      rethrow;
    }
  }

  Future<bool> onUserCancelled() async {
    return await _channel.invokeMethod('onUserCancelled');
  }

// Required to disable activity result to stop app from crashing on null
  Future<bool> disableResult() async {
    if (Platform.isAndroid) {
      return await _channel.invokeMethod('disableResult');
    } else {
      return true;
    }
  }
}
