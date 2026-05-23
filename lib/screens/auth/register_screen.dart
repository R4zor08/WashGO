import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:washgo/core/constants/app_colors.dart';
import 'package:washgo/core/constants/app_text_styles.dart';
import 'package:washgo/core/state/app_state.dart';
import 'package:washgo/core/widgets/app_scaffold.dart';
import 'package:washgo/core/widgets/custom_button.dart';
import 'package:washgo/core/widgets/responsive_content.dart';
import 'package:washgo/core/widgets/custom_text_field.dart';
import 'package:washgo/screens/auth/login_screen.dart';
import 'package:washgo/screens/user/user_main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    final state = context.read<AppState>();
    final success = await state.registerUser(
      fullName: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage ?? 'Registration failed.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account created successfully!')),
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const UserMainScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      padding: EdgeInsets.zero,
      body: ResponsiveContent.auth(
        alignTop: true,
        child: SingleChildScrollView(
          child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textLight),
              ),
            ),
            const WashGoLogo(height: 80),
            const SizedBox(height: 16),
            Text('Create Account', style: AppTextStyles.headline.copyWith(fontSize: 26)),
            const SizedBox(height: 8),
            Text(
              'Join WashGo and book your next car wash',
              style: AppTextStyles.subtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                children: [
                  CustomTextField(
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    prefixIcon: Icons.person_outline,
                    controller: _nameController,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Email',
                    hint: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Password',
                    hint: 'Create a password',
                    prefixIcon: Icons.lock_outline,
                    controller: _passwordController,
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Confirm Password',
                    hint: 'Confirm your password',
                    prefixIcon: Icons.lock_outline,
                    controller: _confirmController,
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(text: 'Register', onPressed: _register),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already have an account? ', style: AppTextStyles.subtitle),
                GestureDetector(
                  onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  child: Text(
                    'Login',
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.cyan,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
        ),
      ),
    );
  }
}
