import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import '../services/dm_service.dart';

class DmChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;

  const DmChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<DmChatScreen> createState() => _DmChatScreenState();
}

class _DmChatScreenState extends State<DmChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  List<DmMessage> _messages = [];
  String? _myUserId;
  Timer? _pollTimer;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _myUserId = await AuthService.getCurrentUserId();
    await _loadMessages();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _poll());
  }

  Future<void> _loadMessages() async {
    final msgs = await DmService.fetchMessages(widget.otherUserId);
    if (mounted) {
      setState(() => _messages = msgs);
      _scrollToBottom();
    }
  }

  Future<void> _poll() async {
    if (_messages.isEmpty) {
      await _loadMessages();
      return;
    }
    final after = _messages.last.createdAt;
    final newMsgs = await DmService.fetchMessages(widget.otherUserId, after: after);
    if (newMsgs.isNotEmpty && mounted) {
      setState(() => _messages = [..._messages, ...newMsgs]);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    _controller.clear();
    final msg = await DmService.sendMessage(widget.otherUserId, text);
    if (msg != null && mounted) {
      setState(() => _messages = [..._messages, msg]);
      _scrollToBottom();
    }
    if (mounted) setState(() => _sending = false);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final msg = _messages[i];
                final isMe = msg.senderId == _myUserId;
                final timeStr = _fmtTime(msg.createdAt);
                return _MessageBubble(text: msg.text, isMe: isMe, time: timeStr);
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.black),
              ),
              const SizedBox(width: 12),
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.lightGray.withValues(alpha: 0.5), shape: BoxShape.circle),
                child: const Icon(Icons.person, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              Text(widget.otherUserName,
                style: const TextStyle(fontFamily: 'Pretendard', fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, -2))],
      ),
      padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: MediaQuery.of(context).padding.bottom + 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextField(
                controller: _controller,
                style: const TextStyle(fontFamily: 'Pretendard', fontSize: 14, color: Colors.black),
                decoration: const InputDecoration(
                  hintText: '메시지를 입력하세요',
                  hintStyle: TextStyle(fontFamily: 'Pretendard', fontSize: 14, color: AppColors.smallText),
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.pointColor, shape: BoxShape.circle),
              child: const Icon(Icons.send, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  static String _fmtTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = h < 12 ? '오전' : '오후';
    final hour = h % 12 == 0 ? 12 : h % 12;
    return '$period $hour:$m';
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String time;
  const _MessageBubble({required this.text, required this.isMe, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            Container(
              width: 32, height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(color: AppColors.lightGray.withValues(alpha: 0.5), shape: BoxShape.circle),
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
          if (isMe)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(time, style: const TextStyle(fontFamily: 'Pretendard', fontSize: 10, color: AppColors.smallText)),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppColors.pointColor : const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
              ),
              child: Text(text,
                style: TextStyle(fontFamily: 'Pretendard', fontSize: 14, color: isMe ? Colors.white : const Color(0xFF121212), height: 1.4)),
            ),
          ),
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(time, style: const TextStyle(fontFamily: 'Pretendard', fontSize: 10, color: AppColors.smallText)),
            ),
        ],
      ),
    );
  }
}
