# WebSocket聊天应用

基于Flutter和Go的实时聊天应用，使用GetX进行状态管理，包含完整的后台管理系统。

## 项目结构

```
.
├── server/              # Go后端服务
│   ├── main.go         # 服务器入口
│   └── internal/
│       ├── handlers/   # HTTP和WebSocket处理器
│       ├── models/     # 数据模型
│       └── websocket/  # WebSocket实现
└── flutter/            # Flutter前端应用
    └── lib/
        ├── controllers/  # GetX控制器
        ├── models/      # 数据模型
        ├── pages/       # UI页面
        ├── routes/      # 路由配置
        └── services/    # 服务层
```

## 功能特性

### 用户功能
- 用户注册和登录
- 实时WebSocket聊天
- 在线用户列表
- 消息历史记录

### 管理员功能
- 管理员登录（用户名: admin, 密码: admin123）
- 用户管理（查看、删除）
- 消息管理（查看、删除）
- 统计信息（总用户数、在线用户数、总消息数）

## 后端启动

1. 安装Go依赖：
```bash
cd server
go mod tidy
```

2. 运行服务器：
```bash
go run main.go
```

服务器将在 `http://localhost:8080` 启动

## 前端启动

1. 安装Flutter依赖：
```bash
cd flutter
flutter pub get
```

2. 运行应用：
```bash
flutter run
```

## API端点

### 用户API
- `POST /api/auth/login` - 用户登录
- `POST /api/auth/register` - 用户注册
- `GET /api/users` - 获取用户列表
- `GET /api/messages` - 获取消息列表
- `GET /ws?user_id={id}` - WebSocket连接

### 管理员API
- `POST /admin/login` - 管理员登录
- `GET /admin/users` - 获取所有用户
- `DELETE /admin/users/:id` - 删除用户
- `GET /admin/messages` - 获取所有消息
- `DELETE /admin/messages/:id` - 删除消息
- `GET /admin/stats` - 获取统计信息

## 技术栈

### 后端
- Go 1.21+
- Gin Web框架
- Gorilla WebSocket
- Bcrypt密码加密

### 前端
- Flutter 3.0+
- GetX状态管理
- WebSocket Channel
- HTTP客户端

## 注意事项

1. 默认管理员账号：用户名 `admin`，密码 `admin123`
2. 数据存储在内存中，服务器重启后数据会丢失
3. WebSocket连接需要先登录获取user_id
4. 生产环境请修改CORS配置和安全设置
