# WebSocket 聊天应用系统

一个功能完整的实时聊天应用系统，包含：
- **Go 后端** - 基于 WebSocket 的实时通信服务器
- **Flutter 聊天客户端** - 使用 GetX 状态管理
- **Flutter 管理后台** - 用户和消息管理

## 📁 项目结构

```
├── backend/              # Go 后端服务
│   ├── cmd/server/      # 主程序入口
│   ├── internal/        # 内部包
│   │   ├── handlers/    # HTTP 处理器
│   │   ├── models/      # 数据模型
│   │   ├── middleware/  # 中间件
│   │   ├── websocket/   # WebSocket 管理
│   │   └── database/    # 数据库连接
│   └── go.mod          # Go 依赖管理
│
├── chat_client/         # Flutter 聊天客户端
│   ├── lib/
│   │   ├── controllers/ # GetX 控制器
│   │   ├── models/      # 数据模型
│   │   ├── services/    # API 和 WebSocket 服务
│   │   ├── views/       # UI 视图
│   │   └── routes/      # 路由配置
│   └── pubspec.yaml    # Flutter 依赖
│
└── admin_panel/         # Flutter 管理后台
    ├── lib/
    │   ├── controllers/ # 管理控制器
    │   ├── services/    # API 服务
    │   └── views/       # 管理视图
    └── pubspec.yaml    # Flutter 依赖
```

## 🚀 快速开始

### 1. 后端服务 (Go)

#### 安装依赖
```bash
cd backend
go mod download
```

#### 运行服务器
```bash
go run cmd/server/main.go
```

服务器将在 `http://localhost:8080` 启动

#### API 端点
- `POST /api/register` - 用户注册
- `POST /api/login` - 用户登录
- `GET /api/ws` - WebSocket 连接
- `GET /api/users` - 获取用户列表
- `GET /api/messages/:user_id` - 获取聊天记录
- `POST /api/messages` - 发送消息
- `GET /api/admin/*` - 管理员 API

### 2. Flutter 聊天客户端

#### 安装依赖
```bash
cd chat_client
flutter pub get
```

#### 运行应用
```bash
flutter run
```

#### 主要功能
- ✅ 用户注册/登录
- ✅ 实时消息推送
- ✅ 在线状态显示
- ✅ 会话列表
- ✅ 未读消息提醒
- ✅ 消息已读状态
- ✅ 用户搜索

### 3. Flutter 管理后台

#### 安装依赖
```bash
cd admin_panel
flutter pub get
```

#### 运行应用
```bash
flutter run
```

#### 管理功能
- 📊 数据统计仪表板
- 👥 用户管理（查看、删除、权限设置）
- 💬 消息管理（查看、删除）
- 📈 实时统计数据

## 🔧 技术栈

### 后端
- **框架**: Gin (HTTP) + Gorilla WebSocket
- **数据库**: SQLite + GORM
- **认证**: JWT
- **密码加密**: bcrypt

### 前端（Flutter）
- **状态管理**: GetX
- **网络请求**: Dio
- **WebSocket**: web_socket_channel
- **本地存储**: shared_preferences
- **图片缓存**: cached_network_image

## 📝 配置说明

### 修改服务器地址

如果部署到服务器，需要修改以下文件中的地址：

**聊天客户端**: `chat_client/lib/services/api_service.dart`
```dart
static const String baseUrl = 'http://your-server:8080/api';
```

**聊天客户端**: `chat_client/lib/services/websocket_service.dart`
```dart
static const String wsUrl = 'ws://your-server:8080/api/ws';
```

**管理后台**: `admin_panel/lib/services/admin_api_service.dart`
```dart
static const String baseUrl = 'http://your-server:8080/api';
```

### JWT 密钥配置

**生产环境请务必修改**: `backend/internal/middleware/auth.go`
```go
var jwtSecret = []byte("your-secret-key-change-in-production")
```

## 🎯 使用说明

### 1. 创建管理员账号

首次运行需要创建管理员账号。可以通过两种方式：

**方式一**: 注册后通过数据库直接设置
```bash
# 进入后端目录
cd backend

# 使用 sqlite3 打开数据库
sqlite3 chat.db

# 更新用户为管理员
UPDATE users SET is_admin = 1 WHERE username = 'your_username';
```

**方式二**: 修改注册代码临时设置首个用户为管理员

### 2. 登录测试

#### 聊天客户端
1. 注册新用户
2. 登录后即可开始聊天
3. 搜索其他用户发起会话

#### 管理后台
1. 使用管理员账号登录
2. 查看仪表板统计
3. 管理用户和消息

## 🔐 安全建议

在生产环境部署时，请注意：

1. ✅ 修改 JWT 密钥
2. ✅ 使用 MySQL/PostgreSQL 替代 SQLite
3. ✅ 启用 HTTPS/WSS
4. ✅ 配置 CORS 白名单
5. ✅ 添加速率限制
6. ✅ 实现文件上传安全检查
7. ✅ 添加日志记录

## 📦 数据库迁移

系统使用 GORM 自动迁移，首次启动会自动创建表结构：
- users (用户表)
- messages (私聊消息表)
- chat_rooms (聊天室表)
- room_messages (聊天室消息表)

## 🐛 故障排查

### 后端无法启动
- 检查端口 8080 是否被占用
- 确认 Go 版本 >= 1.21
- 删除 `chat.db` 重新生成

### Flutter 编译错误
- 运行 `flutter clean`
- 重新 `flutter pub get`
- 检查 Flutter SDK 版本

### WebSocket 连接失败
- 确认后端服务正在运行
- 检查防火墙设置
- 确认 WebSocket URL 正确

## 📄 API 文档

详细的 API 文档可以通过访问后端 `/health` 端点确认服务运行状态。

主要 API：
- 认证相关: `/api/register`, `/api/login`
- 用户相关: `/api/users`, `/api/profile`
- 消息相关: `/api/messages`, `/api/conversations`
- 管理员相关: `/api/admin/*`

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📜 许可证

MIT License

## 🎉 功能特性

### 已实现
- ✅ 用户注册和登录
- ✅ JWT 身份认证
- ✅ 实时消息推送 (WebSocket)
- ✅ 私聊功能
- ✅ 在线状态同步
- ✅ 消息已读/未读
- ✅ 会话列表
- ✅ 用户搜索
- ✅ 管理后台
- ✅ 数据统计

### 待扩展
- ⏳ 群聊功能
- ⏳ 图片/文件发送
- ⏳ 表情包支持
- ⏳ 消息撤回
- ⏳ 语音/视频通话
- ⏳ 消息加密

## 💡 开发建议

1. **开发环境**: 建议使用 VSCode + Flutter 插件 + Go 插件
2. **调试**: 使用 Postman 测试 API，Chrome DevTools 调试 Flutter
3. **日志**: 查看后端控制台输出了解 WebSocket 连接状态

---

如有问题，请提交 Issue 或查看文档。祝使用愉快！ 🚀
