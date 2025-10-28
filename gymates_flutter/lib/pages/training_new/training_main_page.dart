import 'package:flutter/material.dart';
import 'today_training_page.dart';
import 'history_training_page.dart';

/// 🏋️‍♂️ 训练模块主页面
/// 包含两个主 Tab：今日训练（Today）和历史记录（History）
class TrainingMainPage extends StatefulWidget {
  const TrainingMainPage({super.key});

  @override
  State<TrainingMainPage> createState() => _TrainingMainPageState();
}

class _TrainingMainPageState extends State<TrainingMainPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          '训练',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF6366F1),
          unselectedLabelColor: const Color(0xFF9CA3AF),
          indicatorColor: const Color(0xFF6366F1),
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.today),
              text: '今日训练',
            ),
            Tab(
              icon: Icon(Icons.history),
              text: '历史记录',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TodayTrainingPage(),
          HistoryTrainingPage(),
        ],
      ),
    );
  }
}

