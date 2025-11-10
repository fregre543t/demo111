# Flutter 聊天客户端

基于 GetX 的 Flutter 聊天应用。

## 安装

```bash
flutter pub get
```

## 运行

```bash
flutter run
```

## 配置

修改服务器地址：
- `lib/services/api_service.dart` - HTTP API 地址
- `lib/services/websocket_service.dart` - WebSocket 地址

## 功能

- 用户注册/登录
- 实时聊天
- 在线状态
- 会话列表
- 消息提醒

## 技术栈

- GetX - 状态管理
- Dio - HTTP 请求
- WebSocket - 实时通信
- SharedPreferences - 本地存储
