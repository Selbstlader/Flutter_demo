import 'package:flutter/material.dart';

/// 通用文本输入框组件
class CommonTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final bool isConfirmPassword;
  final String? helperText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool passwordVisible;
  final bool confirmPasswordVisible;
  final VoidCallback? onPasswordVisibilityToggle;
  final VoidCallback? onConfirmPasswordVisibilityToggle;

  const CommonTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.isConfirmPassword = false,
    this.helperText,
    this.validator,
    this.keyboardType,
    this.passwordVisible = false,
    this.confirmPasswordVisible = false,
    this.onPasswordVisibilityToggle,
    this.onConfirmPasswordVisibilityToggle,
  });

  @override
  State<CommonTextField> createState() => _CommonTextFieldState();
}

class _CommonTextFieldState extends State<CommonTextField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: Color(0xFF374151),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
            ),
          ),
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.isPassword && 
                (widget.isConfirmPassword 
                    ? !widget.confirmPasswordVisible 
                    : !widget.passwordVisible),
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 16,
            ),
            validator: widget.validator,
            keyboardType: widget.keyboardType,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 16,
              ),
              prefixIcon: Icon(
                widget.icon,
                color: const Color(0xFF6366F1),
                size: 20,
              ),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        (widget.isConfirmPassword 
                            ? widget.confirmPasswordVisible 
                            : widget.passwordVisible)
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF6B7280),
                        size: 20,
                      ),
                      onPressed: () {
                        if (widget.isConfirmPassword) {
                          widget.onConfirmPasswordVisibilityToggle?.call();
                        } else {
                          widget.onPasswordVisibilityToggle?.call();
                        }
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
        if (widget.helperText != null) ...[ 
          const SizedBox(height: 6),
          Text(
            widget.helperText!,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}