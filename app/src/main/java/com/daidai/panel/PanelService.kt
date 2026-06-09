package com.daidai.panel

import android.app.Notification
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.IBinder
import androidx.core.app.NotificationCompat
import kotlinx.coroutines.*
import java.io.BufferedReader
import java.io.File
import java.io.InputStreamReader

class PanelService : Service() {
    
    private val serviceScope = CoroutineScope(Dispatchers.IO + Job())
    private var process: Process? = null
    private var isRunning = false
    
    companion object {
        const val PANEL_PORT = 5700
        const val CHANNEL_ID = "panel_channel"
        const val NOTIFICATION_ID = 1
    }

    override fun onCreate() {
        super.onCreate()
        startForeground(NOTIFICATION_ID, createNotification())
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (!isRunning) {
            startPanel()
        }
        return START_STICKY
    }

    private fun startPanel() {
        serviceScope.launch {
            try {
                isRunning = true
                extractAssets()
                launchGoServer()
                updateNotification(true)
            } catch (e: Exception) {
                e.printStackTrace()
                isRunning = false
                updateNotification(false)
            }
        }
    }

    private fun stopPanel() {
        serviceScope.launch {
            try {
                process?.destroy()
                process = null
                isRunning = false
                updateNotification(false)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    private fun extractAssets() {
        try {
            val webDir = File(filesDir, "web")
            if (!webDir.exists()) {
                webDir.mkdirs()
            }
            
            // 从assets中提取Go服务器
            val goServerFile = File(filesDir, "daidai-server")
            if (!goServerFile.exists()) {
                assets.open("daidai-server-arm64").use { inputStream ->
                    goServerFile.outputStream().use { outputStream ->
                        inputStream.copyTo(outputStream)
                    }
                }
                
                // 设置执行权限
                val chmod = Runtime.getRuntime().exec(arrayOf("chmod", "755", goServerFile.absolutePath))
                chmod.waitFor()
            }
            
        } catch (e: Exception) {
            throw RuntimeException("提取assets文件失败: ${e.message}", e)
        }
    }

    private suspend fun launchGoServer() {
        withContext(Dispatchers.IO) {
            try {
                val goServerPath = File(filesDir, "daidai-server").absolutePath
                val configPath = File(filesDir, "config.yaml").absolutePath
                
                // 检查Go服务器是否存在
                if (!File(goServerPath).exists()) {
                    throw RuntimeException("Go服务器二进制文件不存在")
                }
                
                // 设置执行权限
                val chmod = Runtime.getRuntime().exec(arrayOf("chmod", "+x", goServerPath))
                chmod.waitFor()
                
                // 创建配置文件
                createConfigFile(configPath)
                
                // 启动Go服务器
                val processBuilder = ProcessBuilder(goServerPath)
                processBuilder.directory(filesDir)
                processBuilder.redirectErrorStream(true)
                
                process = processBuilder.start()
                
                // 读取输出用于日志
                val reader = BufferedReader(InputStreamReader(process!!.inputStream))
                var line: String?
                while (reader.readLine().also { line = it } != null) {
                    line?.let {
                        // 这里可以记录日志
                    }
                }
                
                val exitCode = process!!.waitFor()
                isRunning = false
                
                if (exitCode != 0) {
                    throw RuntimeException("Go服务器异常退出，退出码: $exitCode")
                }
                
            } catch (e: Exception) {
                e.printStackTrace()
                isRunning = false
                throw e
            }
        }
    }

    private fun createConfigFile(configPath: String) {
        val configContent = """
            server:
              port: $PANEL_PORT
              mode: release

            database:
              path: ./data/daidai.db

            jwt:
              secret: ""
              access_token_expire: 480h
              refresh_token_expire: 1440h

            data:
              dir: ./data
              scripts_dir: ./data/scripts
              log_dir: ./data/logs

            cors:
              origins:
                - http://localhost:$PANEL_PORT
                - http://127.0.0.1:$PANEL_PORT
        """.trimIndent()
        
        File(configPath).writeText(configContent)
        
        // 创建必要的数据目录
        val dataDir = File(filesDir, "data")
        dataDir.mkdirs()
        File(dataDir, "scripts").mkdirs()
        File(dataDir, "logs").mkdirs()
        File(dataDir, "backups").mkdirs()
    }

    private fun createNotification(): Notification {
        val intent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("呆呆面板运行中")
            .setContentText("点击打开面板")
            .setSmallIcon(R.drawable.ic_notification)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .build()
    }

    private fun updateNotification(isRunning: Boolean) {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(NOTIFICATION_ID, createNotification())
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        super.onDestroy()
        stopPanel()
        serviceScope.cancel()
    }
}