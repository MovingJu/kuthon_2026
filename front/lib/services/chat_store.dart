import 'package:flutter/foundation.dart';
import '../screens/chat_detail_screen.dart';

// 에디터(문화메이트) ↔ 이동주 1:1 채팅 공유 저장소
class DmChatStore {
  DmChatStore._();

  static final messages = ValueNotifier<List<ChatMessage>>([]);

  static void add(ChatMessage msg) {
    messages.value = [...messages.value, msg];
  }
}
