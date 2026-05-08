import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../router/app_router.dart';

const _defaultThumb = 'https://www.figma.com/api/mcp/asset/a70cfec9-a18b-452e-a00e-9bdcfeac1bd5';

class EditorResumeViewScreen extends StatefulWidget {
  const EditorResumeViewScreen({super.key});

  @override
  State<EditorResumeViewScreen> createState() => _EditorResumeViewScreenState();
}

class _EditorResumeViewScreenState extends State<EditorResumeViewScreen> {
  int _tabIndex = 0; // 채널 정보 기본 활성

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(context),
              _buildTabBar(),
              Expanded(
                child: _tabIndex == 0
                    ? _buildChannelInfoTab(context)
                    : _buildContentTab(),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 25),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios, size: 16, color: Colors.black),
          ),
          const SizedBox(width: 10),
          const Text(
            '이력서 열람',
            style: TextStyle(fontFamily: 'Pretendard', fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          _buildTab(0, '채널 정보'),
          const SizedBox(width: 10),
          _buildTab(1, '제작 콘텐츠'),
        ],
      ),
    );
  }

  Widget _buildTab(int idx, String label) {
    final active = _tabIndex == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = idx),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: active ? Colors.black : AppColors.smallText,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 2,
              decoration: BoxDecoration(
                color: active ? AppColors.pointColor : const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 채널 정보 탭 ───────────────────────────────────────────────────────────

  Widget _buildChannelInfoTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 프로필 + 채팅하기
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.person, size: 36, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('냠냠굿', style: TextStyle(fontFamily: 'Pretendard', fontSize: 17, fontWeight: FontWeight.w700, color: Colors.black)),
                    SizedBox(height: 3),
                    Text('리뷰/먹방', style: TextStyle(fontFamily: 'Pretendard', fontSize: 12, color: AppColors.smallText)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.chat),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.pointColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('채팅하기', style: TextStyle(fontFamily: 'Pretendard', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 채널 소개
          const Text('채널 소개', style: TextStyle(fontFamily: 'Pretendard', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 6)],
            ),
            child: const Text(
              '맛있는 걸 더 맛있게 담는 푸드 콘텐츠 크리에이터.\n보는 순간 군침이 도는 영상을 만듭니다.',
              style: TextStyle(fontFamily: 'Pretendard', fontSize: 13, height: 1.6, color: Color(0xFF121212)),
            ),
          ),
          const SizedBox(height: 16),

          // 핵심 스탯 3개
          Row(
            children: [
              Expanded(child: _buildChannelStatCard('구독자', '8.2만')),
              const SizedBox(width: 10),
              Expanded(child: _buildChannelStatCard('총 조회수', '2.1M')),
              const SizedBox(width: 10),
              Expanded(child: _buildChannelStatCard('평균 조회수', '26K')),
            ],
          ),
          const SizedBox(height: 20),

          // 월별 조회수 바 차트
          const Text('월별 조회수 추이', style: TextStyle(fontFamily: 'Pretendard', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black)),
          const SizedBox(height: 10),
          _buildBarChartCard(),
          const SizedBox(height: 20),

          // 시청자 연령대 차트
          const Text('시청자 연령대', style: TextStyle(fontFamily: 'Pretendard', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black)),
          const SizedBox(height: 10),
          _buildAgeChartCard(),
          const SizedBox(height: 20),

          // 카테고리 태그
          const Text('카테고리', style: TextStyle(fontFamily: 'Pretendard', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: ['먹방', '리뷰', '맛집탐방', '숏폼', '브이로그'].map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.pointColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.pointColor, width: 0.5),
              ),
              child: Text(tag, style: const TextStyle(fontFamily: 'Pretendard', fontSize: 12, color: Colors.black)),
            )).toList(),
          ),
          const SizedBox(height: 28),

          // 수락하기 버튼
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.editorMadeContent),
            child: Container(
              height: 52,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.pointColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: const Text(
                '수락하기',
                style: TextStyle(fontFamily: 'Pretendard', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 6)],
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontFamily: 'Pretendard', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.pointColor)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontFamily: 'Pretendard', fontSize: 9, color: AppColors.smallText)),
        ],
      ),
    );
  }

  Widget _buildBarChartCard() {
    const months = ['1월', '2월', '3월', '4월', '5월', '6월'];
    const values = [18000, 24000, 21000, 31000, 26000, 38000];
    const maxVal = 38000;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 6)],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(months.length, (i) {
                final ratio = values[i] / maxVal;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _formatK(values[i]),
                      style: const TextStyle(fontFamily: 'Pretendard', fontSize: 9, color: AppColors.smallText),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      width: 28,
                      height: math.max(8, 80 * ratio),
                      decoration: BoxDecoration(
                        color: i == months.length - 1
                            ? AppColors.pointColor
                            : AppColors.pointColor.withValues(alpha: 0.4),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: months.map((m) => Text(m, style: const TextStyle(fontFamily: 'Pretendard', fontSize: 9, color: AppColors.smallText))).toList(),
          ),
        ],
      ),
    );
  }

  String _formatK(int val) => val >= 10000 ? '${(val / 10000).toStringAsFixed(1)}만' : '${val ~/ 1000}K';

  Widget _buildAgeChartCard() {
    const groups = [
      ('10대', 0.12),
      ('20대', 0.35),
      ('30대', 0.28),
      ('40대', 0.17),
      ('50대+', 0.08),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 6)],
      ),
      child: Column(
        children: groups.map((g) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  child: Text(g.$1, style: const TextStyle(fontFamily: 'Pretendard', fontSize: 11, color: Color(0xFF121212))),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LayoutBuilder(
                    builder: (_, constraints) => Stack(
                      children: [
                        Container(
                          height: 14,
                          decoration: BoxDecoration(color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(7)),
                        ),
                        Container(
                          height: 14,
                          width: constraints.maxWidth * g.$2,
                          decoration: BoxDecoration(color: AppColors.pointColor, borderRadius: BorderRadius.circular(7)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 32,
                  child: Text(
                    '${(g.$2 * 100).toInt()}%',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontFamily: 'Pretendard', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.pointColor),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── 제작 콘텐츠 탭 (수락 전 빈 상태) ────────────────────────────────────────

  Widget _buildContentTab() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.video_library_outlined, size: 48, color: AppColors.smallText),
          SizedBox(height: 14),
          Text(
            '아직 수락된 콘텐츠가 없어요.',
            style: TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.smallText),
          ),
          SizedBox(height: 6),
          Text(
            '채널 정보 탭에서 수락하기를 눌러주세요.',
            style: TextStyle(fontFamily: 'Pretendard', fontSize: 12, color: AppColors.smallText),
          ),
        ],
      ),
    );
  }

  // ─── 영상 분석 (수락 후 editorMadeContent 화면에서 확인) ────────────────────

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
            onTap: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.editorMain, (_) => false),
            child: const Icon(Icons.home, size: 28, color: Colors.black),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.editorPostRegister),
            child: const Icon(Icons.edit_outlined, size: 26, color: Colors.black),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.editorChat),
            child: const Icon(Icons.chat_bubble_outline, size: 26, color: Colors.black),
          ),
          const Icon(Icons.person, size: 28, color: AppColors.pointColor),
        ],
      ),
    );
  }
}
