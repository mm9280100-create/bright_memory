package com.example.br_memory

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.speech.tts.TextToSpeech
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class MainActivity : FlutterFragmentActivity() {
    private val alertsChannel = "br_memory/alerts"
    private val contactChannel = "br_memory/contact"
    private val incomingCallChannel = "br_memory/incoming_call"
    private val notificationChannelId = "br_memory_fall_alerts"
    private val incomingCallChannelId = "br_memory_incoming_calls"
    private var notificationId = 3001
    private var incomingCallNotificationId = 4001
    private var pendingIncomingCallAction: String? = null
    private var pendingIncomingCallIsVideo: Boolean = false
    private var pendingIncomingCallCallerName: String? = null
    private var pendingIncomingCallSessionId: String? = null
    private var flutterEngineRef: FlutterEngine? = null
    private var textToSpeech: TextToSpeech? = null
    private var textToSpeechReady: Boolean = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngineRef = flutterEngine
        createNotificationChannel()
        handleIncomingCallIntent(intent)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, alertsChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "showFallAlert", "showSensorAlert" -> {
                        val title = call.argument<String>("title") ?: "Br. Memory Alert"
                        val message = call.argument<String>("message") ?: ""
                        val speak = call.argument<Boolean>("speak") ?: (call.method == "showSensorAlert")
                        showAlertNotification(title, message)
                        if (speak && message.isNotBlank()) {
                            speakAlert(message)
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, contactChannel)
            .setMethodCallHandler { call, result ->
                val phoneNumber = call.argument<String>("phoneNumber") ?: ""
                when (call.method) {
                    "openPhoneCall" -> result.success(openPhoneDialer(phoneNumber))
                    "openWhatsApp" -> result.success(openWhatsApp(phoneNumber))
                    "shareText" -> {
                        val text = call.argument<String>("text") ?: ""
                        result.success(shareText(text))
                    }
                    "openMeetingRoom" -> {
                        val url = call.argument<String>("url") ?: ""
                        result.success(openMeetingRoom(url))
                    }
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, incomingCallChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "showIncomingCall" -> {
                        val callerName = call.argument<String>("callerName") ?: "Caller"
                        val isVideo = call.argument<Boolean>("isVideo") ?: false
                        val sessionId = call.argument<String>("sessionId") ?: ""
                        showIncomingCallNotification(callerName, isVideo, sessionId)
                        result.success(null)
                    }
                    "clearIncomingCall" -> {
                        clearIncomingCallNotification()
                        result.success(null)
                    }
                    "getInitialAction" -> {
                        result.success(
                            mapOf(
                                "action" to pendingIncomingCallAction,
                                "isVideo" to pendingIncomingCallIsVideo,
                                "callerName" to pendingIncomingCallCallerName,
                                "sessionId" to pendingIncomingCallSessionId
                            )
                        )
                        pendingIncomingCallAction = null
                        pendingIncomingCallCallerName = null
                        pendingIncomingCallSessionId = null
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onDestroy() {
        textToSpeech?.stop()
        textToSpeech?.shutdown()
        textToSpeech = null
        super.onDestroy()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIncomingCallIntent(intent)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channel = NotificationChannel(
            notificationChannelId,
            "Fall alerts",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Patient fall detection alerts"
            enableVibration(true)
        }
        manager.createNotificationChannel(channel)

        val callChannel = NotificationChannel(
            incomingCallChannelId,
            "Incoming calls",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Incoming audio and video call alerts"
            enableVibration(true)
            lockscreenVisibility = Notification.VISIBILITY_PUBLIC
        }
        manager.createNotificationChannel(callChannel)
    }

    private fun showIncomingCallNotification(callerName: String, isVideo: Boolean, sessionId: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            ActivityCompat.checkSelfPermission(
                this,
                Manifest.permission.POST_NOTIFICATIONS
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            return
        }

        val answerIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("incoming_call_action", "answer")
            putExtra("incoming_call_is_video", isVideo)
            putExtra("incoming_call_caller_name", callerName)
            putExtra("incoming_call_session_id", sessionId)
        }
        val declineIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("incoming_call_action", "decline")
            putExtra("incoming_call_is_video", isVideo)
            putExtra("incoming_call_caller_name", callerName)
            putExtra("incoming_call_session_id", sessionId)
        }
        val openIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }

        val answerPendingIntent = PendingIntent.getActivity(
            this,
            4101,
            answerIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val declinePendingIntent = PendingIntent.getActivity(
            this,
            4102,
            declineIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val fullScreenPendingIntent = PendingIntent.getActivity(
            this,
            4103,
            openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val title = callerName
        val text = if (isVideo) "Video call" else "Audio call"
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, incomingCallChannelId)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }

        val notification = builder
            .setSmallIcon(android.R.drawable.sym_call_incoming)
            .setContentTitle(title)
            .setContentText(text)
            .setCategory(Notification.CATEGORY_CALL)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .setOngoing(true)
            .setAutoCancel(false)
            .setDefaults(Notification.DEFAULT_SOUND or Notification.DEFAULT_VIBRATE)
            .setOnlyAlertOnce(false)
            .setPriority(Notification.PRIORITY_MAX)
            .setFullScreenIntent(fullScreenPendingIntent, true)
            .addAction(android.R.drawable.sym_call_missed, "DECLINE", declinePendingIntent)
            .addAction(android.R.drawable.sym_call_incoming, "ANSWER", answerPendingIntent)
            .build()

        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.notify(incomingCallNotificationId, notification)
    }

    private fun clearIncomingCallNotification() {
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.cancel(incomingCallNotificationId)
    }

    private fun handleIncomingCallIntent(intent: Intent?) {
        val action = intent?.getStringExtra("incoming_call_action") ?: return
        val isVideo = intent.getBooleanExtra("incoming_call_is_video", false)
        val callerName = intent.getStringExtra("incoming_call_caller_name") ?: "Caller"
        val sessionId = intent.getStringExtra("incoming_call_session_id") ?: ""
        clearIncomingCallNotification()
        pendingIncomingCallAction = action
        pendingIncomingCallIsVideo = isVideo
        pendingIncomingCallCallerName = callerName
        pendingIncomingCallSessionId = sessionId
        flutterEngineRef?.dartExecutor?.binaryMessenger?.let { messenger ->
            MethodChannel(messenger, incomingCallChannel).invokeMethod(
                "incomingCallAction",
                mapOf(
                    "action" to action,
                    "isVideo" to isVideo,
                    "callerName" to callerName,
                    "sessionId" to sessionId
                )
            )
        }
    }

    private fun showAlertNotification(title: String, message: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            ActivityCompat.checkSelfPermission(
                this,
                Manifest.permission.POST_NOTIFICATIONS
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            return
        }

        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
            ?: Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, notificationChannelId)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }

        val notification = builder
            .setSmallIcon(android.R.drawable.ic_dialog_alert)
            .setContentTitle(title)
            .setContentText(message)
            .setStyle(Notification.BigTextStyle().bigText(message))
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .setPriority(Notification.PRIORITY_HIGH)
            .build()

        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.notify(notificationId++, notification)
    }

    private fun speakAlert(message: String) {
        val tts = textToSpeech
        if (tts == null) {
            textToSpeech = TextToSpeech(this) { status ->
                textToSpeechReady = status == TextToSpeech.SUCCESS
                if (textToSpeechReady) {
                    textToSpeech?.language = Locale.ENGLISH
                    textToSpeech?.setSpeechRate(0.92f)
                    textToSpeech?.speak(
                        message,
                        TextToSpeech.QUEUE_FLUSH,
                        null,
                        "sensor_alert_${System.currentTimeMillis()}"
                    )
                }
            }
            return
        }

        if (!textToSpeechReady) return
        tts.language = Locale.ENGLISH
        tts.speak(
            message,
            TextToSpeech.QUEUE_FLUSH,
            null,
            "sensor_alert_${System.currentTimeMillis()}"
        )
    }

    private fun openPhoneDialer(phoneNumber: String): Boolean {
        return try {
            val action = if (
                ActivityCompat.checkSelfPermission(
                    this,
                    Manifest.permission.CALL_PHONE
                ) == PackageManager.PERMISSION_GRANTED
            ) {
                Intent.ACTION_CALL
            } else {
                Intent.ACTION_DIAL
            }
            val intent = Intent(action).apply {
                data = Uri.parse("tel:${phoneNumber.trim()}")
            }
            startActivity(intent)
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun openWhatsApp(phoneNumber: String): Boolean {
        val digits = phoneNumber.filter { it.isDigit() }
        return try {
            val intent = Intent(Intent.ACTION_VIEW).apply {
                data = Uri.parse("https://wa.me/$digits")
                setPackage("com.whatsapp")
            }
            startActivity(intent)
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun openMeetingRoom(url: String): Boolean {
        if (url.isBlank()) return false
        return try {
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
            startActivity(intent)
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun shareText(text: String): Boolean {
        if (text.isBlank()) return false
        return try {
            val intent = Intent(Intent.ACTION_SEND).apply {
                type = "text/plain"
                putExtra(Intent.EXTRA_TEXT, text)
            }
            startActivity(Intent.createChooser(intent, "Share"))
            true
        } catch (_: Exception) {
            false
        }
    }
}
