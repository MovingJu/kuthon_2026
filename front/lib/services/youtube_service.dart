import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class YouTubeChannelInfo {
  final String channelId;
  final String channelName;
  final String handle;
  final String thumbnailUrl;
  final int subscriberCount;
  final int videoCount;

  const YouTubeChannelInfo({
    required this.channelId,
    required this.channelName,
    required this.handle,
    required this.thumbnailUrl,
    required this.subscriberCount,
    required this.videoCount,
  });
}

class YouTubeAnalytics {
  final int totalViews;
  final double watchTimeHours;
  final List<int> last30DaysViews; // 30 values (newest last)
  final List<AgeDemographic> ageDemographics;
  final double femalePercent;
  final double malePercent;

  const YouTubeAnalytics({
    required this.totalViews,
    required this.watchTimeHours,
    required this.last30DaysViews,
    required this.ageDemographics,
    required this.femalePercent,
    required this.malePercent,
  });
}

class AgeDemographic {
  final String ageGroup;
  final double percent;
  const AgeDemographic({required this.ageGroup, required this.percent});
}

class YouTubeVideo {
  final String videoId;
  final String title;
  final String description;
  final String thumbnailUrl;
  final int durationSeconds;
  final bool isShorts;
  final int viewCount;
  final int likeCount;
  final List<String> tags;

  const YouTubeVideo({
    required this.videoId,
    required this.title,
    this.description = '',
    required this.thumbnailUrl,
    required this.durationSeconds,
    required this.isShorts,
    required this.viewCount,
    required this.likeCount,
    required this.tags,
  });

  String get youtubeUrl => isShorts
      ? 'https://www.youtube.com/shorts/$videoId'
      : 'https://www.youtube.com/watch?v=$videoId';
}

class YouTubeService {
  static const _ytDataBase = 'https://www.googleapis.com/youtube/v3';
  static const _ytAnalyticsBase = 'https://youtubeanalytics.googleapis.com/v2';

  static Future<String?> _getToken() => AuthService.getGoogleAccessToken();

  static Map<String, String> _authHeader(String token) => {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
  };

  // 내 유튜브 채널 기본 정보
  static Future<YouTubeChannelInfo?> fetchMyChannel() async {
    final token = await _getToken();
    if (token == null) return null;

    final res = await http.get(
      Uri.parse('$_ytDataBase/channels?part=snippet,statistics&mine=true'),
      headers: _authHeader(token),
    );
    if (res.statusCode != 200) return null;

    final body = jsonDecode(res.body);
    final items = (body['items'] as List?) ?? [];
    if (items.isEmpty) return null;

    final item = items[0] as Map<String, dynamic>;
    final snippet = item['snippet'] as Map<String, dynamic>;
    final stats = item['statistics'] as Map<String, dynamic>;

    return YouTubeChannelInfo(
      channelId: item['id'] as String? ?? '',
      channelName: snippet['title'] as String? ?? '',
      handle: snippet['customUrl'] as String? ?? '',
      thumbnailUrl: (snippet['thumbnails']?['default']?['url']) as String? ?? '',
      subscriberCount: int.tryParse(stats['subscriberCount']?.toString() ?? '0') ?? 0,
      videoCount: int.tryParse(stats['videoCount']?.toString() ?? '0') ?? 0,
    );
  }

  // 채널 분석 데이터 (Analytics API)
  static Future<YouTubeAnalytics?> fetchAnalytics() async {
    final token = await _getToken();
    if (token == null) return null;

    final now = DateTime.now();
    final end = _fmt(now);
    final start30 = _fmt(now.subtract(const Duration(days: 29)));
    final start = _fmt(now.subtract(const Duration(days: 364)));

    // 총 조회수 + 시청 시간
    final totalsRes = await http.get(
      Uri.parse(
        '$_ytAnalyticsBase/reports?ids=channel==MINE'
        '&metrics=views,estimatedWatchTimeMinutes'
        '&startDate=$start&endDate=$end',
      ),
      headers: _authHeader(token),
    );

    // 최근 30일 일별 조회수
    final dailyRes = await http.get(
      Uri.parse(
        '$_ytAnalyticsBase/reports?ids=channel==MINE'
        '&metrics=views&dimensions=day'
        '&startDate=$start30&endDate=$end'
        '&sort=day',
      ),
      headers: _authHeader(token),
    );

    // 연령·성별 분포
    final demoRes = await http.get(
      Uri.parse(
        '$_ytAnalyticsBase/reports?ids=channel==MINE'
        '&metrics=viewerPercentage&dimensions=gender,ageGroup'
        '&startDate=$start&endDate=$end',
      ),
      headers: _authHeader(token),
    );

    int totalViews = 0;
    double watchTimeHours = 0;
    if (totalsRes.statusCode == 200) {
      final rows = (jsonDecode(totalsRes.body)['rows'] as List?) ?? [];
      if (rows.isNotEmpty) {
        totalViews = (rows[0][0] as num?)?.toInt() ?? 0;
        watchTimeHours = ((rows[0][1] as num?)?.toDouble() ?? 0) / 60;
      }
    }

    final List<int> dailyViews = [];
    if (dailyRes.statusCode == 200) {
      final rows = (jsonDecode(dailyRes.body)['rows'] as List?) ?? [];
      for (final r in rows) {
        dailyViews.add((r[1] as num?)?.toInt() ?? 0);
      }
    }
    // 30개로 맞추기
    while (dailyViews.length < 30) dailyViews.insert(0, 0);
    final trimmed = dailyViews.length > 30 ? dailyViews.sublist(dailyViews.length - 30) : dailyViews;

    final Map<String, double> femaleMap = {};
    final Map<String, double> maleMap = {};
    if (demoRes.statusCode == 200) {
      final rows = (jsonDecode(demoRes.body)['rows'] as List?) ?? [];
      for (final r in rows) {
        final gender = r[0] as String? ?? '';
        final age = r[1] as String? ?? '';
        final pct = (r[2] as num?)?.toDouble() ?? 0;
        if (gender == 'female') femaleMap[age] = (femaleMap[age] ?? 0) + pct;
        if (gender == 'male') maleMap[age] = (maleMap[age] ?? 0) + pct;
      }
    }

    // 연령별 합산 (female+male)
    final allAges = {...femaleMap.keys, ...maleMap.keys}.toList()..sort();
    final ageLabels = {
      'age13-17': '13~17세',
      'age18-24': '18~24세',
      'age25-34': '25~34세',
      'age35-44': '35~44세',
      'age45-54': '45~54세',
      'age55-64': '55~64세',
      'age65-': '65+',
    };
    final ageDemos = allAges.map((k) {
      final total = (femaleMap[k] ?? 0) + (maleMap[k] ?? 0);
      return AgeDemographic(ageGroup: ageLabels[k] ?? k, percent: total / 100);
    }).toList();
    ageDemos.sort((a, b) => b.percent.compareTo(a.percent));

    final femaleTotal = femaleMap.values.fold(0.0, (s, v) => s + v);
    final maleTotal = maleMap.values.fold(0.0, (s, v) => s + v);

    return YouTubeAnalytics(
      totalViews: totalViews,
      watchTimeHours: watchTimeHours,
      last30DaysViews: trimmed,
      ageDemographics: ageDemos,
      femalePercent: femaleTotal,
      malePercent: maleTotal,
    );
  }

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // 내 채널의 최근 영상 목록 (숏폼/롱폼 구분)
  static Future<List<YouTubeVideo>> fetchMyVideos({int maxResults = 20}) async {
    final token = await _getToken();
    if (token == null) return [];

    // 1. 채널 ID 조회
    final chRes = await http.get(
      Uri.parse('$_ytDataBase/channels?part=contentDetails&mine=true'),
      headers: _authHeader(token),
    );
    if (chRes.statusCode != 200) return [];

    final chBody = jsonDecode(chRes.body);
    final uploadPlaylistId = (chBody['items'] as List?)
            ?.firstOrNull?['contentDetails']?['relatedPlaylists']?['uploads'] as String? ?? '';
    if (uploadPlaylistId.isEmpty) return [];

    // 2. 업로드 플레이리스트에서 영상 ID 목록
    final plRes = await http.get(
      Uri.parse('$_ytDataBase/playlistItems?part=snippet&playlistId=$uploadPlaylistId&maxResults=$maxResults'),
      headers: _authHeader(token),
    );
    if (plRes.statusCode != 200) return [];

    final plItems = (jsonDecode(plRes.body)['items'] as List?) ?? [];
    if (plItems.isEmpty) return [];

    final videoIds = plItems
        .map((i) => i['snippet']?['resourceId']?['videoId'] as String? ?? '')
        .where((id) => id.isNotEmpty)
        .join(',');

    // 3. 영상 상세 (duration, statistics, snippet)
    final vRes = await http.get(
      Uri.parse('$_ytDataBase/videos?part=snippet,contentDetails,statistics&id=$videoIds'),
      headers: _authHeader(token),
    );
    if (vRes.statusCode != 200) return [];

    final videos = (jsonDecode(vRes.body)['items'] as List?) ?? [];
    return videos.map((v) {
      final snippet = v['snippet'] as Map<String, dynamic>;
      final details = v['contentDetails'] as Map<String, dynamic>;
      final stats = v['statistics'] as Map<String, dynamic>;
      final durationSec = _parseDuration(details['duration'] as String? ?? 'PT0S');
      return YouTubeVideo(
        videoId: v['id'] as String? ?? '',
        title: snippet['title'] as String? ?? '',
        thumbnailUrl: (snippet['thumbnails']?['medium']?['url'] ??
            snippet['thumbnails']?['default']?['url']) as String? ?? '',
        durationSeconds: durationSec,
        isShorts: durationSec <= 60,
        viewCount: int.tryParse(stats['viewCount']?.toString() ?? '0') ?? 0,
        likeCount: int.tryParse(stats['likeCount']?.toString() ?? '0') ?? 0,
        tags: (snippet['tags'] as List?)?.map((t) => t.toString()).take(1).toList() ?? [],
      );
    }).toList();
  }

  // ISO 8601 duration → seconds (e.g. PT1M30S → 90)
  static int _parseDuration(String iso) {
    final re = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final m = re.firstMatch(iso);
    if (m == null) return 0;
    final h = int.tryParse(m.group(1) ?? '0') ?? 0;
    final min = int.tryParse(m.group(2) ?? '0') ?? 0;
    final s = int.tryParse(m.group(3) ?? '0') ?? 0;
    return h * 3600 + min * 60 + s;
  }
}
