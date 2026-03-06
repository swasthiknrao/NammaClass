import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// NammaClass text field — BRD Section 1.4.
class NcTextField extends StatelessWidget {
  const NcTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.autofocus = false,
    this.autofillHints,
    this.inputFormatters,
    this.focusNode,
    this.readOnly = false,
    this.onTap,
    this.initialValue,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final bool enabled;
  final bool autofocus;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      enabled: enabled,
      autofocus: autofocus,
      autofillHints: autofillHints,
      inputFormatters: inputFormatters,
      focusNode: focusNode,
      readOnly: readOnly,
      onTap: onTap,
      style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 20, color: AppColors.textSecondary)
            : null,
        suffixIcon: suffixIcon,
        counterText: '',
      ),
    );
  }
}

/// NammaClass dropdown field.
class NcDropdown<T> extends StatelessWidget {
  const NcDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.label,
    this.hint,
    this.enabled = true,
  });

  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final String? hint;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: enabled ? onChanged : null,
          isExpanded: true,
          hint: hint != null
              ? Text(
                  hint!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textDisabled,
                  ),
                )
              : null,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
