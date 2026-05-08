import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../router/app_router.dart';

class EditorMyPageScreen extends StatelessWidget {
  const EditorMyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHeader(context),
                const SizedBox(height: 30),
                _buildProfile(context),
                const SizedBox(height: 20),
                _buildActivityCard(),
                const SizedBox(height: 20),
                _buildWarningBanner(),
                const SizedBox(height: 17),
                _buildPostedCard(context),
                const SizedBox(height: 17),
                _buildClipContentCard(context),
                const SizedBox(height: 20),
              ],
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
      color: AppColors.bgWhite,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 25),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios, size: 16, color: Colors.black),
          ),
          const SizedBox(width: 10),
          const Text('마이페이지',
            style: TextStyle(fontFamily: 'Pretendard', fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black)),
          const Spacer(),
          const Icon(Icons.settings, size: 20, color: Colors.black54),
        ],
      ),
    );
  }

  Widget _buildProfile(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: AppColors.lightGray,
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        const SizedBox(height: 10),
        RichText(
          text: const TextSpan(
            style: TextStyle(fontFamily: 'Pretendard', fontSize: 24, color: Colors.black),
            children: [
              TextSpan(text: '문화메이트', style: TextStyle(fontWeight: FontWeight.w700)),
              TextSpan(text: '님', style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.profileManage),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.bgWhite,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: AppColors.pointColor),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8)],
            ),
            child: const Text('내 프로필 관리',
              style: TextStyle(fontFamily: 'Pretendard', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0x99000000))),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 41),
      child: Container(
        height: 121,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.pointColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        padding: const EdgeInsets.fromLTRB(26, 18, 26, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('활동 분석',
              style: TextStyle(fontFamily: 'Pretendard', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 18),
            Row(
              children: [
                _buildActivityStat('성사율', '12'),
                Container(width: 1, height: 41, color: Colors.white.withValues(alpha: 0.5), margin: const EdgeInsets.symmetric(horizontal: 20)),
                _buildActivityStat('모집중인 공고글', '11개'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
          style: const TextStyle(fontFamily: 'Pretendard', fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white)),
        const SizedBox(height: 3),
        Text(value,
          style: const TextStyle(fontFamily: 'Pretendard', fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
      ],
    );
  }

  Widget _buildWarningBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.pointColor),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: const [
                Icon(Icons.warning_amber_rounded, size: 16, color: Colors.red),
                SizedBox(width: 4),
                Text('경고', style: TextStyle(fontFamily: 'Pretendard', fontSize: 10, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text('크리에이터와의 계약에서 놓친 점이 있는지 확인해보세요',
            style: TextStyle(fontFamily: 'Pretendard', fontSize: 8, color: Color(0x99000000))),
        ],
      ),
    );
  }

  Widget _buildPostedCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        height: 194,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.pointColor),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.fromLTRB(25, 20, 25, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('작성한 공고',
              style: TextStyle(fontFamily: 'Pretendard', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.pointColor)),
            const SizedBox(height: 9),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontFamily: 'Pretendard', fontSize: 12, color: Color(0xCC000000)),
                children: [
                  TextSpan(text: '문화메이트님은 지금까지 총 '),
                  TextSpan(text: '21개', style: TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: '의 공고를 업로드 했어요. '),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('모집중', style: TextStyle(fontFamily: 'Pretendard', fontSize: 12, color: AppColors.pointColor)),
                      const SizedBox(height: 6),
                      const Text('11개', style: TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.editorPosted, arguments: 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: AppColors.pointColor, borderRadius: BorderRadius.circular(16)),
                          child: const Text('보러가기',
                            style: TextStyle(fontFamily: 'Pretendard', fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 79, color: Colors.black.withValues(alpha: 0.15)),
                Expanded(
                  child: Column(
                    children: [
                      const Text('마감', style: TextStyle(fontFamily: 'Pretendard', fontSize: 12, color: AppColors.pointColor)),
                      const SizedBox(height: 6),
                      const Text('10개', style: TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.editorPosted, arguments: 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: AppColors.pointColor, borderRadius: BorderRadius.circular(16)),
                          child: const Text('보러가기',
                            style: TextStyle(fontFamily: 'Pretendard', fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClipContentCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        height: 98,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.pointColor),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.fromLTRB(25, 20, 25, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('큘립에서 만든 콘텐츠',
              style: TextStyle(fontFamily: 'Pretendard', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.pointColor)),
            const SizedBox(height: 9),
            Row(
              children: [
                const Expanded(
                  child: Text('여러 크리에이터들이 만든 결과물을 확인하세요 !',
                    style: TextStyle(fontFamily: 'Pretendard', fontSize: 12, color: Color(0xCC000000))),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.editorMadeContent),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.pointColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8)],
                    ),
                    child: const Text('보러가기',
                      style: TextStyle(fontFamily: 'Pretendard', fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ],
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
            onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.editorMain),
            child: const Icon(Icons.home, size: 28, color: Colors.black),
          ),
          GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.editorPostRegister),
            child: const Icon(Icons.edit_outlined, size: 26, color: Colors.black),
          ),
          GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.editorChat),
            child: const Icon(Icons.chat_bubble_outline, size: 26, color: Colors.black),
          ),
          const Icon(Icons.person, size: 28, color: AppColors.pointColor),
        ],
      ),
    );
  }
}
