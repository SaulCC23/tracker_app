import 'package:flutter/material.dart';
import 'package:tracker_app/models/expense.dart';

class HomeScreen extends StatelessWidget {
  final List<Expense> incomes;
  final List<Expense> expenses;
  final List<Map<String, dynamic>> customCategories;

  const HomeScreen({
    super.key,
    this.incomes = const [],
    this.expenses = const [],
    this.customCategories = const [],
  });

  @override
  Widget build(BuildContext context) {
    final sampleExpenses = expenses;
    final sampleIncomes = incomes;

    final totalIncome = sampleIncomes.fold<double>(0, (s, e) => s + e.amount);
    final totalExpenses = sampleExpenses.fold<double>(
      0,
      (s, e) => s + e.amount,
    );
    final totalBalance = totalIncome - totalExpenses;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with avatar
              Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: null,
                    child: Icon(Icons.person),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Welcome!',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Saul Cetina',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.settings, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Balance card (centered like mock)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF00B2E7),
                      Color(0xFFE064F7),
                      Color(0xFFFF8D6C),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    const BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.06),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Total Balance',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${totalBalance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SmallStat(
                          icon: Icons.arrow_upward,
                          label: 'Income',
                          value: '\$${totalIncome.toStringAsFixed(2)}',
                          iconColor: Colors.greenAccent,
                        ),
                        _SmallStat(
                          icon: Icons.arrow_downward,
                          label: 'Expenses',
                          value: '\$${totalExpenses.toStringAsFixed(2)}',
                          iconColor: Colors.redAccent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Transactions header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Transactions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text('View All', style: TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 12),

              // Transactions list as cards
              Column(
                children: sampleExpenses.map((e) {
                  final mapping = _getCategoryMeta(e.category);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.04),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: mapping['color'] as Color,
                        child: Icon(
                          mapping['icon'] as IconData,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(e.category),
                      subtitle: const Text('Today'),
                      trailing: Text(
                        '-\$${e.amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getCategoryMeta(String category) {
    // Check custom categories first
    for (var c in customCategories) {
      if (c['name'] == category) {
        return {'icon': c['icon'], 'color': c['color']};
      }
    }

    switch (category.toLowerCase()) {
      case 'comida':
      case 'food':
        return {'icon': Icons.restaurant, 'color': const Color(0xFFFFB74D)};
      case 'ropa':
      case 'shopping':
        return {'icon': Icons.shopping_bag, 'color': const Color(0xFF9575CD)};
      case 'transporte':
      case 'travel':
        return {'icon': Icons.flight, 'color': const Color(0xFF4DB6AC)};
      default:
        return {'icon': Icons.attach_money, 'color': Colors.grey};
    }
  }
}

class _SmallStat extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String value;
  final Color iconColor;

  const _SmallStat({
    this.icon,
    required this.label,
    required this.value,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null)
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
        if (icon != null) const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
