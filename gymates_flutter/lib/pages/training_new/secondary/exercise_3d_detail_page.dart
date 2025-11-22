import 'package:flutter/material.dart';
import '../../../core/3d_components/index.dart';
import '../../../models/exercise_library.dart';

/// 🏋️ Apple Fitness+ Style Exercise Detail Page
/// 
/// Design Features:
/// - 3D hero header (collapsible)
/// - 3D info cards (parameters, description)
/// - 3D muscle group visualization
/// - 3D action buttons

class Exercise3DDetailPage extends StatelessWidget {
  final ExerciseLibrary exercise;

  const Exercise3DDetailPage({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppleFitnessTheme.backgroundPrimary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppleFitnessTheme.backgroundGradient,
        ),
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    SizedBox(height: AppleFitnessTheme.spacingL),
                    _buildParametersCard(),
                    SizedBox(height: AppleFitnessTheme.spacingL),
                    _buildDescriptionCard(),
                    if (exercise.instructions.isNotEmpty) ...[
                      SizedBox(height: AppleFitnessTheme.spacingL),
                      _buildInstructionsCard(),
                    ],
                    SizedBox(height: AppleFitnessTheme.spacingL),
                    _buildMuscleGroupsCard(),
                    SizedBox(height: AppleFitnessTheme.spacingL),
                    _buildActionButtons(context),
                    SizedBox(height: AppleFitnessTheme.spacingXXL),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: AppleFitnessTheme.primaryGradient,
          ),
          child: Center(
            child: Icon(
              Icons.play_circle_outline,
              size: 100,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeIn3D(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise.name,
            style: AppleFitnessTheme.displaySmall,
          ),
          SizedBox(height: AppleFitnessTheme.spacingM),
          Wrap(
            spacing: AppleFitnessTheme.spacingS,
            runSpacing: AppleFitnessTheme.spacingS,
            children: [
              _buildTag(exercise.part),
              _buildTag(exercise.levelText),
              if (exercise.equipment.isNotEmpty)
                _buildTag(exercise.equipment),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppleFitnessTheme.spacingM,
        vertical: AppleFitnessTheme.spacingS,
      ),
      decoration: BoxDecoration(
        gradient: AppleFitnessTheme.primaryGradient,
        borderRadius: AppleFitnessTheme.radiusSmall,
      ),
      child: Text(
        label,
        style: AppleFitnessTheme.labelMedium.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildParametersCard() {
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
                  Icons.info_outline,
                  color: AppleFitnessTheme.primaryBlue,
                  size: 20,
                ),
                SizedBox(width: AppleFitnessTheme.spacingS),
                Text(
                  '推荐参数',
                  style: AppleFitnessTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: AppleFitnessTheme.spacingL),
            _buildParameterRow(
              icon: Icons.timer,
              label: '预计时长',
              value: '${exercise.estimatedDuration}秒',
            ),
            SizedBox(height: AppleFitnessTheme.spacingM),
            _buildParameterRow(
              icon: Icons.local_fire_department,
              label: '预计消耗',
              value: '${exercise.estimatedCalories}卡路里',
            ),
            if (exercise.equipment.isNotEmpty) ...[
              SizedBox(height: AppleFitnessTheme.spacingM),
              _buildParameterRow(
                icon: Icons.fitness_center,
                label: '器械',
                value: exercise.equipment,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildParameterRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppleFitnessTheme.primaryBlue, size: 20),
        SizedBox(width: AppleFitnessTheme.spacingM),
        Expanded(
          child: Text(
            label,
            style: AppleFitnessTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: AppleFitnessTheme.labelLarge.copyWith(
            color: AppleFitnessTheme.primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard() {
    if (exercise.description.isEmpty) {
      return const SizedBox.shrink();
    }

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
                  Icons.description,
                  color: AppleFitnessTheme.primaryBlue,
                  size: 20,
                ),
                SizedBox(width: AppleFitnessTheme.spacingS),
                Text(
                  '动作描述',
                  style: AppleFitnessTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: AppleFitnessTheme.spacingL),
            Text(
              exercise.description,
              style: AppleFitnessTheme.bodyMedium.copyWith(
                color: AppleFitnessTheme.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMuscleGroupsCard() {
    return FadeIn3D(
      delay: const Duration(milliseconds: 300),
      child: Card3D(
        useFrostedGlass: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.accessibility_new,
                  color: AppleFitnessTheme.primaryBlue,
                  size: 20,
                ),
                SizedBox(width: AppleFitnessTheme.spacingS),
                Text(
                  '目标肌群',
                  style: AppleFitnessTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: AppleFitnessTheme.spacingL),
            Wrap(
              spacing: AppleFitnessTheme.spacingS,
              runSpacing: AppleFitnessTheme.spacingS,
              children: [
                _buildMuscleTag(exercise.part, true),
                if (exercise.muscleGroups.isNotEmpty)
                  ...exercise.muscleGroups.split(',').map(
                    (muscle) => _buildMuscleTag(muscle.trim(), false),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMuscleTag(String muscle, bool isPrimary) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppleFitnessTheme.spacingM,
        vertical: AppleFitnessTheme.spacingS,
      ),
      decoration: BoxDecoration(
        gradient: isPrimary
            ? AppleFitnessTheme.primaryGradient
            : null,
        color: isPrimary
            ? null
            : AppleFitnessTheme.backgroundSecondary,
        borderRadius: AppleFitnessTheme.radiusSmall,
      ),
      child: Text(
        muscle,
        style: AppleFitnessTheme.labelMedium.copyWith(
          color: isPrimary ? Colors.white : AppleFitnessTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return FadeIn3D(
      delay: const Duration(milliseconds: 300),
      child: Card3D(
        useFrostedGlass: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.list_alt,
                  color: AppleFitnessTheme.primaryBlue,
                  size: 20,
                ),
                SizedBox(width: AppleFitnessTheme.spacingS),
                Text(
                  '动作步骤',
                  style: AppleFitnessTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: AppleFitnessTheme.spacingL),
            ...exercise.instructions.asMap().entries.map((entry) {
              return Padding(
                padding: EdgeInsets.only(bottom: AppleFitnessTheme.spacingM),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: AppleFitnessTheme.primaryGradient,
                        borderRadius: AppleFitnessTheme.radiusSmall,
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: AppleFitnessTheme.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppleFitnessTheme.spacingM),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: AppleFitnessTheme.bodyMedium.copyWith(
                          color: AppleFitnessTheme.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return FadeIn3D(
      delay: const Duration(milliseconds: 400),
      child: Column(
        children: [
          Button3D.primary(
            text: '开始训练',
            icon: Icons.play_arrow,
            size: Button3DSize.large,
            onPressed: () {
              // TODO: Navigate to workout
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('开始训练功能开发中'),
                  backgroundColor: AppleFitnessTheme.primaryBlue,
                ),
              );
            },
          ),
          SizedBox(height: AppleFitnessTheme.spacingM),
          Button3D.outline(
            text: '添加到计划',
            icon: Icons.add,
            onPressed: () {
              // TODO: Add to plan
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('已添加到训练计划'),
                  backgroundColor: AppleFitnessTheme.success,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

