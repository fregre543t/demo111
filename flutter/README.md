# Flutter聊天应用

## 启动步骤

1. 安装依赖：
```bash
flutter pub get
```

2. 运行应用：
```bash
flutter run
```

## 注意事项

1. 确保Go后端服务器已启动在 `http://localhost:8080`
2. 如果使用Android模拟器，需要将API服务中的`baseUrl`改为`http://10.0.2.2:8080`
3. 如果使用iOS模拟器或Web，使用`http://localhost:8080`即可

## 功能

- 用户注册和登录
- 实时WebSocket聊天
- 在线用户列表
- 消息历史记录
- 后台管理系统
