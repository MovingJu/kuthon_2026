import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

const _strengthKeywords = [
  '친근한', '진정성 있는', '스토리텔링', '공감능력',
  '꾸준한', '실행력 있는', '추진력', '편집을 잘하는',
  '차별화', '트렌디한', '전문성 있는', '팬층이 탄탄한',
  '비주얼적인', '독특한 아이디어',
];

class StrengthsSheet extends StatefulWidget {
  const StrengthsSheet({super.key});

  @override
  State<StrengthsSheet> createState() => _StrengthsSheetState();
}

class _StrengthsSheetState extends State<StrengthsSheet> {
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
            children: _strengthKeywords.map((kw) => _KeywordChip(
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
              child: const Text('등록', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

class _KeywordChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _KeywordChip({required this.label, required this.selected, required this.onTap});

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
              color: Colors.black.withValues(alpha: selected ? 0.1 : 0.1),
              blurRadius: selected ? 3 : 1.5,
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 12,
            fontWeight: FontWeight.w200,
            color: selected ? Colors.black : AppColors.smallText,
          ),
        ),
      ),
    );
  }
}
