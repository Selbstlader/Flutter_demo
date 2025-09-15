import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_profile_provider.dart';
import '../../../psychological_test/models/user_info.dart';
import '../../../../core/utils/logger_util.dart';
import '../../../auth/services/auth_api_service.dart';

/// 用户信息管理页面
class UserProfilePage extends ConsumerStatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends ConsumerState<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _occupationController = TextEditingController();
  final _educationController = TextEditingController();
  final _previousExperienceController = TextEditingController();

  String _selectedGender = 'male';
  String _selectedMaritalStatus = 'single';
  String _selectedLivingCondition = 'alone';
  String _selectedGraduationStatus = 'graduated';
  List<String> _selectedConcerns = [];
  bool _hasInitialized = false;

  // 预定义选项
  final List<String> _genderOptions = ['male', 'female'];
  final List<String> _maritalStatusOptions = [
    'single',
    'married',
    'divorced',
    'widowed'
  ];
  final List<String> _livingConditionOptions = [
    'alone',
    'with_family',
    'with_roommates',
    'other'
  ];
  final List<String> _graduationStatusOptions = [
    'graduated',
    'studying',
    'dropped_out'
  ];
  final List<String> _concernOptions = [
    '焦虑',
    '抑郁',
    '压力管理',
    '人际关系',
    '学业压力',
    '工作压力',
    '睡眠问题',
    '情绪管理',
    '自信心',
    '其他'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });
  }

  @override
  void dispose() {
    _ageController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _occupationController.dispose();
    _educationController.dispose();
    _previousExperienceController.dispose();
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
    _ageController.text = userInfo.age.toString();
    _phoneController.text = userInfo.phone ?? '';
    _emailController.text = userInfo.email ?? '';
    _occupationController.text = userInfo.occupation;
    _educationController.text = userInfo.education;
    _previousExperienceController.text = userInfo.previousExperience ?? '';
    _selectedGender = userInfo.gender;
    _selectedMaritalStatus = userInfo.maritalStatus;
    _selectedLivingCondition = userInfo.livingCondition;
    _selectedGraduationStatus = userInfo.graduationStatus;
    _selectedConcerns = List<String>.from(userInfo.concerns ?? []);
  }

  /// 创建UserInfo对象
  UserInfo _createUserInfo() {
    final currentUserInfo = ref.read(currentUserInfoProvider);
    return UserInfo(
      id: currentUserInfo?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      age: int.tryParse(_ageController.text.trim()) ?? 0,
      gender: _selectedGender,
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      occupation: _occupationController.text.trim(),
      education: _educationController.text.trim(),
      maritalStatus: _selectedMaritalStatus,
      livingCondition: _selectedLivingCondition,
      graduationStatus: _selectedGraduationStatus,
      concerns: _selectedConcerns.isEmpty ? null : _selectedConcerns,
      previousExperience: _previousExperienceController.text.trim().isEmpty
          ? null
          : _previousExperienceController.text.trim(),
      createdAt: currentUserInfo?.createdAt ?? DateTime.now(),
    );
  }

  /// 保存用户信息
  Future<void> _saveUserInfo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userInfo = _createUserInfo();
    final notifier = ref.read(userProfileNotifierProvider.notifier);
    final authService = AuthApiService();
    final isLoggedIn = authService.isLoggedIn;

    // 显示保存中的提示
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text(isLoggedIn ? '正在保存并同步到云端...' : '正在保存到本地...'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    final success = await notifier.updateUserInfo(userInfo);
    
    if (mounted) {
      // 清除之前的SnackBar
      ScaffoldMessenger.of(context).clearSnackBars();
      
      if (success) {
        final state = ref.read(userProfileNotifierProvider);
        String message;
        Color backgroundColor;
        
        if (state.errorMessage != null && state.errorMessage!.contains('服务器同步失败')) {
          // 本地保存成功但服务器同步失败
          message = '已保存到本地，服务器同步失败';
          backgroundColor = Colors.orange;
        } else if (isLoggedIn) {
          // 完全成功（已登录且同步成功）
          message = '保存成功并已同步到云端';
          backgroundColor = Colors.green;
        } else {
          // 本地保存成功（未登录）
          message = '已保存到本地';
          backgroundColor = Colors.blue;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: backgroundColor,
          ),
        );
        notifier.cancelEditing();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('保存失败，请检查网络连接后重试'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 刷新数据
  Future<void> _refreshData() async {
    final notifier = ref.read(userProfileNotifierProvider.notifier);
    await notifier.refreshFromServer();
    _initializeForm();
  }

  @override
  Widget build(BuildContext context) {
    final userProfileState = ref.watch(userProfileNotifierProvider);
    final isEditing = userProfileState.isEditing;
    final isLoading = userProfileState.isLoading;
    final errorMessage = userProfileState.errorMessage;

    // 监听用户信息变化并更新表单
    ref.listen<UserInfo?>(currentUserInfoProvider, (previous, next) {
      if (next != null && !isEditing) {
        _populateForm(next);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('个人信息'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: isLoading ? null : _refreshData,
            ),
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                ref.read(userProfileNotifierProvider.notifier).startEditing();
              },
            ),
          if (isEditing)
            TextButton(
              onPressed: () {
                ref.read(userProfileNotifierProvider.notifier).cancelEditing();
                _initializeForm(); // 重置表单
              },
              child: const Text(
                '取消',
                style: TextStyle(color: Colors.white),
              ),
            ),
          if (isEditing)
            TextButton(
              onPressed: isLoading ? null : _saveUserInfo,
              child: const Text(
                '保存',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          border: Border.all(color: Colors.red[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red[600]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMessage,
                                style: TextStyle(color: Colors.red[600]),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                ref
                                    .read(userProfileNotifierProvider.notifier)
                                    .clearError();
                              },
                            ),
                          ],
                        ),
                      ),
                    // 登录状态提示卡片
                    _buildLoginStatusCard(),
                    const SizedBox(height: 16),
                    _buildSection(
                      '基本信息',
                      [
                        _buildTextField(
                          controller: _ageController,
                          label: '年龄',
                          enabled: isEditing,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return '请输入年龄';
                            }
                            final age = int.tryParse(value.trim());
                            if (age == null || age < 1 || age > 150) {
                              return '请输入有效的年龄';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildDropdown(
                          label: '性别',
                          value: _selectedGender,
                          items: _genderOptions
                              .map((option) => DropdownMenuItem(
                                    value: option,
                                    child: Text(_getGenderDisplayName(option)),
                                  ))
                              .toList(),
                          onChanged: isEditing
                              ? (value) {
                                  setState(() {
                                    _selectedGender = value!;
                                  });
                                  ref
                                      .read(
                                          userProfileNotifierProvider.notifier)
                                      .markAsChanged();
                                }
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _phoneController,
                          label: '手机号码',
                          enabled: isEditing,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _emailController,
                          label: '邮箱',
                          enabled: isEditing,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      '职业与教育',
                      [
                        _buildTextField(
                          controller: _occupationController,
                          label: '职业',
                          enabled: isEditing,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return '请输入职业';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _educationController,
                          label: '教育背景',
                          enabled: isEditing,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return '请输入教育背景';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildDropdown(
                          label: '毕业状态',
                          value: _selectedGraduationStatus,
                          items: _graduationStatusOptions
                              .map((option) => DropdownMenuItem(
                                    value: option,
                                    child: Text(_getGraduationStatusDisplayName(
                                        option)),
                                  ))
                              .toList(),
                          onChanged: isEditing
                              ? (value) {
                                  setState(() {
                                    _selectedGraduationStatus = value!;
                                  });
                                  ref
                                      .read(
                                          userProfileNotifierProvider.notifier)
                                      .markAsChanged();
                                }
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      '个人状况',
                      [
                        _buildDropdown(
                          label: '婚姻状况',
                          value: _selectedMaritalStatus,
                          items: _maritalStatusOptions
                              .map((option) => DropdownMenuItem(
                                    value: option,
                                    child: Text(
                                        _getMaritalStatusDisplayName(option)),
                                  ))
                              .toList(),
                          onChanged: isEditing
                              ? (value) {
                                  setState(() {
                                    _selectedMaritalStatus = value!;
                                  });
                                  ref
                                      .read(
                                          userProfileNotifierProvider.notifier)
                                      .markAsChanged();
                                }
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _buildDropdown(
                          label: '居住状况',
                          value: _selectedLivingCondition,
                          items: _livingConditionOptions
                              .map((option) => DropdownMenuItem(
                                    value: option,
                                    child: Text(
                                        _getLivingConditionDisplayName(option)),
                                  ))
                              .toList(),
                          onChanged: isEditing
                              ? (value) {
                                  setState(() {
                                    _selectedLivingCondition = value!;
                                  });
                                  ref
                                      .read(
                                          userProfileNotifierProvider.notifier)
                                      .markAsChanged();
                                }
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      '心理健康关注',
                      [
                        _buildConcernsSelector(enabled: isEditing),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _previousExperienceController,
                          label: '之前的心理健康经历',
                          enabled: isEditing,
                          maxLines: 3,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建区块
  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  /// 构建文本输入框
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool enabled = true,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey[100],
      ),
      onChanged: enabled
          ? (value) {
              ref.read(userProfileNotifierProvider.notifier).markAsChanged();
            }
          : null,
    );
  }

  /// 构建下拉选择器
  Widget _buildDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    void Function(String?)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  /// 构建关注问题选择器
  Widget _buildConcernsSelector({bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '关注的心理健康问题',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _concernOptions.map((concern) {
            final isSelected = _selectedConcerns.contains(concern);
            return FilterChip(
              label: Text(concern),
              selected: isSelected,
              onSelected: enabled
                  ? (selected) {
                      setState(() {
                        if (selected) {
                          _selectedConcerns.add(concern);
                        } else {
                          _selectedConcerns.remove(concern);
                        }
                      });
                      ref
                          .read(userProfileNotifierProvider.notifier)
                          .markAsChanged();
                    }
                  : null,
            );
          }).toList(),
        ),
      ],
    );
  }

  // 显示名称转换方法
  String _getGenderDisplayName(String gender) {
    switch (gender) {
      case 'male':
        return '男';
      case 'female':
        return '女';
      default:
        return gender;
    }
  }

  String _getMaritalStatusDisplayName(String status) {
    switch (status) {
      case 'single':
        return '单身';
      case 'married':
        return '已婚';
      case 'divorced':
        return '离异';
      case 'widowed':
        return '丧偶';
      default:
        return status;
    }
  }

  String _getLivingConditionDisplayName(String condition) {
    switch (condition) {
      case 'alone':
        return '独居';
      case 'with_family':
        return '与家人同住';
      case 'with_roommates':
        return '与室友同住';
      case 'other':
        return '其他';
      default:
        return condition;
    }
  }

  String _getGraduationStatusDisplayName(String status) {
    switch (status) {
      case 'graduated':
        return '已毕业';
      case 'studying':
        return '在读';
      case 'dropped_out':
        return '辍学';
      default:
        return status;
    }
  }

  /// 构建登录状态提示卡片
  Widget _buildLoginStatusCard() {
    final authService = AuthApiService();
    final isLoggedIn = authService.isLoggedIn;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLoggedIn ? Colors.green[50] : Colors.orange[50],
        border: Border.all(
          color: isLoggedIn ? Colors.green[300]! : Colors.orange[300]!,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isLoggedIn ? Icons.cloud_done : Icons.cloud_off,
            color: isLoggedIn ? Colors.green[600] : Colors.orange[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoggedIn ? '已登录状态' : '未登录状态',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isLoggedIn ? Colors.green[700] : Colors.orange[700],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isLoggedIn 
                    ? '数据将与服务器同步，修改后自动保存到云端'
                    : '数据仅保存在本地，登录后可同步到云端',
                  style: TextStyle(
                    fontSize: 12,
                    color: isLoggedIn ? Colors.green[600] : Colors.orange[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
