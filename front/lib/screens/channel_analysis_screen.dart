import 'dart:math' show max;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../router/app_router.dart';
import '../services/youtube_service.dart';

class ChannelAnalysisScreen extends StatefulWidget {
  const ChannelAnalysisScreen({super.key});

  @override
  State<ChannelAnalysisScreen> createState() => _ChannelAnalysisScreenState();
}

class _ChannelAnalysisScreenState extends State<ChannelAnalysisScreen> {
  YouTubeChannelInfo? _channel;
  YouTubeAnalytics? _analytics;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        YouTubeService.fetchMyChannel(),
        YouTubeService.fetchAnalytics(),
      ]);
      if (mounted) {
        setState(() {
          _channel = results[0] as YouTubeChannelInfo?;
          _analytics = results[1] as YouTubeAnalytics?;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.pointColor))
                    : _error != null
                        ? _buildError()
                        : _buildBody(),
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

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.smallText, size: 48),
          const SizedBox(height: 12),
          const Text('유튜브 데이터를 불러오지 못했어요', style: TextStyle(fontFamily: 'Pretendard', fontSize: 14, color: AppColors.smallText)),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () { setState(() { _loading = true; _error = null; }); _load(); },
            child: const Text('다시 시도', style: TextStyle(color: AppColors.pointColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 110),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 36),
            _buildChannelCard(),
            const SizedBox(height: 40),
            const Text(
              '채널 분석',
              style: TextStyle(fontFamily: 'Pretendard', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _StatCard(
                  label: '조회수',
                  value: _formatCount(_analytics?.totalViews ?? 0),
                )),
                const SizedBox(width: 20),
                Expanded(child: _StatCard(
                  label: '총 시청 시간',
                  value: '${(_analytics?.watchTimeHours ?? 0).toStringAsFixed(1)}시간',
                )),
              ],
            ),
            const SizedBox(height: 20),
            _GraphCard(dailyViews: _analytics?.last30DaysViews ?? List.filled(30, 0)),
            const SizedBox(height: 40),
            const Text(
              '주 시청자층',
              style: TextStyle(fontFamily: 'Pretendard', fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
            ),
            const SizedBox(height: 20),
            _AgeCard(ageDemographics: _analytics?.ageDemographics ?? []),
            const SizedBox(height: 20),
            _GenderCard(
              femalePercent: _analytics?.femalePercent ?? 0,
              malePercent: _analytics?.malePercent ?? 0,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelCard() {
    final ch = _channel;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: ch?.thumbnailUrl.isNotEmpty == true
                ? Image.network(ch!.thumbnailUrl, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox())
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ch?.channelName ?? '채널명',
                  style: const TextStyle(fontFamily: 'Pretendard', fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                ),
                const SizedBox(height: 1),
                Text(
                  ch?.handle.isNotEmpty == true ? ch!.handle : '',
                  style: const TextStyle(fontFamily: 'Pretendard', fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '구독자 ${_formatCount(ch?.subscriberCount ?? 0)}명',
                      style: const TextStyle(fontFamily: 'Pretendard', fontSize: 12, fontWeight: FontWeight.w200, color: Colors.black),
                    ),
                    const SizedBox(width: 5),
                    Container(width: 2, height: 2, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    Text(
                      '동영상 ${ch?.videoCount ?? 0}개',
                      style: const TextStyle(fontFamily: 'Pretendard', fontSize: 12, fontWeight: FontWeight.w200, color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 4))],
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
              const Text(
                '채널 상세 내용',
                style: TextStyle(fontFamily: 'Pretendard', fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
              ),
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

  static String _formatCount(int n) {
    if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)}만';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}천';
    return n.toString();
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 63),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Pretendard', fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.smallText)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF121212))),
        ],
      ),
    );
  }
}

class _GraphCard extends StatelessWidget {
  final List<int> dailyViews;
  const _GraphCard({required this.dailyViews});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 164,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '한달 간 조회수 그래프',
            style: TextStyle(fontFamily: 'Pretendard', fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF121212)),
          ),
          const SizedBox(height: 12),
          Expanded(child: _BarChart(values: dailyViews)),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<int> values;
  const _BarChart({required this.values});

  @override
  Widget build(BuildContext context) {
    final maxVal = values.fold(0, max);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: values.map((v) {
        final ratio = maxVal > 0 ? v / maxVal : 0.0;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: FractionallySizedBox(
              heightFactor: ratio == 0 ? 0.02 : ratio,
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: ratio == 0
                      ? const Color(0xFFD9D9D9)
                      : AppColors.pointColor.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _AgeCard extends StatelessWidget {
  final List<AgeDemographic> ageDemographics;
  const _AgeCard({required this.ageDemographics});

  @override
  Widget build(BuildContext context) {
    final items = ageDemographics.isNotEmpty
        ? ageDemographics
        : [
            AgeDemographic(ageGroup: '18~24세', percent: 0.653),
            AgeDemographic(ageGroup: '25~34세', percent: 0.133),
            AgeDemographic(ageGroup: '13~17세', percent: 0.065),
            AgeDemographic(ageGroup: '35~44세', percent: 0.036),
            AgeDemographic(ageGroup: '45~54세', percent: 0.023),
            AgeDemographic(ageGroup: '55~64세', percent: 0.016),
            AgeDemographic(ageGroup: '65+', percent: 0.013),
          ];

    final maxRatio = items.fold(0.0, (m, a) => a.percent > m ? a.percent : m);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('연령', style: TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.smallText)),
          const SizedBox(height: 13),
          ...items.map((a) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _AgeRow(label: a.ageGroup, ratio: a.percent, maxRatio: maxRatio),
          )),
        ],
      ),
    );
  }
}

class _AgeRow extends StatelessWidget {
  final String label;
  final double ratio;
  final double maxRatio;
  const _AgeRow({required this.label, required this.ratio, required this.maxRatio});

  @override
  Widget build(BuildContext context) {
    final barFactor = maxRatio > 0 ? (ratio / maxRatio).clamp(0.0, 1.0) : 0.0;
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(label, style: const TextStyle(fontFamily: 'Pretendard', fontSize: 10, fontWeight: FontWeight.w300, color: AppColors.smallText)),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(height: 4, decoration: BoxDecoration(color: const Color(0xFFD9D9D9), borderRadius: BorderRadius.circular(3))),
              FractionallySizedBox(
                widthFactor: barFactor,
                child: Container(height: 4, decoration: BoxDecoration(color: AppColors.pointColor, borderRadius: BorderRadius.circular(3))),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text(
            '${(ratio * 100).toStringAsFixed(1)}%',
            textAlign: TextAlign.right,
            style: const TextStyle(fontFamily: 'Pretendard', fontSize: 10, fontWeight: FontWeight.w300, color: AppColors.smallText),
          ),
        ),
      ],
    );
  }
}

class _GenderCard extends StatelessWidget {
  final double femalePercent;
  final double malePercent;
  const _GenderCard({required this.femalePercent, required this.malePercent});

  @override
  Widget build(BuildContext context) {
    final f = femalePercent > 0 ? femalePercent : 68.3;
    final m = malePercent > 0 ? malePercent : 22.9;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 9, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('성별', style: TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.smallText)),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('여성\n${f.toStringAsFixed(1)}%', textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Pretendard', fontSize: 12, fontWeight: FontWeight.w300, color: Colors.black)),
              const SizedBox(width: 14),
              CustomPaint(
                size: const Size(105, 105),
                painter: _DonutPainter(femaleRatio: f / (f + m)),
              ),
              const SizedBox(width: 14),
              Text('남성\n${m.toStringAsFixed(1)}%', textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Pretendard', fontSize: 12, fontWeight: FontWeight.w300, color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double femaleRatio;
  const _DonutPainter({required this.femaleRatio});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const stroke = 18.0;
    const start = -1.5708; // -π/2

    final bgPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(center, radius, bgPaint);

    final femalePaint = Paint()
      ..color = const Color(0xFFFF8A80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      2 * 3.14159 * femaleRatio,
      false,
      femalePaint,
    );

    final malePaint = Paint()
      ..color = const Color(0xFF64B5F6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start + 2 * 3.14159 * femaleRatio,
      2 * 3.14159 * (1 - femaleRatio),
      false,
      malePaint,
    );
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.femaleRatio != femaleRatio;
}
