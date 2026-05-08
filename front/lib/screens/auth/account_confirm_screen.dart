import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/auth_service.dart';

class AccountConfirmScreen extends StatefulWidget {
  const AccountConfirmScreen({super.key});

  @override
  State<AccountConfirmScreen> createState() => _AccountConfirmScreenState();
}

class _AccountConfirmScreenState extends State<AccountConfirmScreen> {
  String? _displayName;
  Map<String, String>? _channel;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final name = await AuthService.getDisplayName();
    final channel = await AuthService.fetchYouTubeChannel();
    if (!mounted) return;
    setState(() {
      _displayName = name;
      _channel = channel;
      _loading = false;
    });
  }

  Future<void> _connectYouTube() async {
    setState(() => _loading = true);
    final token = await AuthService.requestYouTubeAccess();
    if (!mounted) return;
    if (token == null) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('YouTube 권한을 허용해주세요')),
      );
      return;
    }
    final channel = await AuthService.fetchYouTubeChannel();
    if (!mounted) return;
    setState(() {
      _channel = channel;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 93),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontFamily: 'Pretendard', color: Colors.black),
                        children: [
                          const TextSpan(
                            text: '안녕하세요, ',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                          ),
                          TextSpan(
                            text: _displayName ?? '',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
                          ),
                          const TextSpan(
                            text: ' 님!',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      '아래의 계정으로 활동하시는게 맞나요?',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 108),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: _channel == null
                          ? GestureDetector(
                              onTap: _connectYouTube,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.link, color: AppColors.pointColor),
                                  SizedBox(width: 8),
                                  Text(
                                    'YouTube 채널 연결하기',
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 14,
                                      color: AppColors.pointColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Row(
                              children: [
                                _ChannelThumbnail(url: _channel!['thumbnailUrl'] ?? ''),
                                const SizedBox(width: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _channel!['channelName'] ?? '',
                                      style: const TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 24,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _channel!['handle'] ?? '',
                                      style: const TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          '구독자 ${_channel!['subscriberCount']}명',
                                          style: const TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w200,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Container(
                                          width: 2,
                                          height: 2,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          '동영상 ${_channel!['videoCount']}개',
                                          style: const TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w200,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () async {
                                await AuthService.logout();
                                if (!context.mounted) return;
                                Navigator.pushReplacementNamed(context, '/login');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.lightGray,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('다시 설정하기', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pushReplacementNamed(context, '/account-info'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.pointColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('다음', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
      ),
    );
  }
}

class _ChannelThumbnail extends StatelessWidget {
  final String url;
  const _ChannelThumbnail({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return Container(
        width: 78,
        height: 78,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.lightGray),
      );
    }
    return ClipOval(
      child: Image.network(
        url,
        width: 78,
        height: 78,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 78,
          height: 78,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.lightGray),
        ),
      ),
    );
  }
}
