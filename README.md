# 呆呆面板 Android 原生应用

独立运行的Android应用，无需Termux或Root权限。

## 项目结构

```
daidai-panel-native-android/
├── app/
│   ├── src/
│   │   └── main/
│   │       ├── java/com/daidai/panel/
│   │       │   ├── MainActivity.kt          # 主界面
│   │       │   ├── PanelService.kt          # 后台服务
│   │       │   └── BootReceiver.kt          # 开机自启接收器
│   │       ├── res/
│   │       │   ├── layout/
│   │       │   │   └── activity_main.xml    # 主界面布局
│   │       │   ├── values/
│   │       │   │   ├── strings.xml
│   │       │   │   ├── colors.xml
│   │       │   │   └── themes.xml
│   │       │   └── drawable/
│   │       │       ├── ic_status_running.xml
│   │       │       ├── ic_status_stopped.xml
│   │       │       └── ic_notification.xml
│   │       └── AndroidManifest.xml
│   └── build.gradle.kts
├── gradle/wrapper/
│   └── gradle-wrapper.jar
├── gradlew
└── gradle.properties
```

## 功能特性

1. **独立运行**: 不依赖Termux，完全独立的Android应用
2. **WebView界面**: 使用Android WebView显示呆呆面板界面
3. **后台服务**: 嵌入Go服务器，后台稳定运行
4. **开机自启**: 支持开机自动启动服务
5. **前台通知**: 显示前台通知防止被系统杀死
6. **控制界面**: 提供启动/停止/刷新控制按钮

## 构建方法

### 环境要求

- Android SDK (API 21+)
- JDK 8+
- Gradle 8.2+

### 构建步骤

1. 配置Android SDK路径:
```bash
export ANDROID_HOME=/path/to/android-sdk
```

2. 构建APK:
```bash
cd /workspace/daidai-panel-native-android
./gradlew assembleDebug
```

3. 生成的APK位置:
```
app/build/outputs/apk/debug/app-debug.apk
```

## 安装使用

1. 安装APK到Android设备:
```bash
adb install app-debug.apk
```

2. 打开应用，点击"启动面板"按钮

3. 首次启动需要请求存储权限和电池优化例外

## 技术实现

### MainActivity.kt
- WebView界面管理
- 服务控制按钮
- 状态显示和更新

### PanelService.kt
- 前台服务实现
- Go服务器进程管理
- 通知栏显示
- 电池优化处理

### BootReceiver.kt
- 监听开机完成广播
- 自动启动后台服务

## 架构设计

```
┌─────────────────────────────────┐
│   MainActivity (UI Layer)       │
│   - WebView显示面板              │
│   - 控制按钮                    │
│   - 状态更新                    │
└──────────┬──────────────────────┘
           │
           ↓
┌─────────────────────────────────┐
│   PanelService (Service Layer)  │
│   - 前台服务                    │
│   - 进程管理                    │
│   - 通知栏                      │
└──────────┬──────────────────────┘
           │
           ↓
┌─────────────────────────────────┐
│   Go Server (Native Layer)      │
│   - daidai-server-arm64         │
│   - 本地HTTP服务                │
│   - 面板功能                    │
└─────────────────────────────────┘
```

## 权限说明

- INTERNET: 网络访问
- FOREGROUND_SERVICE: 前台服务
- WAKE_LOCK: 唤醒锁
- REQUEST_IGNORE_BATTERY_OPTIMIZATIONS: 电池优化例外
- WRITE_EXTERNAL_STORAGE: 文件写入
- RECEIVE_BOOT_COMPLETED: 开机自启

## 注意事项

1. **Go服务器集成**: 需要将预编译的`daidai-server-arm64`复制到`assets/`目录
2. **签名配置**: 生产环境需要配置签名密钥
3. **应用权限**: 某些ROM需要手动授予后台运行权限
4. **电池优化**: 建议添加到电池优化白名单

## 版本信息

- 最低API: 21 (Android 5.0)
- 目标API: 33 (Android 13)
- Kotlin: 1.9.0
- Gradle: 8.2
- Android Gradle Plugin: 8.1.0

## 开发计划

- [x] 基础项目结构创建
- [x] MainActivity和PanelService实现
- [x] 布局和资源文件
- [x] AndroidManifest配置
- [ ] Go服务器集成
- [ ] APK构建和测试
- [ ] 功能完善和优化