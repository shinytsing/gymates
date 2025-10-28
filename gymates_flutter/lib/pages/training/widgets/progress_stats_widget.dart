import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressStatsWidget extends StatelessWidget {
	const ProgressStatsWidget({super.key});

	@override
	Widget build(BuildContext context) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Container(
					padding: const EdgeInsets.all(16),
					decoration: BoxDecoration(
						color: Colors.white,
						borderRadius: BorderRadius.circular(12),
						border: Border.all(color: const Color(0xFFE5E7EB)),
					),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							const Text('近7日训练趋势', style: TextStyle(fontWeight: FontWeight.w700)),
							const SizedBox(height: 12),
							SizedBox(
								height: 180,
								child: LineChart(
					LineChartData(
						gridData: const FlGridData(show: false),
						titlesData: FlTitlesData(
							leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
							rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
							bottomTitles: AxisTitles(
								sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta) {
									const labels = ['一','二','三','四','五','六','日'];
									final idx = v.toInt();
									return Padding(
										padding: const EdgeInsets.only(top: 6),
										child: Text(idx >=0 && idx < labels.length ? labels[idx] : '' , style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
									);
								}),
							),
						),
						minY: 0,
										lineBarsData: [
											LineChartBarData(
												isCurved: true,
												color: const Color(0xFF6366F1),
												barWidth: 3,
												dotData: const FlDotData(show: false),
												belowBarData: BarAreaData(show: true, color: const Color(0xFF6366F1).withValues(alpha: 0.15)),
												spots: const [
													FlSpot(0, 2),
													FlSpot(1, 3),
													FlSpot(2, 1.5),
													FlSpot(3, 4),
													FlSpot(4, 3.5),
													FlSpot(5, 2.5),
													FlSpot(6, 5),
												],
											),
										],
									),
								),
							),
						],
					),
				),
			],
		);
	}
}


