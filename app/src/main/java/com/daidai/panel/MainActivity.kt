package com.daidai.panel

import android.annotation.SuppressLint
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.NotificationCompat
import com.daidai.panel.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {
    
    private lateinit var binding: ActivityMainBinding
    private lateinit var webView: WebView
    private val PANEL_PORT = 5700
    private val CHANNEL_ID = "panel_channel"
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        
        setupNotifications()
        setupWebView()
        setupButtons()
        
        // 启动面板服务
        startPanelService()
    }

    @SuppressLint("SetJavaScriptEnabled")
    private fun setupWebView() {
        webView = binding.webView
        
        val settings = webView.settings
        settings.apply {
            javaScriptEnabled = true
            domStorageEnabled = true
            databaseEnabled = true
            allowFileAccess = true
            allowContentAccess = true
            cacheMode = WebSettings.LOAD_DEFAULT
            mixedContentMode = WebSettings.MIXED_CONTENT_ALWAYS_ALLOW
        }
        
        webView.webViewClient = object : WebViewClient() {
            override fun onPageFinished(view: WebView?, url: String?) {
                super.onPageFinished(view, url)
                binding.progressBar.visibility = android.view.View.GONE
            }
        }
        
        loadPanelInterface()
    }
    
    private fun loadPanelInterface() {
        // 加载本地构建的Web界面
        val webDir = filesDir.absolutePath + "/web"
        if (java.io.File("$webDir/index.html").exists()) {
            webView.loadUrl("http://localhost:$PANEL_PORT/")
        } else {
            // 显示启动界面
            showLoadingScreen()
        }
    }
    
    private fun showLoadingScreen() {
        webView.loadDataWithBaseURL(
            "http://localhost:$PANEL_PORT/",
            """
            <html>
            <head>
                <meta charset="utf-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <style>
                    * { margin: 0; padding: 0; box-sizing: border-box; }
                    body { 
                        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
                        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                        min-height: 100vh;
                        display: flex;
                        justify-content: center;
                        align-items: center;
                        color: white;
                    }
                    .container { 
                        text-align: center; 
                        padding: 20px; 
                        max-width: 600px;
                    }
                    h1 { 
                        font-size: 2.5em; 
                        margin-bottom: 10px;
                        text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
                    }
                    p { 
                        font-size: 1.2em; 
                        margin-bottom: 20px;
                        opacity: 0.9;
                    }
                    .status-box {
                        background: rgba(255,255,255,0.2);
                        border-radius: 15px;
                        padding: 30px;
                        margin: 20px 0;
                        backdrop-filter: blur(10px);
                    }
                    .status-icon {
                        font-size: 4em;
                        margin-bottom: 15px;
                    }
                    .status-text {
                        font-size: 1.3em;
                        margin-bottom: 10px;
                    }
                    .detail-text {
                        font-size: 0.9em;
                        opacity: 0.8;
                        line-height: 1.6;
                    }
                    .loading {
                        animation: pulse 2s infinite;
                    }
                    @keyframes pulse {
                        0%, 100% { opacity: 1; }
                        50% { opacity: 0.5; }
                    }
                    .button {
                        background: white;
                        color: #667eea;
                        border: none;
                        padding: 15px 40px;
                        border-radius: 25px;
                        font-size: 1.1em;
                        font-weight: bold;
                        cursor: pointer;
                        margin: 10px;
                        box-shadow: 0 5px 15px rgba(0,0,0,0.2);
                    }
                </style>
            </head>
            <body>
                <div class="container">
                    <h1>🚀 呆呆面板</h1>
                    <p>本地定时任务管理系统</p>
                    <div class="status-box">
                        <div class="status-icon loading">⏳</div>
                        <div class="status-text">正在启动面板服务...</div>
                        <div class="detail-text">
                            首次启动可能需要1-2分钟<br>
                            请稍候，服务即将就绪
                        </div>
                    </div>
                    <button class="button" onclick="location.reload()">刷新状态</button>
                </div>
            </body>
            </html>
            """.trimIndent(),
            "text/html",
            "UTF-8",
            null
        )
    }

    private fun setupButtons() {
        binding.startButton.setOnClickListener {
            startPanelService()
        }
        
        binding.stopButton.setOnClickListener {
            stopPanelService()
        }
        
        binding.refreshButton.setOnClickListener {
            webView.loadUrl("http://localhost:$PANEL_PORT/")
        }
        
        binding.settingsButton.setOnClickListener {
            // TODO: 打开设置界面
        }
    }

    private fun setupNotifications() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "面板服务",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "呆呆面板后台服务通知"
            }
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun startPanelService() {
        val intent = Intent(this, PanelService::class.java)
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
        
        updateStatus(true)
        showNotification("呆呆面板", "面板服务已启动")
        
        // 延迟刷新界面
        binding.root.postDelayed({
            loadPanelInterface()
        }, 3000)
    }

    private fun stopPanelService() {
        val intent = Intent(this, PanelService::class.java)
        stopService(intent)
        
        updateStatus(false)
        showNotification("呆呆面板", "面板服务已停止")
        
        // 显示停止界面
        showStoppedScreen()
    }
    
    private fun showStoppedScreen() {
        webView.loadDataWithBaseURL(
            "http://localhost:$PANEL_PORT/",
            """
            <html>
            <head>
                <meta charset="utf-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <style>
                    * { margin: 0; padding: 0; box-sizing: border-box; }
                    body { 
                        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
                        background: #f5f5f5;
                        min-height: 100vh;
                        display: flex;
                        justify-content: center;
                        align-items: center;
                        color: #333;
                    }
                    .container { 
                        text-align: center; 
                        padding: 20px;
                    }
                    h1 { 
                        font-size: 2em; 
                        margin-bottom: 10px;
                        color: #555;
                    }
                    p { 
                        font-size: 1.1em; 
                        margin-bottom: 20px;
                        color: #666;
                    }
                    .status-box {
                        background: white;
                        border-radius: 15px;
                        padding: 40px;
                        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                    }
                    .status-icon {
                        font-size: 4em;
                        margin-bottom: 15px;
                    }
                    .button {
                        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                        color: white;
                        border: none;
                        padding: 15px 40px;
                        border-radius: 25px;
                        font-size: 1.1em;
                        font-weight: bold;
                        cursor: pointer;
                        margin: 20px 10px;
                    }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="status-box">
                        <div class="status-icon">⏹️</div>
                        <h1>面板已停止</h1>
                        <p>点击上方「启动面板」按钮重新启动服务</p>
                        <button class="button" onclick="location.reload()">立即启动</button>
                    </div>
                </div>
            </body>
            </html>
            """.trimIndent(),
            "text/html",
            "UTF-8",
            null
        )
    }

    private fun updateStatus(isRunning: Boolean) {
        if (isRunning) {
            binding.statusIndicator.setImageResource(R.drawable.ic_status_running)
            binding.statusText.text = "运行中"
            binding.startButton.isEnabled = false
            binding.stopButton.isEnabled = true
        } else {
            binding.statusIndicator.setImageResource(R.drawable.ic_status_stopped)
            binding.statusText.text = "已停止"
            binding.startButton.isEnabled = true
            binding.stopButton.isEnabled = false
        }
    }

    private fun showNotification(title: String, message: String) {
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(message)
            .setSmallIcon(R.drawable.ic_notification)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
        
        val notificationManager = getSystemService(NotificationManager::class.java)
        notificationManager.notify(1, notification)
    }

    override fun onBackPressed() {
        if (webView.canGoBack()) {
            webView.goBack()
        } else {
            super.onBackPressed()
        }
    }
}