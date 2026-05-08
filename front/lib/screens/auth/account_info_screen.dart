import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/auth_service.dart';
import 'strengths_sheet.dart';
import 'styles_sheet.dart';
import 'content_types_sheet.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _birthdateController = TextEditingController();
  String? _selectedGender;
  String? _selectedContentType;
  List<String> _contentTypes = [];
  List<String> _strengths = [];
  List<String> _styles = [];
  bool _submitting = false;
  String? _nameError;
  String? _genderError;
  String? _contactError;
  String? _birthdateError;
  String? _contentTypeError;

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final nameError = _nameController.text.trim().isEmpty ? '이름을 입력해주세요' : null;
    final genderError = _selectedGender == null ? '성별을 선택해주세요' : null;
    final contactError = _contactController.text.trim().isEmpty ? '연락처를 입력해주세요' : null;
    final birthdateError = _birthdateController.text.trim().isEmpty ? '생년월일을 입력해주세요' : null;
    final contentTypeError = _selectedContentType == null ? '선호 콘텐츠 유형을 선택해주세요' : null;

    if (nameError != null || genderError != null || contactError != null ||
        birthdateError != null || contentTypeError != null) {
      setState(() {
        _nameError = nameError;
        _genderError = genderError;
        _contactError = contactError;
        _birthdateError = birthdateError;
        _contentTypeError = contentTypeError;
      });
      return;
    }
    setState(() => _submitting = true);
    try {
      await AuthService.submitProfile(
        name: _nameController.text.trim(),
        gender: _selectedGender ?? '',
        contact: _contactController.text.trim(),
        birthDate: _birthdateController.text.trim(),
        preferredContentTypes: _selectedContentType != null ? [_selectedContentType!] : [],
        categoryTags: _strengths,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/main');
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장에 실패했습니다. 다시 시도해주세요.')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _openContentTypesSheet() async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) => const ContentTypesSheet(),
    );
    if (result != null) setState(() => _contentTypes = result);
  }

  Future<void> _openStrengthsSheet() async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) => const StrengthsSheet(),
    );
    if (result != null) setState(() => _strengths = result);
  }

  Future<void> _openStylesSheet() async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) => const StylesSheet(),
    );
    if (result != null) setState(() => _styles = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 160),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 100),
                  const Center(
                    child: Text(
                      '멋진 계정이네요!',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    '크리에이터님은 어떤 분인지 더 알고싶어요.',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildLabel('이름'),
                  const SizedBox(height: 8),
                  _buildGlassInput(
                    _nameController,
                    onChanged: (_) { if (_nameError != null) setState(() => _nameError = null); },
                  ),
                  if (_nameError != null) ...[
                    const SizedBox(height: 4),
                    Text(_nameError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ],
                  const SizedBox(height: 30),
                  _buildLabel('성별'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _GenderButton(label: '남성', selected: _selectedGender == '남성', onTap: () => setState(() { _selectedGender = '남성'; _genderError = null; })),
                      const SizedBox(width: 10),
                      _GenderButton(label: '여성', selected: _selectedGender == '여성', onTap: () => setState(() { _selectedGender = '여성'; _genderError = null; })),
                      const SizedBox(width: 10),
                      _GenderButton(label: '비공개', selected: _selectedGender == '비공개', onTap: () => setState(() { _selectedGender = '비공개'; _genderError = null; })),
                    ],
                  ),
                  if (_genderError != null) ...[
                    const SizedBox(height: 4),
                    Text(_genderError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ],
                  const SizedBox(height: 30),
                  _buildLabel('연락처'),
                  const SizedBox(height: 8),
                  _buildGlassInput(_contactController, keyboardType: TextInputType.phone,
                    onChanged: (_) { if (_contactError != null) setState(() => _contactError = null); }),
                  if (_contactError != null) ...[
                    const SizedBox(height: 4),
                    Text(_contactError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ],
                  const SizedBox(height: 30),
                  _buildLabel('생년월일'),
                  const SizedBox(height: 8),
                  _buildGlassInput(_birthdateController, keyboardType: TextInputType.datetime,
                    onChanged: (_) { if (_birthdateError != null) setState(() => _birthdateError = null); }),
                  if (_birthdateError != null) ...[
                    const SizedBox(height: 4),
                    Text(_birthdateError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ],
                  const SizedBox(height: 40),
                  const Divider(color: AppColors.gray200, thickness: 1),
                  const SizedBox(height: 40),
                  const Text(
                    '선호 콘텐츠 유형',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _ContentTypeButton(label: '숏폼', selected: _selectedContentType == '숏폼', onTap: () => setState(() { _selectedContentType = '숏폼'; _contentTypeError = null; })),
                      const SizedBox(width: 20),
                      _ContentTypeButton(label: '롱폼', selected: _selectedContentType == '롱폼', onTap: () => setState(() { _selectedContentType = '롱폼'; _contentTypeError = null; })),
                    ],
                  ),
                  if (_contentTypeError != null) ...[
                    const SizedBox(height: 4),
                    Text(_contentTypeError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ],
                  const SizedBox(height: 40),
                  const Text(
                    '나의 콘텐츠 유형',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_contentTypes.isNotEmpty) ...[
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _contentTypes.map((s) => _SelectedTag(label: s)).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _buildAddButton(onTap: _openContentTypesSheet),
                  const SizedBox(height: 40),
                  const Text(
                    '나의 강점',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_strengths.isNotEmpty) ...[
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _strengths.map((s) => _SelectedTag(label: s)).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _buildAddButton(onTap: _openStrengthsSheet),
                  const SizedBox(height: 40),
                  const Text(
                    '나의 스타일',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_styles.isNotEmpty) ...[
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _styles.map((s) => _SelectedTag(label: s)).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _buildAddButton(onTap: _openStylesSheet),
                  const SizedBox(height: 40),
                  const Text(
                    '태그 설정',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightGray,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.white),
                        ),
                      ),
                      child: const Icon(Icons.add, size: 10, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: AppColors.bgWhite,
              padding: const EdgeInsets.fromLTRB(42, 20, 42, 43),
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pointColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _submitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('다음', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.gray800,
      ),
    );
  }

  Widget _buildGlassInput(TextEditingController controller, {TextInputType? keyboardType, ValueChanged<String>? onChanged}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 0.4),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4)],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton({required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.add, size: 16, color: Colors.white),
        label: const Text('추가하기', style: TextStyle(fontSize: 16, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightGray,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _GenderButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GenderButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 38,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: selected ? AppColors.pointColor : AppColors.lightGray,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(label, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}

class _ContentTypeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ContentTypeButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: selected ? AppColors.pointColor : AppColors.lightGray,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Colors.white),
            ),
          ),
          child: Text(label, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}

class _SelectedTag extends StatelessWidget {
  final String label;

  const _SelectedTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x4D46D389),
        border: Border.all(color: AppColors.pointColor, width: 0.4),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 12,
          fontWeight: FontWeight.w200,
          color: Colors.black,
        ),
      ),
    );
  }
}
