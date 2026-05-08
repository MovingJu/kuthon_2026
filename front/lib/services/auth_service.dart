import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'google_button.dart';

String get _baseUrl => '${dotenv.env['API_BASE_URL'] ?? ''}/api/v1';
String get apiBaseUrl => _baseUrl;
const _storage = FlutterSecureStorage();

final _googleSignIn = GoogleSignIn(
  clientId: dotenv.env['GOOGLE_CLIENT_ID'],
  scopes: [
    'email',
    'openid',
    'profile',
    'https://www.googleapis.com/auth/youtube.readonly',
    'https://www.googleapis.com/auth/yt-analytics.readonly',
  ],
);

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class AuthService {
  // ── 이메일 로그인 ──────────────────────────────────────────────────────────

  static Future<void> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      await _storage.write(key: 'access_token', value: data['access_token']);
    } else {
      throw AuthException(_parseDetail(res.body, '로그인에 실패했습니다'));
    }
  }

  static Future<void> register(String email, String password, String name) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'name': name}),
    );

    if (res.statusCode != 201) {
      throw AuthException(_parseDetail(res.body, '회원가입에 실패했습니다'));
    }
  }

  static String _parseDetail(String body, String fallback) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) return decoded['detail']?.toString() ?? fallback;
    } catch (_) {}
    return fallback;
  }

  // ── Google 로그인 ──────────────────────────────────────────────────────────

  /// Google 로그인 결과. isNewUser=true면 회원가입이 필요한 신규 유저.
  static Future<({bool isNewUser, String email})> handleGoogleAccount(GoogleSignInAccount account) async {
    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) throw AuthException('Google ID 토큰을 받지 못했습니다');

    await _storage.write(key: 'google_display_name', value: account.displayName ?? '');
    await _storage.write(key: 'google_photo_url', value: account.photoUrl ?? '');
    if (auth.accessToken != null) {
      await _storage.write(key: 'google_access_token', value: auth.accessToken);
    }

    final res = await http.post(
      Uri.parse('$_baseUrl/auth/google-login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_token': idToken}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      await _storage.write(key: 'access_token', value: data['access_token']);
      return (isNewUser: false, email: account.email);
    } else if (res.statusCode == 404) {
      // 유저 정보 없음 → 회원가입 필요
      return (isNewUser: true, email: account.email);
    } else {
      throw AuthException(_parseDetail(res.body, '구글 로그인에 실패했습니다'));
    }
  }

  /// Non-web: 프로그래밍 방식 로그인. 신규 유저면 isNewUser=true 반환.
  static Future<({bool isNewUser, String email})> googleLogin() async {
    final account = await _googleSignIn.signIn();
    if (account == null) throw AuthException('로그인이 취소되었습니다');
    return handleGoogleAccount(account);
  }

  /// Non-web: Google 이메일만 가져오기 (회원가입 용).
  static Future<String?> googleGetEmail() async {
    final account = await _googleSignIn.signIn();
    if (account == null) throw AuthException('로그인이 취소되었습니다');
    final auth = await account.authentication;
    if (auth.accessToken != null) {
      await _storage.write(key: 'google_access_token', value: auth.accessToken);
    }
    await _storage.write(key: 'google_display_name', value: account.displayName ?? '');
    return account.email;
  }

  /// Web 전용: GIS 버튼 위젯 반환. 클릭 시 onGoogleUserChanged로 account가 옴.
  static Widget renderGoogleButton() => buildGoogleSignInButton();

  /// account 변경 스트림 (Web에서 renderButton 클릭 후 sign-in 이벤트 수신용).
  static Stream<GoogleSignInAccount?> get onGoogleUserChanged =>
      _googleSignIn.onCurrentUserChanged;

  static Future<String?> getGoogleAccessToken() =>
      _storage.read(key: 'google_access_token');

  static Future<String?> getDisplayName() =>
      _storage.read(key: 'google_display_name');

  static Future<String?> getPhotoUrl() =>
      _storage.read(key: 'google_photo_url');

  static Future<Map<String, String>?> fetchYouTubeChannel() async {
    final token = await _storage.read(key: 'youtube_access_token');
    if (token == null) return null;

    final res = await http.get(
      Uri.parse(
          'https://www.googleapis.com/youtube/v3/channels?part=snippet,statistics&mine=true'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) return null;

    final items = (jsonDecode(res.body)['items'] as List?)??[];
    if (items.isEmpty) return null;

    final snippet = items[0]['snippet'] as Map<String, dynamic>;
    final stats = items[0]['statistics'] as Map<String, dynamic>;

    return {
      'channelName': snippet['title'] ?? '',
      'handle': snippet['customUrl'] ?? '',
      'subscriberCount': stats['subscriberCount'] ?? '0',
      'videoCount': stats['videoCount'] ?? '0',
      'thumbnailUrl': snippet['thumbnails']?['default']?['url'] ?? '',
    };
  }

  /// 저장된 토큰이 없으면 requestScopes로 명시적 인가 요청 후 반환.
  /// 반드시 유저 제스처(버튼 클릭) 컨텍스트에서 호출할 것 (팝업 차단 방지).
  static Future<String?> requestYouTubeAccess() async {
    final stored = await _storage.read(key: 'youtube_access_token');
    if (stored != null) return stored;

    final user = _googleSignIn.currentUser;
    if (user == null) return null;

    final granted = await _googleSignIn.requestScopes([
      'https://www.googleapis.com/auth/youtube.readonly',
      'https://www.googleapis.com/auth/yt-analytics.readonly',
    ]);
    if (!granted) return null;

    final auth = await user.authentication;
    if (auth.accessToken != null) {
      await _storage.write(key: 'youtube_access_token', value: auth.accessToken);
    }
    return auth.accessToken;
  }

  // ── 공통 ──────────────────────────────────────────────────────────────────

  static Future<void> logout() async {
    await _googleSignIn.signOut().catchError((_) => null);
    await _storage.deleteAll();
  }

  static Future<void> submitProfile({
    required String name,
    required String gender,
    required String contact,
    required String birthDate,
    required List<String> preferredContentTypes,
    required List<String> categoryTags,
  }) async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) throw AuthException('로그인이 필요합니다');

    final res = await http.patch(
      Uri.parse('$_baseUrl/auth/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'gender': gender,
        'contact': contact,
        'birth_date': birthDate,
        'preferred_content_types': preferredContentTypes,
        'category_tags': categoryTags,
        'role': 'creator',
      }),
    );

    if (res.statusCode != 200) {
      throw AuthException(_parseDetail(res.body, '프로필 저장에 실패했습니다'));
    }
  }

  static Future<String?> getToken() => _storage.read(key: 'access_token');

  static Future<String?> getCurrentUserId() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = base64Url.normalize(parts[1]);
      final decoded = jsonDecode(utf8.decode(base64Url.decode(payload))) as Map<String, dynamic>;
      return decoded['sub'] as String?;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> isLoggedIn() async =>
      (await _storage.read(key: 'access_token')) != null;

  // ── 회원 유형 (creator / editor) ──────────────────────────────────────────

  static Future<void> saveUserType(String type) =>
      _storage.write(key: 'user_type', value: type);

  static Future<String?> getUserType() =>
      _storage.read(key: 'user_type');

  // ── 채널 정보 캐시 ─────────────────────────────────────────────────────────

  static Future<void> cacheChannelData({
    required String channelId,
    required String channelName,
    required String handle,
    required String thumbnailUrl,
    required int subscriberCount,
    required int videoCount,
  }) async {
    await _storage.write(
      key: 'channel_cache',
      value: jsonEncode({
        'channelId': channelId,
        'channelName': channelName,
        'handle': handle,
        'thumbnailUrl': thumbnailUrl,
        'subscriberCount': subscriberCount,
        'videoCount': videoCount,
      }),
    );
  }

  static Future<Map<String, dynamic>?> getCachedChannelData() async {
    final raw = await _storage.read(key: 'channel_cache');
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
