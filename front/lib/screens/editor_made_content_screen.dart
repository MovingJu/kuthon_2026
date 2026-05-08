import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../router/app_router.dart';

const _thumb = 'https://www.figma.com/api/mcp/asset/a70cfec9-a18b-452e-a00e-9bdcfeac1bd5';

class EditorMadeContentScreen extends StatelessWidget {
  const EditorMadeContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildBody(context)),
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
            '큘립에서 만든 콘텐츠',
            style: TextStyle(fontFamily: 'Pretendard', fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '성사된 콘텐츠',
            style: TextStyle(fontFamily: 'Pretendard', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          const SizedBox(height: 4),
          const Text(
            '큘립을 통해 협업된 콘텐츠 목록입니다.',
            style: TextStyle(fontFamily: 'Pretendard', fontSize: 12, color: AppColors.smallText),
          ),
          const SizedBox(height: 20),
          _buildContentItem(context),
        ],
      ),
    );
  }

  Widget _buildContentItem(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.pointColor),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 수락 배지
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.pointColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '✓ 수락 완료',
                  style: TextStyle(fontFamily: 'Pretendard', fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
              const Spacer(),
              const Text(
                '2026.05.09',
                style: TextStyle(fontFamily: 'Pretendard', fontSize: 10, color: AppColors.smallText),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // 콘텐츠 카드
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _thumb,
                  width: 100,
                  height: 74,
                  fit: BoxFit.cover,
                  errorBuilder: (_, e, s) => Container(width: 100, height: 74, color: const Color(0xFFD3D3D3)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '부산찐맛집 !!\n맛집탐방',
                      style: TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w600, height: 1.3, color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    _buildTag('키워드', '리뷰/먹방'),
                    const SizedBox(height: 4),
                    _buildTag('종류', '숏폼 47초'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 12),
          // 크리에이터 정보
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.person, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('냠냠굿', style: TextStyle(fontFamily: 'Pretendard', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black)),
                  Text('리뷰/먹방', style: TextStyle(fontFamily: 'Pretendard', fontSize: 10, color: AppColors.smallText)),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.chat),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.pointColor),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    '채팅하기',
                    style: TextStyle(fontFamily: 'Pretendard', fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.pointColor),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String tag, String value) {
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
          child: Text(
            value,
            style: const TextStyle(fontFamily: 'Pretendard', fontSize: 10, fontWeight: FontWeight.w500, color: Color(0x99000000)),
            overflow: TextOverflow.ellipsis,
          ),
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
