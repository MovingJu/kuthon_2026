import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../router/app_router.dart';

// 이력서 목록 화면 — 지원자 프로필 카드 목록
class EditorResumeListScreen extends StatelessWidget {
  const EditorResumeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildApplicantList(context)),
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
            '이력서 목록',
            style: TextStyle(fontFamily: 'Pretendard', fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantList(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(29, 24, 29, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '지원자 목록',
            style: TextStyle(fontFamily: 'Pretendard', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          const SizedBox(height: 16),
          _buildApplicantCard(
            context,
            name: '냠냠굿',
            category: '리뷰/먹방',
            description: '맛있는 걸 더 맛있게 담는 푸드 콘텐츠 크리에이터.',
            submitDate: '2026.05.09',
            onTap: () => Navigator.pushNamed(context, AppRoutes.editorResumeView),
          ),
          const SizedBox(height: 16),
          _buildApplicantCard(
            context,
            name: '무비마스터',
            category: '영화/리뷰',
            description: '영화 한 편을 60초로 요약하는 숏폼 전문가.',
            submitDate: '2026.05.08',
            onTap: null,
          ),
          const SizedBox(height: 16),
          _buildApplicantCard(
            context,
            name: '테크봇',
            category: 'IT/테크',
            description: '최신 기술 트렌드를 쉽게 풀어드립니다.',
            submitDate: '2026.05.07',
            onTap: null,
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantCard(
    BuildContext context, {
    required String name,
    required String category,
    required String description,
    required String submitDate,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.pointColor),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person, size: 32, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontFamily: 'Pretendard', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.pointColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.pointColor, width: 0.5),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(fontFamily: 'Pretendard', fontSize: 10, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(fontFamily: 'Pretendard', fontSize: 12, color: AppColors.smallText),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        '제출일자',
                        style: TextStyle(fontFamily: 'Pretendard', fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF121212)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        submitDate,
                        style: const TextStyle(fontFamily: 'Pretendard', fontSize: 10, color: Color(0x99121212)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.smallText),
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
