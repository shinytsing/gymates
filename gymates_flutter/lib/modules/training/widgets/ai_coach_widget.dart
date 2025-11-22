import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../subpages/ai_coach_page.dart';
import '../subpages/training_summary_page.dart';
import '../subpages/checkin_share_page.dart';
import '../subpages/history_detail_page.dart';
import '../controllers/plan_controller.dart';
import '../models/session_result.dart';

class AICoachWidget extends StatelessWidget {
	const AICoachWidget({super.key});

	@override
	Widget build(BuildContext context) {
		return Consumer<PlanController>(
			builder: (context, planController, child) {
				return Align(
					alignment: Alignment.bottomRight,
					child: FloatingActionButton.extended(
						icon: const Icon(Icons.smart_toy),
						label: const Text('开始训练'),
						onPressed: () {
							HapticFeedback.lightImpact();
							_startAITraining(context, planController);
						},
					),
				);
			},
		);
	}

	void _startAITraining(BuildContext context, PlanController planController) {
		final todayPlan = planController.todayPlan;
		
		// Navigate to AI Coach page
		Navigator.push(
			context,
			MaterialPageRoute(
				builder: (_) => AICoachPage(
					workoutPlan: todayPlan,
					onTrainingComplete: (result) {
						// Navigate to training summary
						_handleTrainingComplete(context, result);
					},
				),
			),
		);
	}

	void _handleTrainingComplete(BuildContext context, TrainingSessionResult result) {
		// 显示训练总结页
		Navigator.push(
			context,
			MaterialPageRoute(
				builder: (_) => TrainingSummaryPage(
					record: result.toWorkoutRecord(
						planId: result.sessionId,
						planTitle: 'AI教练训练',
					),
					completedSets: result.completedSets,
					onCheckIn: () {
						// 打卡回调
						Navigator.pop(context);
						Navigator.push(
							context,
							MaterialPageRoute(
								builder: (_) => CheckInSharePage(
									record: result.toWorkoutRecord(
										planId: result.sessionId,
										planTitle: 'AI教练训练',
									),
									onShareComplete: () {
										Navigator.pop(context);
									},
								),
							),
						);
					},
					onViewReport: () {
						// 查看报告回调
						Navigator.pop(context);
						Navigator.push(
							context,
							MaterialPageRoute(
								builder: (_) => HistoryDetailPage(
									record: result.toWorkoutRecord(
										planId: result.sessionId,
										planTitle: 'AI教练训练',
									),
								),
							),
						);
					},
					onShare: () {
						// 分享回调
						Navigator.pop(context);
						Navigator.push(
							context,
							MaterialPageRoute(
								builder: (_) => CheckInSharePage(
									record: result.toWorkoutRecord(
										planId: result.sessionId,
										planTitle: 'AI教练训练',
									),
									onShareComplete: () {
										Navigator.pop(context);
									},
								),
							),
						);
					},
				),
			),
		);
	}
}


