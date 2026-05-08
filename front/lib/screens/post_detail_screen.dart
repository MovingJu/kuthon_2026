import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme/app_colors.dart';
import '../services/application_store.dart';
import '../services/auth_service.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  bool _applied = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final id = args?['id'] as String? ?? 'default';
    setState(() => _applied = ApplicationStore.instance.isApplied(id));
  }

  Future<void> _onApply(Map<String, dynamic>? args) async {
    final id = args?['id'] as String? ?? 'default';
    if (_applied) return;

    // 백엔드 API 호출
    try {
      final token = await AuthService.getToken();
      final res = await http.post(
        Uri.parse('$apiBaseUrl/items/$id/apply'),
        headers: {
          'Authorization': 'Bearer ${token ?? ''}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'message': '지원합니다.'}),
      );
      if (res.statusCode == 201 || res.statusCode == 409) {
        // 201: 신청 성공, 409: 이미 신청함 — 둘 다 신청 완료로 처리
        ApplicationStore.instance.apply(AppliedPost(
          id: id,
          title: args?['title'] as String? ?? '',
          subtitle: args?['subtitle'] as String? ?? '',
          reward: args?['reward'] as String? ?? '',
          deadline: args?['deadline'] as String? ?? '',
          imageAsset: args?['imageAsset'] as String? ?? '',
        ));
        setState(() => _applied = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('공고에 신청했습니다!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('신청 실패: ${res.statusCode}')),
          );
        }
      }
    } catch (_) {
      // 네트워크 오류 시 로컬만 업데이트
      ApplicationStore.instance.apply(AppliedPost(
        id: id,
        title: args?['title'] as String? ?? '',
        subtitle: args?['subtitle'] as String? ?? '',
        reward: args?['reward'] as String? ?? '',
        deadline: args?['deadline'] as String? ?? '',
        imageAsset: args?['imageAsset'] as String? ?? '',
      ));
      setState(() => _applied = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('공고에 신청했습니다!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final title = args?['title'] as String? ?? '천년의 기록, 디지털로 다시 피어나다';
    final subtitle = args?['subtitle'] as String? ?? '안동문화재단 크리에이터 모집';
    final reward = args?['reward'] as String? ?? '프로젝트 제작 지원금 50만원';
    final deadline = args?['deadline'] as String? ?? '2026.05.08 ~ 2026.06.30';
    final imageAsset = args?['imageAsset'] as String? ?? '';
    final region = args?['region'] as String? ?? '';
    final ageGroup = args?['ageGroup'] as String? ?? '';
    final contentType = args?['contentType'] as String? ?? '';

    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(context, imageAsset),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '안동문화재단',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.gray500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF121212),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '콘텐츠 소개',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '시간이 멈춘 듯한 안동의 고택과 그 안에 깃든 수많은 기록은 단순한 과거의 유산이 아닙니다. 안동문화재단은 이 오래된 이야기들을 현대적인 픽셀과 모션으로 재해석하여, 오늘날의 대중에게 새로운 감동을 선사할 디지털 크리에이터를 모집합니다.\n\n우리는 단순한 기록을 넘어, 전통과 미래를 잇는 연결고리가 되어줄 창의적인 제작자들을 기다립니다. 안동의 깊은 숨결을 당신의 감각적인 콘텐츠로 다시 꽃피워 주세요. 천년의 시간이 당신의 스크린 위에서 새롭게 시작됩니다.',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        '콘텐츠 조건',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _ConditionRow(label: '리워드', value: reward),
                      const SizedBox(height: 16),
                      _ConditionRow(label: '마감기한', value: '$deadline (협의가능)'),
                      const SizedBox(height: 16),
                      const _ConditionRow(label: '업로드 형태', value: '롱폼, 8분 이상'),
                      const SizedBox(height: 16),
                      const _ConditionRow(label: '가이드', value: '안동 체험 영상 및 후기 필수'),
                      const SizedBox(height: 16),
                      _ConditionRow(
                        label: '타겟층',
                        value: ageGroup.isNotEmpty ? '$ageGroup 시청층 우대' : '전 연령',
                      ),
                      const SizedBox(height: 16),
                      _ConditionTagRow(
                        label: '선호 콘텐츠\n유형',
                        tags: contentType.isNotEmpty ? [contentType] : ['기타'],
                      ),
                      const SizedBox(height: 16),
                      _ConditionTagRow(label: '선호 강점', tags: const ['친근한', '전문성 있는', '트렌디한']),
                      const SizedBox(height: 16),
                      _ConditionRow(
                        label: '태그',
                        value: region.isNotEmpty ? '#$region' : '',
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: SizedBox(
                          width: 328,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _applied ? null : () => _onApply(args),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.pointColor,
                              disabledBackgroundColor: AppColors.lightGray,
                              foregroundColor: Colors.white,
                              disabledForegroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              shadowColor: Colors.black.withValues(alpha: 0.08),
                            ),
                            child: Text(
                              _applied ? '신청 완료' : '지원하기',
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 120),
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

  Widget _buildTopBar(BuildContext context, String imageUrl) {
    return SizedBox(
      height: 313,
      child: Stack(
        children: [
          Positioned(
            top: 73,
            left: -1,
            right: 0,
            child: SizedBox(
              height: 240,
              child: imageUrl.isNotEmpty
                  ? Image.asset(imageUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: const Color(0xFFD9D9D9)))
                  : Container(color: const Color(0xFFD9D9D9)),
            ),
          ),
          Positioned(
            top: 11,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Container(
                color: AppColors.bgWhite,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(context, '/main'),
            child: const Icon(Icons.home_outlined, size: 28, color: Colors.black),
          ),
          GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(context, '/chat'),
            child: const Icon(Icons.chat_bubble_outline, size: 26, color: Colors.black),
          ),
          const Icon(Icons.person_outline, size: 28, color: Colors.black),
        ],
      ),
    );
  }
}

class _ConditionRow extends StatelessWidget {
  final String label;
  final String value;
  const _ConditionRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.gray500,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF121212),
            ),
          ),
        ),
      ],
    );
  }
}

class _ConditionTagRow extends StatelessWidget {
  final String label;
  final List<String> tags;
  const _ConditionTagRow({required this.label, required this.tags});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.gray500,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tags.map((t) => _Tag(label: t)).toList(),
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x4D46D389),
        border: Border.all(color: AppColors.pointColor, width: 0.4),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 3)],
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
      ),
    );
  }
}
