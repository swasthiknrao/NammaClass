import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../canteen/screens/food_canteen_screen.dart';

/// Parent canteen — uses shared FoodCanteenScreen with parent's wallet context.
class CanteenScreen extends ConsumerWidget {
  const CanteenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const FoodCanteenScreen();
  }
}
