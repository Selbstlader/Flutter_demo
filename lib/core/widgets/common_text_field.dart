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
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF374151).withOpacity(0.5),
            ),
          ),
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.isPassword && 
                (widget.isConfirmPassword 
                    ? !widget.confirmPasswordVisible 
                    : !widget.passwordVisible),
            style: const TextStyle(color: Colors.white),
            validator: widget.validator,
            keyboardType: widget.keyboardType,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
              ),
              prefixIcon: Icon(
                widget.icon,
                color: const Color(0xFF6366F1),
              ),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        (widget.isConfirmPassword 
                            ? widget.confirmPasswordVisible 
                            : widget.passwordVisible)
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white.withOpacity(0.7),
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
          const SizedBox(height: 4),
          Text(
            widget.helperText!,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}