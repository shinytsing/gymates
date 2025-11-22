import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 📜 3D List Component - Various 3D list layouts
/// 
/// Features:
/// - CoverFlow style 3D list
/// - Staggered 3D grid
/// - Perspective scroll list
/// - 3D carousel
/// - Parallax scroll effect
/// - Animated list items

/// 🎪 CoverFlow 3D List - Cards with perspective rotation
class CoverFlowList3D extends StatefulWidget {
  final List<Widget> items;
  final double itemHeight;
  final double itemWidth;
  final ValueChanged<int>? onItemTap;
  final int initialIndex;
  
  const CoverFlowList3D({
    super.key,
    required this.items,
    this.itemHeight = 300,
    this.itemWidth = 250,
    this.onItemTap,
    this.initialIndex = 0,
  });

  @override
  State<CoverFlowList3D> createState() => _CoverFlowList3DState();
}

class _CoverFlowList3DState extends State<CoverFlowList3D> {
  late PageController _pageController;
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex.toDouble();
    _pageController = PageController(
      initialPage: widget.initialIndex,
      viewportFraction: 0.7,
    );
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.itemHeight,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          return _buildItem(index);
        },
      ),
    );
  }

  Widget _buildItem(int index) {
    final diff = (index - _currentPage).abs();
    final scale = 1 - (diff * 0.2).clamp(0, 0.3);
    final opacity = (1 - (diff * 0.3).clamp(0, 0.7)).toDouble();
    final rotateY = (index - _currentPage) * 0.3;

    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        widget.onItemTap?.call(index);
      },
      child: Center(
        child: Opacity(
          opacity: opacity,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(rotateY)
              ..scale(scale),
            child: SizedBox(
              width: widget.itemWidth,
              height: widget.itemHeight * 0.9,
              child: widget.items[index],
            ),
          ),
        ),
      ),
    );
  }
}

/// 🎯 Perspective List 3D - List with depth perspective
class PerspectiveList3D extends StatefulWidget {
  final List<Widget> items;
  final double itemHeight;
  final ScrollPhysics? physics;
  final EdgeInsets? padding;
  
  const PerspectiveList3D({
    super.key,
    required this.items,
    this.itemHeight = 120,
    this.physics,
    this.padding,
  });

  @override
  State<PerspectiveList3D> createState() => _PerspectiveList3DState();
}

class _PerspectiveList3DState extends State<PerspectiveList3D> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      physics: widget.physics,
      padding: widget.padding,
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        return _buildItem(index);
      },
    );
  }

  Widget _buildItem(int index) {
    final itemOffset = (index * widget.itemHeight) - _scrollOffset;
    final screenCenter = MediaQuery.of(context).size.height / 2;
    final distanceFromCenter = (itemOffset - screenCenter).abs();
    final normalizedDistance = (distanceFromCenter / screenCenter).clamp(0.0, 1.0);
    
    final scale = 1 - (normalizedDistance * 0.2);
    final rotateX = (itemOffset - screenCenter) / screenCenter * 0.15;
    final translateZ = -normalizedDistance * 50;

    return Container(
      height: widget.itemHeight,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(rotateX)
          ..translate(0.0, 0.0, translateZ)
          ..scale(scale),
        child: widget.items[index],
      ),
    );
  }
}

/// 🎠 Carousel 3D - Circular 3D carousel
class Carousel3D extends StatefulWidget {
  final List<Widget> items;
  final double itemHeight;
  final double itemWidth;
  final double radius;
  final ValueChanged<int>? onItemChange;
  
  const Carousel3D({
    super.key,
    required this.items,
    this.itemHeight = 200,
    this.itemWidth = 150,
    this.radius = 300,
    this.onItemChange,
  });

  @override
  State<Carousel3D> createState() => _Carousel3DState();
}

class _Carousel3DState extends State<Carousel3D> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 2 * math.pi).animate(_controller);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _rotateToIndex(int index) {
    setState(() => _currentIndex = index);
    widget.onItemChange?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.itemHeight * 1.5,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: List.generate(widget.items.length, (index) {
              final angle = (2 * math.pi / widget.items.length) * index + _animation.value;
              final x = math.cos(angle) * widget.radius;
              final z = math.sin(angle) * widget.radius;
              final scale = (z + widget.radius) / (widget.radius * 2);
              
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..translate(x, 0.0, z)
                  ..scale(scale),
                child: GestureDetector(
                  onTap: () => _rotateToIndex(index),
                  child: Opacity(
                    opacity: scale,
                    child: SizedBox(
                      width: widget.itemWidth,
                      height: widget.itemHeight,
                      child: widget.items[index],
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

/// 📊 Staggered Grid 3D - Grid with 3D depth
class StaggeredGrid3D extends StatelessWidget {
  final List<Widget> items;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsets? padding;
  
  const StaggeredGrid3D({
    super.key,
    required this.items,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 16,
    this.crossAxisSpacing = 16,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final row = index ~/ crossAxisCount;
        final col = index % crossAxisCount;
        final rotateY = (col - 0.5) * 0.1;
        final rotateX = (row % 2 == 0) ? -0.05 : 0.05;
        
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 50)),
          tween: Tween(begin: 0, end: 1),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(rotateX * (1 - value))
                ..rotateY(rotateY * (1 - value))
                ..translate(0.0, 50 * (1 - value), 0.0)
                ..scale(value),
              child: Opacity(
                opacity: value,
                child: items[index],
              ),
            );
          },
        );
      },
    );
  }
}

/// 🌊 Parallax List 3D - List with parallax scrolling effect
class ParallaxList3D extends StatefulWidget {
  final List<Widget> items;
  final List<Widget>? backgrounds;
  final double itemHeight;
  final double parallaxFactor;
  
  const ParallaxList3D({
    super.key,
    required this.items,
    this.backgrounds,
    this.itemHeight = 200,
    this.parallaxFactor = 0.5,
  });

  @override
  State<ParallaxList3D> createState() => _ParallaxList3DState();
}

class _ParallaxList3DState extends State<ParallaxList3D> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background layer with parallax
        if (widget.backgrounds != null)
          Positioned.fill(
            child: Transform.translate(
              offset: Offset(0, -_scrollOffset * widget.parallaxFactor),
              child: Column(
                children: widget.backgrounds!,
              ),
            ),
          ),
        // Foreground list
        ListView.builder(
          controller: _scrollController,
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            return Container(
              height: widget.itemHeight,
              margin: const EdgeInsets.all(16),
              child: widget.items[index],
            );
          },
        ),
      ],
    );
  }
}

/// ✨ Animated List Item 3D - List item with entry animation
class AnimatedListItem3D extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;
  
  const AnimatedListItem3D({
    super.key,
    required this.child,
    required this.index,
    this.delay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<AnimatedListItem3D> createState() => _AnimatedListItem3DState();
}

class _AnimatedListItem3DState extends State<AnimatedListItem3D> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    
    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    _rotateAnimation = Tween<double>(begin: -0.1, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    Future.delayed(widget.delay * widget.index, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_rotateAnimation.value)
            ..translate(0.0, _slideAnimation.value, 0.0)
            ..scale(_scaleAnimation.value),
          child: Opacity(
            opacity: _controller.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

