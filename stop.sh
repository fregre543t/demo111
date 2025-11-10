#!/bin/bash

echo "停止后端服务..."

if [ -f .backend.pid ]; then
    PID=$(cat .backend.pid)
    if ps -p $PID > /dev/null; then
        kill $PID
        echo "✅ 后端服务已停止 (PID: $PID)"
    else
        echo "⚠️  进程不存在"
    fi
    rm .backend.pid
else
    echo "⚠️  未找到进程ID文件"
fi
