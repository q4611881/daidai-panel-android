#!/bin/bash

# 简化的gradlew脚本
APP_HOME=$(pwd)
DEFAULT_JVM_OPTS="-Xmx64m -Xms64m"

# 查找Java
if [ -n "$JAVA_HOME" ]; then
    JAVACMD="$JAVA_HOME/bin/java"
else
    JAVACMD="java"
fi

# 查找gradle wrapper jar
GRADLE_WRAPPER="$APP_HOME/gradle/wrapper/gradle-wrapper.jar"

if [ ! -f "$GRADLE_WRAPPER" ]; then
    echo "错误: gradle wrapper jar 不存在"
    exit 1
fi

# 执行gradle
exec "$JAVACMD" $DEFAULT_JVM_OPTS $JAVA_OPTS $GRADLE_OPTS \
    -classpath "$GRADLE_WRAPPER" \
    org.gradle.wrapper.GradleWrapperMain \
    "$@"
