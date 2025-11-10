# API 测试文档

## 使用 curl 测试 API

### 1. 健康检查
```bash
curl http://localhost:8080/health
```

预期响应：
```json
{"status":"ok"}
```

### 2. 用户注册
```bash
curl -X POST http://localhost:8080/api/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "123456",
    "nickname": "测试用户"
  }'
```

预期响应：
```json
{
  "message": "注册成功",
  "user": {
    "id": 1,
    "username": "testuser",
    "nickname": "测试用户",
    "avatar": "https://api.dicebear.com/7.x/avataaars/svg?seed=testuser"
  }
}
```

### 3. 用户登录
```bash
curl -X POST http://localhost:8080/api/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "123456"
  }'
```

预期响应：
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "username": "testuser",
    "nickname": "测试用户",
    "avatar": "...",
    "is_admin": false
  }
}
```

**保存返回的 token 用于后续请求**

### 4. 获取个人资料
```bash
TOKEN="your-token-here"

curl http://localhost:8080/api/profile \
  -H "Authorization: Bearer $TOKEN"
```

### 5. 获取用户列表
```bash
curl http://localhost:8080/api/users \
  -H "Authorization: Bearer $TOKEN"
```

### 6. 发送消息
```bash
curl -X POST http://localhost:8080/api/messages \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "to_user_id": 2,
    "content": "你好！这是测试消息",
    "message_type": "text"
  }'
```

### 7. 获取聊天记录
```bash
# 获取与用户ID为2的聊天记录
curl http://localhost:8080/api/messages/2 \
  -H "Authorization: Bearer $TOKEN"
```

### 8. 获取会话列表
```bash
curl http://localhost:8080/api/conversations \
  -H "Authorization: Bearer $TOKEN"
```

### 9. 获取未读消息数
```bash
curl http://localhost:8080/api/messages/unread/count \
  -H "Authorization: Bearer $TOKEN"
```

### 10. 标记消息为已读
```bash
# 标记来自用户2的所有消息为已读
curl -X PUT http://localhost:8080/api/messages/2/read \
  -H "Authorization: Bearer $TOKEN"
```

## 管理员 API（需要管理员权限）

### 1. 获取统计数据
```bash
curl http://localhost:8080/api/admin/stats \
  -H "Authorization: Bearer $ADMIN_TOKEN"
```

### 2. 获取所有用户
```bash
curl http://localhost:8080/api/admin/users?page=1&page_size=20 \
  -H "Authorization: Bearer $ADMIN_TOKEN"
```

### 3. 删除用户
```bash
curl -X DELETE http://localhost:8080/api/admin/users/3 \
  -H "Authorization: Bearer $ADMIN_TOKEN"
```

### 4. 设置用户为管理员
```bash
curl -X PUT http://localhost:8080/api/admin/users/2/status \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"is_admin": true}'
```

### 5. 获取所有消息
```bash
curl http://localhost:8080/api/admin/messages?page=1&page_size=50 \
  -H "Authorization: Bearer $ADMIN_TOKEN"
```

### 6. 删除消息
```bash
curl -X DELETE http://localhost:8080/api/admin/messages/5 \
  -H "Authorization: Bearer $ADMIN_TOKEN"
```

## WebSocket 测试

### 使用 websocat (推荐)
```bash
# 安装 websocat
# Linux: cargo install websocat
# Mac: brew install websocat

# 连接 WebSocket
websocat "ws://localhost:8080/api/ws?token=$TOKEN"

# 发送消息（JSON格式）
{"type":"message","to_user_id":2,"content":"Hello from WebSocket"}

# 发送打字提示
{"type":"typing","to_user_id":2,"content":""}
```

### 使用 JavaScript
```javascript
const token = 'your-token-here';
const ws = new WebSocket(`ws://localhost:8080/api/ws?token=${token}`);

ws.onopen = () => {
  console.log('WebSocket 连接成功');
  
  // 发送消息
  ws.send(JSON.stringify({
    type: 'message',
    to_user_id: 2,
    content: 'Hello from JavaScript'
  }));
};

ws.onmessage = (event) => {
  console.log('收到消息:', JSON.parse(event.data));
};

ws.onerror = (error) => {
  console.error('WebSocket 错误:', error);
};

ws.onclose = () => {
  console.log('WebSocket 连接关闭');
};
```

## Postman 测试集合

创建 Postman Collection 导入以下配置：

### 环境变量
- `base_url`: http://localhost:8080
- `token`: (登录后设置)
- `admin_token`: (管理员登录后设置)

### 请求集合
1. Health Check (GET): {{base_url}}/health
2. Register (POST): {{base_url}}/api/register
3. Login (POST): {{base_url}}/api/login
4. Get Profile (GET): {{base_url}}/api/profile
   - Header: Authorization: Bearer {{token}}
5. Get Users (GET): {{base_url}}/api/users
   - Header: Authorization: Bearer {{token}}
6. Send Message (POST): {{base_url}}/api/messages
   - Header: Authorization: Bearer {{token}}
7. Get Messages (GET): {{base_url}}/api/messages/:user_id
   - Header: Authorization: Bearer {{token}}

## 自动化测试脚本

创建 `test_api.sh`:
```bash
#!/bin/bash

BASE_URL="http://localhost:8080"
echo "测试后端 API..."

# 1. 健康检查
echo "1. 健康检查..."
curl -s $BASE_URL/health | jq

# 2. 注册用户
echo -e "\n2. 注册用户..."
REGISTER_RESP=$(curl -s -X POST $BASE_URL/api/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test'$(date +%s)'","password":"123456","nickname":"测试用户"}')
echo $REGISTER_RESP | jq

# 3. 登录
USERNAME=$(echo $REGISTER_RESP | jq -r '.user.username')
echo -e "\n3. 登录..."
LOGIN_RESP=$(curl -s -X POST $BASE_URL/api/login \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"$USERNAME\",\"password\":\"123456\"}")
echo $LOGIN_RESP | jq

TOKEN=$(echo $LOGIN_RESP | jq -r '.token')
echo "Token: $TOKEN"

# 4. 获取个人资料
echo -e "\n4. 获取个人资料..."
curl -s $BASE_URL/api/profile \
  -H "Authorization: Bearer $TOKEN" | jq

# 5. 获取用户列表
echo -e "\n5. 获取用户列表..."
curl -s $BASE_URL/api/users \
  -H "Authorization: Bearer $TOKEN" | jq

echo -e "\n测试完成！"
```

运行测试：
```bash
chmod +x test_api.sh
./test_api.sh
```

## 性能测试

使用 Apache Bench (ab) 测试：
```bash
# 测试登录接口
ab -n 1000 -c 10 -p login.json -T application/json \
  http://localhost:8080/api/login

# login.json 内容:
# {"username":"testuser","password":"123456"}
```

使用 wrk 测试：
```bash
wrk -t4 -c100 -d30s http://localhost:8080/health
```

---

更多测试用例可以根据实际需求添加。
