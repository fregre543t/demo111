import 'package:get/get.dart';

import '../modules/chat/controllers/chat_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    final roomId = Get.parameters['roomId'];
    if (roomId == null) {
      throw ArgumentError('缺少房间ID');
    }
    Get.put(ChatController(roomId));
  }
}
