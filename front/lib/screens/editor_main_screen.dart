import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import '../router/app_router.dart';

// Figma 에셋 (529:7332 기준, 7일 유효)
const _avatarMobimaster  = 'https://www.figma.com/api/mcp/asset/00676ace-0907-4c54-9b2c-2f2050684fdc';
const _avatarFitbli      = 'https://www.figma.com/api/mcp/asset/574cf0ed-6398-489c-ae4b-dc739fa99503';
const _avatarNyamnyam    = 'https://www.figma.com/api/mcp/asset/89660cf8-04ee-488b-98a5-fcbda696e4ee';
const _avatarLogin       = 'https://www.figma.com/api/mcp/asset/8ab7458c-d291-4adf-9938-787ea0829dc1';
const _avatarTechbot     = 'https://www.figma.com/api/mcp/asset/10acdb15-7c9e-4100-847c-251706482e14';

const _imgSweetcookie    = 'https://www.figma.com/api/mcp/asset/fee430e1-5a5e-4d1a-9f47-7353ceceed2c';
const _imgTagRight       = 'https://www.figma.com/api/mcp/asset/5cfc78e6-2a93-4d34-86b0-943467d37385';
const _avatarTagLeft     = 'https://www.figma.com/api/mcp/asset/599dbea4-48f0-48a4-8f20-e35bfb4a9f40';
const _avatarTagRight    = 'https://www.figma.com/api/mcp/asset/377cd165-fb76-4788-a93b-e5b6a17939f6';

const _ratingAvatar1     = 'https://www.figma.com/api/mcp/asset/12df3314-6a16-4378-aeba-f551b824cb8d'; // 테크봇
const _ratingAvatar2     = 'https://www.figma.com/api/mcp/asset/801ff162-1b98-4e70-90b9-0c81598fe7bf'; // 핏블리제이
const _ratingAvatar3     = 'https://www.figma.com/api/mcp/asset/c2f10752-b1ed-4193-82a3-b6e81aeb27fb'; // 무비마스터
const _ratingAvatar4     = 'https://www.figma.com/api/mcp/asset/f304663c-3f95-4a6e-95c0-f3c45683bc13'; // 로그인

// ─────────────────────────── 데이터 ───────────────────────────

class _CreatorData {
  final String name, category, description;
  final String? avatarUrl;
  const _CreatorData({
    required this.name,
    required this.category,
    required this.description,
    required this.avatarUrl,
  });
}

class _RatingData {
  final String name, category, avatarUrl;
  const _RatingData({required this.name, required this.category, required this.avatarUrl});
}

const _trendCreators = [
  _CreatorData(
    name: '무비마스터', category: '영화/드라마 리뷰',
    description: '스포 없는 깔끔한 정리\n방대한 지식으로 작품을 분석',
    avatarUrl: _avatarMobimaster,
  ),
  _CreatorData(
    name: '이동주', category: '숏폼 콘텐츠',
    description: '짧지만 강렬하게\n트렌디한 숏폼 전문 에디터',
    avatarUrl: null,
  ),
  _CreatorData(
    name: '냠냠굿', category: '먹방/맛집 탐방',
    description: '전국의 숨겨진 찐맛집만\n찾아다니는 미식가',
    avatarUrl: _avatarNyamnyam,
  ),
  _CreatorData(
    name: '로그인', category: '일상브이로그',
    description: '내 하루가 누군가의 휴식이 되길\n차분한 감성 브이로그',
    avatarUrl: _avatarLogin,
  ),
  _CreatorData(
    name: '테크봇', category: 'IT/전자기기 리뷰',
    description: '모든 신제품을 가장 먼저\n언박싱하는 얼리어답터',
    avatarUrl: _avatarTechbot,
  ),
];

const _ratingCreators = [
  _RatingData(name: '테크봇',   category: 'IT / 전자기기 리뷰', avatarUrl: _ratingAvatar1),
  _RatingData(name: '핏블리제이', category: '운동 / 홈트레이닝',  avatarUrl: _ratingAvatar2),
  _RatingData(name: '무영슬라임', category: '힐링 / DIY',        avatarUrl: _ratingAvatar1),
  _RatingData(name: '무비마스터', category: '영화 / 드라마 리뷰', avatarUrl: _ratingAvatar3),
  _RatingData(name: '로그인',    category: '일상 브이로그',       avatarUrl: _ratingAvatar4),
];

// ─────────────────────────── 화면 ───────────────────────────

class EditorMainScreen extends StatefulWidget {
  const EditorMainScreen({super.key});

  @override
  State<EditorMainScreen> createState() => _EditorMainScreenState();
}

class _EditorMainScreenState extends State<EditorMainScreen> {
  String? _displayName;

  @override
  void initState() {
    super.initState();
    AuthService.getDisplayName().then((name) {
      if (mounted) setState(() => _displayName = name);
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = _displayName ?? '문화 메이트';
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(34, 0, 34, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGreeting(name),
                      const SizedBox(height: 38),
                      _buildTrendSection(),
                      const SizedBox(height: 38),
                      _buildTagSection(),
                      const SizedBox(height: 38),
                      _buildRatingSection(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
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

  // ── 헤더: CULIP 로고 + 검색바 ──
  Widget _buildHeader() {
    return Container(
      color: AppColors.bgWhite,
      padding: const EdgeInsets.fromLTRB(34, 50, 34, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset('assets/images/logo.svg', width: 22, height: 22),
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
          const SizedBox(height: 20),
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.pointColor),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '필요한 크리에이터를 검색해보세요',
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
        ],
      ),
    );
  }

  // ── 인사말 ──
  Widget _buildGreeting(String name) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontFamily: 'Pretendard', fontSize: 20, height: 1.4),
        children: [
          TextSpan(
            text: '$name님',
            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.pointColor),
          ),
          const TextSpan(
            text: '과 \n적합한 크리에이터를 찾았어요!',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
          ),
        ],
      ),
    );
  }

  // ── 섹션 타이틀 공통 ──
  Widget _buildSectionTitle({
    required Widget icon,
    required String highlight,
    required String normal,
  }) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 3),
        RichText(
          text: TextSpan(
            style: const TextStyle(fontFamily: 'Pretendard', fontSize: 16),
            children: [
              TextSpan(
                text: highlight,
                style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.pointColor),
              ),
              TextSpan(
                text: normal,
                style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF121212)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 요즘 대세 크리에이터 ──
  Widget _buildTrendSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          icon: const Icon(Icons.local_fire_department, size: 16, color: AppColors.pointColor),
          highlight: '요즘 대세 ',
          normal: '크리에이터',
        ),
        const SizedBox(height: 13),
        SizedBox(
          height: 116,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: _trendCreators.length,
            separatorBuilder: (_, i) => const SizedBox(width: 13),
            itemBuilder: (_, i) => _TrendCard(
              creator: _trendCreators[i],
              onTap: i == 0
                  ? () => Navigator.pushNamed(context, AppRoutes.editorResumeList)
                  : i == 1
                      ? () => Navigator.pushNamed(context, AppRoutes.creatorChannel)
                      : null,
            ),
          ),
        ),
      ],
    );
  }

  // ── #귀여운 태그를 가진 크리에이터 ──
  Widget _buildTagSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          icon: const Icon(Icons.favorite, size: 13, color: AppColors.pointColor),
          highlight: '#귀여운 ',
          normal: '태그를 가진 크리에이터',
        ),
        const SizedBox(height: 13),
        SizedBox(
          height: 200,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 왼쪽: 스윗쿠키 큰 카드
              const Expanded(child: _BigTagCard()),
              const SizedBox(width: 11),
              // 오른쪽: 이미지 카드 + 아바타 초록 카드
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 오른쪽 상단 이미지 카드
                  Container(
                    width: 135,
                    height: 124,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.pointColor),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8),
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Image.network(
                      _imgTagRight,
                      fit: BoxFit.cover,
                      errorBuilder: (_, e, s) =>
                          Container(color: const Color(0xFFE0E0E0)),
                    ),
                  ),
                  const SizedBox(height: 7),
                  // 오른쪽 하단: 초록 배경 + 두 아바타
                  Container(
                    width: 135,
                    height: 69,
                    decoration: BoxDecoration(
                      color: AppColors.pointColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8),
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 14, top: 9,
                          child: _NetAvatar(url: _avatarTagLeft, size: 51),
                        ),
                        Positioned(
                          left: 65, top: 9,
                          child: _NetAvatar(url: _avatarTagRight, size: 51),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 포트폴리오 평점이 높은 크리에이터 ──
  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          icon: const Icon(Icons.star, size: 16, color: AppColors.pointColor),
          highlight: '포트폴리오 평점이 높은 ',
          normal: '크리에이터',
        ),
        const SizedBox(height: 13),
        Column(
          children: _ratingCreators.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _RatingCard(creator: c),
          )).toList(),
        ),
      ],
    );
  }

  // ── 하단 네비게이션 바 ──
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
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.home, size: 28, color: AppColors.pointColor),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/editor-post-register'),
            child: const Icon(Icons.edit_outlined, size: 26, color: Colors.black),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/editor-chat'),
            child: const Icon(Icons.chat_bubble_outline, size: 26, color: Colors.black),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/editor-my-page'),
            child: const Icon(Icons.person_outline, size: 28, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── 위젯 ───────────────────────────

// 요즘 대세 크리에이터 카드 (239 x 116)
class _TrendCard extends StatelessWidget {
  final _CreatorData creator;
  final VoidCallback? onTap;
  const _TrendCard({required this.creator, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      width: 239,
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        border: Border.all(color: AppColors.pointColor),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      child: Row(
        children: [
          _NetAvatar(url: creator.avatarUrl, size: 91),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(Icons.local_fire_department, size: 20, color: AppColors.pointColor),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        creator.name,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.pointColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  creator.category,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.pointColor,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 4),
                Text(
                  creator.description,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 9,
                    color: Color(0xB3121212),
                    height: 1.33,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ),  // Container
    );  // GestureDetector
  }
}

// 스윗쿠키 큰 카드 (200 x 200)
class _BigTagCard extends StatelessWidget {
  const _BigTagCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.pointColor),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 상단 이미지
          SizedBox(
            height: 80,
            child: Image.network(
              _imgSweetcookie,
              fit: BoxFit.cover,
              errorBuilder: (_, e, s) => Container(color: const Color(0xFFD9D9D9)),
            ),
          ),
          // 하단 크리에이터 정보
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Icon(Icons.local_fire_department, size: 20, color: AppColors.pointColor),
                    SizedBox(width: 4),
                    Text(
                      '스윗쿠키',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.pointColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  '공감/고민상담 토크쇼',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.pointColor,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 4),
                const Text(
                  '시청자대신 화내고 울어준다\n귀여움은 덤으로 가져가는 토크쇼!',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 9,
                    color: Color(0xB3121212),
                    height: 1.33,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 평점 카드 (초록 배경)
class _RatingCard extends StatelessWidget {
  final _RatingData creator;
  const _RatingCard({required this.creator});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.pointColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      child: Row(
        children: [
          _NetAvatar(url: creator.avatarUrl, size: 38),
          const SizedBox(width: 14),
          const Icon(Icons.star, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            creator.name,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Text(
            creator.category,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// 원형 네트워크 아바타
class _NetAvatar extends StatelessWidget {
  final String? url;
  final double size;
  const _NetAvatar({required this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return ClipOval(
        child: Container(
          width: size, height: size,
          color: const Color(0xFFD9D9D9),
          child: Icon(Icons.person, size: size * 0.6, color: Colors.white),
        ),
      );
    }
    return ClipOval(
      child: Image.network(
        url!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, e, s) => Container(
          width: size,
          height: size,
          color: const Color(0xFFD9D9D9),
          child: Icon(Icons.person, size: size * 0.6, color: Colors.white),
        ),
      ),
    );
  }
}
