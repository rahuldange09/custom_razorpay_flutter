//
//  RazorpayWebvViewFactory.swift
//  custom_razorpay_flutter
//
//  Created by Rahul Dange on 05/09/21.
//

public class RazorpayWebViewFactory : NSObject, FlutterPlatformViewFactory{
    let binaryMessenger: FlutterBinaryMessenger
    init(binaryMessenger: FlutterBinaryMessenger) {
        self.binaryMessenger = binaryMessenger
    }
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) ->

    FlutterPlatformView {
        let channel = FlutterMethodChannel(
            name: "rbdevs/razorpay_webview_" + String(viewId),
            binaryMessenger: self.binaryMessenger
        )

        return RazorpayWebView(frame, viewId: viewId,channel : channel, args: args)
    }
}

