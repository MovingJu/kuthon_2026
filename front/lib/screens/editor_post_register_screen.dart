import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme/app_colors.dart';
import '../router/app_router.dart';
import '../services/auth_service.dart';

class EditorPostRegisterScreen extends StatefulWidget {
  const EditorPostRegisterScreen({super.key});

  @override
  State<EditorPostRegisterScreen> createState() => _EditorPostRegisterScreenState();
}

class _EditorPostRegisterScreenState extends State<EditorPostRegisterScreen> {
  final _titleCtrl = TextEditingController();
  final _introCtrl = TextEditingController();
  final _guideCtrl = TextEditingController();

  String? _contentType; // 'short' | 'long'
  DateTimeRange? _dateRange;
  bool _negotiable = false;

  final Set<String> _selectedContentTags = {};
  final Set<String> _selectedStrengthTags = {};
  final Set<String> _selectedStyleTags = {};

  bool get _canRegister =>
      _titleCtrl.text.isNotEmpty &&
      _introCtrl.text.isNotEmpty &&
      _contentType != null &&
      _dateRange != null &&
      _guideCtrl.text.isNotEmpty;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _introCtrl.dispose();
    _guideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 60, 22, 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRequiredSection(),
                const SizedBox(height: 24),
                _buildDivider(),
                const SizedBox(height: 24),
                _buildOptionalSection(),
                const SizedBox(height: 48),
                _buildRegisterButton(),
              ],
            ),
          ),
          Positioned(
            left: 24, right: 24, bottom: 16,
            child: _buildNavBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildRequiredSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('필수 작성란',
            style: TextStyle(fontFamily: 'Pretendard', fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.pointColor)),
          const SizedBox(height: 20),
          _buildFieldLabel('어떤 제목으로 게시할까요?'),
          const SizedBox(height: 14),
          _buildTextField(_titleCtrl, maxLength: 50, hint: '제목을 입력하세요 (50자 이내)'),
          const SizedBox(height: 30),
          _buildFieldLabel('콘텐츠의 소개를 작성해주세요.'),
          const SizedBox(height: 14),
          _buildTextField(_introCtrl, maxLength: 500, hint: '소개를 입력하세요 (500자 이내)', maxLines: 4),
          const SizedBox(height: 30),
          _buildFieldLabel('어떤 콘텐츠로 제작할까요?'),
          const SizedBox(height: 14),
          _buildContentTypeToggle(),
          const SizedBox(height: 30),
          _buildFieldLabel('콘텐츠 제작 기한을 알려주세요.'),
          const SizedBox(height: 14),
          _buildDatePicker(),
          const SizedBox(height: 30),
          _buildFieldLabel('제작 가이드를 작성해주세요.'),
          const SizedBox(height: 14),
          _buildTextField(_guideCtrl, maxLength: 200, hint: '가이드를 입력하세요 (200자 이내)', maxLines: 3),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(label,
      style: const TextStyle(fontFamily: 'Pretendard', fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black));
  }

  Widget _buildTextField(TextEditingController ctrl, {required int maxLength, required String hint, int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLength: maxLength,
      maxLines: maxLines,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(fontFamily: 'Pretendard', fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'Pretendard', fontSize: 12, color: AppColors.smallText),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightGray),
        ),
        filled: true,
        fillColor: Colors.white,
        counterStyle: const TextStyle(fontSize: 10, color: AppColors.smallText),
      ),
    );
  }

  Widget _buildContentTypeToggle() {
    return Row(
      children: [
        Expanded(child: _typeButton('숏폼', 'short')),
        const SizedBox(width: 16),
        Expanded(child: _typeButton('롱폼', 'long')),
      ],
    );
  }

  Widget _typeButton(String label, String value) {
    final selected = _contentType == value;
    return GestureDetector(
      onTap: () => setState(() => _contentType = value),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: selected ? AppColors.pointColor : AppColors.lightGray,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white),
        ),
        alignment: Alignment.center,
        child: Text(label,
          style: const TextStyle(fontFamily: 'Pretendard', fontSize: 14, color: Colors.white)),
      ),
    );
  }

  Widget _buildDatePicker() {
    final dateStr = _dateRange == null
        ? '기간을 선택하세요'
        : '${_fmtDate(_dateRange!.start)} → ${_fmtDate(_dateRange!.end)}${_negotiable ? ' (협의가능)' : ''}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.pointColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 5, offset: const Offset(0, 2))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dateStr,
                  style: const TextStyle(fontFamily: 'Pretendard', fontSize: 14, color: Colors.black)),
                const Icon(Icons.arrow_forward, size: 20, color: Colors.black54),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => setState(() => _negotiable = !_negotiable),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _negotiable ? AppColors.pointColor.withValues(alpha: 0.2) : AppColors.bgWhite,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: _negotiable ? AppColors.pointColor : AppColors.smallText),
            ),
            child: Text('협의 가능',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 10,
                color: _negotiable ? Colors.black : AppColors.smallText,
              )),
          ),
        ),
      ],
    );
  }

  String _fmtDate(DateTime d) => '${d.month}월 ${d.day}일';

  Future<void> _pickDate() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ko'),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.pointColor),
        ),
        child: child!,
      ),
    );
    if (range != null) setState(() => _dateRange = range);
  }

  Widget _buildDivider() {
    return const Divider(color: AppColors.lightGray, thickness: 1);
  }

  Widget _buildOptionalSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('선택 작성란',
            style: TextStyle(fontFamily: 'Pretendard', fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.pointColor)),
          const SizedBox(height: 20),
          _buildTagSection('선호하는 콘텐츠 유형', _contentTags, _selectedContentTags),
          const SizedBox(height: 30),
          _buildTagSection('선호하는 크리에이터의 강점', _strengthTags, _selectedStrengthTags),
          const SizedBox(height: 30),
          _buildTagSection('선호하는 크리에이터 스타일', _styleTags, _selectedStyleTags),
        ],
      ),
    );
  }

  Widget _buildTagSection(String title, List<String> tags, Set<String> selected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
          style: const TextStyle(fontFamily: 'Pretendard', fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 10,
          children: tags.map((tag) {
            final isSelected = selected.contains(tag);
            return GestureDetector(
              onTap: () => setState(() {
                if (isSelected) { selected.remove(tag); } else { selected.add(tag); }
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.pointColor.withValues(alpha: 0.3) : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: isSelected ? Border.all(color: AppColors.pointColor, width: 0.4) : null,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 1.5)],
                ),
                child: Text(tag,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w400 : FontWeight.w200,
                    color: isSelected ? Colors.black : AppColors.smallText,
                  )),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _register() async {
    if (!_canRegister) return;
    final token = await AuthService.getToken();
    final start = _dateRange!.start;
    final end = _dateRange!.end;
    final tags = [
      ..._selectedContentTags,
      ..._selectedStrengthTags,
      ..._selectedStyleTags,
    ].toList();

    final body = jsonEncode({
      'title': _titleCtrl.text,
      'category': _contentType == 'short' ? '숏폼' : '롱폼',
      'region': '전국',
      'description': '${_introCtrl.text}\n\n[제작 가이드]\n${_guideCtrl.text}',
      'tags': tags,
      'budget': '협의',
      'min_subscribers': 0,
      'reference_facts': <String>[],
      'nearby_spots': <String>[],
      'start_date': '${start.year}-${start.month.toString().padLeft(2,'0')}-${start.day.toString().padLeft(2,'0')}',
      'end_date': '${end.year}-${end.month.toString().padLeft(2,'0')}-${end.day.toString().padLeft(2,'0')}',
    });

    final res = await http.post(
      Uri.parse('$apiBaseUrl/items'),
      headers: {'Authorization': 'Bearer ${token ?? ''}', 'Content-Type': 'application/json'},
      body: body,
    );

    if (!mounted) return;
    if (res.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('공고가 등록되었습니다!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('등록 실패: ${res.statusCode}')),
      );
    }
  }

  Widget _buildRegisterButton() {
    return Center(
      child: GestureDetector(
        onTap: _canRegister ? _register : null,
        child: Container(
          width: 328,
          height: 52,
          decoration: BoxDecoration(
            color: _canRegister ? AppColors.pointColor : AppColors.lightGray,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4)],
          ),
          alignment: Alignment.center,
          child: const Text('등록하기',
            style: TextStyle(fontFamily: 'Pretendard', fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildNavBar() {
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
          const Icon(Icons.edit_outlined, size: 26, color: AppColors.pointColor),
          GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.editorChat),
            child: const Icon(Icons.chat_bubble_outline, size: 26, color: Colors.black),
          ),
          GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.editorMyPage),
            child: const Icon(Icons.person_outline, size: 28, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

const _contentTags = ['게임', '메이크업', '힐링', '브이로그', '소통', '요리', '먹방', '베이킹', '뉴스', '음악', '여행', '키즈', '리뷰', '교육/지식', 'DIY', '운동', '자기계발'];
const _strengthTags = ['친근한', '진정성 있는', '스토리텔링', '공감능력', '꾸준한', '실행력 있는', '추진력', '편집을 잘하는', '차별화', '트렌디한', '전문성 있는', '팬층이 탄탄한', '비주얼적인', '독특한 아이디어'];
const _styleTags = ['자막 중심', 'TTS', '더빙', '다이나믹', '정갈한', '차분한', '하이 텐션', '병맛', '직설적인', '실험적인', '튜토리얼성', '정보전달', '관찰형', '미스터리', '고퀄리티', '유머스러운', 'MBTI T', 'MBTI F', '소통이 활발한'];
