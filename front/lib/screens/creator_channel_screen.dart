import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../router/app_router.dart';

const _nyamThumb1 = 'https://www.figma.com/api/mcp/asset/a70cfec9-a18b-452e-a00e-9bdcfeac1bd5';
const _nyamThumb2 = 'https://www.figma.com/api/mcp/asset/632a8b51-c9d8-40ea-92aa-dbdd986e7ff4';

class CreatorChannelScreen extends StatefulWidget {
  const CreatorChannelScreen({super.key});

  @override
  State<CreatorChannelScreen> createState() => _CreatorChannelScreenState();
}

class _CreatorChannelScreenState extends State<CreatorChannelScreen> {
  int _tabIndex = 0;

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
                child: _tabIndex == 0 ? _buildChannelInfoTab(context) : _buildContentTab(context),
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
          const Text('이동주', style: TextStyle(fontFamily: 'Pretendard', fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black)),
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
                    Text('이동주', style: TextStyle(fontFamily: 'Pretendard', fontSize: 17, fontWeight: FontWeight.w700, color: Colors.black)),
                    SizedBox(height: 3),
                    Text('숏폼 콘텐츠', style: TextStyle(fontFamily: 'Pretendard', fontSize: 12, color: AppColors.smallText)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.dmChat),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(color: AppColors.pointColor, borderRadius: BorderRadius.circular(20)),
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
              '짧지만 강렬하게 — 트렌디한 숏폼 전문 에디터.\n보는 사람이 3초 안에 빠져드는 콘텐츠를 만듭니다.',
              style: TextStyle(fontFamily: 'Pretendard', fontSize: 13, height: 1.6, color: Color(0xFF121212)),
            ),
          ),
          const SizedBox(height: 16),

          // 핵심 스탯
          Row(
            children: [
              Expanded(child: _buildStatCard('구독자', '12.4만')),
              const SizedBox(width: 10),
              Expanded(child: _buildStatCard('총 조회수', '3.8M')),
              const SizedBox(width: 10),
              Expanded(child: _buildStatCard('평균 조회수', '48K')),
            ],
          ),
          const SizedBox(height: 20),

          // 월별 조회수 바 차트
          const Text('월별 조회수 추이', style: TextStyle(fontFamily: 'Pretendard', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black)),
          const SizedBox(height: 10),
          _buildBarChart(),
          const SizedBox(height: 20),

          // 시청자 연령대
          const Text('시청자 연령대', style: TextStyle(fontFamily: 'Pretendard', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black)),
          const SizedBox(height: 10),
          _buildAgeChart(),
          const SizedBox(height: 20),

          // 카테고리 태그
          const Text('카테고리', style: TextStyle(fontFamily: 'Pretendard', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: ['숏폼', '트렌디', '에디팅', '자막 중심', '고퀄리티'].map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.pointColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.pointColor, width: 0.5),
              ),
              child: Text(tag, style: const TextStyle(fontFamily: 'Pretendard', fontSize: 12, color: Colors.black)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
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

  Widget _buildBarChart() {
    // 이동주 — 냠냠굿보다 높은 수치
    const months = ['1월', '2월', '3월', '4월', '5월', '6월'];
    const values = [32000, 41000, 38000, 55000, 49000, 71000];
    const maxVal = 71000;

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
                    Text(_fmtK(values[i]), style: const TextStyle(fontFamily: 'Pretendard', fontSize: 9, color: AppColors.smallText)),
                    const SizedBox(height: 3),
                    Container(
                      width: 28,
                      height: math.max(8, 80 * ratio),
                      decoration: BoxDecoration(
                        color: i == months.length - 1 ? AppColors.pointColor : AppColors.pointColor.withValues(alpha: 0.4),
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

  String _fmtK(int val) => val >= 10000 ? '${(val / 10000).toStringAsFixed(1)}만' : '${val ~/ 1000}K';

  Widget _buildAgeChart() {
    // 이동주 — 10~20대 비율이 더 높음
    const groups = [
      ('10대', 0.22),
      ('20대', 0.41),
      ('30대', 0.21),
      ('40대', 0.11),
      ('50대+', 0.05),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 6)],
      ),
      child: Column(
        children: groups.map((g) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              SizedBox(width: 36, child: Text(g.$1, style: const TextStyle(fontFamily: 'Pretendard', fontSize: 11, color: Color(0xFF121212)))),
              const SizedBox(width: 8),
              Expanded(
                child: LayoutBuilder(
                  builder: (_, c) => Stack(
                    children: [
                      Container(height: 14, decoration: BoxDecoration(color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(7))),
                      Container(height: 14, width: c.maxWidth * g.$2, decoration: BoxDecoration(color: AppColors.pointColor, borderRadius: BorderRadius.circular(7))),
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
        )).toList(),
      ),
    );
  }

  // ─── 제작 콘텐츠 탭 ─────────────────────────────────────────────────────────

  Widget _buildContentTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(fontFamily: 'Pretendard', fontSize: 19),
              children: [
                TextSpan(text: '이동주', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.pointColor)),
                TextSpan(text: '님이 만든 콘텐츠', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildContentCard('부산찐맛집 !!', '맛집탐방', '리뷰/먹방', '숏폼 47초', _nyamThumb1),
          const SizedBox(height: 16),
          _buildContentCard('제주 앞바다 차원', '달라병 걸리다.', '여행/바다', '롱폼 17분', _nyamThumb2),
        ],
      ),
    );
  }

  Widget _buildContentCard(String title, String subtitle, String keyword, String type, String thumbUrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.pointColor),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              thumbUrl,
              width: 110, height: 82,
              fit: BoxFit.cover,
              errorBuilder: (_, e, s) => Container(width: 110, height: 82, color: const Color(0xFFD3D3D3)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$title\n$subtitle', style: const TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w600, height: 1.3, color: Colors.black)),
                const SizedBox(height: 8),
                _buildTagRow('키워드', keyword),
                const SizedBox(height: 4),
                _buildTagRow('종류', type),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagRow(String tag, String value) {
    return Row(
      children: [
        Container(
          width: 35, height: 17,
          decoration: BoxDecoration(color: AppColors.pointColor, borderRadius: BorderRadius.circular(10)),
          alignment: Alignment.center,
          child: Text(tag, style: const TextStyle(fontFamily: 'Pretendard', fontSize: 8, fontWeight: FontWeight.w600, color: Colors.white)),
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Text(value, style: const TextStyle(fontFamily: 'Pretendard', fontSize: 10, fontWeight: FontWeight.w500, color: Color(0x99000000)), overflow: TextOverflow.ellipsis),
        ),
      ],
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
            onTap: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.editorMain, (_) => false),
            child: const Icon(Icons.home, size: 28, color: AppColors.pointColor),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.editorPostRegister),
            child: const Icon(Icons.edit_outlined, size: 26, color: Colors.black),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.editorChat),
            child: const Icon(Icons.chat_bubble_outline, size: 26, color: Colors.black),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.editorMyPage),
            child: const Icon(Icons.person_outline, size: 28, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
