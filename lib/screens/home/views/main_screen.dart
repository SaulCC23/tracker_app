import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'add_expense_screen.dart';
import 'transactions_screen.dart';
import 'package:tracker_app/models/expense.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Expense> _incomes = [];
  final List<Expense> _expenses = [];

  List<Widget> get _screens => [
        HomeScreen(incomes: _incomes, expenses: _expenses),
        TransactionsScreen(incomes: _incomes, expenses: _expenses),
      ];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _screens[_currentIndex],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => const AddExpenseScreen(),
          );

          if (result != null && result is Map) {
            final Expense? e = result['expense'] as Expense?;
            final bool isExpense = result['isExpense'] as bool? ?? true;
            if (e != null) {
              setState(() {
                if (isExpense) {
                  _expenses.add(e);
                } else {
                  _incomes.add(e);
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${isExpense ? 'Cargo' : 'Abono'} saved: ${e.category} \$${e.amount.toStringAsFixed(2)}')));
            }
          }
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE064F7), Color(0xFFFF8D6C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        elevation: 12,
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: Container(
            height: 64,
            child: Row(
              children: [
                // Left: Inicio
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _currentIndex = 0),
                    child: _NavItem(
                      icon: Icons.home,
                      label: 'Inicio',
                      selected: _currentIndex == 0,
                      color: primary,
                          verticalPadding: 4,
                    ),
                  ),
                ),

                // Spacer for FAB
                    const SizedBox(width: 72),

                // Right: Apps (shows Transactions)
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _currentIndex = 1),
                    child: _NavItem(
                      icon: Icons.show_chart,
                      label: 'Apps',
                      selected: _currentIndex == 1,
                      color: primary,
                          verticalPadding: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color color;

  final double verticalPadding;

  const _NavItem({required this.icon, required this.label, required this.selected, required this.color, this.verticalPadding = 6});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      decoration: BoxDecoration(
        color: selected ? color.withOpacity(0.06) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: selected ? 1.15 : 1.0, end: selected ? 1.15 : 1.0),
            duration: const Duration(milliseconds: 250),
            builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
            child: Icon(icon, color: selected ? color : Colors.grey[600]),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 12, color: selected ? color : Colors.grey[600])),
        ],
      ),
    );
  }
}
