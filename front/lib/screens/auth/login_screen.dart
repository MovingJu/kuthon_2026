import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_colors.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _hidePassword = true;
  bool _loading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  StreamSubscription? _googleSub;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _googleSub = AuthService.onGoogleUserChanged.listen(_onWebGoogleUser);
    }
  }

  Future<void> _onWebGoogleUser(GoogleSignInAccount? account) async {
    if (account == null) return;
    setState(() => _loading = true);
    try {
      final result = await AuthService.handleGoogleAccount(account);
      if (!mounted) return;
      if (result.isNewUser) {
        Navigator.pushReplacementNamed(context, '/signup', arguments: result.email);
      } else {
        Navigator.pushReplacementNamed(context, '/account-confirm');
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Google 로그인에 실패했습니다')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _googleSub?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일과 비밀번호를 입력해주세요')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthService.login(email, password);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/account-confirm');
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('서버에 연결할 수 없습니다')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  _buildLogo(),
                  const SizedBox(height: 80),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _GlassInputField(
                          prefixIcon: const Icon(Icons.person_outline, size: 24, color: AppColors.gray500),
                          hintText: '이메일',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 19),
                        _GlassInputField(
                          prefixIcon: const Icon(Icons.lock_outline, size: 24, color: AppColors.gray500),
                          hintText: '비밀번호',
                          controller: _passwordController,
                          obscureText: _hidePassword,
                          suffixIcon: GestureDetector(
                            onTap: () => setState(() => _hidePassword = !_hidePassword),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(Icons.remove_red_eye_outlined, color: AppColors.gray500, size: 20),
                            ),
                          ),
                        ),
                        const SizedBox(height: 52),
                        _buildLoginButton(),
                      ],
                    ),
                  ),
                  const Spacer(),
                  _buildSocialDivider(),
                  const SizedBox(height: 34),
                  _buildSocialButtons(),
                  const SizedBox(height: 34),
                  _buildSignupRow(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/images/culip_logo.svg',
          width: 38,
          height: 35,
        ),
        const SizedBox(width: 13),
        const Text(
          'CULIP',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.4,
            color: Color(0xFF46D389),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _loading ? null : _onLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pointColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: _loading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('로그인', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildSocialDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 33),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Divider(color: AppColors.gray200),
          Container(
            color: AppColors.warmWhite,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: const Text(
              '소셜 로그인',
              style: TextStyle(fontSize: 12, color: AppColors.gray500),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onGoogleLoginMobile() async {
    setState(() => _loading = true);
    try {
      final result = await AuthService.googleLogin();
      if (!mounted) return;
      if (result.isNewUser) {
        Navigator.pushReplacementNamed(context, '/signup', arguments: result.email);
      } else {
        Navigator.pushReplacementNamed(context, '/account-confirm');
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      debugPrint('Google 로그인 에러: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildSocialButtons() {
    return kIsWeb
        ? AuthService.renderGoogleButton()
        : _SocialButton(
            backgroundColor: Colors.white,
            borderColor: AppColors.gray200,
            onTap: _loading ? null : _onGoogleLoginMobile,
            child: Image.network(
              'https://www.figma.com/api/mcp/asset/090628b9-3d62-4337-b41f-ef4613bb139b',
              width: 48,
              height: 48,
              errorBuilder: (_, __, ___) =>
                  const Text('G', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF4285F4))),
            ),
          );
  }

  Future<void> _onGoogleSignup() async {
    setState(() => _loading = true);
    try {
      final result = await AuthService.googleLogin();
      if (!mounted) return;
      if (result.isNewUser) {
        Navigator.pushNamed(context, '/signup', arguments: result.email);
      } else {
        Navigator.pushReplacementNamed(context, '/account-confirm');
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      Navigator.pushNamed(context, '/signup', arguments: '');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildSignupRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('회원이 아니신가요?', style: TextStyle(fontSize: 12, color: AppColors.gray500)),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: _loading ? null : _onGoogleSignup,
          child: const Text(
            '구글로 로그인',
            style: TextStyle(fontSize: 12, color: AppColors.gray800, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final Color backgroundColor;
  final Color borderColor;
  final Widget child;
  final VoidCallback? onTap;

  const _SocialButton({
    required this.backgroundColor,
    required this.borderColor,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 0.5),
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _GlassInputField extends StatelessWidget {
  final Widget prefixIcon;
  final String hintText;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  const _GlassInputField({
    required this.prefixIcon,
    required this.hintText,
    this.obscureText = false,
    this.suffixIcon,
    this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 0.4),
            ),
            child: Row(
              children: [
                const SizedBox(width: 20),
                SizedBox(width: 24, height: 24, child: prefixIcon),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: controller,
                    obscureText: obscureText,
                    keyboardType: keyboardType,
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: const TextStyle(
                        fontSize: 16,
                        color: AppColors.gray500,
                        letterSpacing: 0.43,
                      ),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                if (suffixIcon != null) suffixIcon!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
