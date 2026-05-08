import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../router/app_router.dart';
import '../services/application_store.dart';

class ParticipatedContentScreen extends StatefulWidget {
  const ParticipatedContentScreen({super.key});

  @override
  State<ParticipatedContentScreen> createState() => _ParticipatedContentScreenState();
}

class _ParticipatedContentScreenState extends State<ParticipatedContentScreen> {
  int _selectedTab = 0;
  static const _tabs = ['신청', '참여', '종료'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: Column(
        children: [
          _buildHeader(context),
          _buildTabBar(),
          Expanded(child: _buildBody()),
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
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 25),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.black),
              ),
              const SizedBox(width: 10),
              const Text(
                '참여 콘텐츠',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 20,
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

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final selected = i == _selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  children: [
                    Text(
                      _tabs[i],
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: selected ? Colors.black : const Color(0xFF979797),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.pointColor : const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBody() {
    // 신청 탭: 실제 신청 목록 표시
    if (_selectedTab == 0) {
      final posts = ApplicationStore.instance.applied;
      if (posts.isEmpty) return _buildEmpty();
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(32, 20, 32, 20),
        itemCount: posts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, i) => _PostCard(post: posts[i]),
      );
    }
    return _buildEmpty();
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.article_outlined, size: 70, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            '콘텐츠 참여내역이 없습니다.',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 29),
          SizedBox(
            width: 328,
            height: 40,
            child: ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.main),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                '콘텐츠 탐색하러 가기',
                style: TextStyle(fontFamily: 'Pretendard', fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final AppliedPost post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.fromLTRB(20, 13, 19, 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  post.title,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Text(
                  post.subtitle,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 9,
                    color: Color(0xCC000000),
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                _BadgeRow(label: '리워드', value: post.reward),
                const SizedBox(height: 2),
                _BadgeRow(label: '기한', value: post.deadline),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 105,
              height: 105,
              color: const Color(0xFFD3D3D3),
              child: post.imageAsset.isNotEmpty
                  ? Image.asset(post.imageAsset, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox())
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeRow extends StatelessWidget {
  final String label;
  final String value;
  const _BadgeRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 35,
          height: 17,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFB1B1B1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0x99000000),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
