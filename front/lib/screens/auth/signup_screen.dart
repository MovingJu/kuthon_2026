import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final email = ModalRoute.of(context)?.settings.arguments as String?;
    if (email != null && email.isNotEmpty) {
      _emailController.text = email;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    final prefill = ModalRoute.of(context)?.settings.arguments as String?;
    final email = (prefill != null && prefill.isNotEmpty) ? prefill : _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일을 입력해주세요')),
      );
      return;
    }
    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호는 8자 이상이어야 합니다')),
      );
      return;
    }
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 일치하지 않습니다')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthService.register(email, password, '');
      await AuthService.login(email, password);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/member-type');
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefillEmail = ModalRoute.of(context)?.settings.arguments as String?;
    final hasEmail = prefillEmail != null && prefillEmail.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(42, 0, 42, 200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 191),
                  const Text(
                    '이메일',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _GlassField(
                    child: hasEmail
                        ? Text(
                            prefillEmail,
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 12,
                              color: AppColors.gray500,
                              letterSpacing: -0.43,
                            ),
                          )
                        : TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: 'abcd1234@gmail.com',
                              hintStyle: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 12,
                                color: AppColors.gray500,
                                letterSpacing: -0.43,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: const TextStyle(fontSize: 12),
                          ),
                  ),
                  const SizedBox(height: 82),
                  const Text(
                    '비밀번호',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _GlassField(
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: '비밀번호(8자 이상, 문자/숫자/기호 사용가능)',
                        hintStyle: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          color: Color(0xFF74777D),
                          letterSpacing: -0.43,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    '비밀번호 확인',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _GlassField(
                    child: TextField(
                      controller: _confirmController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: '비밀번호 재입력',
                        hintStyle: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          color: Color(0xFF74777D),
                          letterSpacing: -0.43,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(fontSize: 12),
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
                  onPressed: _loading ? null : _onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pointColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('다음', style: TextStyle(fontFamily: 'Pretendard', fontSize: 14)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassField extends StatelessWidget {
  final Widget child;
  const _GlassField({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x1FFFFFFF), Color(0x33FFFFFF)],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white, width: 0.4),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8)],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
          child: child,
        ),
      ),
    );
  }
}
