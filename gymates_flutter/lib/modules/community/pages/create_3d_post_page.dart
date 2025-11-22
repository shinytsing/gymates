import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/3d_components/index.dart';
import '../../../services/community_service.dart';

/// 📝 Apple Fitness+ Style Create Post Page
/// 
/// Design Features:
/// - 3D text editor card
/// - 3D image grid (with add button)
/// - 3D tag selector (chip cloud)
/// - 3D publish button (floating)
/// - Smooth animations
/// - Character counter

class Create3DPostPage extends StatefulWidget {
  final String postType;
  final VoidCallback? onBack;
  final Function(Map<String, dynamic>)? onPublish;

  const Create3DPostPage({
    super.key,
    this.postType = 'moment',
    this.onBack,
    this.onPublish,
  });

  @override
  State<Create3DPostPage> createState() => _Create3DPostPageState();
}

class _Create3DPostPageState extends State<Create3DPostPage>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final CommunityService _communityService = CommunityService();
  
  final List<String> _selectedTags = [];
  final List<XFile> _selectedImages = [];
  bool _isLocationEnabled = false;
  bool _isPublic = true;
  bool _isLoading = false;
  
  late AnimationController _publishController;
  late Animation<double> _publishScale;

  final List<String> _availableTags = [
    '#减脂', '#增肌', '#瑜伽', '#跑步', '#力量训练',
    '#有氧', '#HIIT', '#普拉提', '#游泳', '#骑行',
    '#健身心得', '#饮食分享', '#训练计划', '#成果展示',
  ];

  @override
  void initState() {
    super.initState();
    
    _publishController = AnimationController(
      duration: AppleFitnessTheme.durationNormal,
      vsync: this,
    );
    
    _publishScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _publishController,
        curve: AppleFitnessTheme.easeInOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    _titleController.dispose();
    _publishController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 9) {
      showAlertDialog3D(
        context: context,
        title: '提示',
        message: '最多只能选择9张图片',
        confirmText: '确定',
      );
      return;
    }

    final images = await _imagePicker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        final remaining = 9 - _selectedImages.length;
        _selectedImages.addAll(images.take(remaining));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        if (_selectedTags.length < 5) {
          _selectedTags.add(tag);
        } else {
          showAlertDialog3D(
            context: context,
            title: '提示',
            message: '最多只能选择5个标签',
            confirmText: '确定',
          );
        }
      }
    });
  }

  Future<void> _publish() async {
    if (_contentController.text.trim().isEmpty) {
      showAlertDialog3D(
        context: context,
        title: '提示',
        message: '请输入内容',
        confirmText: '确定',
      );
      return;
    }

    // Animate button
    await _publishController.forward();
    _publishController.reverse();

    setState(() => _isLoading = true);

    try {
      // Convert XFile to String URLs (assuming images are already uploaded)
      final imageUrls = _selectedImages.map((file) => file.path).toList();
      
      final result = await _communityService.createPost(
        content: _contentController.text.trim(),
        type: widget.postType, // 'text', 'image', 'video', 'article'
        images: imageUrls,
        tags: _selectedTags,
      );

      if (mounted) {
        widget.onPublish?.call(result);
        Navigator.pop(context, result);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showAlertDialog3D(
          context: context,
          title: '发布失败',
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
        onPressed: widget.onBack ?? () => Navigator.pop(context),
      ),
      title: Text(
        '发布动态',
        style: AppleFitnessTheme.titleLarge,
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: AppleFitnessTheme.spacingM),
          child: AnimatedBuilder(
            animation: _publishScale,
            builder: (context, child) {
              return Transform.scale(
                scale: _publishScale.value,
                child: child,
              );
            },
            child: Button3D.primary(
              text: '发布',
              icon: Icons.send,
              onPressed: _isLoading ? () {} : () => _publish(),
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
            // Title input (optional)
            if (widget.postType == 'article')
              FadeIn3D(
                child: Input3D(
                  controller: _titleController,
                  hint: '输入标题（可选）',
                  maxLength: 50,
                ),
              ),
            
            if (widget.postType == 'article')
              SizedBox(height: AppleFitnessTheme.spacingL),
            
            // Content input
            FadeIn3D(
              delay: const Duration(milliseconds: 100),
              child: Card3D(
                useFrostedGlass: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _contentController,
                      maxLines: 8,
                      maxLength: 1000,
                      style: AppleFitnessTheme.bodyMedium,
                      decoration: InputDecoration(
                        hintText: '分享你的健身心得...',
                        hintStyle: AppleFitnessTheme.bodyMedium.copyWith(
                          color: AppleFitnessTheme.textTertiary,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                    Text(
                      '${_contentController.text.length}/1000',
                      style: AppleFitnessTheme.bodySmall.copyWith(
                        color: AppleFitnessTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: AppleFitnessTheme.spacingL),
            
            // Images section
            FadeIn3D(
              delay: const Duration(milliseconds: 200),
              child: _buildImagesSection(),
            ),
            
            SizedBox(height: AppleFitnessTheme.spacingL),
            
            // Tags section
            FadeIn3D(
              delay: const Duration(milliseconds: 300),
              child: _buildTagsSection(),
            ),
            
            SizedBox(height: AppleFitnessTheme.spacingL),
            
            // Options section
            FadeIn3D(
              delay: const Duration(milliseconds: 400),
              child: _buildOptionsSection(),
            ),
            
            SizedBox(height: AppleFitnessTheme.spacingXXL),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.image,
              color: AppleFitnessTheme.textSecondary,
              size: 20,
            ),
            SizedBox(width: AppleFitnessTheme.spacingS),
            Text(
              '添加图片',
              style: AppleFitnessTheme.titleMedium,
            ),
            const Spacer(),
            Text(
              '${_selectedImages.length}/9',
              style: AppleFitnessTheme.bodySmall.copyWith(
                color: AppleFitnessTheme.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppleFitnessTheme.spacingM),
        Card3D(
          useFrostedGlass: true,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _selectedImages.length + 1,
            itemBuilder: (context, index) {
              if (index == _selectedImages.length) {
                return _buildAddImageButton();
              }
              return _buildImageItem(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        decoration: BoxDecoration(
          color: AppleFitnessTheme.backgroundSecondary,
          borderRadius: AppleFitnessTheme.radiusMedium,
          border: Border.all(
            color: AppleFitnessTheme.textTertiary.withValues(alpha: 0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Icon(
          Icons.add_photo_alternate,
          color: AppleFitnessTheme.textTertiary,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildImageItem(int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: AppleFitnessTheme.radiusMedium,
            image: DecorationImage(
              image: FileImage(File(_selectedImages[index].path)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.tag,
              color: AppleFitnessTheme.textSecondary,
              size: 20,
            ),
            SizedBox(width: AppleFitnessTheme.spacingS),
            Text(
              '添加标签',
              style: AppleFitnessTheme.titleMedium,
            ),
            const Spacer(),
            Text(
              '${_selectedTags.length}/5',
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
          children: _availableTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return GestureDetector(
              onTap: () => _toggleTag(tag),
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
                  tag,
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
    );
  }

  Widget _buildOptionsSection() {
    return Card3D(
      useFrostedGlass: true,
      child: Column(
        children: [
          _buildOptionRow(
            icon: Icons.location_on,
            title: '添加位置',
            value: _isLocationEnabled,
            onChanged: (value) {
              setState(() => _isLocationEnabled = value);
            },
          ),
          Divider(
            height: AppleFitnessTheme.spacingL,
            color: AppleFitnessTheme.textTertiary.withValues(alpha: 0.1),
          ),
          _buildOptionRow(
            icon: Icons.public,
            title: '公开可见',
            subtitle: _isPublic ? '所有人可见' : '仅好友可见',
            value: _isPublic,
            onChanged: (value) {
              setState(() => _isPublic = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionRow({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppleFitnessTheme.spacingS),
          decoration: BoxDecoration(
            gradient: AppleFitnessTheme.primaryGradient,
            borderRadius: AppleFitnessTheme.radiusSmall,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        SizedBox(width: AppleFitnessTheme.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppleFitnessTheme.bodyMedium,
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: AppleFitnessTheme.bodySmall.copyWith(
                    color: AppleFitnessTheme.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppleFitnessTheme.primaryBlue,
        ),
      ],
    );
  }
}

