import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

const _styleKeywords = [
  '자막 중심', 'TTS', '더빙', '다이나믹', '정갈한',
  '차분한', '하이 텐션', '병맛', '직설적인',
  '실험적인', '튜토리얼성', '정보전달', '관찰형',
  '미스터리', '고퀄리티',
];

class StylesSheet extends StatefulWidget {
  const StylesSheet({super.key});

  @override
  State<StylesSheet> createState() => _StylesSheetState();
}

class _StylesSheetState extends State<StylesSheet> {
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
            children: _styleKeywords.map((kw) => _KeywordChip(
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
              color: Colors.black.withValues(alpha: 0.1),
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
