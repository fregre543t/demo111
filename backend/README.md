# Go WebSocket 聊天后端

基于 Gin + Gorilla WebSocket 的实时聊天服务器。

## 安装

```bash
go mod download
```

## 运行

```bash
go run cmd/server/main.go
```

## 依赖

- Gin - HTTP 框架
- Gorilla WebSocket - WebSocket 支持
- GORM - ORM 框架
- JWT - 身份认证
- bcrypt - 密码加密

## 数据库

使用 SQLite 作为默认数据库，首次运行会自动创建 `chat.db` 文件。

生产环境建议使用 MySQL 或 PostgreSQL。

## 配置

修改 `internal/middleware/auth.go` 中的 JWT 密钥：
```go
var jwtSecret = []byte("your-secret-key")
```

## API 文档

详见主项目 README。
