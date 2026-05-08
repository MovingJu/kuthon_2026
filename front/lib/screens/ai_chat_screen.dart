import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import 'package:http/http.dart' as http;

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      appBar: AppBar(
        backgroundColor: AppColors.bgWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'AI 도우미',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.pointColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.pointColor,
          labelStyle: const TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'AI 채팅'),
            Tab(text: 'AI 추천 공고'),
            Tab(text: '팩트체크'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ChatTab(),
          _RecommendedTab(),
          _FactCheckTab(),
        ],
      ),
    );
  }
}

// ─── 탭 1: AI 채팅 ──────────────────────────────────────────────────────────────

class _ChatTab extends StatefulWidget {
  const _ChatTab();

  @override
  State<_ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<_ChatTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_Message> _messages = [];
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    _controller.clear();
    setState(() {
      _messages.add(_Message(text: text, isUser: true));
      _sending = true;
    });
    _scrollToBottom();

    try {
      final token = await AuthService.getToken();
      final res = await http.post(
        Uri.parse('$apiBaseUrl/ai/chat'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'message': text}),
      );
      if (!mounted) return;
      if (res.statusCode == 200) {
        final reply = jsonDecode(res.body)['reply'] as String? ?? '';
        setState(() => _messages.add(_Message(text: reply, isUser: false)));
      } else {
        setState(() => _messages.add(const _Message(text: '응답을 받지 못했습니다. 다시 시도해주세요.', isUser: false)));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _messages.add(const _Message(text: '서버에 연결할 수 없습니다.', isUser: false)));
    } finally {
      if (mounted) setState(() => _sending = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? const _EmptyView(
                  icon: Icons.chat_bubble_outline,
                  title: 'AI에게 무엇이든 물어보세요',
                  subtitle: '공고 추천, 콘텐츠 아이디어 등 자유롭게 질문하세요',
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: _messages.length + (_sending ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (_sending && i == _messages.length) {
                      return const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            _AiAvatar(),
                            SizedBox(width: 8),
                            _TypingBubble(),
                          ],
                        ),
                      );
                    }
                    return _MessageBubble(message: _messages[i]);
                  },
                ),
        ),
        _buildInputBar(context),
      ],
    );
  }

  Widget _buildInputBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: const InputDecoration(
                  hintText: '메시지를 입력하세요',
                  hintStyle: TextStyle(fontSize: 14, color: Color(0xFFAAAAAA)),
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: const TextStyle(fontFamily: 'Pretendard', fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sending ? null : _send,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _sending ? Colors.grey[300] : AppColors.pointColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;
  const _Message({required this.text, required this.isUser});
}

class _AiAvatar extends StatelessWidget {
  const _AiAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.pointColor.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.smart_toy_outlined, size: 18, color: AppColors.pointColor),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _Message message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            const _AiAvatar(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: message.isUser ? AppColors.pointColor : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  height: 1.5,
                  color: message.isUser ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) => Padding(
          padding: EdgeInsets.only(left: i == 0 ? 0 : 4),
          child: Container(width: 6, height: 6, decoration: BoxDecoration(color: Colors.grey[400], shape: BoxShape.circle)),
        )),
      ),
    );
  }
}

// ─── 탭 2: 추천 공고 ────────────────────────────────────────────────────────────

class _RecommendedTab extends StatefulWidget {
  const _RecommendedTab();

  @override
  State<_RecommendedTab> createState() => _RecommendedTabState();
}

class _RecommendedTabState extends State<_RecommendedTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final token = await AuthService.getToken();
      final res = await http.get(
        Uri.parse('$apiBaseUrl/items/recommended'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (!mounted) return;
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _items = List<Map<String, dynamic>>.from(data['items'] ?? []);
          _loading = false;
        });
      } else {
        setState(() { _error = '추천 공고를 불러오지 못했습니다'; _loading = false; });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() { _error = '서버에 연결할 수 없습니다'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.pointColor));
    }
    if (_error != null) {
      return _ErrorView(message: _error!, onRetry: _load);
    }
    if (_items.isEmpty) {
      return const _EmptyView(
        icon: Icons.recommend_outlined,
        title: '추천 공고가 없습니다',
        subtitle: '프로필을 채우면 맞춤 공고를 추천해드려요',
      );
    }
    return RefreshIndicator(
      color: AppColors.pointColor,
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _ItemCard(item: _items[i]),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const _ItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final tags = List<String>.from(item['tags'] ?? []);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.pointColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item['category'] ?? '',
                  style: const TextStyle(fontSize: 11, color: AppColors.pointColor, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item['region'] ?? '',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item['title'] ?? '',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          if ((item['description'] ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              item['description'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
            ),
          ],
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: tags.map((t) => _Tag(label: t)).toList(),
            ),
          ],
          if (item['budget'] != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.attach_money, size: 14, color: AppColors.pointColor),
                const SizedBox(width: 4),
                Text(item['budget'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
    );
  }
}

// ─── 탭 2: 팩트체크 ─────────────────────────────────────────────────────────────

class _FactCheckTab extends StatefulWidget {
  const _FactCheckTab();

  @override
  State<_FactCheckTab> createState() => _FactCheckTabState();
}

class _FactCheckTabState extends State<_FactCheckTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _textController = TextEditingController();
  List<Map<String, dynamic>> _items = [];
  Map<String, dynamic>? _selectedItem;
  Map<String, dynamic>? _result;
  bool _loadingItems = true;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    try {
      final token = await AuthService.getToken();
      final res = await http.get(
        Uri.parse('$apiBaseUrl/items'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (!mounted) return;
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _items = List<Map<String, dynamic>>.from(data['items'] ?? []);
          _loadingItems = false;
        });
      } else {
        setState(() => _loadingItems = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingItems = false);
    }
  }

  Future<void> _check() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('원고 내용을 입력해주세요')),
      );
      return;
    }
    if (_selectedItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('관련 공고를 선택해주세요')),
      );
      return;
    }

    setState(() { _checking = true; _result = null; });
    try {
      final token = await AuthService.getToken();
      final res = await http.post(
        Uri.parse('$apiBaseUrl/factcheck'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'item_id': _selectedItem!['id'], 'text': text}),
      );
      if (!mounted) return;
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() => _result = data['fact_check']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('팩트체크에 실패했습니다')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('서버에 연결할 수 없습니다')),
      );
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('관련 공고 선택', style: TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _loadingItems
              ? const Center(child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(color: AppColors.pointColor, strokeWidth: 2),
                ))
              : _items.isEmpty
                  ? const Text('공고가 없습니다', style: TextStyle(color: Colors.grey, fontSize: 13))
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Map<String, dynamic>>(
                          isExpanded: true,
                          value: _selectedItem,
                          hint: const Text('공고를 선택하세요', style: TextStyle(fontSize: 14, color: Colors.grey)),
                          items: _items.map((item) {
                            return DropdownMenuItem(
                              value: item,
                              child: Text(
                                item['title'] ?? '',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontFamily: 'Pretendard', fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedItem = val),
                        ),
                      ),
                    ),
          const SizedBox(height: 20),
          const Text('원고 내용', style: TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: TextField(
              controller: _textController,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: '팩트체크할 원고 내용을 입력하세요',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                contentPadding: EdgeInsets.all(14),
                border: InputBorder.none,
              ),
              style: const TextStyle(fontFamily: 'Pretendard', fontSize: 14, height: 1.5),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _checking ? null : _check,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _checking
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('팩트체크 실행', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text('팩트체크 결과', style: TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _FactCheckResult(result: _result!),
          ],
        ],
      ),
    );
  }
}

class _FactCheckResult extends StatelessWidget {
  final Map<String, dynamic> result;
  const _FactCheckResult({required this.result});

  @override
  Widget build(BuildContext context) {
    final raw = result['result'];
    final resultMap = raw is Map<String, dynamic> ? raw : <String, dynamic>{};

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.pointColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: resultMap.isEmpty
          ? Text(
              raw?.toString() ?? '결과 없음',
              style: const TextStyle(fontFamily: 'Pretendard', fontSize: 14, height: 1.6),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: resultMap.entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.key,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.pointColor),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        e.value.toString(),
                        style: const TextStyle(fontFamily: 'Pretendard', fontSize: 13, height: 1.5),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

// ─── 공통 위젯 ──────────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyView({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontFamily: 'Pretendard', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onRetry,
            child: const Text('다시 시도', style: TextStyle(color: AppColors.pointColor)),
          ),
        ],
      ),
    );
  }
}
