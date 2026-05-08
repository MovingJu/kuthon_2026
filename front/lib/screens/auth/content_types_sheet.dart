import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

const _contentTypeKeywords = [
  '게임', '메이크업', '힐링', '브이로그', '소통',
  '요리', '먹방', '베이킹', '뉴스', '음악',
  '여행', '키즈', '리뷰', '교육/지식', 'DIY',
  '운동', '자기계발',
];

class ContentTypesSheet extends StatefulWidget {
  const ContentTypesSheet({super.key});

  @override
  State<ContentTypesSheet> createState() => _ContentTypesSheetState();
}

class _ContentTypesSheetState extends State<ContentTypesSheet> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Color(0x40000000), blurRadius: 20, offset: Offset(0, -4))],
      ),
      padding: const EdgeInsets.fromLTRB(42, 40, 42, 85),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 10,
            children: _contentTypeKeywords.map((kw) => _TypeChip(
              label: kw,
              selected: _selected.contains(kw),
              onTap: () => setState(() {
                if (_selected.contains(kw)) {
                  _selected.remove(kw);
                } else {
                  _selected.add(kw);
                }
              }),
            )).toList(),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, _selected.toList()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('등록', style: TextStyle(fontFamily: 'Pretendard', fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? const Color(0x4D46D389) : Colors.white,
          border: selected
              ? Border.all(color: AppColors.pointColor, width: 0.4)
              : null,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: selected ? 0.1 : 0.06),
              blurRadius: selected ? 3 : 1.5,
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 12,
            fontWeight: selected ? FontWeight.w400 : FontWeight.w200,
            color: selected ? Colors.black : AppColors.gray500,
          ),
        ),
      ),
    );
  }
}
