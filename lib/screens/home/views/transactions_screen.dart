import 'package:flutter/material.dart';
import 'package:tracker_app/models/expense.dart';
import 'package:tracker_app/widgets/expense_chart.dart';

class TransactionsScreen extends StatefulWidget {
  final List<Expense> incomes;
  final List<Expense> expenses;
  final List<Map<String, dynamic>> customCategories;

  const TransactionsScreen({
    super.key,
    this.incomes = const [],
    this.expenses = const [],
    this.customCategories = const [],
  });

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  // 0 = Income, 1 = Expenses
  int _selectedSegment = 1;

  // Local UI state

  @override
  Widget build(BuildContext context) {
    final expenses = widget.expenses;
    final incomes = widget.incomes;
    final shownList = _selectedSegment == 0 ? incomes : expenses;
    final totalAmount = shownList.fold<double>(0, (s, e) => s + e.amount);

    // Build a simple transaction list for the list view (no dates stored currently)
    final List<_Tx> txList = [
      // incomes as positive
      ...incomes.map(
        (e) => _Tx(
          title: e.category,
          amount: e.amount,
          date: 'Today',
          category: e.category,
        ),
      ),
      // expenses as negative amounts
      ...expenses.map(
        (e) => _Tx(
          title: e.category,
          amount: -e.amount,
          date: 'Today',
          category: e.category,
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Transactions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.tune, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Segmented control (Income / Expenses)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedSegment = 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            gradient: _selectedSegment == 0
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF00B2E7),
                                      Color(0xFFE064F7),
                                    ],
                                  )
                                : const LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.transparent,
                                    ],
                                  ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                color: _selectedSegment == 0
                                    ? Colors.white
                                    : Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                              child: const Text('Income'),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedSegment = 1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            gradient: _selectedSegment == 1
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF00B2E7),
                                      Color(0xFFE064F7),
                                    ],
                                  )
                                : const LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.transparent,
                                    ],
                                  ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                color: _selectedSegment == 1
                                    ? Colors.white
                                    : Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                              child: const Text('Expenses'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Chart card with total
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      '01 Jan 2021 - 01 April 2021',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      (_selectedSegment == 0 ? '\$' : '\$') +
                          totalAmount.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // thinner chart area
                    SizedBox(
                      height: 110,
                      child: ExpenseChart(expenses: shownList),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Transactions grouped by date
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 6),
                    const Text('Today', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    ...txList.map((t) => _txCard(t, context)),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _txCard(_Tx tx, BuildContext context) {
    final meta = _getCategoryMeta(tx.category);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: meta['color'] as Color,
          child: Icon(meta['icon'] as IconData, color: Colors.white),
        ),
        title: Text(
          tx.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(tx.date, style: const TextStyle(color: Colors.grey)),
        trailing: Text(
          (tx.amount < 0 ? '-' : '+') +
              '\$${tx.amount.abs().toStringAsFixed(0)}',
          style: TextStyle(
            color: tx.amount < 0 ? Colors.red : Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getCategoryMeta(String category) {
    // Check custom categories first
    for (var c in widget.customCategories) {
      if (c['name'] == category) {
        return {'icon': c['icon'], 'color': c['color']};
      }
    }

    switch (category.toLowerCase()) {
      case 'food':
      case 'comida':
        return {'icon': Icons.restaurant, 'color': const Color(0xFFFFB74D)};
      case 'transport':
      case 'transporte':
        return {'icon': Icons.directions_car, 'color': const Color(0xFF4DB6AC)};
      case 'shopping':
      case 'ropa':
        return {'icon': Icons.shopping_bag, 'color': const Color(0xFF9575CD)};
      case 'bills':
        return {'icon': Icons.receipt_long, 'color': const Color(0xFF90A4AE)};
      case 'salary':
        return {
          'icon': Icons.monetization_on,
          'color': const Color(0xFF81C784),
        };
      default:
        return {'icon': Icons.attach_money, 'color': Colors.grey};
    }
  }
}

class _Tx {
  final String title;
  final double amount;
  final String date;
  final String category;

  const _Tx({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });
}
