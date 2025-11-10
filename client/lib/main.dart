import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'app/services/api_service.dart';
import 'app/services/session_service.dart';
import 'app/services/websocket_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync<SessionService>(
    () => SessionService().init(),
    permanent: true,
  );
  await Get.putAsync<ApiService>(
    () => ApiService().init(),
    permanent: true,
  );
  Get.put<WebSocketService>(
    WebSocketService(),
    permanent: true,
  );
  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'WebSocket Chat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
