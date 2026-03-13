import 'package:flutter/material.dart';

/// Fallback widget when a widget fails to build.
/// Prevents the default red error screen.
class ErrorFallback extends StatelessWidget {
  const ErrorFallback({super.key, this.message, this.details});

  final String? message;
  final FlutterErrorDetails? details;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(
        context,
      ).colorScheme.errorContainer.withValues(alpha: 0.3),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                message ?? 'Something went wrong',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (details != null &&
                  details!.exceptionAsString().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  details!.exceptionAsString(),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
