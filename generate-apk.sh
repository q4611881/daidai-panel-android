#!/bin/bash

# 呆呆面板 Android 应用 - 生成APK脚本
# 此脚本用于在没有Android SDK的环境中提供构建指导

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║         呆呆面板 Android 应用 - APK生成器                    ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 检查环境
echo "🔍 检查构建环境..."
if [ -z "$ANDROID_HOME" ]; then
    echo "❌ Android SDK 未找到"
    echo ""
    echo "💡 解决方案："
    echo ""
    echo "方案 1: 使用 Android Studio"
    echo "  1. 下载并安装 Android Studio"
    echo "  2. 打开项目: $SCRIPT_DIR"
    echo "  3. 点击 Build -> Build Bundle(s) / APK(s) -> Build APK(s)"
    echo ""
    echo "方案 2: 使用命令行构建"
    echo "  1. 安装 Android SDK"
    echo "  2. 设置环境变量: export ANDROID_HOME=/path/to/android-sdk"
    echo "  3. 运行: ./gradlew assembleDebug"
    echo ""
    echo "方案 3: 使用在线构建服务"
    echo "  1. 将项目上传到 GitHub"
    echo "  2. 使用 GitHub Actions 自动构建"
    echo "  3. 或使用其他CI/CD服务"
    echo ""
    
    # 创建GitHub Actions配置
    echo "📝 正在创建 GitHub Actions 配置..."
    mkdir -p .github/workflows
    cat > .github/workflows/build-apk.yml << 'GITHUB_EOF'
name: Build APK

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Set up JDK 11
      uses: actions/setup-java@v3
      with:
        java-version: '11'
        distribution: 'temurin'

    - name: Set up Android SDK
      uses: android-actions/setup-android@v2

    - name: Grant execute permission for gradlew
      run: chmod +x gradlew

    - name: Build Debug APK
      run: ./gradlew assembleDebug --stacktrace

    - name: Build Release APK
      run: ./gradlew assembleRelease --stacktrace

    - name: Upload Debug APK
      uses: actions/upload-artifact@v3
      with:
        name: debug-apk
        path: app/build/outputs/apk/debug/app-debug.apk

    - name: Upload Release APK
      uses: actions/upload-artifact@v3
      with:
        name: release-apk
        path: app/build/outputs/apk/release/app-release.apk
GITHUB_EOF

    echo "✅ GitHub Actions 配置已创建: .github/workflows/build-apk.yml"
    echo ""
    echo "🚀 快速开始:"
    echo "  1. 将项目推送到 GitHub"
    echo "  2. 在 GitHub 上启用 Actions"
    echo "  3. 手动触发构建或推送代码自动构建"
    echo "  4. 下载生成的 APK 文件"
    echo ""
    
    # 创建详细的构建指南
    cat > BUILD_GUIDE.md << 'GUIDE_EOF'
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
GUIDE_EOF

    echo "✅ 详细构建指南已创建: BUILD_GUIDE.md"
    echo ""
    exit 1
fi

# 继续构建流程
echo "✅ Android SDK 已找到: $ANDROID_HOME"
echo ""

# 检查 Java
if ! command -v java &> /dev/null; then
    echo "❌ Java 未安装"
    echo "请安装 JDK 11 或更高版本"
    exit 1
fi

echo "✅ Java 已安装: $(java -version 2>&1 | head -1)"
echo ""

# 清理旧构建
echo "🧹 清理旧构建..."
./gradlew clean || exit 1
echo ""

# 构建 APK
echo "🔨 开始构建 APK..."
echo "这可能需要几分钟时间..."
echo ""

./gradlew assembleDebug || exit 1

echo ""
echo "✅ 构建完成！"
echo ""

# 检查 APK 文件
APK_PATH="app/build/outputs/apk/debug/app-debug.apk"
if [ -f "$APK_PATH" ]; then
    APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
    echo "📦 APK 信息:"
    echo "   位置: $APK_PATH"
    echo "   大小: $APK_SIZE"
    echo ""
    
    # 复制到项目根目录
    cp "$APK_PATH" "./daidai-panel-debug.apk"
    echo "✅ APK 已复制到: ./daidai-panel-debug.apk"
    echo ""
    
    echo "🚀 安装方法:"
    echo "   方法 1: adb install daidai-panel-debug.apk"
    echo "   方法 2: 直接复制到手机安装"
    echo ""
    
    echo "📱 使用说明:"
    echo "   1. 安装 APK 到 Android 设备"
    echo "   2. 打开应用，授权必要权限"
    echo "   3. 点击'启动面板'"
    echo "   4. 等待服务启动"
    echo "   5. 开始使用呆呆面板"
    echo ""
    
    echo "🎉 恭喜！APK 构建成功！"
else
    echo "❌ APK 构建失败"
    exit 1
fi