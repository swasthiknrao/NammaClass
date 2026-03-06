import 'package:flutter/material.dart';

/// Themed checkbox. Use for boolean options.
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.tristate = false,
  });

  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final String? label;
  final bool tristate;

  @override
  Widget build(BuildContext context) {
    final widget = Checkbox(
      value: value,
      onChanged: onChanged,
      tristate: tristate,
    );
    if (label != null) {
      return InkWell(
        onTap: onChanged != null ? () => onChanged!(!(value ?? false)) : null,
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
