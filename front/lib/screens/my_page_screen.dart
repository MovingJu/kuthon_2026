import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import '../services/youtube_service.dart';
import '../router/app_router.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  String? _displayName;
  YouTubeChannelInfo? _channelInfo;
  String? _userType;
  int? _statApplied;
  int? _statApproved;
  int? _statCompleted;

  @override
  void initState() {
    super.initState();
    AuthService.getDisplayName().then((name) {
      if (mounted) setState(() => _displayName = name);
    });
    YouTubeService.fetchMyChannel().then((info) {
      if (mounted) setState(() => _channelInfo = info);
    });
    AuthService.getUserType().then((type) {
      if (mounted) setState(() => _userType = type);
    });
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    final token = await AuthService.getToken();
    if (token == null) return;
    final res = await http.get(
      Uri.parse('$apiBaseUrl/my/stats'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200 && mounted) {
      final data = jsonDecode(res.body);
      setState(() {
        _statApplied = data['applied'];
        _statApproved = data['approved'];
        _statCompleted = data['completed'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _displayName ?? '사용자';
    final videoCount = _channelInfo?.videoCount;

    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 70),
                _buildAvatar(),
                const SizedBox(height: 23),
                _buildName(name),
                const SizedBox(height: 22),
                _buildChannelButton(context),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildActivityCard(),
                      const SizedBox(height: 28),
                      _buildWarningRow(),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        title: '포트폴리오',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.portfolio),
                        body: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 12,
                              color: Color(0xCC000000),
                            ),
                            children: [
                              TextSpan(text: '${name}님의 포트폴리오가 총 '),
                              TextSpan(
                                text: videoCount != null ? '$videoCount개' : '...',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              const TextSpan(text: ' 쌓였어요!'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 17),
                      _buildInfoCard(
                        title: '채널 분석',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.channelAnalysis),
                        body: const Text(
                          '더 큰 성장을 위해선 채널 분석이 필요해요!',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            color: Color(0xCC000000),
                          ),
                        ),
                      ),
                      const SizedBox(height: 110),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 16,
            child: _buildNavBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 52, 32, 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.black),
              ),
              const SizedBox(width: 18),
              const Expanded(
                child: Text(
                  '마이페이지',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.profileManage),
                child: Icon(Icons.settings, size: 20, color: AppColors.pointColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final thumbnailUrl = _channelInfo?.thumbnailUrl;
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: thumbnailUrl != null && thumbnailUrl.isNotEmpty
          ? Image.network(
              thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(),
            )
          : null,
    );
  }

  Widget _buildName(String name) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: name,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const TextSpan(
            text: '님',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.channelManage),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          border: Border.all(color: AppColors.pointColor),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8)],
        ),
        child: const Text(
          '내 채널 관리',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0x99000000),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.participatedContent),
      child: _activityCardContent(),
    );
  }

  Widget _activityCardContent() {
    return Container(
      height: 121,
      decoration: BoxDecoration(
        color: AppColors.pointColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8)],
      ),
      padding: const EdgeInsets.fromLTRB(26, 18, 26, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '참여 활동',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ActivityStat(label: '신청', value: _statApplied?.toString() ?? '-'),
              Container(width: 1, height: 41, color: Colors.white.withValues(alpha: 0.5)),
              _ActivityStat(label: '참여', value: _statApproved?.toString() ?? '-'),
              Container(width: 1, height: 41, color: Colors.white.withValues(alpha: 0.5)),
              _ActivityStat(label: '종료', value: _statCompleted?.toString() ?? '-'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarningRow() {
    return Row(
      children: [
        Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.pointColor),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange),
              SizedBox(width: 3),
              Text(
                '경고',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 7),
        const Flexible(
          child: Text(
            '에디터와의 계약에서 놓친 점이 있는지 확인해보세요',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 8,
              color: Color(0x99000000),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({required String title, required Widget body, required VoidCallback onTap}) {
    return Container(
      constraints: const BoxConstraints(minHeight: 98),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        border: Border.all(color: AppColors.pointColor),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8)],
      ),
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.pointColor,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(child: body),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.pointColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8)],
                  ),
                  child: const Text(
                    '보러가기',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    final isEditor = _userType == 'editor';
    final homeRoute = isEditor ? '/editor-main' : '/main';
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: isEditor ? 40 : 70, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(context, homeRoute),
            child: const Icon(Icons.home_outlined, size: 28, color: Colors.black),
          ),
          if (isEditor)
            const Icon(Icons.edit_outlined, size: 26, color: Colors.black),
          GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(context, '/chat'),
            child: const Icon(Icons.chat_bubble_outline, size: 26, color: Colors.black),
          ),
          const Icon(Icons.person, size: 28, color: AppColors.pointColor),
        ],
      ),
    );
  }
}

class _ActivityStat extends StatelessWidget {
  final String label;
  final String value;
  const _ActivityStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Pretendard', fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white)),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(fontFamily: 'Pretendard', fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
      ],
    );
  }
}
