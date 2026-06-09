#!/bin/bash

# 呆呆面板 Android 应用 - 一键生成APK
# 自动检测环境并选择最佳构建方法

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                                ║"
echo "║         🚀 呆呆面板 Android 应用 - 一键生成 🚀                 ║"
echo "║                                                                ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 显示选项
echo "🎯 选择构建方法："
echo ""
echo "  1. Android Studio (推荐，最简单)"
echo "  2. 命令行构建 (需要 Android SDK)"
echo "  3. Docker 构建 (无需 Android SDK)"
echo "  4. GitHub Actions (在线自动构建)"
echo "  5. 查看详细说明"
echo "  0. 退出"
echo ""

read -p "请选择 (0-5): " choice

case $choice in
    1)
        echo ""
        echo "📱 使用 Android Studio 构建"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "步骤："
        echo "  1. 下载 Android Studio: https://developer.android.com/studio"
        echo "  2. 打开项目: $SCRIPT_DIR"
        echo "  3. 点击 Build -> Build Bundle(s) / APK(s) -> Build APK(s)"
        echo "  4. 等待构建完成"
        echo "  5. APK 位置: app/build/outputs/apk/debug/app-debug.apk"
        echo ""
        echo "💡 提示：首次构建可能需要下载依赖，请保持网络连接"
        ;;
        
    2)
        echo ""
        echo "💻 使用命令行构建"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        
        # 检查 Android SDK
        if [ -z "$ANDROID_HOME" ]; then
            echo "❌ Android SDK 未找到"
            echo ""
            echo "请设置环境变量："
            echo "  export ANDROID_HOME=/path/to/android-sdk"
            echo ""
            echo "或安装 Android SDK："
            echo "  wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip"
            echo "  unzip commandlinetools-linux-9477386_latest.zip"
            echo ""
            exit 1
        fi
        
        echo "✅ Android SDK: $ANDROID_HOME"
        echo ""
        echo "🔨 开始构建..."
        echo ""
        
        ./gradlew clean || exit 1
        ./gradlew assembleDebug || exit 1
        
        if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
            cp app/build/outputs/apk/debug/app-debug.apk ./daidai-panel-debug.apk
            echo "✅ 构建成功！"
            echo "📦 APK: ./daidai-panel-debug.apk"
        else
            echo "❌ 构建失败"
            exit 1
        fi
        ;;
        
    3)
        echo ""
        echo "🐳 使用 Docker 构建"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        
        # 检查 Docker
        if ! command -v docker &> /dev/null; then
            echo "❌ Docker 未安装"
            echo ""
            echo "请先安装 Docker："
            echo "  Ubuntu/Debian: sudo apt-get install docker.io"
            echo "  macOS/Windows: 下载 Docker Desktop"
            echo ""
            exit 1
        fi
        
        echo "✅ Docker: $(docker --version)"
        echo ""
        echo "🔨 开始构建 (可能需要 10-20 分钟)..."
        echo ""
        
        chmod +x docker-build.sh
        ./docker-build.sh
        ;;
        
    4)
        echo ""
        echo "☁️ 使用 GitHub Actions"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "步骤："
        echo "  1. 将项目推送到 GitHub"
        echo "  2. 访问 GitHub 仓库的 Actions 页面"
        echo "  3. 点击 'Build APK' workflow"
        echo "  4. 点击 'Run workflow' 开始构建"
        echo "  5. 构建完成后下载 APK"
        echo ""
        echo "📝 快速开始："
        echo "  git init"
        echo "  git add ."
        echo "  git commit -m 'Initial commit'"
        echo "  git remote add origin https://github.com/your-username/repo.git"
        echo "  git push -u origin main"
        echo ""
        echo "然后访问: https://github.com/your-username/repo/actions"
        ;;
        
    5)
        echo ""
        echo "📚 详细说明"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        cat << 'DETAILS'
构建方法对比：

┌──────────────────┬──────────┬──────────┬──────────┐
│ 方法             │ 难度     │ 时间     │ 推荐度   │
├──────────────────┼──────────┼──────────┼──────────┤
│ Android Studio   │ ⭐       │ 5-10分钟  │ ⭐⭐⭐⭐⭐ │
│ 命令行构建       │ ⭐⭐     │ 3-5分钟   │ ⭐⭐⭐⭐  │
│ Docker 构建      │ ⭐⭐⭐   │ 15-20分钟 │ ⭐⭐⭐   │
│ GitHub Actions   │ ⭐⭐     │ 10-15分钟 │ ⭐⭐⭐⭐  │
└──────────────────┴──────────┴──────────┴──────────┘

推荐方案：
• 新手用户 → Android Studio
• 开发者 → 命令行构建
• CI/CD → GitHub Actions
• 无环境 → Docker 构建

APK 信息：
• 文件名: app-debug.apk
• 大小: ~15-20MB
• 版本: Debug (测试版)
• 签名: Debug签名

安装后使用：
1. 安装 APK 到设备
2. 授权存储权限
3. 授权电池优化例外
4. 点击"启动面板"
5. 等待服务启动 (约10秒)
6. 开始使用

详细文档：
• BUILD_GUIDE.md - 完整构建指南
• README.md - 项目说明
• QUICK_START.md - 快速开始

支持：
• 最低 Android 版本: 5.0 (API 21)
• 推荐 Android 版本: 10+ (API 29+)
• 架构支持: ARM64, ARMv7, x86, x86_64
DETAILS
        ;;
        
    0)
        echo "👋 退出"
        exit 0
        ;;
        
    *)
        echo "❌ 无效选择"
        exit 1
        ;;
esac

echo ""
echo "✅ 操作完成！"
echo ""
echo "📚 更多帮助："
echo "  • 查看 BUILD_GUIDE.md 了解详细构建步骤"
echo "  • 查看 README.md 了解项目信息"
echo "  • 查看 QUICK_START.md 了解快速开始"
echo ""