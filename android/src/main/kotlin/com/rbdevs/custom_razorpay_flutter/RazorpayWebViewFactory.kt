
import android.content.Context
import android.util.Log
import com.razorpay.Razorpay
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformViewFactory

class RazorpayWebViewFactory(private val messenger: BinaryMessenger?) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {


    override fun create(context: Context?, viewId: Int, args: Any?): RazorpayWebView? {
        Log.d("RazorpayWebViewFactory", "create: $viewId")
        return messenger?.let { RazorpayWebView(context!!, it, viewId) }

    }
}