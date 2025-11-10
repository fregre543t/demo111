#!/bin/bash

echo "==================================="
echo "  WebSocket 聊天应用启动脚本"
echo "==================================="
echo ""

# 检查Go是否安装
if ! command -v go &> /dev/null; then
    echo "❌ 未检测到Go，请先安装 Go 1.21+"
    exit 1
fi

# 检查Flutter是否安装
if ! command -v flutter &> /dev/null; then
    echo "⚠️  未检测到Flutter，将只启动后端服务"
    FLUTTER_INSTALLED=false
else
    FLUTTER_INSTALLED=true
fi

echo "1️⃣  启动后端服务..."
cd backend
go mod download
nohup go run cmd/server/main.go > ../backend.log 2>&1 &
BACKEND_PID=$!
echo "✅ 后端服务已启动 (PID: $BACKEND_PID)"
echo "   访问地址: http://localhost:8080"
cd ..

if [ "$FLUTTER_INSTALLED" = true ]; then
    echo ""
    echo "2️⃣  Flutter 应用:"
    echo "   聊天客户端: cd chat_client && flutter run"
    echo "   管理后台: cd admin_panel && flutter run"
fi

echo ""
echo "==================================="
echo "启动完成！"
echo ""
echo "后端日志: tail -f backend.log"
echo "停止服务: kill $BACKEND_PID"
echo "==================================="

# 保存PID到文件
echo $BACKEND_PID > .backend.pid
