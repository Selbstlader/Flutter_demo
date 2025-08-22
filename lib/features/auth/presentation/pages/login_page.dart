import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/animations/slide_in_animation.dart';

/// 登录页
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 处理登录
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 模拟登录请求
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        // 登录成功，跳转到首页
        context.go(AppConstants.homeRoute);
      }
    } catch (e) {
      // 处理登录错误
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('登录失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 标题
                SlideInAnimation(
                  direction: SlideDirection.top,
                  child: Text(
                    '欢迎回来',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                
                SizedBox(height: 8.h),
                
                SlideInAnimation(
                  direction: SlideDirection.top,
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    '请登录您的账户',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                SizedBox(height: 48.h),
                
                // 用户名输入框
                SlideInAnimation(
                  direction: SlideDirection.left,
                  delay: const Duration(milliseconds: 200),
                  child: TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: '用户名',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入用户名';
                      }
                      return null;
                    },
                  ),
                ),
                
                SizedBox(height: 16.h),
                
                // 密码输入框
                SlideInAnimation(
                  direction: SlideDirection.right,
                  delay: const Duration(milliseconds: 300),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: '密码',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入密码';
                      }
                      if (value.length < 6) {
                        return '密码长度不能少于6位';
                      }
                      return null;
                    },
                  ),
                ),
                
                SizedBox(height: 32.h),
                
                // 登录按钮
                SlideInAnimation(
                  direction: SlideDirection.bottom,
                  delay: const Duration(milliseconds: 400),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('登录'),
                  ),
                ),
                
                SizedBox(height: 16.h),
                
                // 注册链接
                SlideInAnimation(
                  direction: SlideDirection.bottom,
                  delay: const Duration(milliseconds: 500),
                  child: TextButton(
                    onPressed: () {
                      // 跳转到注册页
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('注册功能待实现')),
                      );
                    },
                    child: const Text('还没有账户？立即注册'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}