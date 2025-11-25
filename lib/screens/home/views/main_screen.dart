import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'add_expense_screen.dart';
import 'transactions_screen.dart';
import 'package:tracker_app/models/expense.dart';
import 'package:tracker_app/services/storage_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isFabHovered = false;

  final StorageService _storageService = StorageService();

  @override
  Widget build(BuildContext context) {
    // Color vibrante acorde al gradiente del FAB (Purple)
    final navColor = const Color(0xFFE064F7);

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _storageService.getCategoriesStream(),
      builder: (context, categoriesSnapshot) {
        final categories = categoriesSnapshot.data ?? [];

        return StreamBuilder<List<Expense>>(
          stream: _storageService.getExpensesStream(),
          builder: (context, expensesSnapshot) {
            final expenses = expensesSnapshot.data ?? [];

            return StreamBuilder<List<Expense>>(
              stream: _storageService.getIncomesStream(),
              builder: (context, incomesSnapshot) {
                final incomes = incomesSnapshot.data ?? [];

                final screens = [
                  HomeScreen(
                    incomes: incomes,
                    expenses: expenses,
                    customCategories: categories,
                  ),
                  TransactionsScreen(
                    incomes: incomes,
                    expenses: expenses,
                    customCategories: categories,
                  ),
                ];

                return Scaffold(
                  extendBody: true,
                  body: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: screens[_currentIndex],
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: () async {
                      final result = await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) =>
                            AddExpenseScreen(availableCategories: categories),
                      );

                      if (result != null && result is Map) {
                        // Handle new category creation if passed back
                        if (result.containsKey('newCategory')) {
                          final newCat =
                              result['newCategory'] as Map<String, dynamic>;
                          // Check if category with same name exists
                          final exists = categories.any(
                            (c) => c['name'] == newCat['name'],
                          );
                          if (!exists) {
                            _storageService.addCategory(newCat);
                          }
                        }

                        final Expense? e = result['expense'] as Expense?;
                        final bool isExpense =
                            result['isExpense'] as bool? ?? true;
                        if (e != null) {
                          if (isExpense) {
                            _storageService.addExpense(e);
                          } else {
                            _storageService.addIncome(e);
                          }

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${isExpense ? 'Cargo' : 'Abono'} saved: ${e.category} \$${e.amount.toStringAsFixed(2)}',
                                ),
                              ),
                            );
                          }
                        }
                      }
                    },
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    hoverElevation: 0,
                    focusElevation: 0,
                    highlightElevation: 0,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _isFabHovered = true),
                      onExit: (_) => setState(() => _isFabHovered = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        transform: Matrix4.identity()
                          ..scale(_isFabHovered ? 1.1 : 1.0),
                        transformAlignment: Alignment.center,
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
                              color: _isFabHovered
                                  ? const Color(0xFFE064F7).withOpacity(0.4)
                                  : Colors.black.withOpacity(0.18),
                              blurRadius: _isFabHovered ? 12 : 10,
                              offset: _isFabHovered
                                  ? const Offset(0, 8)
                                  : const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerDocked,
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
                                  selected: _currentIndex == 0,
                                  color: navColor,
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
                                  selected: _currentIndex == 1,
                                  color: navColor,
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
              },
            );
          },
        );
      },
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final bool selected;
  final Color color;
  final double verticalPadding;

  const _NavItem({
    required this.icon,
    required this.selected,
    required this.color,
    this.verticalPadding = 6,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelectedOrHovered = widget.selected || _isHovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: widget.verticalPadding),
        decoration: BoxDecoration(
          color: widget.selected
              ? widget.color.withOpacity(0.12)
              : _isHovered
              ? widget.color.withOpacity(0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(
                begin: widget.selected ? 1.15 : 1.0,
                end: widget.selected ? 1.15 : (_isHovered ? 1.1 : 1.0),
              ),
              duration: const Duration(milliseconds: 200),
              builder: (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Icon(
                widget.icon,
                color: isSelectedOrHovered ? widget.color : Colors.grey[600],
                shadows: isSelectedOrHovered
                    ? [
                        Shadow(
                          color: widget.color.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
