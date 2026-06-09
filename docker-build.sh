#!/bin/bash

# 呆呆面板 Android 应用 - Docker 构建脚本

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║         呆呆面板 Android 应用 - Docker 构建                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装"
    echo ""
    echo "💡 请先安装 Docker:"
    echo "   Ubuntu/Debian: sudo apt-get install docker.io"
    echo "   macOS: 下载 Docker Desktop"
    echo "   Windows: 下载 Docker Desktop"
    echo ""
    exit 1
fi

echo "✅ Docker 已安装: $(docker --version)"
echo ""

# 检查 Docker 服务是否运行
if ! docker info &> /dev/null; then
    echo "❌ Docker 服务未运行"
    echo "💡 请启动 Docker 服务"
    exit 1
fi

echo "✅ Docker 服务运行中"
echo ""

# 构建 Docker 镜像
echo "🐳 构建 Docker 镜像..."
echo "这可能需要 10-20 分钟 (首次构建需要下载 Android SDK)"
echo ""

docker build -t daidai-panel-builder . || exit 1

echo ""
echo "✅ Docker 镜像构建完成"
echo ""

# 运行构建
echo "🔨 开始构建 APK..."
echo ""

docker run --rm -v "$(pwd):/workspace" daidai-panel-builder || exit 1

echo ""
echo "✅ APK 构建完成"
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