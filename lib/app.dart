import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:washgo/core/constants/app_colors.dart';
import 'package:washgo/core/state/app_state.dart';
import 'package:washgo/screens/auth/splash_screen.dart';

class WashGoApp extends StatelessWidget {
  const WashGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'WashGo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.darkNavy,
          colorScheme: const ColorScheme.dark(
            primary: AppColors.aquaBlue,
            secondary: AppColors.limeAccent,
            tertiary: AppColors.cyan,
            surface: AppColors.cardDark,
            error: AppColors.dangerRed,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: AppColors.textLight),
            titleTextStyle: TextStyle(
              color: AppColors.textLight,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.cardDark,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.aquaBlue, width: 1.5),
            ),
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            labelStyle: const TextStyle(color: AppColors.textSecondary),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: AppColors.cardDark,
            selectedColor: AppColors.limeAccent.withValues(alpha: 0.2),
            labelStyle:
                const TextStyle(color: AppColors.textLight, fontSize: 13),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          snackBarTheme: const SnackBarThemeData(
            backgroundColor: AppColors.cardDark,
            contentTextStyle: TextStyle(color: AppColors.textLight),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
