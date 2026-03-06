import 'package:flutter/material.dart';

// ignore_for_file: deprecated_member_use

/// Themed radio group. Use for single selection from a few options.
class AppRadio<T> extends StatelessWidget {
  const AppRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final widget = Radio<T>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
    );
    if (label != null) {
      return InkWell(
        onTap: onChanged != null ? () => onChanged!(value) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              widget,
              const SizedBox(width: 12),
              Expanded(child: Text(label!)),
            ],
          ),
        ),
      );
    }
    return widget;
  }
}
