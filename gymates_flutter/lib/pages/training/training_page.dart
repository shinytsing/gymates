import 'package:flutter/material.dart';
import '../../pages/training_new/training_main_page.dart';

/// 🏋️‍♀️ Training Page - Main training page wrapper
/// 
/// This is the main training page that provides access to all training features
/// Contains two main tabs: Today Training and History
class TrainingPage extends StatelessWidget {
  const TrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TrainingMainPage();
  }
}

