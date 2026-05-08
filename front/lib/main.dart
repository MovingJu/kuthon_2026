import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'router/app_router.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await dotenv.load();
  runApp(const KhuthonApp());
}

class KhuthonApp extends StatelessWidget {
  const KhuthonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Khuthon',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko'), Locale('en')],
      locale: const Locale('ko'),
      home: const AuthGate(),
      routes: appRoutes,
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (!mounted) return;

    if (!loggedIn) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final userType = await AuthService.getUserType();
    if (!mounted) return;

    final defaultHome = userType == 'editor' ? '/editor-main' : '/main';

    final path = Uri.base.path;
    const knownRoutes = {
      '/login', '/signup', '/account-confirm', '/account-info',
      '/main', '/editor-main', '/ai', '/chat', '/post-detail', '/my-page',
    };
    final target = (path.isEmpty || path == '/' || !knownRoutes.contains(path))
        ? defaultHome
        : path;
    Navigator.pushReplacementNamed(context, target);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
