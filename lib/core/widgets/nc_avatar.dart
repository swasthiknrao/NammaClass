import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/extensions.dart';

/// CircleAvatar with photo URL or deterministic initials fallback.
class NcAvatar extends StatelessWidget {
  const NcAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.radius = 20,
    this.showBorder = false,
  });

  final String name;
  final String? imageUrl;
  final double radius;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final avatarColor = name.avatarColor;
    final initials = name.initials;

    Widget child;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      child = CachedNetworkImage(
        imageUrl: imageUrl!,
        imageBuilder: (context, provider) =>
            CircleAvatar(radius: radius, backgroundImage: provider),
        placeholder: (context, url) => _InitialsAvatar(
          initials: initials,
          color: avatarColor,
          radius: radius,
        ),
        errorWidget: (context, url, error) => _InitialsAvatar(
          initials: initials,
          color: avatarColor,
          radius: radius,
        ),
      );
    } else {
      child = _InitialsAvatar(
        initials: initials,
        color: avatarColor,
        radius: radius,
      );
    }

    if (showBorder) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.card, width: 2),
        ),
        child: child,
      );
    }
    return child;
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({
    required this.initials,
    required this.color,
    required this.radius,
  });
  final String initials;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withValues(alpha: 0.15),
      child: Text(
        initials,
        style: AppTypography.labelMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.55,
        ),
      ),
    );
  }
}
