import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tracker_app/models/expense.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  final List<String> _categories = ['Food', 'Transport', 'Shopping', 'Bills', 'Salary', 'Other'];
  String? _selectedCategory;

  DateTime _selectedDate = DateTime.now();

  // true = Cargo (expense), false = Abono (income)
  bool _isExpense = true;

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

    final expense = Expense(category: _selectedCategory ?? 'Other', amount: amount);

    // Return a map containing the Expense and metadata so the caller can decide where to add it.
    Navigator.of(context).pop({
      'expense': expense,
      'isExpense': _isExpense,
      'date': _selectedDate,
      'note': _noteController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
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
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.close, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              const Text('Add Expenses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 18),

              // amount + type toggle
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                child: Row(
                  children: [
                    ToggleButtons(
                      isSelected: [_isExpense, !_isExpense],
                      onPressed: (i) => setState(() => _isExpense = i == 0),
                      borderRadius: BorderRadius.circular(12),
                      constraints: const BoxConstraints(minWidth: 80, minHeight: 40),
                      children: const [Text('Cargo'), Text('Abono')],
                    ),
                    const SizedBox(width: 12),
                    const Text('\$', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]'))],
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(border: InputBorder.none, hintText: '0.00'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // form fields
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Category dropdown
                      Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          children: [
                            CircleAvatar(radius: 18, backgroundColor: Colors.grey[200], child: const Icon(Icons.category, color: Colors.grey, size: 18)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedCategory,
                                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                onChanged: (v) => setState(() => _selectedCategory = v),
                                decoration: const InputDecoration(border: InputBorder.none),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Note
                      Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          children: [
                            CircleAvatar(radius: 18, backgroundColor: Colors.grey[200], child: const Icon(Icons.note, color: Colors.grey, size: 18)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _noteController,
                                decoration: const InputDecoration(border: InputBorder.none, hintText: 'Note'),
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
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          child: Row(
                            children: [
                              CircleAvatar(radius: 18, backgroundColor: Colors.grey[200], child: const Icon(Icons.calendar_today, color: Colors.grey, size: 18)),
                              const SizedBox(width: 12),
                              Expanded(child: Text(_formatDate(_selectedDate))),
                              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey)
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                  onPressed: _save,
                  child: Ink(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFF00B2E7), Color(0xFFE064F7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: const Text('SAVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
