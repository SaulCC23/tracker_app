import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tracker_app/models/expense.dart';

class ExpenseChart extends StatelessWidget {
  final List<Expense> expenses;

  const ExpenseChart({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const Center(child: Text('No hay gastos para mostrar'));
    }

    return _GradientBarChart(expenses: expenses);
  }
}

class _GradientBarChart extends StatelessWidget {
  final List<Expense> expenses;
  const _GradientBarChart({required this.expenses});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final height = constraints.maxHeight;
      return CustomPaint(
        size: Size(width, height),
        painter: _BarChartPainter(expenses: expenses, theme: Theme.of(context)),
      );
    });
  }
}

class _BarChartPainter extends CustomPainter {
  final List<Expense> expenses;
  final ThemeData theme;

  _BarChartPainter({required this.expenses, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final double leftPadding = 40; // space for Y labels
    final double bottomPadding = 36; // space for category labels
    final usableWidth = size.width - leftPadding - 16;
    final usableHeight = size.height - bottomPadding - 16;

    // compute max
    final maxAmount = expenses.map((e) => e.amount).fold<double>(0, (p, n) => n > p ? n : p);
    final maxTick = _niceMax(maxAmount);

    // draw Y axis labels and horizontal grid lines
    final tickCount = 4;
    final textStyle = TextStyle(color: Colors.grey[600], fontSize: 11);
    for (int i = 0; i <= tickCount; i++) {
      final y = 16 + (usableHeight) - (usableHeight * (i / tickCount));
      final value = (maxTick * (i / tickCount)).toInt();
      final tp = TextPainter(text: TextSpan(text: '\$${value}', style: textStyle), textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(6, y - tp.height / 2));

      // grid line
      final gridPaint = Paint()..color = Colors.grey.withOpacity(0.12)..strokeWidth = 1;
      canvas.drawLine(Offset(leftPadding, y), Offset(size.width - 8, y), gridPaint);
    }

    // bars
    final n = expenses.length;
    if (n == 0) return;
    final spacing = usableWidth / (n * 1.6);
    final barWidth = spacing;
    final startX = leftPadding + spacing / 2;

    for (int i = 0; i < n; i++) {
      final e = expenses[i];
      final x = startX + i * spacing * 1.6;
      final hFactor = maxTick == 0 ? 0.0 : (e.amount / maxTick);
      final barHeight = usableHeight * hFactor;
      final barTop = 16 + (usableHeight - barHeight);
      final rect = Rect.fromLTWH(x, barTop, barWidth, barHeight);

      // gradient for bar
      final gradient = LinearGradient(colors: [Color(0xFF00B2E7), Color(0xFFE064F7), Color(0xFFFF8D6C)], begin: Alignment.bottomCenter, end: Alignment.topCenter);
      paint.shader = gradient.createShader(rect);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
      canvas.drawRRect(rrect, paint);

      // draw category label
      final catTp = TextPainter(text: TextSpan(text: e.category, style: TextStyle(color: Colors.grey[800], fontSize: 12)), textDirection: TextDirection.ltr, textAlign: TextAlign.center);
      catTp.layout(minWidth: barWidth + 8, maxWidth: barWidth + 24);
      catTp.paint(canvas, Offset(x - 4, size.height - bottomPadding + 6));

      // draw amount under category small
      final amtTp = TextPainter(text: TextSpan(text: '\$${e.amount.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey[700], fontSize: 11)), textDirection: TextDirection.ltr, textAlign: TextAlign.center);
      amtTp.layout(minWidth: barWidth + 8, maxWidth: barWidth + 24);
      amtTp.paint(canvas, Offset(x - 4, size.height - bottomPadding + 20));
    }
  }

  double _niceMax(double max) {
    if (max <= 0) return 1;
    final exp = (math.log(max) / math.ln10).floor();
    final magnitude = math.pow(10, exp).toDouble();
    final normalized = (max / magnitude).ceil();
    return normalized * magnitude;
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) => oldDelegate.expenses != expenses || oldDelegate.theme != theme;
}



