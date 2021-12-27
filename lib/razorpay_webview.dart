import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class RazorpayWebview extends StatelessWidget {
  static const _VIEW_TYPE = "rbdevs/razorpay_webview";
  const RazorpayWebview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return PlatformViewLink(
        viewType: _VIEW_TYPE,
        surfaceFactory:
            (BuildContext context, PlatformViewController controller) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
        onCreatePlatformView: (PlatformViewCreationParams params) {
          _onPlatformViewCreated(params.id);
          return PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            viewType: _VIEW_TYPE,
            layoutDirection: TextDirection.ltr,
            creationParams: <String, dynamic>{},
            creationParamsCodec: const StandardMessageCodec(),
          )
            ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
            ..create();
        },
      );
    } else if (Platform.isIOS) {
      return UiKitView(
        viewType: _VIEW_TYPE,
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else {
      return const Text("Not supported. Supports only Android and IOS");
    }
  }

  void _onPlatformViewCreated(int id) {
    final paymentController = _PaymentWebViewController();
    paymentController._init(id);
    if (Platform.isIOS) {
      paymentController.showWebView();
    }
  }
}

class _PaymentWebViewController {
  late MethodChannel _platfromViewChannel;

  void _init(int id) {
    _platfromViewChannel = MethodChannel('${RazorpayWebview._VIEW_TYPE}_$id');
  }

  Future<bool> showWebView() async {
    return await _platfromViewChannel.invokeMethod("showWebView", true);
  }
}
