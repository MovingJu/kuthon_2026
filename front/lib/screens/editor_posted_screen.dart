import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../router/app_router.dart';

class EditorPostedScreen extends StatefulWidget {
  const EditorPostedScreen({super.key});

  @override
  State<EditorPostedScreen> createState() => _EditorPostedScreenState();
}

class _EditorPostedScreenState extends State<EditorPostedScreen> {
  int _tabIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is int) setState(() => _tabIndex = arg);
  }

  static const _recruitingPosts = [
    _PostData(
      title: "대나무 숲의 속삭임과 함께하는 '담양 죽순 요리'",
      desc: '자연의 소리와 전통 음식이 어우러지는 고감도 미식 필름 제작',
      totalResumes: 13,
      unread: 9,
    ),
    _PostData(
      title: '감성 브이로그 #일상 #카페투어',
      desc: '서울 숨은 카페를 찾아 떠나는 감성 영상 제작',
      totalResumes: 7,
      unread: 2,
    ),
  ];

  static const _closedPosts = [
    _PostData(
      title: "대나무 숲의 속삭임과 함께하는 '담양 죽순 요리'",
      desc: '자연의 소리와 전통 음식이 어우러지는 고감도 미식 필름 제작',
      totalResumes: 13,
      unread: 9,
    ),
    _PostData(
      title: '부산 로컬 먹방 콘텐츠 제작',
      desc: '부산 현지인만 아는 맛집 탐방 숏폼 영상',
      totalResumes: 21,
      unread: 0,
    ),
  ];

  List<_PostData> get _currentPosts =>
      _tabIndex == 0 ? _recruitingPosts : _closedPosts;

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
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(32, 20, 32, 16),
                  itemCount: _currentPosts.length,
                  separatorBuilder: (_, i) => const SizedBox(height: 14),
                  itemBuilder: (_, i) => _buildPostCard(_currentPosts[i], context),
                ),
              ),
            ],
          ),
          // 공고 작성하기 버튼 — 네비 위 고정
          Positioned(
            left: 0, right: 0, bottom: 102,
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.editorPostRegister),
                child: Container(
                  width: 328,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.pointColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '공고 작성하기',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
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
            '작성한 공고',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
      child: Row(
        children: [
          _buildTab(0, '모집중'),
          const SizedBox(width: 10),
          _buildTab(1, '마감'),
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

  Widget _buildPostCard(_PostData post, BuildContext context) {
    return GestureDetector(
      // 공고 카드 클릭 → 이력서 목록으로 이동
      onTap: () => Navigator.pushNamed(context, AppRoutes.editorResumeList),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 13, 20, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 243,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post.desc,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 9,
                      color: Color(0xCC000000),
                      height: 1.33,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontFamily: 'Pretendard', fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                children: [
                  const TextSpan(text: '총 이력서 '),
                  TextSpan(
                    text: '${post.totalResumes}개',
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.pointColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 9),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontFamily: 'Pretendard', fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                children: [
                  const TextSpan(text: '읽지 않은 이력서 '),
                  TextSpan(
                    text: '${post.unread}개',
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.pointColor),
                  ),
                ],
              ),
            ),
          ],
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

class _PostData {
  final String title, desc;
  final int totalResumes, unread;
  const _PostData({required this.title, required this.desc, required this.totalResumes, required this.unread});
}
