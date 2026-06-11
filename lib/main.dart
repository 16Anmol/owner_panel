import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'services/api_service.dart';
import 'screens/main_shell.dart';
import 'screens/login_screen.dart';
import 'utils/onboarding.dart';
// ignore: unused_import
import 'screens/onboarding_payment_screen.dart'; // kept for re-enabling payment

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const OwnerPanelApp());
}

class OwnerPanelApp extends StatelessWidget {
  const OwnerPanelApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Owner Panel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const _Splash(),
    );
  }
}

class _Splash extends StatefulWidget {
  const _Splash();
  @override
  State<_Splash> createState() => _SplashState();
}

class _SplashState extends State<_Splash> {
  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final token = await ApiService.getToken();
    if (!mounted) return;
    // ── PAYMENT GATE PAUSED ──────────────────────────────────
    // Re-enable later by restoring the getMe()/isPaid routing that
    // sent unpaid owners to OnboardingPaymentScreen.
    if (token != null) {
      try {
        final me = await ApiService.getMe();
        if (mounted)
          routeAfterAuth(context, me['owner'] as Map<String, dynamic>?);
      } catch (_) {
        _go(const MainShell());
      }
    } else {
      _go(const LoginScreen());
    }
  }

  void _go(Widget w) =>
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => w));

  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: Color(0xFFB05A38),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_work_rounded, size: 72, color: Colors.white),
            SizedBox(height: 16),
            Text('LexNLand',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1)),
          ],
        )),
      );
}
