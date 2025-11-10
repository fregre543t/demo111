# 部署指南

## 本地开发部署

### 1. 后端部署

```bash
cd backend
go mod download
go run cmd/server/main.go
```

或使用 Makefile：
```bash
cd backend
make run
```

### 2. Flutter 应用部署

#### 聊天客户端
```bash
cd chat_client
flutter pub get
flutter run
```

#### 管理后台
```bash
cd admin_panel
flutter pub get
flutter run
```

### 3. 一键启动（Linux/Mac）

```bash
./start.sh
```

停止服务：
```bash
./stop.sh
```

## 生产环境部署

### Docker 部署

#### 1. 构建镜像
```bash
docker-compose build
```

#### 2. 启动服务
```bash
docker-compose up -d
```

#### 3. 查看日志
```bash
docker-compose logs -f
```

### 手动部署

#### 后端服务器

1. **编译二进制文件**
```bash
cd backend
CGO_ENABLED=1 go build -o server cmd/server/main.go
```

2. **使用 systemd 管理服务**

创建 `/etc/systemd/system/chat-backend.service`:
```ini
[Unit]
Description=Chat Backend Service
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/opt/chat-backend
ExecStart=/opt/chat-backend/server
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

启动服务：
```bash
sudo systemctl daemon-reload
sudo systemctl enable chat-backend
sudo systemctl start chat-backend
```

3. **配置 Nginx 反向代理**

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location /api {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

#### Flutter Web 部署

1. **构建 Web 应用**
```bash
cd chat_client
flutter build web

cd ../admin_panel
flutter build web
```

2. **部署到 Nginx**
```bash
cp -r chat_client/build/web /var/www/chat
cp -r admin_panel/build/web /var/www/admin
```

Nginx 配置：
```nginx
server {
    listen 80;
    server_name chat.your-domain.com;
    root /var/www/chat;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
}

server {
    listen 80;
    server_name admin.your-domain.com;
    root /var/www/admin;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

#### Flutter 移动应用部署

**Android**:
```bash
cd chat_client
flutter build apk --release
# APK 位于: build/app/outputs/flutter-apk/app-release.apk
```

**iOS**:
```bash
cd chat_client
flutter build ios --release
# 在 Xcode 中打开 ios/Runner.xcworkspace 进行签名和发布
```

## 数据库配置

### SQLite (默认)
适合小规模应用，无需额外配置。

### MySQL

1. 修改 `backend/internal/database/database.go`:
```go
import "gorm.io/driver/mysql"

// 在 InitDatabase 中替换为:
dsn := "user:password@tcp(127.0.0.1:3306)/chatdb?charset=utf8mb4&parseTime=True&loc=Local"
DB, err = gorm.Open(mysql.Open(dsn), &gorm.Config{})
```

2. 更新 `go.mod`:
```bash
go get gorm.io/driver/mysql
```

### PostgreSQL

1. 修改 `backend/internal/database/database.go`:
```go
import "gorm.io/driver/postgres"

// 在 InitDatabase 中替换为:
dsn := "host=localhost user=postgres password=yourpassword dbname=chatdb port=5432 sslmode=disable"
DB, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
```

2. 更新 `go.mod`:
```bash
go get gorm.io/driver/postgres
```

## 环境变量配置

创建 `.env` 文件：
```env
# 数据库
DATABASE_URL=sqlite:chat.db

# JWT
JWT_SECRET=your-super-secret-key-here

# 服务器
SERVER_PORT=8080
GIN_MODE=release

# CORS
CORS_ORIGINS=https://your-domain.com
```

## HTTPS/WSS 配置

### 使用 Let's Encrypt

1. 安装 certbot
```bash
sudo apt install certbot python3-certbot-nginx
```

2. 获取证书
```bash
sudo certbot --nginx -d your-domain.com
```

3. Nginx 配置
```nginx
server {
    listen 443 ssl http2;
    server_name your-domain.com;

    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;

    location /api/ws {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    location /api {
        proxy_pass http://localhost:8080;
    }
}
```

4. 更新 Flutter 配置
```dart
// 修改为 HTTPS 和 WSS
static const String baseUrl = 'https://your-domain.com/api';
static const String wsUrl = 'wss://your-domain.com/api/ws';
```

## 性能优化

### 1. 数据库优化
- 添加索引
- 使用连接池
- 定期清理过期数据

### 2. 缓存配置
- Redis 缓存用户会话
- 消息队列处理高并发

### 3. 负载均衡
- 使用 Nginx 负载均衡
- 多实例部署后端服务

## 监控和日志

### 日志配置
```go
// 使用日志库如 logrus 或 zap
import "github.com/sirupsen/logrus"

log := logrus.New()
log.SetFormatter(&logrus.JSONFormatter{})
log.SetOutput(os.Stdout)
```

### 监控工具
- Prometheus + Grafana
- ELK Stack (Elasticsearch, Logstash, Kibana)

## 备份策略

### 数据库备份
```bash
# SQLite
cp chat.db chat_backup_$(date +%Y%m%d).db

# MySQL
mysqldump -u user -p chatdb > backup.sql

# PostgreSQL
pg_dump chatdb > backup.sql
```

### 自动备份脚本
```bash
#!/bin/bash
BACKUP_DIR=/backup
DATE=$(date +%Y%m%d_%H%M%S)
cp chat.db $BACKUP_DIR/chat_$DATE.db
# 保留最近7天的备份
find $BACKUP_DIR -name "chat_*.db" -mtime +7 -delete
```

## 故障排查

### 常见问题

1. **WebSocket 连接失败**
   - 检查防火墙设置
   - 确认 Nginx 配置正确
   - 查看后端日志

2. **数据库连接错误**
   - 检查数据库配置
   - 确认数据库服务运行中
   - 查看连接字符串是否正确

3. **CORS 错误**
   - 配置正确的 CORS 头
   - 检查前端请求地址

## 安全建议

1. ✅ 使用 HTTPS/WSS
2. ✅ 定期更新依赖
3. ✅ 实施速率限制
4. ✅ 启用 SQL 注入防护
5. ✅ XSS 防护
6. ✅ 定期备份数据
7. ✅ 监控异常访问

---

有问题请查看主 README 或提交 Issue。
