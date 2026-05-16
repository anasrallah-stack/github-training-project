package com.example.untitled16

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

class WifiTrackingService : Service() {

    companion object {
        const val CHANNEL_ID = "wifi_tracker_channel"
        const val NOTIFICATION_ID = 888
        const val ACTION_STOP = "ACTION_STOP_TRACKING"
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            stopForegroundService()
            return START_NOT_STICKY
        }
        startForegroundNotification()
        // ✅ START_NOT_STICKY — لا يُعاد تشغيل Service بعد الإيقاف
        return START_NOT_STICKY
    }

    private fun startForegroundNotification() {
        createChannel()

        val stopIntent = Intent(this, WifiTrackingService::class.java).apply {
            action = ACTION_STOP
        }
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        val stopPending = PendingIntent.getService(this, 0, stopIntent, flags)

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("TimeSync")
            .setContentText("جارٍ مراقبة شبكة العمل")
            .setSmallIcon(android.R.drawable.ic_menu_recent_history)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .addAction(android.R.drawable.ic_delete, "إيقاف", stopPending)
            .build()

        startForeground(NOTIFICATION_ID, notification)
    }

    private fun stopForegroundService() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        stopSelf()
    }

    private fun createChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "WiFi Tracker",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "تتبع ساعات العمل"
                setShowBadge(false)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    // ✅ onTaskRemoved موجود في Service وليس Activity
    override fun onTaskRemoved(rootIntent: Intent?) {
        super.onTaskRemoved(rootIntent)
        stopForegroundService()
    }
}