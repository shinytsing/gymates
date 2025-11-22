import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/3d_components/index.dart';
import '../../models/user_achievement_data.dart';

/// 👤 Apple Fitness+ Style Edit Profile Page
/// 
/// Design Features:
/// - 3D avatar selector (with animation)
/// - 3D form cards (grouped sections)
/// - 3D goal selector (chips)
/// - 3D preference tags (multi-select)
/// - 3D save button (floating)
/// - Smooth validation feedback

class Edit3DProfilePage extends StatefulWidget {
  final UserAchievementData user;

  const Edit3DProfilePage({
    super.key,
    required this.user,
  });

  @override
  State<Edit3DProfilePage> createState() => _Edit3DProfilePageState();
}

class _Edit3DProfilePageState extends State<Edit3DProfilePage>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  
  String _selectedGoal = '';
  String _selectedExperience = '';
  List<String> _selectedPreferences = [];
  String _avatarUrl = '';
  File? _avatarFile;
  bool _isLoading = false;
  
  late AnimationController _avatarController;
  late AnimationController _saveController;
  late Animation<double> _avatarRotation;
  late Animation<double> _saveScale;

  final List<String> _goals = ['减脂', '增肌', '塑形', '健康', '力量提升'];
  final List<String> _experiences = ['初级', '中级', '高级'];
  final List<String> _preferences = [
    '力量训练', '有氧运动', '瑜伽', '普拉提', '游泳',
    '跑步', '骑行', '舞蹈', '拳击', 'CrossFit',
  ];

  @override
  void initState() {
    super.initState();
    
    _avatarController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _saveController = AnimationController(
      duration: AppleFitnessTheme.durationNormal,
      vsync: this,
    );
    
    _avatarRotation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(
        parent: _avatarController,
        curve: Curves.easeInOut,
      ),
    );
    
    _saveScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _saveController,
        curve: AppleFitnessTheme.easeInOutCubic,
      ),
    );
    
    _initializeForm();
  }

  void _initializeForm() {
    _nameController.text = widget.user.username;
    _bioController.text = widget.user.bio ?? '';
    _ageController.text = ''; // UserAchievementData doesn't have age
    _heightController.text = ''; // UserAchievementData doesn't have height
    _weightController.text = ''; // UserAchievementData doesn't have weight
    _locationController.text = ''; // UserAchievementData doesn't have location
    _avatarUrl = widget.user.avatar;
    _selectedGoal = widget.user.fitnessGoal ?? '减脂';
    _selectedExperience = '中级'; // UserAchievementData doesn't have experienceLevel
    _selectedPreferences = ['力量训练']; // UserAchievementData doesn't have preferences
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _locationController.dispose();
    _avatarController.dispose();
    _saveController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() {
        _avatarFile = File(image.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    await _saveController.forward();
    _saveController.reverse();

    setState(() => _isLoading = true);

    try {
      // TODO: Upload avatar and save profile
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showAlertDialog3D(
          context: context,
          title: '保存失败',
          message: e.toString(),
          confirmText: '确定',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppleFitnessTheme.backgroundPrimary,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppleFitnessTheme.backgroundGradient,
        ),
        child: Stack(
          children: [
            _buildContent(),
            if (_isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: Center(
                  child: CircularProgress3D(
                    value: 0.0,
                    size: 60,
                    progressColor: AppleFitnessTheme.primaryBlue,
                    showPercentage: false,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        '编辑资料',
        style: AppleFitnessTheme.titleLarge,
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: AppleFitnessTheme.spacingM),
          child: AnimatedBuilder(
            animation: _saveScale,
            builder: (context, child) {
              return Transform.scale(
                scale: _saveScale.value,
                child: child,
              );
            },
            child: Button3D.primary(
              text: '保存',
              icon: Icons.check,
              onPressed: _isLoading ? () {} : () => _saveProfile(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar section
            _buildAvatarSection(),
            SizedBox(height: AppleFitnessTheme.spacingXL),
            
            // Basic info
            _buildBasicInfoSection(),
            SizedBox(height: AppleFitnessTheme.spacingL),
            
            // Body measurements
            _buildMeasurementsSection(),
            SizedBox(height: AppleFitnessTheme.spacingL),
            
            // Goals
            _buildGoalsSection(),
            SizedBox(height: AppleFitnessTheme.spacingL),
            
            // Experience
            _buildExperienceSection(),
            SizedBox(height: AppleFitnessTheme.spacingL),
            
            // Preferences
            _buildPreferencesSection(),
            SizedBox(height: AppleFitnessTheme.spacingXXL),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return FadeIn3D(
      child: Center(
        child: GestureDetector(
          onTap: _pickAvatar,
          child: AnimatedBuilder(
            animation: _avatarRotation,
            builder: (context, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.002)
                  ..rotateY(_avatarRotation.value),
                child: child,
              );
            },
            child: Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppleFitnessTheme.primaryGradient,
                    boxShadow: AppleFitnessTheme.softGlow(
                      AppleFitnessTheme.primaryBlue,
                      intensity: 0.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: CircleAvatar(
                    radius: 56,
                    backgroundImage: _avatarFile != null
                        ? FileImage(_avatarFile!)
                        : (_avatarUrl.isNotEmpty
                            ? NetworkImage(_avatarUrl)
                            : null) as ImageProvider?,
                    child: _avatarFile == null && _avatarUrl.isEmpty
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(AppleFitnessTheme.spacingS),
                    decoration: BoxDecoration(
                      gradient: AppleFitnessTheme.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: AppleFitnessTheme.softShadow(elevation: 8),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return FadeIn3D(
      delay: const Duration(milliseconds: 100),
      child: Card3D(
        useFrostedGlass: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: AppleFitnessTheme.primaryBlue,
                  size: 20,
                ),
                SizedBox(width: AppleFitnessTheme.spacingS),
                Text(
                  '基本信息',
                  style: AppleFitnessTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: AppleFitnessTheme.spacingL),
            Input3D(
              controller: _nameController,
              hint: '昵称',
              prefixIcon: Icons.badge,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入昵称';
                }
                return null;
              },
            ),
            SizedBox(height: AppleFitnessTheme.spacingM),
            Input3D(
              controller: _bioController,
              hint: '个人简介',
              prefixIcon: Icons.edit_note,
              maxLines: 3,
              maxLength: 100,
            ),
            SizedBox(height: AppleFitnessTheme.spacingM),
            Input3D(
              controller: _ageController,
              hint: '年龄',
              prefixIcon: Icons.cake,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: AppleFitnessTheme.spacingM),
            Input3D(
              controller: _locationController,
              hint: '所在地',
              prefixIcon: Icons.location_on,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementsSection() {
    return FadeIn3D(
      delay: const Duration(milliseconds: 200),
      child: Card3D(
        useFrostedGlass: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.straighten,
                  color: AppleFitnessTheme.primaryBlue,
                  size: 20,
                ),
                SizedBox(width: AppleFitnessTheme.spacingS),
                Text(
                  '身体数据',
                  style: AppleFitnessTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: AppleFitnessTheme.spacingL),
            Row(
              children: [
                Expanded(
                  child: Input3D(
                    controller: _heightController,
                    hint: '身高 (cm)',
                    prefixIcon: Icons.height,
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: AppleFitnessTheme.spacingM),
                Expanded(
                  child: Input3D(
                    controller: _weightController,
                    hint: '体重 (kg)',
                    prefixIcon: Icons.monitor_weight,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsSection() {
    return FadeIn3D(
      delay: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flag,
                color: AppleFitnessTheme.primaryBlue,
                size: 20,
              ),
              SizedBox(width: AppleFitnessTheme.spacingS),
              Text(
                '健身目标',
                style: AppleFitnessTheme.titleMedium,
              ),
            ],
          ),
          SizedBox(height: AppleFitnessTheme.spacingM),
          Wrap(
            spacing: AppleFitnessTheme.spacingS,
            runSpacing: AppleFitnessTheme.spacingS,
            children: _goals.map((goal) {
              final isSelected = goal == _selectedGoal;
              return GestureDetector(
                onTap: () => setState(() => _selectedGoal = goal),
                child: AnimatedContainer(
                  duration: AppleFitnessTheme.durationFast,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppleFitnessTheme.spacingL,
                    vertical: AppleFitnessTheme.spacingM,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? AppleFitnessTheme.primaryGradient
                        : null,
                    color: isSelected
                        ? null
                        : AppleFitnessTheme.backgroundSecondary,
                    borderRadius: AppleFitnessTheme.radiusMedium,
                    boxShadow: isSelected
                        ? AppleFitnessTheme.softShadow(elevation: 8)
                        : AppleFitnessTheme.softShadow(elevation: 2),
                  ),
                  child: Text(
                    goal,
                    style: AppleFitnessTheme.labelLarge.copyWith(
                      color: isSelected
                          ? Colors.white
                          : AppleFitnessTheme.textPrimary,
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

  Widget _buildExperienceSection() {
    return FadeIn3D(
      delay: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: AppleFitnessTheme.primaryBlue,
                size: 20,
              ),
              SizedBox(width: AppleFitnessTheme.spacingS),
              Text(
                '训练经验',
                style: AppleFitnessTheme.titleMedium,
              ),
            ],
          ),
          SizedBox(height: AppleFitnessTheme.spacingM),
          Card3D(
            useFrostedGlass: true,
            child: Column(
              children: _experiences.map((experience) {
                final isSelected = experience == _selectedExperience;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: experience != _experiences.last
                        ? AppleFitnessTheme.spacingM
                        : 0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedExperience = experience);
                    },
                    child: Container(
                      padding: EdgeInsets.all(AppleFitnessTheme.spacingM),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? AppleFitnessTheme.primaryGradient
                            : null,
                        borderRadius: AppleFitnessTheme.radiusSmall,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: isSelected
                                ? Colors.white
                                : AppleFitnessTheme.textTertiary,
                          ),
                          SizedBox(width: AppleFitnessTheme.spacingM),
                          Text(
                            experience,
                            style: AppleFitnessTheme.bodyMedium.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppleFitnessTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return FadeIn3D(
      delay: const Duration(milliseconds: 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite,
                color: AppleFitnessTheme.primaryBlue,
                size: 20,
              ),
              SizedBox(width: AppleFitnessTheme.spacingS),
              Text(
                '训练偏好',
                style: AppleFitnessTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                '${_selectedPreferences.length}/5',
                style: AppleFitnessTheme.bodySmall.copyWith(
                  color: AppleFitnessTheme.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppleFitnessTheme.spacingM),
          Wrap(
            spacing: AppleFitnessTheme.spacingS,
            runSpacing: AppleFitnessTheme.spacingS,
            children: _preferences.map((pref) {
              final isSelected = _selectedPreferences.contains(pref);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedPreferences.remove(pref);
                    } else {
                      if (_selectedPreferences.length < 5) {
                        _selectedPreferences.add(pref);
                      } else {
                        showAlertDialog3D(
                          context: context,
                          title: '提示',
                          message: '最多只能选择5个偏好',
                          confirmText: '确定',
                        );
                      }
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: AppleFitnessTheme.durationFast,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppleFitnessTheme.spacingM,
                    vertical: AppleFitnessTheme.spacingS,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? AppleFitnessTheme.primaryGradient
                        : null,
                    color: isSelected
                        ? null
                        : AppleFitnessTheme.backgroundSecondary,
                    borderRadius: AppleFitnessTheme.radiusSmall,
                    boxShadow: isSelected
                        ? AppleFitnessTheme.softShadow(elevation: 4)
                        : null,
                  ),
                  child: Text(
                    pref,
                    style: AppleFitnessTheme.labelMedium.copyWith(
                      color: isSelected
                          ? Colors.white
                          : AppleFitnessTheme.textPrimary,
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
}

