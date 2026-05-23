import 'dart:io';

import 'package:flutter/material.dart';
import 'package:washgo/core/constants/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  final String? profileImagePath;
  final double radius;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    this.profileImagePath,
    this.radius = 36,
    this.onTap,
  });

  bool get _hasValidImage {
    if (profileImagePath == null || profileImagePath!.isEmpty) return false;
    return File(profileImagePath!).existsSync();
  }

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white.withValues(alpha: 0.2),
      backgroundImage: _hasValidImage ? FileImage(File(profileImagePath!)) : null,
      child: _hasValidImage
          ? null
          : Icon(Icons.person, size: radius, color: AppColors.textLight),
    );

    if (onTap == null) return avatar;

    return GestureDetector(
      onTap: onTap,
      child: avatar,
    );
  }
}
