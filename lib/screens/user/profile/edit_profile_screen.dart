import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:washgo/core/constants/app_colors.dart';
import 'package:washgo/core/constants/app_text_styles.dart';
import 'package:washgo/core/layout/responsive_layout.dart';
import 'package:washgo/core/state/app_state.dart';
import 'package:washgo/core/widgets/custom_button.dart';
import 'package:washgo/core/widgets/responsive_content.dart';
import 'package:washgo/core/widgets/custom_text_field.dart';
import 'package:washgo/core/widgets/profile_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _imagePicker = ImagePicker();

  String? _pickedImagePath;
  bool _clearPhoto = false;

  static final _sectionLabelStyle = AppTextStyles.caption.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6,
    color: AppColors.cyan,
  );

  static final _sectionTitleStyle = AppTextStyles.title.copyWith(fontSize: 16);

  @override
  void initState() {
    super.initState();
    final user = context.read<AppState>().currentUser!;
    _nameController = TextEditingController(text: user.fullName);
    _emailController = TextEditingController(text: user.email);
    _pickedImagePath = user.profileImagePath;
  }

  String? get _displayImagePath {
    if (_clearPhoto) return null;
    return _pickedImagePath;
  }

  bool get _hasPhoto => _displayImagePath != null && _displayImagePath!.isNotEmpty;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final file = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (file == null || !mounted) return;
      setState(() {
        _pickedImagePath = file.path;
        _clearPhoto = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open gallery. Please try again.')),
      );
    }
  }

  void _removePhoto() {
    setState(() {
      _pickedImagePath = null;
      _clearPhoto = true;
    });
  }

  Future<void> _save() async {
    if (_passwordController.text.isNotEmpty &&
        _passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    final state = context.read<AppState>();

    final error = await state.updateCurrentUserProfile(
      fullName: _nameController.text,
      email: _emailController.text,
      newPassword: _passwordController.text.isNotEmpty ? _passwordController.text : null,
      profileImagePath: _clearPhoto ? null : _pickedImagePath,
      clearProfileImage: _clearPhoto,
    );

    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.screenBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: ResponsiveContent.auth(
                  alignTop: true,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      ResponsiveLayout.horizontalPadding(context),
                      8,
                      ResponsiveLayout.horizontalPadding(context),
                      16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildPhotoCard(),
                        const SizedBox(height: 16),
                        _buildAccountCard(),
                        const SizedBox(height: 16),
                        _buildPasswordCard(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomBar(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textLight, size: 20),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edit Profile', style: AppTextStyles.title),
                const SizedBox(height: 2),
                Text(
                  'Update your photo and account info',
                  style: AppTextStyles.subtitle.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard() {
    return _FormCard(
      child: Column(
        children: [
          Text('PROFILE PHOTO', style: _sectionLabelStyle),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickPhoto,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: AppColors.glowShadow(blur: 20),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.cardDark,
                    ),
                    child: ProfileAvatar(
                      key: ValueKey(_displayImagePath ?? 'no-photo'),
                      profileImagePath: _displayImagePath,
                      radius: 52,
                    ),
                  ),
                ),
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.cyan, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.camera_alt_outlined, size: 18, color: AppColors.cyan),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap photo to choose from gallery',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textLight.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickPhoto,
                  icon: const Icon(Icons.photo_library_outlined, size: 18),
                  label: const Text('Gallery'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.cyan,
                    side: BorderSide(color: AppColors.cyan.withValues(alpha: 0.6)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (_hasPhoto) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _removePhoto,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Remove'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.dangerRed,
                      side: BorderSide(color: AppColors.dangerRed.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard() {
    return _FormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ACCOUNT DETAILS', style: _sectionLabelStyle),
          const SizedBox(height: 6),
          Text('Personal information', style: _sectionTitleStyle),
          const SizedBox(height: 20),
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
        ],
      ),
    );
  }

  Widget _buildPasswordCard() {
    return _FormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.aquaBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.lock_outline, color: AppColors.cyan, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SECURITY', style: _sectionLabelStyle),
                    const SizedBox(height: 2),
                    Text('Change password', style: _sectionTitleStyle),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Leave both fields empty to keep your current password.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textLight.withValues(alpha: 0.65),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'New Password',
            hint: 'Enter new password',
            prefixIcon: Icons.lock_outline,
            controller: _passwordController,
            obscureText: true,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Confirm Password',
            hint: 'Re-enter new password',
            prefixIcon: Icons.lock_outline,
            controller: _confirmController,
            obscureText: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        ResponsiveLayout.horizontalPadding(context),
        12,
        ResponsiveLayout.horizontalPadding(context),
        12,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardDark.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: CustomButton(
        text: 'Save Changes',
        icon: Icons.check_circle_outline,
        onPressed: _save,
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final Widget child;

  const _FormCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: child,
    );
  }
}
