# 🚀 快速开始指南

## 1️⃣ 启动后端服务

\`\`\`bash
cd backend
go run cmd/server/main.go
\`\`\`

服务器将在 http://localhost:8080 启动

## 2️⃣ 测试后端是否正常

\`\`\`bash
curl http://localhost:8080/health
# 预期输出: {"status":"ok"}
\`\`\`

## 3️⃣ 注册测试用户

\`\`\`bash
curl -X POST http://localhost:8080/api/register \\
  -H "Content-Type: application/json" \\
  -d '{
    "username": "admin",
    "password": "admin123",
    "nickname": "管理员"
  }'
\`\`\`

## 4️⃣ 设置管理员权限

\`\`\`bash
# 打开数据库
cd backend
sqlite3 chat.db

# 执行 SQL
UPDATE users SET is_admin = 1 WHERE username = 'admin';

# 退出
.quit
\`\`\`

## 5️⃣ 启动 Flutter 应用

### 聊天客户端
\`\`\`bash
cd chat_client
flutter pub get
flutter run
\`\`\`

### 管理后台
\`\`\`bash
cd admin_panel
flutter pub get
flutter run
\`\`\`

## 6️⃣ 测试功能

### 聊天客户端测试
1. 打开应用，点击"注册"
2. 创建两个测试账号（例如: user1, user2）
3. 使用 user1 登录
4. 搜索 user2 并开始聊天
5. 切换到 user2 账号，查看是否收到消息

### 管理后台测试
1. 使用 admin/admin123 登录
2. 查看仪表板统计数据
3. 进入用户管理，查看所有用户
4. 进入消息管理，查看聊天记录

## 📝 常用命令

### 后端
\`\`\`bash
# 启动服务
cd backend && go run cmd/server/main.go

# 编译
cd backend && make build

# 清理数据库
cd backend && rm chat.db
\`\`\`

### Flutter
\`\`\`bash
# 安装依赖
flutter pub get

# 运行
flutter run

# 清理缓存
flutter clean
\`\`\`

## 🐛 常见问题

### Q: 后端启动失败？
A: 检查端口8080是否被占用，或者删除chat.db重新生成

### Q: Flutter连接不上后端？
A: 确认后端服务正在运行，检查API地址配置

### Q: WebSocket连接失败？
A: 查看后端日志，确认Token是否正确

## 🎉 完成！

现在你已经成功启动了整个系统！

查看详细文档:
- [README.md](README.md) - 完整说明
- [API_TEST.md](API_TEST.md) - API测试
- [DEPLOYMENT.md](DEPLOYMENT.md) - 部署指南
