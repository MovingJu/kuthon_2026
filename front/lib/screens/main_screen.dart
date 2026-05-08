import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import '../theme/app_colors.dart';
import '../services/auth_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? _displayName;
  String? _selectedRegion;
  String? _selectedAgeGroup;
  String? _selectedContentType;
  List<_ItemData> _apiItems = [];

  @override
  void initState() {
    super.initState();
    AuthService.getDisplayName().then((name) {
      if (mounted) setState(() => _displayName = name);
    });
    _fetchApiItems();
  }

  Future<void> _fetchApiItems() async {
    try {
      final token = await AuthService.getToken();
      final res = await http.get(
        Uri.parse('$apiBaseUrl/items'),
        headers: {'Authorization': 'Bearer ${token ?? ''}'},
      );
      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        final items = (data['items'] as List? ?? []).map((e) {
          final m = e as Map<String, dynamic>;
          final startDate = m['start_date'] as String? ?? '';
          final endDate = m['end_date'] as String? ?? '';
          final deadline = (startDate.isNotEmpty && endDate.isNotEmpty)
              ? '$startDate ~ $endDate'
              : '일정 미정';
          return _ItemData(
            id: m['id'] as String? ?? '',
            title: m['title'] as String? ?? '',
            subtitle: m['description'] as String? ?? '',
            reward: m['budget'] as String? ?? '협의',
            deadline: deadline,
            imageUrl: '',
            region: m['region'] as String? ?? '전국',
            ageGroup: '',
            contentType: m['category'] as String? ?? '',
          );
        }).toList();
        setState(() => _apiItems = items);
      }
    } catch (_) {}
  }

  List<_ItemData> get _filteredAll {
    final all = [..._apiItems, ..._allItems];
    return all.where((item) {
      if (_selectedRegion != null && item.region != _selectedRegion) return false;
      if (_selectedAgeGroup != null && item.ageGroup != _selectedAgeGroup) return false;
      if (_selectedContentType != null && item.contentType != _selectedContentType) return false;
      return true;
    }).toList();
  }

  bool get _hasFilter =>
      _selectedRegion != null || _selectedAgeGroup != null || _selectedContentType != null;

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
                _buildHeader(),
                const SizedBox(height: 0),
                _buildContentArea(),
                const SizedBox(height: 100),
              ],
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 16,
            child: _buildNavBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.bgWhite,
      padding: const EdgeInsets.fromLTRB(33, 52, 33, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/logo.svg',
                    width: 22,
                    height: 22,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'CULIP',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.pointColor,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.menu_rounded, size: 24, color: Colors.black),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.pointColor),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '찾고싶은 공고를 검색해보세요',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      color: Colors.grey[600],
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                const Icon(Icons.search, size: 17, color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildContentArea() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          _buildGreetingAndFilters(),
          const SizedBox(height: 38),
          if (_hasFilter) ...[
            _buildFilteredSection(),
          ] else ...[
            _buildSection(
              labelHighlight: '지금 가장 인기 많은 ',
              labelNormal: '공고',
              items: _sampleItems1,
            ),
            const SizedBox(height: 38),
            _buildSection(
              labelHighlight: '20대 연령층',
              labelNormal: ' 시청자를 가졌다면',
              items: _sampleItems2,
            ),
            const SizedBox(height: 38),
            _buildSection(
              labelHighlight: '먹방 콘텐츠',
              labelNormal: ' 크리에이터 모집',
              items: _sampleItems3,
            ),
          ],
          const SizedBox(height: 44),
        ],
      ),
    );
  }

  Widget _buildGreetingAndFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(fontFamily: 'Pretendard', fontSize: 20),
              children: [
                TextSpan(
                  text: '${_displayName ?? ''}님,\n',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.pointColor,
                  ),
                ),
                const TextSpan(
                  text: '이런 공고는 어떠세요 ?',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterIconButton(
                  onTap: () => _showAllFiltersSheet(),
                ),
                const SizedBox(width: 9),
                _FilterChip(
                  label: _selectedRegion ?? '지역 선택',
                  selected: _selectedRegion != null,
                  onTap: () => _showRegionSheet(),
                ),
                const SizedBox(width: 9),
                _FilterChip(
                  label: _selectedAgeGroup ?? '시청 층',
                  selected: _selectedAgeGroup != null,
                  onTap: () => _showAgeGroupSheet(),
                ),
                const SizedBox(width: 9),
                _FilterChip(
                  label: _selectedContentType ?? '콘텐츠 유형',
                  selected: _selectedContentType != null,
                  onTap: () => _showContentTypeSheet(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredSection() {
    final filtered = _filteredAll;
    if (filtered.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        child: Center(
          child: Text(
            '해당 조건의 공고가 없습니다.',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              color: Color(0xFF979797),
            ),
          ),
        ),
      );
    }
    return _buildSection(
      labelHighlight: '필터 결과 ',
      labelNormal: '공고',
      items: filtered,
    );
  }

  Widget _buildSection({
    required String labelHighlight,
    required String labelNormal,
    required List<_ItemData> items,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            children: [
              const _YoutubeIcon(),
              const SizedBox(width: 3),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: labelHighlight,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.pointColor,
                      ),
                    ),
                    TextSpan(
                      text: labelNormal,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF121212),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 40),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(width: 18),
            itemBuilder: (context, i) => GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/post-detail', arguments: {
                'id': items[i].id,
                'title': items[i].title,
                'subtitle': items[i].subtitle,
                'reward': items[i].reward,
                'deadline': items[i].deadline,
                'imageAsset': items[i].imageUrl,
                'region': items[i].region,
                'ageGroup': items[i].ageGroup,
                'contentType': items[i].contentType,
              }),
              child: _ItemCard(item: items[i]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavBar() {
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
      padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.home, size: 28, color: AppColors.pointColor),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/chat'),
            child: const Icon(Icons.chat_bubble_outline, size: 26, color: Colors.black),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/my-page'),
            child: const Icon(Icons.person_outline, size: 28, color: Colors.black),
          ),
        ],
      ),
    );
  }

  void _showAllFiltersSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        title: '필터 초기화',
        onReset: () {
          Navigator.pop(context);
          setState(() {
            _selectedRegion = null;
            _selectedAgeGroup = null;
            _selectedContentType = null;
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('필터를 초기화하시겠습니까?',
                style: TextStyle(fontFamily: 'Pretendard', fontSize: 16)),
          ],
        ),
      ),
    );
  }

  void _showRegionSheet() {
    const regions = ['전체', '서울/수도권', '강원', '경북', '전남', '충남', '제주'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SelectionSheet(
        title: '지역 선택',
        options: regions,
        selected: _selectedRegion,
        onSelect: (v) {
          Navigator.pop(context);
          setState(() => _selectedRegion = v == '전체' ? null : v);
        },
      ),
    );
  }

  void _showAgeGroupSheet() {
    const ageGroups = ['전체', '10대', '20대', '30대', '40대+', '만명대'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SelectionSheet(
        title: '시청 층 선택',
        options: ageGroups,
        selected: _selectedAgeGroup,
        onSelect: (v) {
          Navigator.pop(context);
          setState(() => _selectedAgeGroup = v == '전체' ? null : v);
        },
      ),
    );
  }

  void _showContentTypeSheet() {
    const contentTypes = ['전체', '숏폼', '롱폼', '먹방', 'ASMR', '문화/역사', '힐링'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SelectionSheet(
        title: '콘텐츠 유형 선택',
        options: contentTypes,
        selected: _selectedContentType,
        onSelect: (v) {
          Navigator.pop(context);
          setState(() => _selectedContentType = v == '전체' ? null : v);
        },
      ),
    );
  }
}

class _FilterIconButton extends StatelessWidget {
  final VoidCallback onTap;
  const _FilterIconButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF979797)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.tune, size: 16, color: Color(0xFF979797)),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? const Color(0x3346D389) : Colors.white,
          border: Border.all(
            color: selected ? const Color(0xFF121212) : const Color(0xFF979797),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                color: selected ? const Color(0xFF121212) : const Color(0xFF979797),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: selected ? const Color(0xFF121212) : const Color(0xFF979797),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _SelectionSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDCDCDC),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: options.map((opt) {
              final isSelected = opt == '전체'
                  ? selected == null
                  : selected == opt;
              return GestureDetector(
                onTap: () => onSelect(opt),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.pointColor : Colors.white,
                    border: Border.all(
                      color: isSelected ? AppColors.pointColor : const Color(0xFFDCDCDC),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    opt,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF121212),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onReset;

  const _FilterSheet({required this.title, required this.child, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDCDCDC),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          child,
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onReset,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                '필터 초기화',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _YoutubeIcon extends StatelessWidget {
  const _YoutubeIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFFFF0000),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Center(
        child: Icon(Icons.play_arrow, color: Colors.white, size: 18),
      ),
    );
  }
}

class _ItemData {
  final String id;
  final String title;
  final String subtitle;
  final String reward;
  final String deadline;
  final String imageUrl;
  final String region;
  final String ageGroup;
  final String contentType;

  const _ItemData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.reward,
    required this.deadline,
    required this.imageUrl,
    required this.region,
    required this.ageGroup,
    required this.contentType,
  });
}

class _ItemCard extends StatelessWidget {
  final _ItemData item;
  const _ItemCard({required this.item});

  static Color _regionBg(String r) => switch (r) {
        '경북' => const Color(0xFFEDE7F6),
        '강원' => const Color(0xFFE3F2FD),
        '전남' => const Color(0xFFE8F5E9),
        '충남' => const Color(0xFFFFF9C4),
        '제주' => const Color(0xFFFFE0B2),
        _ => const Color(0xFFF5F5F5),
      };

  static Color _regionFg(String r) => switch (r) {
        '경북' => const Color(0xFF7E57C2),
        '강원' => const Color(0xFF1976D2),
        '전남' => const Color(0xFF388E3C),
        '충남' => const Color(0xFFF9A825),
        '제주' => const Color(0xFFE65100),
        _ => const Color(0xFF757575),
      };

  static Color _typeBg(String t) => switch (t) {
        '숏폼' => const Color(0xFFE0F7FA),
        '먹방' => const Color(0xFFFFF3E0),
        'ASMR' => const Color(0xFFF3E5F5),
        '힐링' => const Color(0xFFE8F5E9),
        '문화/역사' => const Color(0xFFFFF8E1),
        _ => const Color(0xFFF5F5F5),
      };

  static Color _typeFg(String t) => switch (t) {
        '숏폼' => const Color(0xFF00838F),
        '먹방' => const Color(0xFFE65100),
        'ASMR' => const Color(0xFF7B1FA2),
        '힐링' => const Color(0xFF2E7D32),
        '문화/역사' => const Color(0xFFF57F17),
        _ => const Color(0xFF757575),
      };

  Widget _chip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 331,
      height: 140,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 19, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: 160,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 9,
                    color: Color(0xCC000000),
                    height: 1.33,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    _chip('📍 ${item.region}', _regionBg(item.region), _regionFg(item.region)),
                    const SizedBox(width: 4),
                    _chip(item.contentType, _typeBg(item.contentType), _typeFg(item.contentType)),
                    if (item.ageGroup.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      _chip(item.ageGroup, const Color(0xFFFFECB3), const Color(0xFFF57C00)),
                    ],
                  ],
                ),
                const SizedBox(height: 1),
                _TagRow(label: '리워드', value: item.reward),
                const SizedBox(height: 1),
                _TagRow(label: '기한', value: item.deadline),
              ],
            ),
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              item.imageUrl,
              width: 105,
              height: 105,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                width: 105,
                height: 105,
                color: AppColors.lightGray,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TagRow extends StatelessWidget {
  final String label;
  final String value;
  const _TagRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 35,
          height: 17,
          decoration: BoxDecoration(
            color: const Color(0xFFB1B1B1),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0x99000000),
            ),
          ),
        ),
      ],
    );
  }
}

final _allItems = [..._sampleItems1, ..._sampleItems2, ..._sampleItems3];

final _sampleItems1 = [
  const _ItemData(
    id: 'post_001',
    title: '천년의 기록, 디지털로 다시 피어나다',
    subtitle: '안동문화재단 크리에이터 모집',
    reward: '프로젝트 제작 지원금 50만원',
    deadline: '2026.05.08 ~ 2026.06.30',
    imageUrl: 'assets/images/image47.jpg',
    region: '경북',
    ageGroup: '만명대',
    contentType: '문화/역사',
  ),
  const _ItemData(
    id: 'post_002',
    title: '안동 선유낙화놀이 x 숏폼 챌린지 크리에이터 모집',
    subtitle: '낙화놀이의 특별한 순간을 트렌디한 숏폼 콘텐츠로 확산시킬 크리에이터 모집',
    reward: '프로젝트 제작 지원금 70만원',
    deadline: '2026.06.30 ~ 2026.07.21',
    imageUrl: 'assets/images/image49.jpg',
    region: '경북',
    ageGroup: '만명대',
    contentType: '숏폼',
  ),
  const _ItemData(
    id: 'post_003',
    title: '잊혀진 전통의 맛을 시각화하다',
    subtitle: '종가집 내림 음식의 \'비밀 레시피\'를 시네마틱 푸드 필름으로!',
    reward: '프로젝트 제작 지원금 20만원',
    deadline: '2026.05.03 ~ 2026.06.03',
    imageUrl: 'assets/images/image50.jpg',
    region: '경북',
    ageGroup: '만명대',
    contentType: '먹방',
  ),
];

final _sampleItems2 = [
  const _ItemData(
    id: 'post_004',
    title: '양양의 파도와 단청의 만남, \'K-서프\'',
    subtitle: '서핑의 성지 양양에서 k-서프 영상제작',
    reward: '프로젝트 제작 지원금 50만원',
    deadline: '2026.05.08 ~ 2026.06.30',
    imageUrl: 'assets/images/image48.jpg',
    region: '강원',
    ageGroup: '20대',
    contentType: '숏폼',
  ),
  const _ItemData(
    id: 'post_005',
    title: '낙산사 파도 소리와 범종의 울림',
    subtitle: '20대의 지친 마음을 달래줄 고퀄리티 힐링 콘텐츠 제작',
    reward: '템플스테이 1인실 2박 3일 숙박권',
    deadline: '2026.05.30 ~ 2026.06.30',
    imageUrl: 'assets/images/image51.jpg',
    region: '강원',
    ageGroup: '20대',
    contentType: '힐링',
  ),
  const _ItemData(
    id: 'post_006',
    title: '[미식/ASMR] 종가집 \'비밀 레시피\' 리믹스',
    subtitle: '안동 찜닭부터 종가 음식까지, 천년의 맛을 언박싱하다',
    reward: '프리미엄 안동 한우지급',
    deadline: '2026.06.10 ~ 2026.07.10',
    imageUrl: 'assets/images/image52.jpg',
    region: '경북',
    ageGroup: '20대',
    contentType: 'ASMR',
  ),
];

final _sampleItems3 = [
  const _ItemData(
    id: 'post_007',
    title: '대나무 숲의 속삭임과 함께하는 \'담양 죽순 요리\'',
    subtitle: '자연의 소리와 전통 음식이 어우러지는 고감도 미식 필름 제작',
    reward: '양 명인 제조 식재료 협찬',
    deadline: '2026.05.02 ~ 2026.08.20',
    imageUrl: 'assets/images/image53.jpg',
    region: '전남',
    ageGroup: '30대',
    contentType: '먹방',
  ),
  const _ItemData(
    id: 'post_008',
    title: '궁남지 포룡정에서 맛보는 백제 왕실의 디저트',
    subtitle: '통 병과(떡, 한과)를 현대적인 감각으로 리뷰하는 비주얼 먹방',
    reward: '한옥 스테이 2박 3일 숙박권',
    deadline: '2026.08.10 ~ 2026.09.10',
    imageUrl: 'assets/images/image55.jpg',
    region: '충남',
    ageGroup: '30대',
    contentType: '먹방',
  ),
  const _ItemData(
    id: 'post_009',
    title: '갓 잡은 바다의 보물, 제주 해녀의 소라 먹방 챌린지',
    subtitle: '해녀의 삶과 전통을 숏폼 형식으로 아카이빙하는 프로젝트',
    reward: '고급 해산물 10종세트',
    deadline: '2026.05.08 ~ 2026.05.29',
    imageUrl: 'assets/images/image57.jpg',
    region: '제주',
    ageGroup: '20대',
    contentType: '먹방',
  ),
];
