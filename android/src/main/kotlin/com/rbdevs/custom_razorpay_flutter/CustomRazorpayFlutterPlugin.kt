package com.rbdevs.custom_razorpay_flutter

import RazorpayWebViewFactory
import android.app.Activity
import android.content.Intent
import android.util.Log
import androidx.annotation.NonNull
import com.razorpay.*
import io.flutter.embedding.android.FlutterActivity

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import org.json.JSONArray
import org.json.JSONObject

/** CustomRazorpayFlutterPlugin */
class CustomRazorpayFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var flutterActivity: Activity? = null
    private var shouldAcceptResult: Boolean = false

    companion object {
        lateinit var razorpay: Razorpay
        private val isRazorpayInitialized get() = this::razorpay.isInitialized

    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "rbdevs/custom_razorpay_flutter")
        channel.setMethodCallHandler(this)
        flutterPluginBinding.platformViewRegistry.registerViewFactory("rbdevs/razorpay_webview", RazorpayWebViewFactory(flutterPluginBinding.binaryMessenger))

    }


    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        val args = call.arguments
//        Log.d("########SUPER",call.method)
        when (call.method) {
            "initRazorpay" -> initRazorpay(args as String, result)

            "getPaymentMethods" -> fetchPaymentMethods(args, result)

            "getCardNetwork" -> getCardNetwork(args, result)
            "getCardNetworkLength" -> getCardNetworkLength(args, result)
            "isValidCardNumber" -> isValidCardNumber(args, result)

            "getAppsWhichSupportUpi" -> getAppsWhichSupportUpi(result)
            "isValidVpa" -> isValidVpa(args, result)

            "getBankLogoUrl" -> getBankLogoUrl(args, result)
            "getWalletLogoUrl" -> getWalletLogoUrl(args, result)
            "getWalletSqLogoUrl" -> getWalletSqLogoUrl(args, result)

            "validateFields" -> validateFields(args, result)
            "submit" -> submit(args, result)
            "onUserCancelled" -> onUserCancelled(result)
            "disableResult" -> disableResult(result)

            else -> result.notImplemented()

        }
    }


    private fun initRazorpay(razorpayKey: String, result: Result) {
        razorpay = Razorpay(flutterActivity, razorpayKey)
        result.success(true)
    }

    private fun fetchPaymentMethods(arguments: Any, returnResult: Result) {
//        val payload = JSONObject()
/*    if(arguments is String && arguments.isNotEmpty()) {
      payload.put("subscription_id", arguments)
    }*/
        razorpay.getPaymentMethods(object : PaymentMethodsCallback {
            override fun onPaymentMethodsReceived(result: String?) {
                // Log.d("Result", "" + result)
                returnResult.success(result)
            }

            override fun onError(error: String?) {
                // Log.e("Get Payment error", error!!)
                returnResult.error(error, error, error)
            }
        })
    }


    private fun getCardNetwork(args: Any, result: Result) {
        result.success(razorpay.getCardNetwork(args.toString()))
    }

    private fun getCardNetworkLength(args: Any?, result: Result) {
        result.success(razorpay.getCardNetworkLength(razorpay.getCardNetwork(args.toString())))
    }

    private fun isValidCardNumber(args: Any?, result: Result) {
        result.success(razorpay.isValidCardNumber(args.toString()))
    }

    private fun getAppsWhichSupportUpi(result: Result) {
        Razorpay.getAppsWhichSupportUpi(flutterActivity) { appDetailsList ->
            val appDetailsJsonArray = JSONArray()
            appDetailsList.forEach { appDetail ->
                val jsonObject = JSONObject()
                jsonObject.put("app_name", appDetail.appName)
                jsonObject.put("package_name", appDetail.packageName)
                jsonObject.put("icon_base64", appDetail.iconBase64)
                appDetailsJsonArray.put(jsonObject)
            }
            result.success(appDetailsJsonArray.toString())
        }
    }

    private fun isValidVpa(args: Any?, result: Result) {
        razorpay.isValidVpa(args.toString(), object : ValidateVpaCallback {
            override fun onResponse(p0: JSONObject) {
                result.success(p0.toString())
            }

            override fun onFailure() {
                result.success(false)
            }
        })
    }


    //get Logos
    private fun getBankLogoUrl(args: Any?, result: Result) {
        result.success(razorpay.getBankLogoUrl(args.toString()))
    }

    private fun getWalletLogoUrl(args: Any?, result: Result) {
        result.success(razorpay.getWalletLogoUrl(args.toString()))
    }

    private fun getWalletSqLogoUrl(args: Any?, result: Result) {
        result.success(razorpay.getWalletSqLogoUrl(args.toString()))
    }

    private fun validateFields(arguments: Any, result: Result) {
        val payload = getPaymentPayload(arguments)

        razorpay.validateFields(payload, object : ValidationListener {
            override fun onValidationError(p0: MutableMap<String, String>?) {
                result.error(p0.toString(), p0.toString(), p0)

            }

            override fun onValidationSuccess() {
                result.success(true)

            }
        })
    }

    private fun getPaymentPayload(arguments: Any): JSONObject {
        val args = arguments as Map<*, *>
        val payload = JSONObject()
        try {
            payload.put("currency", args["currency"]); // pass in currency subunits. For example, paise. Amount: 1000 equals ₹10
            payload.put("amount", args["amount"]); // pass in currency subunits. For example, paise. Amount: 1000 equals ₹10
            payload.put("contact", args["contact"])
            payload.put("email", args["email"])
            payload.put("customer_id", args["customer_id"])
            payload.put("save", args["save"])

            if (args["subscription_id"].toString().isNotEmpty()) {
                payload.put("subscription_id", args["subscription_id"])
            } else {
                payload.put("order_id", args["order_id"])
            }

            when (args["method"] as String) {
                "card" -> {
                    val card = args["card"] as Map<*, *>
                    if (card["token"] == null) {
                        payload.put("card[name]", card["name"])
                        payload.put("card[number]", card["number"])
                        payload.put("card[expiry_month]", card["expiry_month"])
                        payload.put("card[expiry_year]", card["expiry_year"])
                    } else {
                        payload.put("token", card["token"])
                        payload.put("consent_to_save_card", 1)
                    }
                    payload.put("card[cvv]", card["cvv"])
                }
                "netbanking" -> {
                    payload.put("bank", (args["netbanking"] as Map<*, *>)["bank_code"])
                }
                "upi" -> {
                    val upi = args["upi"] as Map<*, *>
                    if (upi["flow"] != null && upi["flow"]?.equals("intent")!!) {
                        payload.put("_[flow]", upi["flow"])
                        payload.put("description", args["description"])
                        payload.put("upi_app_package_name", upi["upi_app_package_name"])
                    } else {
                        payload.put("vpa", upi["vpa"])
                    }
                }
                "wallet" -> {
                    payload.put("wallet", (args["wallet"] as Map<*, *>)["wallet_code"])
                }
            }
            payload.put("method", args["method"])


        } catch (e: Exception) {
            e.printStackTrace()
        }
        return payload
    }

    private fun submit(arguments: Any, result: Result) {
        val payload = getPaymentPayload(arguments)

        razorpay.validateFields(payload, object : ValidationListener {
            override fun onValidationError(p0: MutableMap<String, String>?) {
                result.error(p0.toString(), p0.toString(), p0)
//        shouldAcceptActivityResult = false
                shouldAcceptResult = false

            }

            override fun onValidationSuccess() {
                shouldAcceptResult = true
                razorpay.submit(payload, object : PaymentResultWithDataListener {
                    override fun onPaymentSuccess(p0: String?, p1: PaymentData?) {
                        // Log.d("Success", p0!!)
                        result.success(p1?.data.toString())
                        shouldAcceptResult = false
//            shouldAcceptActivityResult = false

                    }

                    override fun onPaymentError(p0: Int, p1: String?, p2: PaymentData?) {
                        // Log.e("Error", p1!!)
                        result.error(p0.toString(), p1, p2?.data.toString())
//            shouldAcceptActivityResult = false
                        shouldAcceptResult = false
                    }
                })
            }
        })
    }

    private fun onUserCancelled(result: Result) {
        razorpay.onBackPressed()
        shouldAcceptResult = false
        result.success(true)
    }

    private fun disableResult(result: Result) {
//    shouldAcceptActivityResult = false
        result.success(true)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        shouldAcceptResult = false
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (isRazorpayInitialized && shouldAcceptResult) {
            razorpay.onActivityResult(requestCode, resultCode, data)
            return true
        }
        return true
    }


    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        flutterActivity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        flutterActivity = null
        shouldAcceptResult = false
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        flutterActivity = binding.activity
        binding.addActivityResultListener(this)

    }

    override fun onDetachedFromActivity() {
        flutterActivity = null
        shouldAcceptResult = false
    }
}
