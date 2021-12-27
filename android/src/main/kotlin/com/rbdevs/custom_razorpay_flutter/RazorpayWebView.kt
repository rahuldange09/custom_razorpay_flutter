import android.content.Context
import android.view.View
import android.webkit.WebView
import com.rbdevs.custom_razorpay_flutter.CustomRazorpayFlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class RazorpayWebView(context: Context, messenger: BinaryMessenger, id: Int) : PlatformView, MethodChannel.MethodCallHandler {
    private var webView: WebView = WebView(context)
    private var methodChannel: MethodChannel = MethodChannel(messenger, "rbdevs/razorpay_webview$id")

    init {
        methodChannel.setMethodCallHandler(this)
        CustomRazorpayFlutterPlugin.razorpay.setWebView(webView)
    }


    override fun getView(): View {
        return webView
    }


    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "showWebView" -> {
                val showWeView = call.arguments as Boolean
                webView.visibility = if (showWeView) View.VISIBLE else View.GONE
//                RazorpayCustomPayment.shouldAcceptActivityResult = true
                result.success(showWeView)
            }
            else -> {
                result.notImplemented()
            }
        }

    }

    override fun dispose() {
        webView.destroy()
    }
}