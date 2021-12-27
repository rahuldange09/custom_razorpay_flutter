//
//  RazorpayWebView.swift
//  custom_razorpay_flutter
//
//  Created by Rahul Dange on 05/09/21.
//
import WebKit

public class RazorpayWebView: NSObject, FlutterPlatformView{
    let frame: CGRect
    let viewId: Int64
    let channel: FlutterMethodChannel
    let webview: WKWebView
    
    
    init(_ frame:CGRect, viewId: Int64,channel: FlutterMethodChannel, args: Any?){
        self.frame = frame
        self.viewId = viewId
        self.channel = channel
        
        let config = WKWebViewConfiguration()
        let webview = WKWebView(frame: frame, configuration: config)
        self.webview = webview

        
        channel.setMethodCallHandler({
            (call: FlutterMethodCall, result: FlutterResult) -> Void in
            
            if (call.method == "showWebView") {
                SwiftCustomRazorpayFlutterPlugin.webView = webview
                result(true)
                
            }
        })
    }
    
    public func view() -> UIView {
        return self.webview
    }
}
