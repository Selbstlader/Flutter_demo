import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/widgets/safe_area_scaffold.dart';
import '../../../../core/widgets/unified_text_field.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/services/storage_service.dart';
import '../../../settings/providers/user_profile_provider.dart';
import '../../models/user_info.dart';

class UserInfoFormPage extends ConsumerStatefulWidget {
  const UserInfoFormPage({super.key});

  @override
  ConsumerState<UserInfoFormPage> createState() => _UserInfoFormPageState();
}

class _UserInfoFormPageState extends ConsumerState<UserInfoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _occupationController = TextEditingController();
  final _locationController = TextEditingController();
  
  Gender? _selectedGender;
  Education? _selectedEducation;
  MaritalStatus? _selectedMaritalStatus;
  LivingCondition? _selectedLivingCondition;
  GraduationStatus? _selectedGraduationStatus;
  bool _isLoading = false;
  bool _hasInitialized = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  /// 初始化表单数据
  void _initializeForm() {
    final userInfo = ref.read(currentUserInfoProvider);
    if (userInfo != null && !_hasInitialized) {
      _populateForm(userInfo);
      _hasInitialized = true;
    }
  }

  /// 填充表单数据
  void _populateForm(UserInfo userInfo) {
    // 注意：UserInfo模型中没有name和location字段，这里保持原有逻辑
    _ageController.text = userInfo.age.toString();
    _occupationController.text = userInfo.occupation;
    
    // 转换枚举值
    _selectedGender = _getGenderFromString(userInfo.gender);
    _selectedEducation = _getEducationFromString(userInfo.education);
    _selectedMaritalStatus = _getMaritalStatusFromString(userInfo.maritalStatus);
    _selectedLivingCondition = _getLivingConditionFromString(userInfo.livingCondition);
    _selectedGraduationStatus = _getGraduationStatusFromString(userInfo.graduationStatus);
  }

  // 枚举转换方法
  Gender? _getGenderFromString(String gender) {
    return Gender.values.firstWhere(
      (g) => g.displayName == gender || g.name == gender,
      orElse: () => Gender.male,
    );
  }

  Education? _getEducationFromString(String education) {
    return Education.values.firstWhere(
      (e) => e.displayName == education || e.name == education,
      orElse: () => Education.bachelor,
    );
  }

  MaritalStatus? _getMaritalStatusFromString(String status) {
    return MaritalStatus.values.firstWhere(
      (s) => s.displayName == status || s.name == status,
      orElse: () => MaritalStatus.single,
    );
  }

  LivingCondition? _getLivingConditionFromString(String condition) {
    return LivingCondition.values.firstWhere(
      (c) => c.displayName == condition || c.name == condition,
      orElse: () => LivingCondition.alone,
    );
  }

  GraduationStatus? _getGraduationStatusFromString(String status) {
    return GraduationStatus.values.firstWhere(
      (s) => s.displayName == status || s.name == status,
      orElse: () => GraduationStatus.graduated,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // 监听用户信息变化并更新表单
    ref.listen<UserInfo?>(currentUserInfoProvider, (previous, next) {
      if (next != null && !_hasInitialized) {
        _populateForm(next);
        _hasInitialized = true;
      }
    });

    return SafeAreaScaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          '基本信息',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF64748B),
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 页面说明
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF0EA5E9).withOpacity(0.2),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFF0EA5E9),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '为了提供更准确的心理健康评估，请填写以下基本信息。所有信息仅用于生成个性化测试题目，不会被上传或分享。',
                        style: TextStyle(
                          color: Color(0xFF0C4A6E),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // 基本信息表单
              _buildSectionTitle('基本信息'),
              const SizedBox(height: 16),
              
              UnifiedTextField(
                controller: _nameController,
                label: '姓名或昵称',
                hintText: '请输入您的姓名或昵称',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入姓名或昵称';
                  }
                  if (value.trim().length < 2) {
                    return '姓名至少需要2个字符';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: UnifiedTextField(
                      controller: _ageController,
                      label: '年龄',
                      hintText: '请输入年龄',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '请输入年龄';
                        }
                        final age = int.tryParse(value.trim());
                        if (age == null || age < 10 || age > 120) {
                          return '请输入有效年龄(10-120)';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdownField<Gender>(
                      label: '性别',
                      value: _selectedGender,
                      items: Gender.values,
                      itemBuilder: (gender) => gender.displayName,
                      onChanged: (value) => setState(() => _selectedGender = value),
                      validator: (value) => value == null ? '请选择性别' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              UnifiedTextField(
                controller: _occupationController,
                label: '职业',
                hintText: '请输入您的职业',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入职业';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              UnifiedTextField(
                controller: _locationController,
                label: '所在地区',
                hintText: '请输入所在城市或地区',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入所在地区';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // 详细信息
              _buildSectionTitle('详细信息'),
              const SizedBox(height: 16),
              
              _buildDropdownField<Education>(
                label: '教育程度',
                value: _selectedEducation,
                items: Education.values,
                itemBuilder: (education) => education.displayName,
                onChanged: (value) => setState(() => _selectedEducation = value),
                validator: (value) => value == null ? '请选择教育程度' : null,
              ),
              const SizedBox(height: 16),
              
              _buildDropdownField<GraduationStatus>(
                label: '毕业状态',
                value: _selectedGraduationStatus,
                items: GraduationStatus.values,
                itemBuilder: (status) => status.displayName,
                onChanged: (value) => setState(() => _selectedGraduationStatus = value),
                validator: (value) => value == null ? '请选择毕业状态' : null,
              ),
              const SizedBox(height: 16),
              
              _buildDropdownField<MaritalStatus>(
                label: '婚姻状况',
                value: _selectedMaritalStatus,
                items: MaritalStatus.values,
                itemBuilder: (status) => status.displayName,
                onChanged: (value) => setState(() => _selectedMaritalStatus = value),
                validator: (value) => value == null ? '请选择婚姻状况' : null,
              ),
              const SizedBox(height: 16),
              
              _buildDropdownField<LivingCondition>(
                label: '居住情况',
                value: _selectedLivingCondition,
                items: LivingCondition.values,
                itemBuilder: (condition) => condition.displayName,
                onChanged: (value) => setState(() => _selectedLivingCondition = value),
                validator: (value) => value == null ? '请选择居住情况' : null,
              ),
              const SizedBox(height: 32),
              
              // 提交按钮
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  text: '开始测试',
                  onPressed: _isLoading ? null : _submitForm,
                  showLoading: _isLoading,
                ),
              ),
              const SizedBox(height: 16),
              
              // 隐私说明
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      color: Color(0xFF64748B),
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '您的个人信息将被安全保护，仅用于生成个性化测试内容，不会被存储到云端或与第三方分享。',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1E293B),
      ),
    );
  }
  
  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemBuilder,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          dropdownColor: Colors.white,
          decoration: InputDecoration(
            hintText: '请选择$label',
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 16,
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF4A90E2),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemBuilder(item),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1F2937),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
  
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final currentUserInfo = ref.read(currentUserInfoProvider);
      
      // 创建用户信息对象
      final userInfo = UserInfo(
        id: currentUserInfo?.id ?? const Uuid().v4(),
        age: int.parse(_ageController.text.trim()),
        gender: _selectedGender!.name, // 使用枚举的name而不是displayName
        occupation: _occupationController.text.trim(),
        education: _selectedEducation!.name,
        maritalStatus: _selectedMaritalStatus!.name,
        livingCondition: _selectedLivingCondition!.name,
        graduationStatus: _selectedGraduationStatus!.name,
        createdAt: currentUserInfo?.createdAt ?? DateTime.now(),
        // 保留现有的其他字段
        phone: currentUserInfo?.phone,
        email: currentUserInfo?.email,
        concerns: currentUserInfo?.concerns,
        previousExperience: currentUserInfo?.previousExperience,
      );
      
      // 同步保存到Provider和本地存储
      final notifier = ref.read(userProfileNotifierProvider.notifier);
      final success = await notifier.updateUserInfo(userInfo);
      
      if (success) {
        // 导航到测试题目页面
        if (mounted) {
          context.go('/test-questions?userInfoId=${userInfo.id}');
        }
      } else {
        throw Exception('保存用户信息失败');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存信息失败：$e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}