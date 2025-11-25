class Expense {
  final String category;
  final double amount;
  final DateTime? date;
  final String? note;

  Expense({required this.category, required this.amount, this.date, this.note});
}
