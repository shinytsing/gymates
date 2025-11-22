import 'package:flutter/material.dart';
import '../../../services/training_session_service.dart';

class WorkoutHistoryWidget extends StatefulWidget {
    const WorkoutHistoryWidget({super.key});

    @override
    State<WorkoutHistoryWidget> createState() => _WorkoutHistoryWidgetState();
}

class _WorkoutHistoryWidgetState extends State<WorkoutHistoryWidget> {
    String _selectedFilter = '全部';
    DateTimeRange? _dateRange;

    @override
    Widget build(BuildContext context) {
        return FutureBuilder(
            future: TrainingSessionService.getTrainingHistory(),
            builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                }
                var records = snapshot.data ?? [];

                // 日期过滤
                if (_dateRange != null) {
                    records = records.where((r) => r.completedAt.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) && r.completedAt.isBefore(_dateRange!.end.add(const Duration(days: 1)))).toList();
                }

                // 简单的肌群过滤占位（用标题包含演示）
                if (_selectedFilter != '全部') {
                    records = records.where((r) => r.planTitle.contains(_selectedFilter)).toList();
                }

                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Row(
                            children: [
                                Expanded(child: _FilterDropdown(value: _selectedFilter, onChanged: (v) => setState(() => _selectedFilter = v))),
                                const SizedBox(width: 12),
                                OutlinedButton.icon(
                                    onPressed: _pickDateRange,
                                    icon: const Icon(Icons.date_range),
                                    label: Text(_dateRange == null ? '选择日期' : '${_dateRange!.start.month}/${_dateRange!.start.day} - ${_dateRange!.end.month}/${_dateRange!.end.day}'),
                                ),
                            ],
                        ),
                        const SizedBox(height: 12),
                        ...records.map((r) => _RecordTile(record: r)),
                    ],
                );
            },
        );
    }

    Future<void> _pickDateRange() async {
        final now = DateTime.now();
        final lastMonth = now.subtract(const Duration(days: 30));
        final range = await showDateRangePicker(
            context: context,
            firstDate: lastMonth.subtract(const Duration(days: 365)),
            lastDate: now,
            initialDateRange: DateTimeRange(start: lastMonth, end: now),
        );
        if (range != null) {
            setState(() => _dateRange = range);
        }
    }
}

class _RecordTile extends StatelessWidget {
	final TrainingHistoryRecord record;
	const _RecordTile({required this.record});

	@override
	Widget build(BuildContext context) {
		return Container(
			margin: const EdgeInsets.only(bottom: 12),
			padding: const EdgeInsets.all(12),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(12),
				border: Border.all(color: const Color(0xFFE5E7EB)),
			),
			child: Row(
				children: [
					Container(
						width: 36,
						height: 36,
						decoration: BoxDecoration(color: const Color(0xFF6366F1).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
						child: const Icon(Icons.fitness_center, color: Color(0xFF6366F1)),
					),
					const SizedBox(width: 12),
					Expanded(
						child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
							Text(record.planTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
							const SizedBox(height: 4),
							Text('${record.durationMinutes}分钟 · ${record.totalCalories}千卡 · ${record.completedExercises}/${record.totalExercises}', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
						]),
					),
					Text('${record.completionPercentage}%'),
				],
			),
		);
	}
}

class _FilterDropdown extends StatelessWidget {
    final String value;
    final ValueChanged<String> onChanged;
    const _FilterDropdown({required this.value, required this.onChanged});

    @override
    Widget build(BuildContext context) {
        const options = ['全部','胸部','背部','腿部','肩部','手臂','核心'];
        return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                    value: value,
                    items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) { if (v != null) onChanged(v); },
                ),
            ),
        );
    }
}


