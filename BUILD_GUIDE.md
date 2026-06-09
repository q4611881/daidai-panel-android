# 呆呆面板 Android 应用 - APK 构建指南

## 方法 1: 使用 Android Studio (推荐)

### 步骤:
1. **安装 Android Studio**
   - 下载: https://developer.android.com/studio
   - 安装并启动 Android Studio

2. **打开项目**
   - File -> Open
   - 选择项目目录: `daidai-panel-native-android`
   - 等待 Gradle 同步完成

3. **构建 APK**
   - Build -> Build Bundle(s) / APK(s) -> Build APK(s)
   - 等待构建完成

4. **获取 APK**
   - 构建完成后，点击通知中的 "locate"
   - APK 位置: `app/build/outputs/apk/debug/app-debug.apk`

---

## 方法 2: 使用命令行

### 环境准备:
```bash
# 安装 Android SDK
# 下载: https://developer.android.com/studio#command-tools

# 设置环境变量
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin

# 验证安装
adb version
```

### 构建步骤:
```bash
# 进入项目目录
cd daidai-panel-native-android

# 构建调试版本
./gradlew assembleDebug

# 构建发布版本
./gradlew assembleRelease

# APK 位置
# Debug: app/build/outputs/apk/debug/app-debug.apk
# Release: app/build/outputs/apk/release/app-release.apk
```

---

## 方法 3: 使用 GitHub Actions

### 步骤:
1. **推送到 GitHub**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin https://github.com/your-username/daidai-panel-android.git
   git push -u origin main
   ```

2. **启用 GitHub Actions**
   - 访问 GitHub 仓库
   - 点击 Actions 标签
   - 启用 Actions

3. **触发构建**
   - 推送代码自动触发
   - 或手动触发: Actions -> Build APK -> Run workflow

4. **下载 APK**
   - 构建完成后，下载 Artifacts
   - 解压获取 APK 文件

---

## 方法 4: 使用 Docker

### 使用 Docker 构建:
```bash
# 构建镜像
docker build -t daidai-panel-builder .

# 运行构建
docker run --rm -v $(pwd):/workspace daidai-panel-builder

# APK 位置
# app/build/outputs/apk/debug/app-debug.apk
```

### Dockerfile:
```dockerfile
FROM openjdk:11-jdk

# 安装 Android SDK
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
RUN unzip commandlinetools-linux-9477386_latest.zip -d /opt/android-sdk
RUN mkdir -p /opt/android-sdk/cmdline-tools/latest
RUN mv /opt/android-sdk/cmdline-tools/* /opt/android-sdk/cmdline-tools/latest/

# 设置环境变量
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
ENV PATH=$PATH:$ANDROID_HOME/platform-tools

# 接受许可
RUN yes | sdkmanager --licenses || true

# 安装必要的 SDK 组件
RUN sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"

WORKDIR /workspace
COPY . .

# 构建 APK
RUN chmod +x gradlew && ./gradlew assembleDebug
```

---

## 常见问题

### Q: Gradle 构建失败?
A: 检查网络连接，Gradle 需要下载依赖。

### Q: SDK 版本不匹配?
A: 更新 build.gradle.kts 中的 SDK 版本。

### Q: 签名问题?
A: Debug 版本使用默认签名，Release 版本需要配置签名。

---

## APK 信息

### Debug 版本
- 文件名: `app-debug.apk`
- 大小: ~15-20MB
- 签名: Debug 签名
- 用途: 测试和开发

### Release 版本
- 文件名: `app-release.apk`
- 大小: ~10-15MB
- 签名: 需要配置
- 用途: 发布和分发

---

## 下一步

构建完成后:
1. 在 Android 设备上安装 APK
2. 授予必要的权限
3. 启动应用
4. 点击"启动面板"
5. 开始使用呆呆面板
