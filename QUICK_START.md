# 呆呆面板 Android 原生应用 - 快速开始

## 快速构建指南

### 前提条件
- 已安装 Android SDK (API 21+)
- 已安装 JDK 11+
- 已配置环境变量

### 一键构建

```bash
# 进入项目目录
cd /workspace/daidai-panel-native-android

# 准备Go服务器
mkdir -p app/src/main/assets
cp ../build-android-quick/server/daidai-server-arm64 app/src/main/assets/
chmod +x app/src/main/assets/daidai-server-arm64

# 构建APK
chmod +x build-apk.sh
./build-apk.sh
```

### 手动构建

```bash
# 1. 设置环境变量
export ANDROID_HOME=/path/to/android-sdk
export JAVA_HOME=/path/to/jdk-11

# 2. 清理构建
./gradlew clean

# 3. 构建Debug版本
./gradlew assembleDebug

# 4. 安装到设备
adb install app/build/outputs/apk/debug/app-debug.apk
```

## 首次使用

1. 安装APK到Android设备
2. 打开应用，授权存储和电池优化权限
3. 点击"启动面板"按钮
4. 等待服务器启动完成
5. 开始使用呆呆面板

## 常见问题

### Q: 构建时提示找不到Android SDK?
A: 设置 ANDROID_HOME 环境变量指向你的Android SDK安装路径。

### Q: 无法安装APK?
A: 确保手机开启了"允许未知来源安装"设置。

### Q: 服务无法启动?
A: 检查存储权限和电池优化设置，将应用添加到白名单。

### Q: 开机不自启?
A: 在手机设置中授予应用自启动权限。

## 技术支持

如有问题，请查看详细文档:
- README.md - 项目概览
- IMPLEMENTATION.md - 详细实现文档  
- PROJECT_SUMMARY.md - 项目总结

## 项目特性

- ✅ 独立运行，无需Termux
- ✅ 无需Root权限
- ✅ 后台稳定运行
- ✅ 开机自动启动
- ✅ Material Design界面
- ✅ 前台服务保护
- ✅ 电池优化处理

## 版本信息

- 最低支持: Android 5.0 (API 21)
- 推荐版本: Android 10+ (API 29+)
- 目标版本: Android 13 (API 33)
