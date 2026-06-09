# 呆呆面板 Android 原生应用 - 完整实现文档

## 项目概述

这是一个完全独立的Android原生应用，实现了呆呆面板的所有功能，无需依赖Termux或Root权限。

## 技术栈

- **开发语言**: Kotlin
- **UI框架**: Android Native + WebView
- **后台服务**: 嵌入式Go服务器
- **构建工具**: Gradle 8.2
- **最低API**: 21 (Android 5.0)
- **目标API**: 33 (Android 13)

## 核心功能

### 1. 独立运行
- 完全独立的Android应用
- 无需Termux环境
- 无需Root权限
- 自包含所有依赖

### 2. WebView界面
- 原生WebView集成
- 支持JavaScript交互
- 响应式布局
- 触摸和滑动支持

### 3. 后台服务
- 前台服务保证不被系统杀死
- 嵌入式Go服务器
- 进程生命周期管理
- 异常自动恢复

### 4. 开机自启
- 监听开机完成广播
- 自动启动后台服务
- 延迟启动减少资源占用

### 5. 电池优化
- 自动请求电池优化例外
- 前台通知保持活跃
- 低功耗运行模式

## 项目结构详解

### 核心代码

#### MainActivity.kt
```kotlin
功能:
- WebView初始化和配置
- 面板加载和显示
- 服务控制按钮处理
- 状态实时更新
- 权限请求处理

关键特性:
- 自动重试连接
- 用户友好的错误提示
- 流畅的状态切换
```

#### PanelService.kt
```kotlin
功能:
- 前台服务管理
- Go服务器进程控制
- 通知栏显示
- 电池优化处理

关键特性:
- 进程异常检测和恢复
- 前台通知持续显示
- 服务间通信
```

#### BootReceiver.kt
```kotlin
功能:
- 监听开机广播
- 自动启动服务
- 延迟启动优化

关键特性:
- 兼容不同厂商ROM
- 权限检查
- 启动失败重试
```

### 资源文件

#### 布局文件
- `activity_main.xml`: 主界面布局
- 使用Material Design 3组件
- 响应式布局设计

#### 资源文件
- `strings.xml`: 国际化字符串
- `colors.xml`: 主题颜色配置
- `themes.xml`: Material主题样式
- `drawable/`: 自定义图标资源

### 配置文件

#### AndroidManifest.xml
```xml
关键配置:
- 应用权限声明
- 组件注册
- 服务配置
- 启动器配置
```

#### build.gradle.kts
```kotlin
关键配置:
- 依赖管理
- 构建配置
- 签名配置
- 混淆规则
```

## 构建和部署

### 环境准备

#### 必需软件
1. Android SDK (API 21+)
2. JDK 11+
3. Gradle 8.2+

#### 环境变量配置
```bash
export ANDROID_HOME=/path/to/android-sdk
export JAVA_HOME=/path/to/jdk-11
```

### 构建步骤

#### 1. 准备Go服务器
```bash
# 将预编译的Go服务器复制到assets目录
cp /path/to/daidai-server-arm64 app/src/main/assets/
chmod +x app/src/main/assets/daidai-server-arm64
```

#### 2. 清理构建
```bash
./gradlew clean
```

#### 3. 构建APK
```bash
# Debug版本
./gradlew assembleDebug

# Release版本
./gradlew assembleRelease
```

#### 4. 安装APK
```bash
# 通过ADB安装
adb install app/build/outputs/apk/debug/app-debug.apk

# 或者手动复制APK到手机安装
```

### 快速构建脚本

提供了自动化构建脚本 `build-apk.sh`:

```bash
# 给予执行权限
chmod +x build-apk.sh

# 运行构建
./build-apk.sh
```

## 使用指南

### 首次使用

1. **安装APK**
   - 将APK文件复制到手机
   - 允许未知来源安装
   - 完成安装

2. **授权权限**
   - 存储权限
   - 电池优化例外
   - 后台运行权限

3. **启动面板**
   - 打开应用
   - 点击"启动面板"按钮
   - 等待服务器启动

4. **访问面板**
   - WebView自动加载
   - 显示呆呆面板界面
   - 正常使用所有功能

### 日常使用

- **启动面板**: 点击启动按钮
- **停止面板**: 点击停止按钮
- **刷新界面**: 点击刷新按钮
- **查看状态**: 状态指示灯显示运行状态

### 开机自启

- 首次使用时授予自启动权限
- 手机开机后自动启动服务
- 延迟启动避免资源竞争
- 可在应用中手动控制

## 高级配置

### 自定义端口

修改 `PanelService.kt` 中的端口配置:

```kotlin
private const val SERVER_PORT = 5700  // 修改为你需要的端口
```

### 自定义界面

修改 `activity_main.xml` 布局文件。

### 添加新功能

扩展 MainActivity.kt 或创建新的 Activity。

## 故障排除

### 常见问题

#### 1. 服务无法启动
**症状**: 点击启动按钮后服务无法启动

**解决**:
- 检查存储权限
- 添加到电池优化白名单
- 检查Go服务器文件是否正确

#### 2. WebView无法加载
**症状**: 显示空白或错误页面

**解决**:
- 检查网络连接
- 确认服务已启动
- 清除应用数据重试

#### 3. 开机不自启
**症状**: 开机后服务没有自动启动

**解决**:
- 检查自启动权限
- 检查电池优化设置
- 手动授予后台运行权限

#### 4. 服务被系统杀死
**症状**: 后台运行一段时间后服务停止

**解决**:
- 添加到电池优化白名单
- 确认前台通知显示
- 检查ROM的后台管理策略

### 日志调试

查看应用日志:

```bash
# 过滤应用日志
adb logcat | grep com.daidai.panel

# 查看详细日志
adb logcat -v time | grep -E "PanelService|MainActivity"
```

## 性能优化

### 内存优化
- 使用WebView内存缓存
- 及时清理资源
- 优化Go服务器配置

### 电池优化
- 低功耗模式
- 智能唤醒
- 减少后台活动

### 网络优化
- 本地缓存
- 请求合并
- 连接复用

## 安全考虑

### 权限最小化
- 只申请必需的权限
- 动态权限请求
- 权限使用说明

### 数据保护
- 本地数据加密
- 安全的网络通信
- 敏感信息保护

### 代码混淆
- 启用ProGuard混淆
- 移除调试信息
- 代码签名

## 版本更新

### 版本规划
- v1.0: 基础功能实现
- v1.1: 性能优化和bug修复
- v1.2: 新增功能和界面优化
- v2.0: 重构和重大更新

### 更新策略
- OTA更新
- 增量更新
- 数据迁移

## 技术支持

### 问题反馈
- GitHub Issues
- 社区论坛
- 技术支持邮件

### 文档
- 用户手册
- 开发者文档
- API文档

## 贡献指南

### 代码贡献
- Fork项目
- 创建分支
- 提交代码
- 发起PR

### 功能建议
- 提交Issue
- 讨论功能
- 提供方案

## 许可证

本项目遵循 MIT 许可证。