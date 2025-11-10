# WebSocket 聊天应用

基于 Flutter 和 Go 的实时聊天应用，包含完整的前端、后端和后台管理功能。

## 项目结构

```
.
├── backend/          # Go 后端服务
│   ├── config/       # 配置管理
│   ├── database/     # 数据库连接
│   ├── handlers/     # 请求处理
│   ├── middleware/   # 中间件
│   ├── models/       # 数据模型
│   └── main.go       # 入口文件
├── flutter/          # Flutter 前端应用
│   └── lib/
│       └── app/      # 应用代码
└── README.md         # 项目说明
```

## 功能特性

### 前端（Flutter + GetX）
- ✅ 用户注册和登录
- ✅ WebSocket实时聊天
- ✅ 聊天室列表和创建
- ✅ 个人资料管理
- ✅ 后台管理界面（管理员）

### 后端（Go + Gin）
- ✅ RESTful API
- ✅ WebSocket服务器
- ✅ JWT认证
- ✅ SQLite数据库
- ✅ 后台管理API

## 快速开始

### 后端启动

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

服务器默认运行在 `http://localhost:8080`

### 前端启动

1. 进入前端目录：
```bash
cd flutter
```

2. 安装依赖：
```bash
flutter pub get
```

3. 配置API地址（如需要）：
编辑 `lib/app/services/api_service.dart` 中的 `baseUrl`

4. 运行应用：
```bash
flutter run
```

## 环境变量（后端）

- `PORT`: 服务器端口（默认: 8080）
- `ENVIRONMENT`: 运行环境（development/production）
- `JWT_SECRET`: JWT密钥（生产环境请修改）
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

## WebSocket消息格式

### 发送消息
```json
{
  "type": "message",
  "room_id": 1,
  "content": "消息内容"
}
```

### 加入聊天室
```json
{
  "type": "join",
  "room_id": 1
}
```

### 离开聊天室
```json
{
  "type": "leave",
  "room_id": 1
}
```

### 接收消息
```json
{
  "type": "message",
  "room_id": 1,
  "user_id": 1,
  "username": "用户昵称",
  "content": "消息内容",
  "message": {
    "id": 1,
    "room_id": 1,
    "user_id": 1,
    "content": "消息内容",
    "created_at": "2024-01-01T00:00:00Z",
    "user": {
      "id": 1,
      "username": "username",
      "nickname": "昵称",
      "avatar": "头像URL"
    }
  }
}
```

## 技术栈

### 后端
- Go 1.21+
- Gin Web框架
- GORM ORM
- SQLite数据库
- Gorilla WebSocket
- JWT认证

### 前端
- Flutter 3.0+
- GetX状态管理
- Dio HTTP客户端
- WebSocket实时通信
- GetStorage本地存储

## 开发说明

1. 首次运行会自动创建数据库和表结构
2. 注册的第一个用户可以通过数据库设置为管理员
3. WebSocket连接需要有效的JWT令牌
4. 管理员功能需要用户具有 `is_admin=true` 权限

## 许可证

MIT License
