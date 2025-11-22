import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/user_achievement_data.dart';

/// 👤 个人资料编辑页 - EditProfilePage
/// 
/// 基于Figma设计的个人资料编辑页面
/// 包含头像上传、基本信息编辑、健身目标设置

class EditProfilePage extends StatefulWidget {
  final UserAchievementData user;

  const EditProfilePage({
    super.key,
    required this.user,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _formAnimationController;
  
  late Animation<double> _headerAnimation;
  late Animation<double> _formAnimation;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _locationController = TextEditingController();

  String _selectedGoal = '';
  String _selectedExperience = '';
  List<String> _selectedPreferences = [];
  
  String _avatarUrl = '';
  File? _avatarFile; // 本地选择的图片文件
  final ImagePicker _imagePicker = ImagePicker();

  final List<String> _goals = ['减脂', '增肌', '塑形', '健康', '力量提升'];
  final List<String> _experiences = ['初级', '中级', '高级'];
  final List<String> _preferences = [
    '力量训练', '有氧运动', '瑜伽', '普拉提', '游泳', 
    '跑步', '骑行', '舞蹈', '拳击', 'CrossFit'
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _initializeForm();
  }

  void _initializeAnimations() {
    // 头部动画控制器
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // 表单动画控制器
    _formAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // 头部动画
    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // 表单动画
    _formAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() async {
    // 开始头部动画
    _headerAnimationController.forward();
    
    // 延迟开始表单动画
    await Future.delayed(const Duration(milliseconds: 200));
    _formAnimationController.forward();
  }

  void _initializeForm() {
    _nameController.text = widget.user.name;
    _bioController.text = widget.user.bio ?? '';
    _ageController.text = '25'; // 默认年龄
    _heightController.text = '170'; // 默认身高
    _weightController.text = '65'; // 默认体重
    _locationController.text = ''; // widget.user没有location字段
    _selectedGoal = widget.user.fitnessGoal ?? '健康';
    _selectedExperience = '中级'; // 默认值
    _selectedPreferences = []; // 默认空列表
    _avatarUrl = widget.user.avatar;
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _formAnimationController.dispose();
    _nameController.dispose();
    _bioController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // 头部区域
            _buildHeader(),
            
            // 内容区域
            Expanded(
              child: _buildContent(),
            ),
            
            // 底部操作区
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _headerAnimation.value)),
          child: Opacity(
            opacity: _headerAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // 返回按钮
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      size: 24,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // 标题
                  const Expanded(
                    child: Text(
                      '编辑资料',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  
                  // 保存按钮
                  GestureDetector(
                    onTap: _saveProfile,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '保存',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return AnimatedBuilder(
      animation: _formAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _formAnimation.value)),
          child: Opacity(
            opacity: _formAnimation.value,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 头像编辑
                    _buildAvatarSection(),
                    
                    const SizedBox(height: 24),
                    
                    // 基本信息
                    _buildBasicInfoSection(),
                    
                    const SizedBox(height: 24),
                    
                    // 身体数据
                    _buildBodyDataSection(),
                    
                    const SizedBox(height: 24),
                    
                    // 健身目标
                    _buildGoalSection(),
                    
                    const SizedBox(height: 24),
                    
                    // 运动偏好
                    _buildPreferencesSection(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '头像',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 头像
          GestureDetector(
            onTap: _changeAvatar,
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF3F4F6),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: _avatarFile != null
                        ? Image.file(
                            _avatarFile!,
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          )
                        : (_avatarUrl.isNotEmpty
                            ? Image.network(
                                _avatarUrl,
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Color(0xFF9CA3AF),
                                  );
                                },
                              )
                            : const Icon(
                                Icons.person,
                                size: 50,
                                color: Color(0xFF9CA3AF),
                              )),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFF6366F1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x336366F1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          const Text(
            '点击更换头像',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '基本信息',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 姓名
          _buildTextField(
            controller: _nameController,
            label: '姓名',
            hint: '请输入你的姓名',
            icon: Icons.person,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入姓名';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // 个人简介
          _buildTextField(
            controller: _bioController,
            label: '个人简介',
            hint: '介绍一下自己...',
            icon: Icons.description,
            maxLines: 3,
          ),
          
          const SizedBox(height: 16),
          
          // 年龄
          _buildTextField(
            controller: _ageController,
            label: '年龄',
            hint: '请输入年龄',
            icon: Icons.cake,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入年龄';
              }
              final age = int.tryParse(value);
              if (age == null || age < 1 || age > 120) {
                return '请输入有效年龄';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // 位置
          _buildTextField(
            controller: _locationController,
            label: '位置',
            hint: '请输入所在城市',
            icon: Icons.location_on,
          ),
        ],
      ),
    );
  }

  Widget _buildBodyDataSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '身体数据',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _heightController,
                  label: '身高 (cm)',
                  hint: '170',
                  icon: Icons.height,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入身高';
                    }
                    final height = int.tryParse(value);
                    if (height == null || height < 100 || height > 250) {
                      return '请输入有效身高';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _weightController,
                  label: '体重 (kg)',
                  hint: '65',
                  icon: Icons.monitor_weight,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入体重';
                    }
                    final weight = double.tryParse(value);
                    if (weight == null || weight < 20 || weight > 200) {
                      return '请输入有效体重';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '健身目标',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _goals.map((goal) {
              final isSelected = _selectedGoal == goal;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedGoal = goal;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFF6366F1)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected 
                          ? const Color(0xFF6366F1)
                          : const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    goal,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected 
                          ? Colors.white
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            '健身经验',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          
          const SizedBox(height: 8),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _experiences.map((experience) {
              final isSelected = _selectedExperience == experience;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedExperience = experience;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected 
                          ? const Color(0xFF10B981)
                          : const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    experience,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected 
                          ? Colors.white
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '运动偏好',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          
          const SizedBox(height: 8),
          
          const Text(
            '选择你喜欢的运动类型（可多选）',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _preferences.map((preference) {
              final isSelected = _selectedPreferences.contains(preference);
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    if (isSelected) {
                      _selectedPreferences.remove(preference);
                    } else {
                      _selectedPreferences.add(preference);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFF8B5CF6)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected 
                          ? const Color(0xFF8B5CF6)
                          : const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    preference,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected 
                          ? Colors.white
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 14,
              color: Color(0xFF9CA3AF),
            ),
            prefixIcon: Icon(
              icon,
              size: 20,
              color: const Color(0xFF6B7280),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF6366F1),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 重置按钮
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _resetForm();
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: Color(0xFFE5E7EB),
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                '重置',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 保存按钮
          Expanded(
            child: ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                '保存',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _changeAvatar() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 拖拽指示器
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // 标题
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '选择头像',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              
              // 选项
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    _buildOptionItem(
                      Icons.camera_alt,
                      '拍照',
                      '使用相机拍摄新照片',
                      () {
                        Navigator.of(context).pop();
                        _pickImageFromCamera();
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildOptionItem(
                      Icons.photo_library,
                      '从相册选择',
                      '从手机相册中选择照片',
                      () {
                        Navigator.of(context).pop();
                        _pickImageFromGallery();
                      },
                    ),
                    if (_avatarFile != null || _avatarUrl.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildOptionItem(
                        Icons.delete_outline,
                        '删除头像',
                        '移除当前头像',
                        () {
                          Navigator.of(context).pop();
                          _deleteAvatar();
                        },
                        color: const Color(0xFFEF4444),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 从相机拍照
  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _avatarFile = File(image.path);
        });
        
        HapticFeedback.mediumImpact();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('头像已更新，记得保存'),
                ],
              ),
              backgroundColor: Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      print('拍照失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('拍照失败: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  /// 从相册选择图片
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _avatarFile = File(image.path);
        });
        
        HapticFeedback.mediumImpact();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('头像已更新，记得保存'),
                ],
              ),
              backgroundColor: Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      print('选择图片失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('选择图片失败: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  /// 删除头像
  void _deleteAvatar() {
    HapticFeedback.lightImpact();
    
    setState(() {
      _avatarFile = null;
      _avatarUrl = '';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('头像已删除，记得保存'),
          ],
        ),
        backgroundColor: Color(0xFF6366F1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildOptionItem(
    IconData icon,
    String label,
    String subtitle,
    VoidCallback onTap, {
    Color color = const Color(0xFF1F2937),
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: color.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  void _resetForm() {
    _initializeForm();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('表单已重置'),
        backgroundColor: Color(0xFF6366F1),
      ),
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      
      // 显示加载对话框
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('正在保存...'),
                ],
              ),
            ),
          ),
        ),
      );
      
      try {
        // TODO: 实际上传图片到服务器
        // if (_avatarFile != null) {
        //   // 上传图片到服务器并获取URL
        //   final avatarUrl = await _uploadAvatar(_avatarFile!);
        //   _avatarUrl = avatarUrl;
        // }
        
        // TODO: 保存用户信息到后端
        // await _profileService.updateProfile({
        //   'name': _nameController.text,
        //   'bio': _bioController.text,
        //   'age': int.parse(_ageController.text),
        //   'height': int.parse(_heightController.text),
        //   'weight': double.parse(_weightController.text),
        //   'location': _locationController.text,
        //   'goal': _selectedGoal,
        //   'experience': _selectedExperience,
        //   'preferences': _selectedPreferences,
        //   'avatar': _avatarUrl,
        // });
        
        // 模拟网络请求
        await Future.delayed(const Duration(seconds: 1));
        
        if (mounted) {
          Navigator.of(context).pop(); // 关闭加载对话框
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('资料保存成功'),
                ],
              ),
              backgroundColor: Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );
          
          Navigator.of(context).pop(); // 返回上一页
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // 关闭加载对话框
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('保存失败: $e'),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
      }
    }
  }
  
  /// 上传头像到服务器
  /// TODO: 实现实际的上传逻辑
  Future<String> _uploadAvatar(File imageFile) async {
    // 这里应该调用后端API上传图片
    // 示例代码：
    // final request = http.MultipartRequest(
    //   'POST',
    //   Uri.parse('$apiBaseUrl/api/user/upload-avatar'),
    // );
    // request.headers['Authorization'] = 'Bearer $token';
    // request.files.add(
    //   await http.MultipartFile.fromPath('avatar', imageFile.path),
    // );
    // final response = await request.send();
    // final responseData = await response.stream.bytesToString();
    // final jsonData = json.decode(responseData);
    // return jsonData['data']['avatar_url'];
    
    // 暂时返回本地路径（实际应返回服务器URL）
    return imageFile.path;
  }
}
