import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';

class GoalData {
  final String category; // "Total Goals" or "Completed Goals"
  final int count; // Number of goals

  GoalData(this.category, this.count);
}

class GoalsBarChart extends StatelessWidget {
  final List<GoalData> data;

  const GoalsBarChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16.0),
      child: SfCartesianChart(
        title: ChartTitle(text: 'Goals Overview'),
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(),
        series: <ChartSeries<GoalData, String>>[
          ColumnSeries<GoalData, String>(
            dataSource: data,
            xValueMapper: (GoalData goal, _) => goal.category,
            yValueMapper: (GoalData goal, _) => goal.count,
            color: Colors.teal,
            dataLabelSettings: DataLabelSettings(isVisible: true), // Show labels on bars
          )
        ],
      ),
    );
  }
}
