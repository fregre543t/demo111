# Go后端服务器

## 启动步骤

1. 安装依赖：
```bash
go mod tidy
```

2. 运行服务器：
```bash
go run main.go
```

服务器将在 `http://localhost:8080` 启动

## API端点

### 用户API
- `POST /api/auth/login` - 用户登录
- `POST /api/auth/register` - 用户注册
- `GET /api/users` - 获取用户列表
- `GET /api/messages` - 获取消息列表
- `GET /ws?user_id={id}` - WebSocket连接

### 管理员API
- `POST /admin/login` - 管理员登录（用户名: admin, 密码: admin123）
- `GET /admin/users` - 获取所有用户
- `DELETE /admin/users/:id` - 删除用户
- `GET /admin/messages` - 获取所有消息
- `DELETE /admin/messages/:id` - 删除消息
- `GET /admin/stats` - 获取统计信息
