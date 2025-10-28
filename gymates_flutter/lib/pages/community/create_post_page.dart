import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/gymates_theme.dart';

/// 📝 创建帖子页面 - 完全按照 Figma 设计实现
/// 
/// 设计规范：
/// - 简洁的帖子创建界面
/// - 支持文字、图片、视频
/// - 话题标签选择
/// - 位置分享
/// - 隐私设置

class CreatePostPage extends StatefulWidget {
  final String postType;
  final VoidCallback? onBack;
  final Function(Map<String, dynamic>)? onPublish;

  const CreatePostPage({
    super.key,
    required this.postType,
    this.onBack,
    this.onPublish,
  });

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage>
    with TickerProviderStateMixin {
  late AnimationController _formController;
  late Animation<double> _formAnimation;

  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _titleController = TextEditingController();

  final List<String> _selectedTags = [];
  final List<String> _selectedImages = [];
  bool _isLocationEnabled = false;
  bool _isPublic = true;
  bool _isLoading = false;

  final List<String> _availableTags = [
    '#减脂', '#增肌', '#瑜伽', '#跑步', '#力量训练',
    '#有氧', '#HIIT', '#普拉提', '#游泳', '#骑行',
    '#健身心得', '#饮食分享', '#训练计划', '#成果展示'
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _formController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _formAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _formController.forward();
  }

  @override
  void dispose() {
    _formController.dispose();
    _contentController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymatesTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: GymatesTheme.lightTextPrimary,
          ),
          onPressed: () {
            widget.onBack?.call();
            Navigator.pop(context);
          },
        ),
        title: Text(
          '创建${widget.postType}',
          style: TextStyle(
            color: GymatesTheme.lightTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handlePublish,
            child: Text(
              '发布',
              style: TextStyle(
                color: _isLoading 
                    ? GymatesTheme.lightTextSecondary
                    : GymatesTheme.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _formAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 30 * (1 - _formAnimation.value)),
            child: Opacity(
              opacity: _formAnimation.value,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题输入
                      _buildTitleField(),
                      
                      const SizedBox(height: 16),
                      
                      // 内容输入
                      _buildContentField(),
                      
                      const SizedBox(height: 16),
                      
                      // 图片上传
                      _buildImageUpload(),
                      
                      const SizedBox(height: 16),
                      
                      // 话题标签
                      _buildTopicTags(),
                      
                      const SizedBox(height: 16),
                      
                      // 位置分享
                      _buildLocationToggle(),
                      
                      const SizedBox(height: 16),
                      
                      // 隐私设置
                      _buildPrivacySettings(),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '标题',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: GymatesTheme.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: '给你的帖子起个吸引人的标题',
            hintStyle: TextStyle(
              color: GymatesTheme.lightTextSecondary,
              fontSize: 16,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: GymatesTheme.borderColor,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: GymatesTheme.borderColor,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: GymatesTheme.primaryColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '内容',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: GymatesTheme.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _contentController,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: '分享你的健身心得、训练计划或成果...',
            hintStyle: TextStyle(
              color: GymatesTheme.lightTextSecondary,
              fontSize: 16,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: GymatesTheme.borderColor,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: GymatesTheme.borderColor,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: GymatesTheme.primaryColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '图片',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: GymatesTheme.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        
        // 已选择的图片
        if (_selectedImages.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: GymatesTheme.borderColor,
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _selectedImages[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: GymatesTheme.lightBackground,
                          child: const Icon(
                            Icons.image,
                            color: GymatesTheme.lightTextSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        
        const SizedBox(height: 8),
        
        // 添加图片按钮
        GestureDetector(
          onTap: _addImage,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: GymatesTheme.borderColor,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate,
                  color: GymatesTheme.lightTextSecondary,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  '添加图片',
                  style: TextStyle(
                    fontSize: 12,
                    color: GymatesTheme.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopicTags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '话题标签',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: GymatesTheme.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        
        // 已选择的标签
        if (_selectedTags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedTags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: GymatesTheme.primaryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTags.remove(tag);
                        });
                      },
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        
        const SizedBox(height: 8),
        
        // 可选标签
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedTags.remove(tag);
                  } else {
                    _selectedTags.add(tag);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? GymatesTheme.primaryColor.withValues(alpha: 0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected 
                        ? GymatesTheme.primaryColor
                        : GymatesTheme.borderColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected 
                        ? GymatesTheme.primaryColor
                        : GymatesTheme.lightTextSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationToggle() {
    return Row(
      children: [
        Switch(
          value: _isLocationEnabled,
          onChanged: (value) {
            setState(() {
              _isLocationEnabled = value;
            });
          },
          activeThumbColor: GymatesTheme.primaryColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '分享位置',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: GymatesTheme.lightTextPrimary,
                ),
              ),
              Text(
                '让附近的健身伙伴知道你在哪里',
                style: TextStyle(
                  fontSize: 12,
                  color: GymatesTheme.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacySettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '隐私设置',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: GymatesTheme.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        
        Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: _isPublic,
              onChanged: (value) {
                setState(() {
                  _isPublic = value!;
                });
              },
              activeColor: GymatesTheme.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              '公开',
              style: TextStyle(
                fontSize: 14,
                color: GymatesTheme.lightTextPrimary,
              ),
            ),
            const SizedBox(width: 24),
            Radio<bool>(
              value: false,
              groupValue: _isPublic,
              onChanged: (value) {
                setState(() {
                  _isPublic = value!;
                });
              },
              activeColor: GymatesTheme.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              '仅关注者',
              style: TextStyle(
                fontSize: 14,
                color: GymatesTheme.lightTextPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _addImage() {
    HapticFeedback.lightImpact();
    // TODO: 实现图片选择逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('图片选择功能待实现'),
        backgroundColor: GymatesTheme.primaryColor,
      ),
    );
  }

  void _handlePublish() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入帖子内容'),
          backgroundColor: GymatesTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    HapticFeedback.lightImpact();

    // TODO: 实现发布逻辑
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    final postData = {
      'title': _titleController.text,
      'content': _contentController.text,
      'images': _selectedImages,
      'tags': _selectedTags,
      'isLocationEnabled': _isLocationEnabled,
      'isPublic': _isPublic,
      'type': widget.postType,
    };

    widget.onPublish?.call(postData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('发布成功'),
        backgroundColor: GymatesTheme.successColor,
      ),
    );

    Navigator.pop(context);
  }
}
