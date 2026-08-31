package com.example.degloat_gui

import android.content.pm.PackageManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import rikka.shizuku.Shizuku
import java.io.BufferedReader
import java.io.InputStreamReader
import kotlin.concurrent.thread

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.degloat.app/shizuku"
    private var permissionCallback: ((Boolean) -> Unit)? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Setup Shizuku request permission result listener
        Shizuku.addRequestPermissionResultListener { requestCode, grantResult ->
            if (requestCode == 1001) {
                val granted = grantResult == PackageManager.PERMISSION_GRANTED
                permissionCallback?.invoke(granted)
                permissionCallback = null
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAvailable" -> {
                    val available = try {
                        Shizuku.pingBinder()
                    } catch (e: Throwable) {
                        false
                    }
                    result.success(available)
                }
                "checkPermission" -> {
                    val granted = if (Shizuku.isPreV11()) {
                        false
                    } else {
                        Shizuku.checkSelfPermission() == PackageManager.PERMISSION_GRANTED
                    }
                    result.success(granted)
                }
                "requestPermission" -> {
                    if (Shizuku.isPreV11()) {
                        result.success(false)
                        return@setMethodCallHandler
                    }
                    if (Shizuku.checkSelfPermission() == PackageManager.PERMISSION_GRANTED) {
                        result.success(true)
                        return@setMethodCallHandler
                    }
                    permissionCallback = { granted ->
                        result.success(granted)
                    }
                    try {
                        Shizuku.requestPermission(1001)
                    } catch (e: Throwable) {
                        permissionCallback = null
                        result.error("ERROR", e.message, null)
                    }
                }
                "execute" -> {
                    val command = call.argument<String>("command")
                    if (command == null) {
                        result.error("BAD_ARGS", "Missing command", null)
                        return@setMethodCallHandler
                    }

                    // Run execute in background thread to avoid blocking main UI thread
                    thread {
                        try {
                            val process = Shizuku.newProcess(arrayOf("sh"), null, null)
                            val os = process.outputStream
                            os.write((command + "\n").toByteArray())
                            os.write("exit\n".toByteArray())
                            os.flush()

                            val stdout = process.inputStream.bufferedReader().use { it.readText() }
                            val stderr = process.errorStream.bufferedReader().use { it.readText() }
                            val exitCode = process.waitFor()

                            runOnUiThread {
                                result.success(mapOf(
                                    "exitCode" to exitCode,
                                    "stdout" to stdout,
                                    "stderr" to stderr
                                ))
                            }
                        } catch (e: Throwable) {
                            runOnUiThread {
                                result.success(mapOf(
                                    "exitCode" to -1,
                                    "stdout" to "",
                                    "stderr" to e.message.toString()
                                ))
                            }
                        }
                    }
                }
                "getInstalledApps" -> {
                    thread {
                        try {
                            val pm = packageManager
                            val packages = pm.getInstalledPackages(0)
                            val appList = ArrayList<Map<String, Any>>()
                            for (pkg in packages) {
                                 val appInfo = pkg.applicationInfo
                                 if (appInfo != null) {
                                     val map = HashMap<String, Any>()
                                     map["packageName"] = pkg.packageName
                                     map["label"] = appInfo.loadLabel(pm).toString()
                                     map["isSystem"] = (appInfo.flags and android.content.pm.ApplicationInfo.FLAG_SYSTEM) != 0
                                     appList.add(map)
                                 }
                            }
                            runOnUiThread {
                                result.success(appList)
                            }
                        } catch (e: Throwable) {
                            runOnUiThread {
                                result.error("ERROR", e.message, null)
                            }
                        }
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
