import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_typography.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/namma_ai_chat_view.dart';

/// Full-screen Namma AI (e.g. deep link `/namma-ai`). Primary UX is the side panel from the FAB.
class NammaAiScreen extends ConsumerWidget {
  const NammaAiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Sign in to use Namma AI.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.auto_awesome,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text('Namma AI', style: AppTypography.headlineSmall),
          ],
        ),
      ),
      body: const NammaAiChatView(),
    );
  }
}
