FROM openjdk:11-jdk-slim

# 安装必要的工具
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# 设置 Android SDK 环境变量
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
ENV PATH=$PATH:$ANDROID_HOME/platform-tools
ENV PATH=$PATH:$ANDROID_HOME/emulator
ENV PATH=$PATH:$ANDROID_HOME/tools
ENV PATH=$PATH:$ANDROID_HOME/tools/bin

# 创建 Android SDK 目录
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools

# 下载并安装 Android Command Line Tools
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip && \
    unzip commandlinetools-linux-9477386_latest.zip -d ${ANDROID_HOME}/cmdline-tools && \
    mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest && \
    rm commandlinetools-linux-9477386_latest.zip

# 接受许可
RUN yes | sdkmanager --licenses || true

# 安装必要的 SDK 组件
RUN sdkmanager --update && \
    sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0" "ndk;25.1.8937393"

# 设置工作目录
WORKDIR /workspace

# 复制项目文件
COPY . .

# 设置权限
RUN chmod +x gradlew

# 构建 APK
RUN ./gradlew assembleDebug --stacktrace

# 输出 APK 信息
RUN ls -lh app/build/outputs/apk/debug/

# 设置默认命令
CMD ["bash"]