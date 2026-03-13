import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Launches the phone dialer with the given [phone] number.
/// Supports Indian format (10 digits, optionally prefixed with +91).
/// Shows a SnackBar if the number is invalid or launch fails.
Future<void> launchTel(
  BuildContext context, {
  required String phone,
  String? fallbackSnackBar,
}) async {
  final sanitized = phone.replaceAll(RegExp(r'[^\d+]'), '');
  if (sanitized.length < 10) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(fallbackSnackBar ?? 'Invalid phone number'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    return;
  }
  final uri = Uri.parse(
    sanitized.startsWith('+') ? 'tel:$sanitized' : 'tel:+91$sanitized',
  );
  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw StateError('Cannot launch tel');
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(fallbackSnackBar ?? 'Cannot make call'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
