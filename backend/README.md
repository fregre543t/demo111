# 聊天应用后端

基于 Go 和 WebSocket 的聊天应用后端服务。

## 功能特性

- 用户注册和登录（JWT认证）
- WebSocket实时聊天
- 聊天室管理
- 后台管理功能
- RESTful API

## 技术栈

- Go 1.21+
- Gin Web框架
- GORM ORM
- SQLite数据库
- Gorilla WebSocket
- JWT认证

## 安装和运行

1. 安装依赖：
```bash
go mod tidy
```

2. 运行服务器：
```bash
go run main.go
```

服务器默认运行在 `http://localhost:8080`

## 环境变量

- `PORT`: 服务器端口（默认: 8080）
- `ENVIRONMENT`: 运行环境（development/production）
- `JWT_SECRET`: JWT密钥
- `DB_PATH`: 数据库文件路径（默认: chat.db）

## API文档

### 认证接口

- `POST /api/auth/register` - 用户注册
- `POST /api/auth/login` - 用户登录

### 用户接口（需要认证）

- `GET /api/user/profile` - 获取用户信息
- `PUT /api/user/profile` - 更新用户信息

### 聊天室接口（需要认证）

- `GET /api/rooms` - 获取聊天室列表
- `POST /api/rooms` - 创建聊天室
- `GET /api/rooms/:id` - 获取聊天室详情
- `GET /api/rooms/:id/messages` - 获取聊天室消息

### WebSocket接口（需要认证）

- `GET /api/ws` - WebSocket连接

### 后台管理接口（需要管理员权限）

- `GET /api/admin/users` - 获取用户列表
- `PUT /api/admin/users/:id` - 更新用户
- `DELETE /api/admin/users/:id` - 删除用户
- `GET /api/admin/messages` - 获取消息列表
- `DELETE /api/admin/messages/:id` - 删除消息
- `GET /api/admin/rooms` - 获取聊天室列表
- `DELETE /api/admin/rooms/:id` - 删除聊天室
- `GET /api/admin/stats` - 获取统计信息
