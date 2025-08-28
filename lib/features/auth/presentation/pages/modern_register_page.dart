import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as provider;
import '../../providers/auth_provider.dart';
import '../../../../core/widgets/common_text_field.dart';
import '../../../../core/widgets/error_message_widget.dart';
import '../../../../core/widgets/gradient_button.dart';

class ModernRegisterPage extends ConsumerStatefulWidget {
  const ModernRegisterPage({super.key});

  @override
  ConsumerState<ModernRegisterPage> createState() => _ModernRegisterPageState();
}

class _ModernRegisterPageState extends ConsumerState<ModernRegisterPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _emailController.dispose();
    _nicknameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = provider.Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      _emailController.text.trim(),
      _passwordController.text,
      _confirmPasswordController.text,
      nickname: _nicknameController.text.trim().isEmpty ? null : _nicknameController.text.trim(),
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFE2E8F0),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                    MediaQuery.of(context).padding.top - 
                    MediaQuery.of(context).padding.bottom,
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildRegisterForm(),
                      const SizedBox(height: 16),
                      _buildFooter(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Color(0xFF64748B),
                size: 20,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
              ),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_add_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '创建账户',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '填写信息完成注册',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF64748B),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            CommonTextField(
              controller: _emailController,
              label: '邮箱',
              hint: '请输入您的邮箱地址',
              icon: Icons.email_outlined,
              helperText: '邮箱将用于登录和接收验证信息',
              keyboardType: TextInputType.emailAddress,
            
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入邮箱地址';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                  return '请输入正确的邮箱格式';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            CommonTextField(
              controller: _nicknameController,
              label: '昵称（可选）',
              hint: '请输入您的昵称',
              icon: Icons.badge_outlined,
              helperText: '昵称用于显示，可以为空',
            ),
            const SizedBox(height: 20),
            CommonTextField(
              controller: _passwordController,
              label: '密码',
              hint: '请输入密码（至少6位）',
              icon: Icons.lock_outline,
              isPassword: true,
              helperText: '密码至少6位',
              passwordVisible: _isPasswordVisible,
              onPasswordVisibilityToggle: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入密码';
                }
                if (value.length < 6) {
                  return '密码至少6位';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            CommonTextField(
              controller: _confirmPasswordController,
              label: '确认密码',
              hint: '请再次输入密码',
              icon: Icons.lock_outline,
              isPassword: true,
              isConfirmPassword: true,
              confirmPasswordVisible: _isConfirmPasswordVisible,
              onConfirmPasswordVisibilityToggle: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请确认密码';
                }
                if (value != _passwordController.text) {
                  return '两次输入的密码不一致';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 错误信息显示
            const ErrorMessageWidget(),

            const SizedBox(height: 8),
            _buildRegisterButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return AuthGradientButton(
      text: '注册',
      onPressed: _handleRegister,
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '已有账户？',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () => context.pop(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            '返回登录',
            style: TextStyle(
              color: Color(0xFF6366F1),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}