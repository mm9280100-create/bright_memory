package com.example.br_memory

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class CallFirebaseMessagingService : FirebaseMessagingService() {
    private val incomingCallChannelId = "br_memory_incoming_calls"
    private val incomingCallNotificationId = 4001

    override fun onMessageReceived(message: RemoteMessage) {
        val data = message.data
        if (data["type"] != "call-invite") return
        if (data["target"] != "br_memory") return
        val createdAt = data["createdAt"]?.toLongOrNull() ?: 0L
        if (createdAt > 0L && System.currentTimeMillis() - createdAt > 45_000L) return

        showIncomingCallNotification(
            callerName = data["from"] ?: "Caller",
            isVideo = data["mode"] == "video",
            sessionId = data["sessionId"] ?: ""
        )
    }

    private fun showIncomingCallNotification(
        callerName: String,
        isVideo: Boolean,
        sessionId: String
    ) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            ActivityCompat.checkSelfPermission(
                this,
                Manifest.permission.POST_NOTIFICATIONS
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            return
        }

        createIncomingCallChannel()

        val answerIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_SINGLE_TOP or
                Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("incoming_call_action", "answer")
            putExtra("incoming_call_is_video", isVideo)
            putExtra("incoming_call_caller_name", callerName)
            putExtra("incoming_call_session_id", sessionId)
        }
        val declineIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_SINGLE_TOP or
                Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("incoming_call_action", "decline")
            putExtra("incoming_call_is_video", isVideo)
            putExtra("incoming_call_caller_name", callerName)
            putExtra("incoming_call_session_id", sessionId)
        }
        val openIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_SINGLE_TOP or
                Intent.FLAG_ACTIVITY_CLEAR_TOP
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

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, incomingCallChannelId)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }

        val notification = builder
            .setSmallIcon(android.R.drawable.sym_call_incoming)
            .setContentTitle(callerName)
            .setContentText(if (isVideo) "Video call" else "Audio call")
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

    private fun createIncomingCallChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channel = NotificationChannel(
            incomingCallChannelId,
            "Incoming calls",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Incoming audio and video call alerts"
            enableVibration(true)
            lockscreenVisibility = Notification.VISIBILITY_PUBLIC
        }
        manager.createNotificationChannel(channel)
    }
}
