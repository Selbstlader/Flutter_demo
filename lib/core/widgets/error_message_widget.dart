import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_notifier.dart';

/// 通用错误信息显示组件
class ErrorMessageWidget extends ConsumerWidget {
  const ErrorMessageWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorMessage = ref.watch(authErrorProvider);
    
    if (errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.red.shade900.withOpacity(0.3),
          border: Border.all(color: Colors.red.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                errorMessage,
                style: TextStyle(color: Colors.red.shade400),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.red.shade400),
              onPressed: () => ref.read(authNotifierProvider.notifier).clearError(),
              iconSize: 20,
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}