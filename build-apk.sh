#!/bin/bash

# 呆呆面板Android应用构建脚本

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "======================================"
echo "呆呆面板 Android 应用构建"
echo "======================================"

# 检查环境
echo "检查构建环境..."

if [ -z "$ANDROID_HOME" ]; then
    echo "错误: ANDROID_HOME 环境变量未设置"
    echo "请设置: export ANDROID_HOME=/path/to/android-sdk"
    exit 1
fi

if [ ! -f "gradlew" ]; then
    echo "错误: gradlew 脚本不存在"
    exit 1
fi

if [ ! -f "gradle/wrapper/gradle-wrapper.jar" ]; then
    echo "错误: gradle wrapper jar 不存在"
    exit 1
fi

# 检查Java
if ! command -v java &> /dev/null; then
    echo "错误: Java 未安装或未添加到PATH"
    exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | head -1 | cut -d'"' -f2 | cut -d'.' -f1)
if [ "$JAVA_VERSION" -lt 11 ]; then
    echo "错误: 需要 Java 11 或更高版本"
    exit 1
fi

echo "环境检查完成"

# 清理旧的构建
echo "清理旧的构建..."
./gradlew clean

# 构建Debug APK
echo "构建 Debug APK..."
./gradlew assembleDebug

APK_PATH="app/build/outputs/apk/debug/app-debug.apk"

if [ -f "$APK_PATH" ]; then
    APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
    echo "======================================"
    echo "构建成功!"
    echo "======================================"
    echo "APK 位置: $APK_PATH"
    echo "APK 大小: $APK_SIZE"
    echo ""
    echo "安装命令:"
    echo "  adb install $APK_PATH"
    echo ""
    echo "或者直接复制APK文件到手机安装"
else
    echo "错误: APK 构建失败"
    exit 1
fi