import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../router/app_router.dart';
import '../services/youtube_service.dart';

const _channelAvatarUrl = 'https://yt3.ggpht.com/ytc/AIdro_nZf0Zq1IIsQhlDgpOp5Rg7xi3gqyfpqCp_QpdGBipYhoI=s240-c-k-c0x00ffffff-no-rj';

const _imgAsmr = 'https://www.figma.com/api/mcp/asset/1a045723-194f-4aed-a227-5e370e8c793f';
const _imgVlog = 'https://www.figma.com/api/mcp/asset/1fdac9df-b826-4cc7-9bdf-4771dc3d6a63';
const _imgDiy = 'https://www.figma.com/api/mcp/asset/b59b306e-78fd-4fb1-8810-80188898e5ef';
const _imgFestival = 'https://www.figma.com/api/mcp/asset/76ae7bf9-7bbe-4bbf-b750-878670ab14dd';
const _imgPalace = 'https://www.figma.com/api/mcp/asset/7876d522-9452-4bcb-b983-febd4453b22a';

const _mockVideos = [
  YouTubeVideo(
    videoId: 'mock1',
    title: '종가집 장독대와 빗소리 ASMR',
    description: '',
    thumbnailUrl: _imgAsmr,
    durationSeconds: 55,
    isShorts: true,
    viewCount: 12400,
    likeCount: 830,
    tags: ['ASMR'],
  ),
  YouTubeVideo(
    videoId: 'mock2',
    title: "한복 입고 걷는 담양, 'K-감성 투어'",
    description: '',
    thumbnailUrl: _imgVlog,
    durationSeconds: 58,
    isShorts: true,
    viewCount: 8700,
    likeCount: 610,
    tags: ['VLOG'],
  ),
  YouTubeVideo(
    videoId: 'mock3',
    title: "15초의 마법, 'K-굿즈 탄생 챌린지'",
    description: '',
    thumbnailUrl: _imgDiy,
    durationSeconds: 53,
    isShorts: true,
    viewCount: 5300,
    likeCount: 420,
    tags: ['DIY'],
  ),
  YouTubeVideo(
    videoId: 'mock4',
    title: "젊어진 축제, 활기로 가득한 '선유줄불놀이'",
    description: '밤하늘의 불꽃 비 아래에서 즐거워하는 가족, 연인들의 모습과 축제의 하이라이트를 속도감 있게 편집한 영상',
    thumbnailUrl: _imgFestival,
    durationSeconds: 437,
    isShorts: false,
    viewCount: 34200,
    likeCount: 1820,
    tags: ['현장 스케치'],
  ),
  YouTubeVideo(
    videoId: 'mock5',
    title: '임금님의 정원, 비원(秘苑)의 밤을 걷다',
    description: '일반 관람객이 퇴장한 야간의 창덕궁을 배경으로, 건축물의 아름다움과 그 속에 담긴 역사를 나레이션과 함께 깊이 있게 담아낸 고화질 시네마틱 다큐멘터리',
    thumbnailUrl: _imgPalace,
    durationSeconds: 612,
    isShorts: false,
    viewCount: 21800,
    likeCount: 1140,
    tags: ['다큐멘터리'],
  ),
];

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shorts = [_mockVideos[0], _mockVideos[1], _mockVideos[2]];
    final longs = [_mockVideos[3], _mockVideos[4]];

    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _ChannelProfile(),
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 31),
                        child: _ChannelStats(),
                      ),
                      const SizedBox(height: 28),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 31),
                        child: _PortfolioTitle(total: _mockVideos.length),
                      ),
                      const SizedBox(height: 28),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 31),
                        child: Text('숏폼형', style: TextStyle(fontFamily: 'Pretendard', fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black)),
                      ),
                      const SizedBox(height: 13),
                      _buildGrid(shorts),
                      const SizedBox(height: 27),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 31),
                        child: Text('롱폼형', style: TextStyle(fontFamily: 'Pretendard', fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black)),
                      ),
                      const SizedBox(height: 13),
                      ...longs.map((v) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _LongCard(video: v),
                      )),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
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

  Widget _buildGrid(List<YouTubeVideo> videos) {
    final rows = <Widget>[];
    for (var i = 0; i < videos.length; i += 2) {
      rows.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
          child: Row(
            children: [
              Expanded(child: _ShortCard(video: videos[i])),
              const SizedBox(width: 16),
              Expanded(
                child: i + 1 < videos.length
                    ? _ShortCard(video: videos[i + 1])
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 25),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.black),
              ),
              const SizedBox(width: 10),
              const Text('채널 상세 내용', style: TextStyle(fontFamily: 'Pretendard', fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black)),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (_) => false),
            child: const Icon(Icons.home_outlined, size: 28, color: Colors.black),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.chat, (_) => false),
            child: const Icon(Icons.chat_bubble_outline, size: 26, color: Colors.black),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.myPage, (_) => false),
            child: const Icon(Icons.person, size: 28, color: AppColors.pointColor),
          ),
        ],
      ),
    );
  }
}

class _ChannelProfile extends StatelessWidget {
  const _ChannelProfile();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 31),
      child: Row(
        children: [
          ClipOval(
            child: Image.network(
              _channelAvatarUrl,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                width: 72,
                height: 72,
                color: const Color(0xFFD9D9D9),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '이동주',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '숏폼',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 13,
                  color: Color(0xFF979797),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PortfolioTitle extends StatelessWidget {
  final int total;
  const _PortfolioTitle({required this.total});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontFamily: 'Pretendard', fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black, height: 1.3),
        children: [
          const TextSpan(text: '내 포트폴리오에는\n'),
          TextSpan(
            text: '$total개',
            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.pointColor),
          ),
          const TextSpan(text: '가 쌓였어요!'),
        ],
      ),
    );
  }
}

class _ChannelStats extends StatelessWidget {
  const _ChannelStats();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _StatItem(label: '구독자', value: '1.2만'),
          _Divider(),
          _StatItem(label: '총 조회수', value: '234만'),
          _Divider(),
          _StatItem(label: '업로드', value: '5개'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontFamily: 'Pretendard', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.pointColor)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontFamily: 'Pretendard', fontSize: 11, color: Color(0xFF979797))),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: const Color(0xFFE0E0E0));
  }
}

class _ShortCard extends StatelessWidget {
  final YouTubeVideo video;
  const _ShortCard({required this.video});

  @override
  Widget build(BuildContext context) {
    final tag = video.tags.isNotEmpty ? video.tags.first : 'Shorts';

    return Container(
      height: 231,
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.16), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  video.thumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(color: AppColors.lightGray),
                ),
                Positioned(
                  top: 7, left: 10,
                  child: _TagChip(label: tag),
                ),
                const Center(child: Icon(Icons.play_circle_fill, size: 33, color: Colors.white)),
              ],
            ),
          ),
          Container(
            height: 72,
            color: AppColors.pointColor,
            padding: const EdgeInsets.fromLTRB(13, 8, 13, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.play_arrow, size: 14, color: Colors.white),
                    SizedBox(width: 2),
                    Text('S', style: TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 2),
                Expanded(
                  child: Text(
                    video.title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: const TextStyle(fontFamily: 'Pretendard', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white, height: 1.2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LongCard extends StatelessWidget {
  final YouTubeVideo video;
  const _LongCard({required this.video});

  @override
  Widget build(BuildContext context) {
    final tag = video.tags.isNotEmpty ? video.tags.first : '롱폼';
    final mins = video.durationSeconds ~/ 60;
    final secs = video.durationSeconds % 60;
    final durationStr = '$mins:${secs.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        height: 259,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.16), blurRadius: 4, offset: const Offset(0, 4))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    video.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(color: AppColors.lightGray),
                  ),
                  Positioned(top: 14, left: 10, child: _TagChip(label: tag)),
                  Positioned(
                    bottom: 8, right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(4)),
                      child: Text(durationStr, style: const TextStyle(fontFamily: 'Pretendard', fontSize: 10, color: Colors.white)),
                    ),
                  ),
                  const Center(child: Icon(Icons.play_circle_fill, size: 33, color: Colors.white)),
                ],
              ),
            ),
            Container(
              height: 75,
              color: AppColors.pointColor,
              padding: const EdgeInsets.fromLTRB(13, 10, 13, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        Icon(Icons.play_arrow, size: 14, color: Colors.white),
                        SizedBox(width: 2),
                        Text('L', style: TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontFamily: 'Pretendard', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Text(
                            video.description.isNotEmpty
                                ? video.description
                                : '조회수 ${_fmt(video.viewCount)}회  좋아요 ${_fmt(video.likeCount)}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontFamily: 'Pretendard', fontSize: 9, fontWeight: FontWeight.w400, color: Colors.white, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmt(int n) {
    if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)}만';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}천';
    return n.toString();
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.pointColor),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.20), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Text(
        label,
        style: const TextStyle(fontFamily: 'Pretendard', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.pointColor),
      ),
    );
  }
}
