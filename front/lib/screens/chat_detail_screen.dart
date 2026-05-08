import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ChatMessage {
  final String text;
  final bool isMe;
  final String time;
  const ChatMessage({required this.text, required this.isMe, required this.time});
}

class ChatDetailScreen extends StatefulWidget {
  final String name;
  final List<ChatMessage> messages;
  const ChatDetailScreen({super.key, required this.name, required this.messages});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late final List<ChatMessage> _messages;
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _messages = List.from(widget.messages);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(text: text, isMe: true, time: _nowTime()));
    });
    _controller.clear();
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

  static String _nowTime() {
    final now = DateTime.now();
    final h = now.hour;
    final m = now.minute.toString().padLeft(2, '0');
    final period = h < 12 ? '오전' : '오후';
    final hour = h % 12 == 0 ? 12 : h % 12;
    return '$period $hour:$m';
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
              itemBuilder: (_, i) => _MessageBubble(message: _messages[i]),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.lightGray.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              Text(
                widget.name,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
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
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(24),
              ),
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.pointColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.lightGray.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ],
          if (isMe)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                message.time,
                style: const TextStyle(fontFamily: 'Pretendard', fontSize: 10, color: AppColors.smallText),
              ),
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
              child: Text(
                message.text,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  color: isMe ? Colors.white : const Color(0xFF121212),
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                message.time,
                style: const TextStyle(fontFamily: 'Pretendard', fontSize: 10, color: AppColors.smallText),
              ),
            ),
        ],
      ),
    );
  }
}
