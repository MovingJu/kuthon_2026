import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../router/app_router.dart';
import '../../services/auth_service.dart';

class MemberTypeScreen extends StatelessWidget {
  const MemberTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 42),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 200),
              _TypeSection(
                question: '창의적인 콘텐츠를 만든다면?',
                buttonLabel: '크리에이터 회원으로 시작',
                onTap: () async {
                  await AuthService.saveUserType('creator');
                  if (context.mounted) Navigator.pushReplacementNamed(context, '/account-confirm');
                },
              ),
              const SizedBox(height: 60),
              _TypeSection(
                question: '색다른 홍보를 원한다면?',
                buttonLabel: '에디터 회원으로 시작',
                onTap: () async {
                  await AuthService.saveUserType('editor');
                  if (context.mounted) Navigator.pushReplacementNamed(context, AppRoutes.editorMain);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeSection extends StatelessWidget {
  final String question;
  final String buttonLabel;
  final VoidCallback onTap;

  const _TypeSection({
    required this.question,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 33),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              buttonLabel,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
