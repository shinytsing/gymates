import 'package:flutter/material.dart';
import '../theme/cartoon_3d_theme.dart';
import '../../shared/widgets/cartoon_3d_widgets.dart';
import '../../pages/cartoon_3d_home_page.dart';
import '../../modules/training/main_page_3d.dart';
import '../../modules/community/main_page_3d.dart';
import '../../modules/mates/main_page_3d.dart';
import '../../modules/messages/main_page_3d.dart';
import '../../modules/profile/main_page_3d.dart';

/// 🎨 3D卡通风格主导航
/// 统一使用3D卡通视觉风格
class Cartoon3DMainNavigation extends StatefulWidget {
  const Cartoon3DMainNavigation({super.key});

  @override
  State<Cartoon3DMainNavigation> createState() => _Cartoon3DMainNavigationState();
}

class _Cartoon3DMainNavigationState extends State<Cartoon3DMainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    Cartoon3DHomePage(),        // 首页
    TrainingMainPage3D(),           // 训练 (已改造)
    CommunityMainPage3D(),          // 社区 (已改造)
    MatesMainPage3D(),              // 搭子 (已改造)
    MessagesMainPage3D(),           // 消息 (已改造)
    ProfileMainPage3D(),            // 个人 (已改造)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Cartoon3DBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          Cartoon3DBottomNavItem(
            icon: Icons.home_rounded,
            label: '首页',
            gradient: Cartoon3DTheme.primary3DGradient,
          ),
          Cartoon3DBottomNavItem(
            icon: Icons.fitness_center_rounded,
            label: '训练',
            gradient: Cartoon3DTheme.purple3DGradient,
          ),
          Cartoon3DBottomNavItem(
            icon: Icons.people_rounded,
            label: '社区',
            gradient: Cartoon3DTheme.teal3DGradient,
          ),
          Cartoon3DBottomNavItem(
            icon: Icons.people_alt_rounded,
            label: '搭子',
            gradient: LinearGradient(
              colors: [
                Cartoon3DTheme.energyOrange,
                Cartoon3DTheme.sunnyYellow,
              ],
            ),
          ),
          Cartoon3DBottomNavItem(
            icon: Icons.message_rounded,
            label: '消息',
            gradient: LinearGradient(
              colors: [
                Cartoon3DTheme.softPink,
                Cartoon3DTheme.lavender,
              ],
            ),
          ),
          Cartoon3DBottomNavItem(
            icon: Icons.person_rounded,
            label: '我的',
            gradient: Cartoon3DTheme.rainbow3DGradient,
          ),
        ],
      ),
    );
  }
}

