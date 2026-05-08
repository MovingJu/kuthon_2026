import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../router/app_router.dart';
import '../services/chat_store.dart';
import 'dm_chat_screen.dart';

const _avatarNyamnyam  = 'https://www.figma.com/api/mcp/asset/2280e757-5862-4fb5-a583-82c0eb9760cd';
const _avatarMovieMaster = 'https://www.figma.com/api/mcp/asset/ef1709bc-eb09-4466-ba89-eb8b61e18a00';
const _avatarLogin     = 'https://www.figma.com/api/mcp/asset/a74d9b53-9289-4c9e-9f8b-d7d23d4a0540';

const _chats = [
  _ChatData(name: '냠냠굿', lastMessage: '잘부탁드립니다!', avatarUrl: _avatarNyamnyam, unread: true),
  _ChatData(name: '무비마스터', lastMessage: '일정 조율 불가능할까요?', avatarUrl: _avatarMovieMaster, unread: false),
  _ChatData(name: '테크봇', lastMessage: '저랑은 조금 안맞지만 해보겠습니다.', avatarUrl: null, unread: false),
  _ChatData(name: '로그인', lastMessage: '아 너무 힘들것같아요', avatarUrl: _avatarLogin, unread: true),
];

class EditorChatScreen extends StatefulWidget {
  const EditorChatScreen({super.key});

  @override
  State<EditorChatScreen> createState() => _EditorChatScreenState();
}

class _EditorChatScreenState extends State<EditorChatScreen> {
  bool _unreadOnly = false;

  @override
  void initState() {
    super.initState();
    DmChatStore.messages.addListener(_onDmChanged);
  }

  @override
  void dispose() {
    DmChatStore.messages.removeListener(_onDmChanged);
    super.dispose();
  }

  void _onDmChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final dmMessages = DmChatStore.messages.value;
    final hasDm = dmMessages.isNotEmpty;
    final dmLastMessage = hasDm ? dmMessages.last.text : '메시지를 보내보세요';
    final dmUnread = hasDm && dmMessages.last.isMe; // 내가(에디터) 보낸 마지막 메시지는 읽음, 크리에이터가 보낸 건 unread

    final displayChats = _unreadOnly ? _chats.where((c) => c.unread).toList() : _chats;

    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(37, 20, 37, 100),
                  children: [
                    // 이동주(크리에이터)와의 DM 채팅
                    if (!_unreadOnly || (dmUnread && hasDm)) ...[
                      _buildDmItem(context, dmLastMessage, !dmMessages.last.isMe && hasDm),
                      const SizedBox(height: 30),
                    ],
                    ...displayChats.map((chat) => Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: _buildChatItem(chat, context),
                    )),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 24, right: 24, bottom: 16,
            child: _buildNavBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDmItem(BuildContext context, String lastMessage, bool unread) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const DmChatScreen(
            otherUserId: 'user_206e7fcd',
            otherUserName: '이동주 (크리에이터)',
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 57, height: 57,
            decoration: BoxDecoration(color: AppColors.pointColor.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: const Icon(Icons.person, color: AppColors.pointColor, size: 28),
          ),
          const SizedBox(width: 26),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('이동주 (크리에이터)',
                  style: TextStyle(fontFamily: 'Pretendard', fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF121212))),
                const SizedBox(height: 13),
                Text(lastMessage,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'Pretendard', fontSize: 14, color: AppColors.smallText)),
              ],
            ),
          ),
          if (unread)
            Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.bgWhite,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 25),
      child: Row(
        children: [
          _buildFilterPill(
            label: '전체',
            icon: Icons.people,
            selected: !_unreadOnly,
            onTap: () => setState(() => _unreadOnly = false),
          ),
          const SizedBox(width: 14),
          _buildUnreadPill(),
        ],
      ),
    );
  }

  Widget _buildFilterPill({required String label, required IconData icon, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.pointColor : AppColors.bgWhite,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: AppColors.pointColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: selected ? Colors.white : AppColors.pointColor),
            const SizedBox(width: 5),
            Text(label,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : AppColors.pointColor,
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildUnreadPill() {
    return GestureDetector(
      onTap: () => setState(() => _unreadOnly = !_unreadOnly),
      child: Container(
        width: 59, height: 38,
        decoration: BoxDecoration(
          color: _unreadOnly ? AppColors.pointColor.withValues(alpha: 0.1) : AppColors.bgWhite,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: AppColors.pointColor),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.black54),
            if (_unreadOnly) const Text('안읽음',
              style: TextStyle(fontFamily: 'Pretendard', fontSize: 8, fontWeight: FontWeight.w500, color: Colors.black54)),
            Positioned(
              top: 4, right: 6,
              child: Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatItem(_ChatData chat, BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.chat),
      child: Row(
        children: [
          _buildAvatar(chat.avatarUrl),
          const SizedBox(width: 26),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(chat.name,
                  style: const TextStyle(fontFamily: 'Pretendard', fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF121212))),
                const SizedBox(height: 13),
                Text(chat.lastMessage,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'Pretendard', fontSize: 14, color: AppColors.smallText)),
              ],
            ),
          ),
          if (chat.unread)
            Container(
              width: 12, height: 12,
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? url) {
    if (url == null) {
      return Container(
        width: 57, height: 57,
        decoration: const BoxDecoration(color: AppColors.lightGray, shape: BoxShape.circle),
        child: const Icon(Icons.person, size: 28, color: Colors.white),
      );
    }
    return ClipOval(
      child: Image.network(
        url, width: 57, height: 57, fit: BoxFit.cover,
        errorBuilder: (_, e, s) => Container(
          width: 57, height: 57,
          color: AppColors.lightGray,
          child: const Icon(Icons.person, size: 28, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.editorMain),
            child: const Icon(Icons.home, size: 28, color: Colors.black),
          ),
          GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.editorPostRegister),
            child: const Icon(Icons.edit_outlined, size: 26, color: Colors.black),
          ),
          const Icon(Icons.chat_bubble, size: 26, color: AppColors.pointColor),
          GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.editorMyPage),
            child: const Icon(Icons.person_outline, size: 28, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

class _ChatData {
  final String name, lastMessage;
  final String? avatarUrl;
  final bool unread;
  const _ChatData({required this.name, required this.lastMessage, required this.avatarUrl, required this.unread});
}
