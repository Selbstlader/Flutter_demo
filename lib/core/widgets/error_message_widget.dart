import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';

/// 通用错误信息显示组件
class ErrorMessageWidget extends StatelessWidget {
  const ErrorMessageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.errorMessage != null) {
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
                    authProvider.errorMessage!,
                    style: TextStyle(color: Colors.red.shade400),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red.shade400),
                  onPressed: () => authProvider.clearError(),
                  iconSize: 20,
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}