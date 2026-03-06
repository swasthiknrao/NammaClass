import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

extension StringX on String {
  /// Initials from name: 'Ravi Kumar' → 'RK'
  String get initials {
    final parts = trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  /// Deterministic avatar color from name hash
  Color get avatarColor {
    const colors = [
      AppColors.primary,
      AppColors.teal,
      AppColors.accent,
      Color(0xFF7D3C98),
      Color(0xFF2E86C1),
      Color(0xFF117A65),
      Color(0xFF884EA0),
      Color(0xFF1A5276),
    ];
    return colors[hashCode.abs() % colors.length];
  }

  /// Subject color for timetable / diary color coding
  Color get subjectColor {
    const colors = [
      Color(0xFF1B4F72),
      Color(0xFF117A65),
      Color(0xFFE67E22),
      Color(0xFF884EA0),
      Color(0xFF922B21),
      Color(0xFF1E8449),
      Color(0xFF2E86C1),
      Color(0xFF7D6608),
    ];
    return colors[hashCode.abs() % colors.length];
  }
}

extension DateTimeX on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  bool get isPast => isBefore(DateTime.now());

  bool get isSameWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isAfter(startOfWeek) &&
        isBefore(endOfWeek.add(const Duration(days: 1)));
  }
}

extension NumX on num {
  /// 0.92 → '92%'
  String get asPercent => '${(this * 100).round()}%';
}

extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  bool get isDesktop => screenWidth >= 1024;
}
