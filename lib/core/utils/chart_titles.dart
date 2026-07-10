import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Shared axis titles for simple bar/line charts in this app: only the
/// bottom axis shows a label per data point, everything else is hidden.
FlTitlesData simpleBottomAxisTitles(Widget Function(int index) labelBuilder) {
  return FlTitlesData(
    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) => labelBuilder(value.toInt()),
      ),
    ),
  );
}
