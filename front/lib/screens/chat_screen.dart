import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/dm_service.dart';
import '../services/auth_service.dart';
import 'chat_detail_screen.dart';
import 'dm_chat_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _showUnreadOnly = false;
  List<Map<String, String>> _dmChats = [];
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _debugUserId();
    _fetchChats();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _fetchChats());
  }

  Future<void> _debugUserId() async {
    final id = await AuthService.getCurrentUserId();
    debugPrint('[ChatScreen] my user_id from JWT: $id');
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchChats() async {
    try {
      final chats = await DmService.fetchChatList();
      debugPrint('[ChatScreen] fetchChatList result: $chats');
      if (mounted) setState(() => _dmChats = chats);
    } catch (e) {
      debugPrint('[ChatScreen] fetchChatList error: $e');
    }
  }

  static final _chats = [
    _ChatItem(
      name: '김현창 에디터',
      lastMessage: '안녕하세요! 안동문화재단 담당자 김현창 입니다. 지원해주신 공고 보고 연락드렸습니다.',
      hasUnread: true,
      messages: [
        ChatMessage(text: '안녕하세요! 안동문화재단 담당자 김현창 입니다. 지원해주신 공고 보고 연락드렸습니다.', isMe: false, time: '오전 10:32'),
        ChatMessage(text: '안녕하세요! 연락 주셔서 감사합니다 😊 어떤 프로젝트인지 더 자세히 알 수 있을까요?', isMe: true, time: '오전 10:35'),
        ChatMessage(text: '네, 안동 전통문화 관련 숏폼 영상 제작 프로젝트입니다. 안동 탈춤, 하회마을 등 전통 콘텐츠를 현대적으로 재해석하는 영상이에요.', isMe: false, time: '오전 10:38'),
        ChatMessage(text: '관심 있으시면 미팅 일정 잡아볼게요!', isMe: false, time: '오전 10:38'),
        ChatMessage(text: '정말 흥미로운 주제네요! 미팅 일정 잡아주시면 참여하고 싶습니다.', isMe: true, time: '오전 10:42'),
        ChatMessage(text: '그럼 이번 주 목요일 오후 3시 어떠세요? 화상으로 진행할 예정입니다.', isMe: false, time: '오전 10:45'),
        ChatMessage(text: '네, 목요일 오후 3시 가능합니다!', isMe: true, time: '오전 10:47'),
      ],
    ),
    _ChatItem(
      name: '수원미술관',
      lastMessage: '안녕하세요, 지원해주신 공고 보고 연락드렸습니다.',
      hasUnread: false,
      messages: [
        ChatMessage(text: '안녕하세요, 지원해주신 공고 보고 연락드렸습니다.', isMe: false, time: '오후 2:10'),
        ChatMessage(text: '안녕하세요! 관심 가져주셔서 감사합니다.', isMe: true, time: '오후 2:15'),
        ChatMessage(text: '포트폴리오 확인했는데 저희 전시 콘텐츠와 잘 맞을 것 같아요. 수원 현대미술 특별전 숏폼 영상 3편 제작을 원합니다.', isMe: false, time: '오후 2:18'),
        ChatMessage(text: '좋습니다! 예산과 일정은 어떻게 되시나요?', isMe: true, time: '오후 2:22'),
        ChatMessage(text: '제작비는 편당 30만원이고, 다음 달 말까지 납품 예정입니다.', isMe: false, time: '오후 2:25'),
      ],
    ),
    _ChatItem(
      name: '오주희',
      lastMessage: '네 마감기한 엄수해서 업로드 부탁드립니다',
      hasUnread: false,
      messages: [
        ChatMessage(text: '안녕하세요, 프로젝트 진행 상황 공유드릴게요.', isMe: false, time: '오전 9:00'),
        ChatMessage(text: '네, 말씀해 주세요!', isMe: true, time: '오전 9:05'),
        ChatMessage(text: '영상 편집본 1차 검토 완료했습니다. 몇 가지 수정 사항 보내드릴게요.', isMe: false, time: '오전 9:07'),
        ChatMessage(text: '색보정 부분이랑 인트로 자막 수정 부탁드려요. 마감은 이번 주 금요일까지입니다.', isMe: false, time: '오전 9:08'),
        ChatMessage(text: '네, 수정해서 목요일 저녁까지 올려드리겠습니다.', isMe: true, time: '오전 9:12'),
        ChatMessage(text: '네 마감기한 엄수해서 업로드 부탁드립니다', isMe: false, time: '오전 9:14'),
      ],
    ),
    _ChatItem(
      name: '담당자 동주',
      lastMessage: '진행 하시는거 맞으실까요?',
      hasUnread: true,
      messages: [
        ChatMessage(text: '안녕하세요, K-서프 영상제작 건으로 연락드렸습니다.', isMe: false, time: '오후 4:30'),
        ChatMessage(text: '안녕하세요!', isMe: true, time: '오후 4:45'),
        ChatMessage(text: '지원해 주신 공고 검토 중인데요, 혹시 서핑 관련 촬영 경험이 있으신가요?', isMe: false, time: '오후 4:47'),
        ChatMessage(text: '네, 작년에 양양에서 수상스포츠 관련 영상 2편 촬영한 경험이 있습니다.', isMe: true, time: '오후 5:02'),
        ChatMessage(text: '오 좋네요! 포트폴리오 링크 보내주실 수 있나요?', isMe: false, time: '오후 5:05'),
        ChatMessage(text: '진행 하시는거 맞으실까요?', isMe: false, time: '오후 5:32'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final displayed = _showUnreadOnly ? _chats.where((c) => c.hasUnread).toList() : _chats;

    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 16),
              children: [
                ..._dmChats
                  .where((c) => !_showUnreadOnly || int.tryParse(c['unread_count'] ?? '0')! > 0)
                  .map((c) => _DmChatListItem(
                    name: c['other_user_name'] ?? c['other_user_id']!,
                    lastMessage: c['last_message'] ?? '',
                    hasUnread: int.tryParse(c['unread_count'] ?? '0')! > 0,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DmChatScreen(
                          otherUserId: c['other_user_id']!,
                          otherUserName: c['other_user_name'] ?? c['other_user_id']!,
                        ),
                      ),
                    ),
                  )),
                ...displayed.map((c) => _ChatListItem(chat: c)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32.81, 49, 32.81, 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
                  ),
                  const SizedBox(width: 11),
                  const Text(
                    '채팅',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _showUnreadOnly = false),
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: _showUnreadOnly ? Colors.transparent : AppColors.pointColor,
                        border: Border.all(color: AppColors.pointColor),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people, size: 20, color: _showUnreadOnly ? AppColors.pointColor : Colors.white),
                          const SizedBox(width: 5),
                          Text(
                            '전체',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: _showUnreadOnly ? AppColors.pointColor : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  GestureDetector(
                    onTap: () => setState(() => _showUnreadOnly = true),
                    child: Container(
                      width: 59,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _showUnreadOnly ? AppColors.pointColor : AppColors.bgWhite,
                        border: Border.all(color: AppColors.pointColor),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 18,
                            color: _showUnreadOnly ? Colors.white : AppColors.pointColor,
                          ),
                          if (_showUnreadOnly || true)
                            Positioned(
                              top: 8,
                              right: 12,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DmChatListItem extends StatelessWidget {
  final String name;
  final String lastMessage;
  final bool hasUnread;
  final VoidCallback onTap;
  const _DmChatListItem({required this.name, required this.lastMessage, required this.hasUnread, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 20),
        child: Row(
          children: [
            Container(
              width: 57, height: 57,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.pointColor.withValues(alpha: 0.2),
              ),
              child: const Icon(Icons.person, color: AppColors.pointColor, size: 30),
            ),
            const SizedBox(width: 26),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(name, style: const TextStyle(fontFamily: 'Pretendard', fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF121212))),
                  const SizedBox(height: 4),
                  Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Pretendard', fontSize: 14, color: AppColors.gray500)),
                ],
              ),
            ),
            if (hasUnread)
              Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
          ],
        ),
      ),
    );
  }
}

class _ChatItem {
  final String name;
  final String lastMessage;
  final bool hasUnread;
  final List<ChatMessage> messages;

  const _ChatItem({
    required this.name,
    required this.lastMessage,
    required this.hasUnread,
    required this.messages,
  });
}

class _ChatListItem extends StatelessWidget {
  final _ChatItem chat;
  const _ChatListItem({required this.chat});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailScreen(name: chat.name, messages: chat.messages),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
        child: Container(
          height: 57,
          margin: const EdgeInsets.only(bottom: 20),
          child: Row(
            children: [
              Container(
                width: 57,
                height: 57,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lightGray.withValues(alpha: 0.5),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 26),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      chat.name,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF121212),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chat.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
              if (chat.hasUnread)
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
