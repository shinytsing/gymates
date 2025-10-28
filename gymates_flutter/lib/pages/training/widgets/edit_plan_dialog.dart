import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../training_detail_page.dart';
import '../subpages/edit_plan_page.dart';
import '../../../shared/models/mock_data.dart';

class EditPlanDialog extends StatefulWidget {
	const EditPlanDialog({super.key});

	@override
	State<EditPlanDialog> createState() => _EditPlanDialogState();
}

class _EditPlanDialogState extends State<EditPlanDialog> {
	int _sets = 3;
	int _reps = 10;
	final List<String> _selectedMuscles = [];

	@override
	Widget build(BuildContext context) {
		return Dialog(
			shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
			child: Padding(
				padding: const EdgeInsets.all(16),
				child: SingleChildScrollView(
					child: Column(
						mainAxisSize: MainAxisSize.min,
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							const Text('编辑训练计划', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
							const SizedBox(height: 12),
							Wrap(spacing: 8, children: ['胸部','背部','腿部','肩部','手臂','核心'].map((m) => FilterChip(label: Text(m), selected: _selectedMuscles.contains(m), onSelected: (v){setState((){v ? _selectedMuscles.add(m) : _selectedMuscles.remove(m);});})).toList()),
							const SizedBox(height: 12),
							Row(children: [
								Expanded(child: _numberField('组数', _sets, (v)=> setState(()=> _sets = v))),
								const SizedBox(width: 12),
								Expanded(child: _numberField('次数', _reps, (v)=> setState(()=> _reps = v))),
							]),
							const SizedBox(height: 12),
							Row(children: [
								Expanded(child: OutlinedButton.icon(onPressed: _openEditPlanPage, icon: const Icon(Icons.edit), label: const Text('详细编辑'))),
								const SizedBox(width: 12),
								Expanded(child: ElevatedButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('保存'))),
							]),
						],
					),
				),
			),
		);
	}

	Widget _numberField(String label, int value, ValueChanged<int> onChanged) {
		return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
			Text(label),
			const SizedBox(height: 8),
			Container(
				padding: const EdgeInsets.symmetric(horizontal: 12),
				decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(12)),
				child: Row(children: [
					IconButton(icon: const Icon(Icons.remove), onPressed: ()=> onChanged((value - 1).clamp(1, 99))),
					Expanded(child: Center(child: Text('$value', style: const TextStyle(fontWeight: FontWeight.w600)))),
					IconButton(icon: const Icon(Icons.add), onPressed: ()=> onChanged((value + 1).clamp(1, 99))),
				]),
			),
		]);
	}

	void _openEditPlanPage() {
		HapticFeedback.lightImpact();
		Navigator.pop(context); // 关闭对话框
		Navigator.push(
			context,
			MaterialPageRoute(
				builder: (context) => EditPlanPage(
					onPlanSaved: (plan) {
						// 计划保存后的回调
						ScaffoldMessenger.of(context).showSnackBar(
							const SnackBar(
								content: Text('训练计划已保存'),
								backgroundColor: Color(0xFF10B981),
							),
						);
					},
				),
			),
		);
	}

	void _applyAIRecommendation() {
		setState(() {
			_sets = 4;
			_reps = 12;
			if (_selectedMuscles.isEmpty) _selectedMuscles.addAll(['胸部','背部','腿部']);
		});
	}

	void _save() {
		final mock = MockTrainingPlan(
			id: DateTime.now().millisecondsSinceEpoch.toString(),
			title: '自定义计划',
			description: '根据你的偏好生成',
			duration: '30分钟',
			difficulty: 'intermediate',
			calories: 300,
			exercises: const ['热身','主练','拉伸'],
			image: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
			isCompleted: false,
			progress: 0,
			trainingMode: '自定义',
			targetMuscles: _selectedMuscles,
			exerciseDetails: const [],
			suitableFor: '中级',
			weeklyFrequency: 3,
			createdAt: DateTime.now(),
			lastCompleted: null,
		);
		Navigator.pop(context);
		Navigator.push(context, MaterialPageRoute(builder: (_) => TrainingDetailPage(trainingPlan: mock)));
	}
}


