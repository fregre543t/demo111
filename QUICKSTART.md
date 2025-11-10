# 快速启动指南

## 后端启动

1. 进入后端目录：
```bash
cd backend
```

2. 安装依赖：
```bash
go mod tidy
```

3. 运行服务器：
```bash
go run main.go
```

服务器将在 `http://localhost:8080` 启动

## 前端启动

1. 进入前端目录：
```bash
cd flutter
```

2. 安装依赖：
```bash
flutter pub get
```

3. 运行应用：
```bash
flutter run
```

## 首次使用

1. 启动后端服务器
2. 启动Flutter应用
3. 注册一个新账号
4. 登录后可以：
   - 创建聊天室
   - 加入聊天室进行实时聊天
   - 查看和编辑个人资料
   - 如果是管理员，可以访问后台管理功能

## 设置管理员

首次注册的用户可以通过数据库设置为管理员：

1. 使用SQLite工具打开 `backend/chat.db`
2. 找到 `users` 表
3. 将第一个用户的 `is_admin` 字段设置为 `1` (true)

或者通过SQL命令：
```sql
UPDATE users SET is_admin = 1 WHERE id = 1;
```

## 注意事项

- 确保后端服务器在Flutter应用启动前已运行
- WebSocket连接需要有效的认证令牌
- 默认API地址为 `http://localhost:8080`，如需修改请编辑 `flutter/lib/app/services/api_service.dart`
- 生产环境请修改JWT密钥（通过环境变量 `JWT_SECRET`）
