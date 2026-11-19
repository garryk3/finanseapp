package com.example.finanseapp

import android.app.Activity
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterFragmentActivity() {
    private val channelName = "com.example.finanseapp/file_saver"
    private val requestCode = 4041
    private var pendingResult: MethodChannel.Result? = null
    private var pendingSource: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method != "saveFile") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val source = call.argument<String>("sourcePath")
                val fileName = call.argument<String>("fileName")
                if (source == null || fileName == null) {
                    result.error("invalid_arguments", null, null)
                    return@setMethodCallHandler
                }
                pendingResult = result
                pendingSource = source
                val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                    addCategory(Intent.CATEGORY_OPENABLE)
                    type = "application/octet-stream"
                    putExtra(Intent.EXTRA_TITLE, fileName)
                }
                try {
                    startActivityForResult(intent, requestCode)
                } catch (error: Exception) {
                    pendingResult = null
                    pendingSource = null
                    result.error("save_unavailable", error.message, null)
                }
            }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode != this.requestCode) {
            super.onActivityResult(requestCode, resultCode, data)
            return
        }
        val result = pendingResult
        val source = pendingSource
        pendingResult = null
        pendingSource = null
        if (resultCode != Activity.RESULT_OK || data?.data == null || source == null) {
            result?.success(false)
            return
        }
        val uri: Uri = data.data!!
        try {
            contentResolver.openOutputStream(uri)?.use { output ->
                File(source).inputStream().use { input -> input.copyTo(output) }
            } ?: throw IllegalStateException("no output stream")
            result?.success(true)
        } catch (error: Exception) {
            result?.success(false)
        }
    }
}
