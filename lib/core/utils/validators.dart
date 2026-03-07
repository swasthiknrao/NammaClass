import 'package:flutter/material.dart';

/// NammaClass validators — Indian phone, email, password rules.
class AppValidators {
  AppValidators._();

  static String? required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    if (v.trim().length != 10) return 'Enter a valid 10-digit mobile number';
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v.trim())) {
      return 'Enter a valid Indian mobile number';
    }
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    if (!RegExp(r'^[\w.+-]+@[\w-]+\.\w{2,}$').hasMatch(v.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? otp(String? v) {
    if (v == null || v.length != 6) return 'Enter 6-digit OTP';
    return null;
  }

  /// Returns a [FormFieldValidator] that checks for non-empty input with optional custom message.
  /// Use this when you want to pass `required` into [combine] with a message.
  static FormFieldValidator<String> requiredField([
    String message = 'Required',
  ]) =>
      (v) => (v == null || v.trim().isEmpty) ? message : null;

  static FormFieldValidator<String> minLength(int min, [String? message]) =>
      (String? v) {
        if (v == null || v.trim().isEmpty) return message ?? 'Required';
        if (v.trim().length < min)
          return message ?? 'Minimum $min characters required';
        return null;
      };

  static FormFieldValidator<String> maxLength(int max, [String? message]) =>
      (String? v) {
        if (v != null && v.length > max)
          return message ?? 'Maximum $max characters allowed';
        return null;
      };

  static FormFieldValidator<String> combine(
    List<FormFieldValidator<String>> validators,
  ) => (String? v) {
    for (final fn in validators) {
      final result = fn(v);
      if (result != null) return result;
    }
    return null;
  };
}
