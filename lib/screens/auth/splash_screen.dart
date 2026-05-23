import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:washgo/core/constants/app_colors.dart';
import 'package:washgo/core/constants/app_text_styles.dart';
import 'package:washgo/core/state/app_state.dart';
import 'package:washgo/core/widgets/app_scaffold.dart';
import 'package:washgo/screens/auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final state = context.read<AppState>();
    await state.initialize();

    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AppState>().isLoading;
    final screenW = MediaQuery.sizeOf(context).width;
    final orbScale = (screenW / 390).clamp(0.75, 1.2);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.screenBackgroundGradient,
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 220 * orbScale,
                height: 220 * orbScale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.limeAccent.withValues(alpha: 0.18),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -80,
              child: Container(
                width: 280 * orbScale,
                height: 280 * orbScale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.aquaBlue.withValues(alpha: 0.12),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  WashGoLogo(height: 120 * orbScale.clamp(0.9, 1.15), showGlow: true),
                  const SizedBox(height: 24),
                  Text(
                    'WashGo',
                    style: AppTextStyles.headline.copyWith(fontSize: 36),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Book. Wash. Go.',
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.mintGlow,
                      fontSize: 16,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 48),
                  if (isLoading)
                    const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.aquaBlue,
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
}
