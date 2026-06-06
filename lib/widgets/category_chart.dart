import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/transaction.dart';
import '../state/budget_controller.dart';
import '../utils/formatters.dart';

/// Gráfico de dona que muestra cómo se reparten los gastos por categoría.
class CategoryChart extends StatelessWidget {
  const CategoryChart({super.key, required this.controller});

  final BudgetController controller;

  @override
  Widget build(BuildContext context) {
    final data = controller.expensesByCategory;
    final total = controller.totalExpense;

    if (data.isEmpty || total <= 0) {
      return const SizedBox.shrink();
    }

    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gastos por categoría',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 130,
                  height: 130,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 38,
                          sections: [
                            for (final e in entries)
                              PieChartSectionData(
                                value: e.value,
                                color: e.key.color,
                                radius: 22,
                                showTitle: false,
                              ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Total',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.black54)),
                          FittedBox(
                            child: Text(
                              formatMoney(total),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    children: [
                      for (final e in entries)
                        _LegendRow(
                          category: e.key,
                          amount: e.value,
                          percent: e.value / total,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.category,
    required this.amount,
    required this.percent,
  });

  final Category category;
  final double amount;
  final double percent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: category.color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              category.label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '${(percent * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
