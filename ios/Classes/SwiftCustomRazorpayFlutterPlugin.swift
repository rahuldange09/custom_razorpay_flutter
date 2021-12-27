import Flutter
import UIKit
import Razorpay
import WebKit

public class SwiftCustomRazorpayFlutterPlugin: NSObject, FlutterPlugin, WKNavigationDelegate, RazorpayPaymentCompletionProtocol{

    
    var razorpay: RazorpayCheckout!
    static var webView: WKWebView!
    var flutterResult : FlutterResult!
    var razorpayKey : String!
    
  public static func register(with registrar: FlutterPluginRegistrar) {
//    let channel = FlutterMethodChannel(name: "rbdevs/custom_razorpay_flutter", binaryMessenger: registrar.messenger())
    let instance = SwiftCustomRazorpayFlutterPlugin()

   
    
//    let controller : FlutterViewController = rootViewController as! FlutterViewController
    let customPaymentChannel = FlutterMethodChannel(name: "rbdevs/custom_razorpay_flutter",
                                                    binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: customPaymentChannel)
    
//    registrar(forPlugin: "rbdevs/razorpay_webview")?.register(webViewFactory, withId: "rbdevs/razorpay_webview")


    let webViewFactory = RazorpayWebViewFactory(binaryMessenger: registrar.messenger())
    registrar.register(webViewFactory, withId: "rbdevs/razorpay_webview")
//    registrar.register(webViewFactory, withId: "rbdevs/webview")
//    registrar.addMethodCallDelegate( RazorpayWebViewFactory(),channel: customPaymentChannel)
//    self.setMethodChannel(customPaymentChannel: customPaymentChannel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

    switch call.method{
    case "initRazorpay":
        self.initRazorpay(result: result, razorpayKey: call.arguments as! String)
        break
    case "getPaymentMethods":
        self.getPaymentMethods(result: result, subscriptionId: call.arguments as! String)
        break
    case "getCardNetwork":
        self.getCardNetwork(result: result, cardNumber: call.arguments as! String)
        break
    case "isValidCardNumber":
        self.isValidCardNumber(result: result, cardNumber: call.arguments as! String)
        break
    case "getCardNetworkLength":
        self.getCardNetworkLength(result: result, cardNetwork: call.arguments as! String)
        break
    case "getAppsWhichSupportUpi":
        self.getAppsWhichSupportUpi(result: result)
        break
    case "getBankLogoUrl":
        self.getBankLogoUrl(result: result, bankCode: call.arguments as! String)
        break
    case "getWalletLogoUrl":
        self.getWalletLogoUrl(result: result, walletName: call.arguments as! String)
        break
    case "getWalletSqLogoUrl":
        self.getWalletSqLogo(result: result, walletName: call.arguments as! String)
        break
    case "submit":
        self.submit(result: result, arguments: call.arguments)
        break
    case "onUserCancelled":
        self.onUserCancelled(result: result)
        break
    default:
        result(FlutterMethodNotImplemented)
        break
    }
  }

    
    
    private func initRazorpay(result : FlutterResult, razorpayKey : String){
        self.razorpayKey = razorpayKey;
        SwiftCustomRazorpayFlutterPlugin.webView = WKWebView()
        razorpay = RazorpayCheckout.initWithKey(razorpayKey, andDelegate: self, withPaymentWebView: SwiftCustomRazorpayFlutterPlugin.webView)
        result(true)
    }
    
    private func getPaymentMethods( result :@escaping FlutterResult, subscriptionId : String){
        // For subscriptions
        let options :[String:String]? = subscriptionId.isEmpty ? nil :  ["subscription_id": subscriptionId]
        
        var paymentMethods :[AnyHashable:Any] = [:]
        var errorDescription: String = ""
        razorpay.getPaymentMethods(withOptions: options, withSuccessCallback: { methods in
            paymentMethods = methods
            result(paymentMethods)
        }) { error in
            errorDescription = error
            result(FlutterError(code: "RAZORPAY_FAILURE",
                                message: "Failed to get payment methods",
                                details: errorDescription))
        }
    }
    
    private func getCardNetwork(result : FlutterResult, cardNumber : String){
        result(razorpay.getCardNetwork(fromCardNumber: cardNumber))
    }
    
    private func isValidCardNumber(result : FlutterResult, cardNumber : String){
        result(razorpay.isCardValid(cardNumber))
        
    }
    
    private func getCardNetworkLength(result : FlutterResult, cardNetwork : String){
        result(razorpay.getCardNetworkLength(ofNetwork: cardNetwork))
    }

    private func getAppsWhichSupportUpi(result :@escaping  FlutterResult){
        RazorpayCheckout.getAppsWhichSupportUpi { upiApps in
            result(upiApps)
        }

    }
    
    
    private func getBankLogoUrl(result : FlutterResult, bankCode : String){
        let bankURL : String = razorpay.getBankLogo(havingBankCode : bankCode)?.absoluteString ?? ""
        result(bankURL)
    }
    
    private func getWalletLogoUrl(result : FlutterResult, walletName : String){
        let walletURL : String = razorpay.getWalletLogo(havingWalletName : walletName)?.absoluteString ?? ""
        result(walletURL)
    }
    
    private func getWalletSqLogo(result : FlutterResult, walletName : String){
        let walletURL : String = razorpay.getWalletSqLogo(havingWalletName : walletName)?.absoluteString ?? ""
        result(walletURL)
    }
    
    
    private func submit(result : @escaping FlutterResult, arguments : Any?){
        self.flutterResult = result;
        let payload : Dictionary<String , Any> = arguments as! Dictionary<String , Any>
        // print(payload);
        var options: [String:Any] = [
            "amount": payload["amount"] ?? 0,
            "currency": "INR",
            "email": payload["email"] ?? "",
            "contact": payload["contact"] ?? "",
            "method": payload["method"] ?? "",
            "customer_id": payload["customer_id"] ?? "",
            "save": payload["save"] ?? 0,
        ]
        
        if(!(payload["subscription_id"] as! String).isEmpty){
            options["subscription_id"] = payload["subscription_id"]
        }else{
            options["order_id"] = payload["order_id"]
        }
        
        switch payload["method"] as! String {
        case "card":
            let card : Dictionary<String , Any> = payload["card"] as! Dictionary<String , Any>
            if(card["token"] == nil){
                options["card[name]"] = card["name"]
                options["card[number]"] = card["number"]
                options["card[expiry_month]"] = card["expiry_month"]
                options["card[expiry_year]"] = card["expiry_year"]
            }else{
                options["token"] = card["token"]
            }
            options["card[cvv]"] = card["cvv"]
            break
        case "netbanking":
            let netbanking : Dictionary<String , Any> = payload["netbanking"] as! Dictionary<String , Any>
            options["bank"] = netbanking["bank_code"]
            break
        case "upi":
            let upi : Dictionary<String , Any> = payload["upi"] as! Dictionary<String , Any>
            options["vpa"] = upi["vpa"]
            break
        case "wallet":
            let wallet : Dictionary<String , Any> = payload["wallet"] as! Dictionary<String , Any>
            options["wallet"] = wallet["wallet_code"]
            break
        default:
            break;
        }
        
        
        // print(options);
        // have to intialize again after webview created to pass webview successfully to razorpay
        razorpay = RazorpayCheckout.initWithKey(self.razorpayKey, andDelegate: self, withPaymentWebView: SwiftCustomRazorpayFlutterPlugin.webView)
        SwiftCustomRazorpayFlutterPlugin.webView.navigationDelegate = self
        razorpay.authorize(options)
        
    }
    
    private func onUserCancelled(result : FlutterResult){
        razorpay.userCancelledPayment()
        result(true)
    }
    
    
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!){
        if razorpay != nil{
            razorpay.webView(webView, didCommit: navigation)
        }
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError er: Error) {
        if razorpay != nil{
            razorpay.webView(webView, didFailProvisionalNavigation: navigation, withError: er)
        }
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError er: Error){
        if razorpay != nil{
            razorpay.webView(webView, didFail: navigation, withError: er)
        }
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
        if razorpay != nil{
            razorpay.webView(webView, didFinish: navigation)
        }
    }
    
    
    public func onPaymentSuccess(_ payment_id: String, andData response: [AnyHashable : Any]) {
        self.flutterResult( response)
    }
    
    public func onPaymentError(_ code: Int32, description str: String, andData response: [AnyHashable : Any]) {
        self.flutterResult(FlutterError(code: String(code),
                                        message: str,
                                        details: response))
    }
}
