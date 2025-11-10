# 更新日志

## [1.0.0] - 2025-11-10

### 新增功能
- ✅ Go 后端 WebSocket 服务器
- ✅ RESTful API 接口
- ✅ JWT 身份认证
- ✅ 用户注册和登录
- ✅ 实时消息推送
- ✅ 私聊功能
- ✅ 在线状态管理
- ✅ 消息已读/未读状态
- ✅ 会话列表
- ✅ Flutter 聊天客户端（GetX）
- ✅ Flutter 管理后台
- ✅ 数据统计仪表板
- ✅ 用户管理
- ✅ 消息管理
- ✅ 完整的部署文档

### 技术栈
- 后端: Go 1.21 + Gin + Gorilla WebSocket + GORM + JWT
- 前端: Flutter + GetX + Dio + WebSocket
- 数据库: SQLite (支持 MySQL/PostgreSQL)

### 文件结构
```
├── backend/              # Go 后端
├── chat_client/         # Flutter 聊天客户端
├── admin_panel/         # Flutter 管理后台
├── README.md           # 项目说明
├── DEPLOYMENT.md       # 部署指南
├── API_TEST.md        # API 测试文档
└── docker-compose.yml # Docker 配置
```

### 待实现
- ⏳ 群聊功能
- ⏳ 图片/文件发送
- ⏳ 表情包支持
- ⏳ 消息撤回
- ⏳ 语音/视频通话

---

## 如何贡献

欢迎提交 Issue 和 Pull Request！
