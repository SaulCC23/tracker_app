import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tracker_app/models/expense.dart';
import 'package:tracker_app/screens/home/views/add_category_dialog.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

Map<String, Object> _categoryMeta(String category) {
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
      return {'icon': Icons.monetization_on, 'color': const Color(0xFF81C784)};
    default:
      return {'icon': Icons.attach_money, 'color': Colors.grey};
  }
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  final List<String> _categories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Salary',
    'Other',
  ];
  String? _selectedCategory;

  DateTime _selectedDate = DateTime.now();

  // true = Cargo (expense), false = Abono (income)
  bool _isExpense = true;

  final Map<String, Map<String, dynamic>> _customCategories = {};

  Map<String, dynamic> _getCategoryMeta(String category) {
    if (_customCategories.containsKey(category)) {
      return _customCategories[category]!;
    }
    return _categoryMeta(category);
  }

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories.first;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _save() {
    final raw = _amountController.text.replaceAll(',', '.');
    final amount = double.tryParse(raw) ?? 0.0;

    final expense = Expense(
      category: _selectedCategory ?? 'Other',
      amount: amount,
    );

    // Return a map containing the Expense and metadata so the caller can decide where to add it.
    Navigator.of(context).pop({
      'expense': expense,
      'isExpense': _isExpense,
      'date': _selectedDate,
      'note': _noteController.text,
    });
  }

  Future<void> _showAddCategoryDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => const AddCategoryDialog(),
    );

    if (result != null) {
      setState(() {
        final name = result['name'] as String;
        _categories.add(name);
        _customCategories[name] = {
          'icon': result['icon'],
          'color': result['color'],
        };
        _selectedCategory = name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final _selectedMeta = _getCategoryMeta(_selectedCategory ?? 'Other');
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        height: mq.height * 0.85,
        margin: const EdgeInsets.only(top: 40),
        decoration: const BoxDecoration(
          color: Color(0xFFF6F5FB),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            children: [
              // top bar with close
              Row(
                children: [
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.close, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              const Text(
                'Add Expenses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 18),

              // amount + type toggle (styled like design)
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 6,
                    ),
                    child: ToggleButtons(
                      isSelected: [_isExpense, !_isExpense],
                      onPressed: (i) => setState(() => _isExpense = i == 0),
                      borderRadius: BorderRadius.circular(12),
                      constraints: const BoxConstraints(
                        minWidth: 100,
                        minHeight: 36,
                      ),
                      children: const [Text('Cargo'), Text('Abono')],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 24,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '\$',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            textAlign: TextAlign.center,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9\.,]'),
                              ),
                            ],
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..shader = const LinearGradient(
                                  colors: [
                                    Color(0xFF00B2E7),
                                    Color(0xFFE064F7),
                                  ],
                                ).createShader(Rect.fromLTWH(0, 0, 200, 40)),
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: '0.00',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // form fields
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Category dropdown
                      // Category dropdown
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor:
                                        _selectedMeta['color'] as Color,
                                    child: Icon(
                                      _selectedMeta['icon'] as IconData,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedCategory,
                                      items: _categories.map((c) {
                                        final meta = _getCategoryMeta(c);
                                        return DropdownMenuItem(
                                          value: c,
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 14,
                                                backgroundColor:
                                                    meta['color'] as Color,
                                                child: Icon(
                                                  meta['icon'] as IconData,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(c),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (v) =>
                                          setState(() => _selectedCategory = v),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: _showAddCategoryDialog,
                              icon: const Icon(Icons.add),
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Note
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.grey[200],
                              child: const Icon(
                                Icons.note,
                                color: Colors.grey,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _noteController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Note',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Date row
                      InkWell(
                        onTap: _pickDate,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.grey[200],
                                child: const Icon(
                                  Icons.calendar_today,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(_formatDate(_selectedDate))),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    elevation: 0,
                  ),
                  onPressed: _save,
                  child: Ink(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF00B2E7), Color(0xFFE064F7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: const Text(
                        'SAVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      height: 52,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
