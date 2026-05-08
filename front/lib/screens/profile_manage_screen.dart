import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';

class ProfileManageScreen extends StatefulWidget {
  const ProfileManageScreen({super.key});

  @override
  State<ProfileManageScreen> createState() => _ProfileManageScreenState();
}

class _ProfileManageScreenState extends State<ProfileManageScreen> {
  String _gender = '여자';
  String? _displayName;
  String? _userType;

  final Set<String> _selectedContentTypes = {'DIY'};
  final Set<String> _selectedStrengths = {'진정성 있는', '추진력'};
  final Set<String> _selectedStyles = {'차분한', '튜토리얼성'};

  static const _contentTypes = [
    '게임', '메이크업', '힐링', '브이로그', '소통',
    '요리', '먹방', '베이킹', '뉴스', '음악',
    '여행', '키즈', '리뷰', '교육/지식', 'DIY',
    '운동', '자기계발',
  ];

  static const _strengths = [
    '친근한', '진정성 있는', '스토리텔링', '공감능력',
    '꾸준한', '실행력 있는', '추진력', '편집을 잘하는',
    '차별화', '트렌디한', '전문성 있는', '팬층이 탄탄한',
    '비주얼적인', '독특한 아이디어',
  ];

  static const _styles = [
    '자막 중심', 'TTS', '더빙', '다이나믹', '정갈한',
    '차분한', '하이 텐션', '병맛', '직설적인',
    '실험적인', '튜토리얼성', '정보전달', '관찰형',
    '미스터리', '고퀄리티', '유머스러운', 'MBTI T',
    'MBTI F', '소통이 활발한',
  ];

  @override
  void initState() {
    super.initState();
    AuthService.getDisplayName().then((name) {
      if (mounted) setState(() => _displayName = name);
    });
    AuthService.getUserType().then((type) {
      if (mounted) setState(() => _userType = type);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 56),
                _buildAvatar(),
                const SizedBox(height: 22),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 34),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildField(label: '이름', value: _displayName ?? '박혜원', editable: false),
                      const SizedBox(height: 22),
                      _buildGenderField(),
                      const SizedBox(height: 22),
                      _buildField(label: '전화번호', value: '010-1234-5678'),
                      const SizedBox(height: 22),
                      _buildField(label: '이메일', value: '010-1234-5678'),
                      const SizedBox(height: 22),
                      _buildField(label: '소속', value: '010-1234-5678'),
                      const SizedBox(height: 22),
                      _buildTagSection(
                        label: '콘텐츠유형',
                        tags: _contentTypes,
                        selected: _selectedContentTypes,
                      ),
                      const SizedBox(height: 22),
                      _buildTagSection(
                        label: '강점',
                        tags: _strengths,
                        selected: _selectedStrengths,
                      ),
                      const SizedBox(height: 22),
                      _buildTagSection(
                        label: '스타일',
                        tags: _styles,
                        selected: _selectedStyles,
                      ),
                      const SizedBox(height: 100),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 25),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              child: const Icon(Icons.arrow_back_ios, size: 14, color: Colors.black),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            '내 프로필 관리',
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

  Widget _buildAvatar() {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          border: Border.all(color: AppColors.pointColor, width: 1),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.camera_alt_outlined, size: 20, color: Colors.grey),
      ),
    );
  }

  Widget _buildField({required String label, required String value, bool editable = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 11),
        Container(
          height: 41,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.pointColor),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    color: Color(0xFF979797),
                  ),
                ),
              ),
              if (editable)
                const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF979797)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '성별',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 11),
        Row(
          children: [
            _GenderButton(
              label: '여자',
              selected: _gender == '여자',
              onTap: () => setState(() => _gender = '여자'),
            ),
            const SizedBox(width: 12),
            _GenderButton(
              label: '남자',
              selected: _gender == '남자',
              onTap: () => setState(() => _gender = '남자'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTagSection({
    required String label,
    required List<String> tags,
    required Set<String> selected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 6,
          runSpacing: 10,
          children: tags.map((tag) {
            final isSelected = selected.contains(tag);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selected.remove(tag);
                  } else {
                    selected.add(tag);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0x4D46D389)
                      : Colors.white,
                  border: isSelected
                      ? Border.all(color: AppColors.pointColor, width: 0.4)
                      : null,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: isSelected
                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 3)]
                      : [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 1.5)],
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w400 : FontWeight.w200,
                    color: isSelected ? Colors.black : const Color(0xFF979797),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
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
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
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
          GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(context, '/my-page'),
            child: const Icon(Icons.person, size: 28, color: AppColors.pointColor),
          ),
        ],
      ),
    );
  }
}

class _GenderButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GenderButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 41,
        decoration: BoxDecoration(
          color: selected ? AppColors.pointColor : Colors.transparent,
          border: Border.all(color: AppColors.pointColor),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            color: selected ? Colors.white : const Color(0xFF979797),
          ),
        ),
      ),
    );
  }
}
