# Flutter 聊天应用

基于 Flutter 和 GetX 的聊天应用前端。

## 功能特性

- 用户注册和登录
- WebSocket实时聊天
- 聊天室管理
- 个人资料管理
- 后台管理功能（管理员）

## 技术栈

- Flutter 3.0+
- GetX 状态管理
- Dio HTTP客户端
- WebSocket实时通信
- GetStorage本地存储

## 安装和运行

1. 安装依赖：
```bash
flutter pub get
```

2. 配置API地址：
编辑 `lib/app/services/api_service.dart` 中的 `baseUrl`，确保指向后端服务器地址。

3. 运行应用：
```bash
flutter run
```

## 项目结构

```
lib/
├── app/
│   ├── models/          # 数据模型
│   ├── routes/          # 路由配置
│   ├── services/        # 服务层（API、WebSocket、存储等）
│   └── modules/         # 功能模块
│       ├── splash/      # 启动页
│       ├── auth/        # 认证（登录/注册）
│       ├── home/        # 首页（聊天室列表）
│       ├── chat/        # 聊天界面
│       ├── profile/     # 个人资料
│       └── admin/       # 后台管理
└── main.dart           # 应用入口
```

## 注意事项

- 确保后端服务器已启动
- WebSocket连接需要有效的认证令牌
- 管理员功能需要用户具有管理员权限
