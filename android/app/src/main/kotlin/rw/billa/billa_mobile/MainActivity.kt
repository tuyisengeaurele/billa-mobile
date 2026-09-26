package rw.billa.billa_mobile

import android.content.ActivityNotFoundException
import android.content.Intent
import android.provider.ContactsContract
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pendingPick: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CONTACT_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method != "pickPhone") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            if (pendingPick != null) {
                result.error("busy", "A contact is already being picked", null)
                return@setMethodCallHandler
            }
            // Picking a single phone entry hands this app read access to just
            // that entry, so no contacts permission is needed or requested.
            pendingPick = result
            try {
                startActivityForResult(
                    Intent(Intent.ACTION_PICK, ContactsContract.CommonDataKinds.Phone.CONTENT_URI),
                    PICK_PHONE_REQUEST,
                )
            } catch (e: ActivityNotFoundException) {
                pendingPick = null
                result.error("unavailable", "No contacts app is installed", null)
            }
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode != PICK_PHONE_REQUEST) {
            @Suppress("DEPRECATION")
            super.onActivityResult(requestCode, resultCode, data)
            return
        }
        val result = pendingPick
        pendingPick = null
        val uri = data?.data
        if (resultCode != RESULT_OK || uri == null) {
            result?.success(null)
            return
        }
        val projection = arrayOf(
            ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME,
            ContactsContract.CommonDataKinds.Phone.NUMBER,
        )
        contentResolver.query(uri, projection, null, null, null)?.use { cursor ->
            if (cursor.moveToFirst()) {
                result?.success(mapOf("name" to cursor.getString(0), "phone" to cursor.getString(1)))
                return
            }
        }
        result?.success(null)
    }

    companion object {
        private const val CONTACT_CHANNEL = "billa/contact_picker"
        private const val PICK_PHONE_REQUEST = 4711
    }
}
