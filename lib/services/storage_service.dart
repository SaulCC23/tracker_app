import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/models/expense.dart';

class StorageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Base reference to user data
  // Using a fixed user ID for now as per plan
  DocumentReference get _userDoc =>
      _firestore.collection('data').doc('user_data');

  // Collection references
  CollectionReference get _expensesRef => _userDoc.collection('expenses');
  CollectionReference get _incomesRef => _userDoc.collection('incomes');
  CollectionReference get _categoriesRef => _userDoc.collection('categories');

  // --- Categories ---

  Future<void> addCategory(Map<String, dynamic> category) async {
    final data = {
      'name': category['name'],
      'icon': (category['icon'] as IconData).codePoint,
      'fontFamily': (category['icon'] as IconData).fontFamily,
      'fontPackage': (category['icon'] as IconData).fontPackage,
      'color': (category['color'] as Color).value,
      'createdAt': FieldValue.serverTimestamp(),
    };
    await _categoriesRef.add(data);
  }

  Stream<List<Map<String, dynamic>>> getCategoriesStream() {
    return _categoriesRef.orderBy('createdAt').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'],
          'icon': IconData(
            data['icon'],
            fontFamily: data['fontFamily'],
            fontPackage: data['fontPackage'],
          ),
          'color': Color(data['color']),
        };
      }).toList();
    });
  }

  // Legacy support: loadCategories (one-time fetch)
  Future<List<Map<String, dynamic>>> loadCategories() async {
    final snapshot = await _categoriesRef.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'name': data['name'],
        'icon': IconData(
          data['icon'],
          fontFamily: data['fontFamily'],
          fontPackage: data['fontPackage'],
        ),
        'color': Color(data['color']),
      };
    }).toList();
  }

  // Legacy support: saveCategories (bulk save - deprecated but kept for compatibility if needed)
  Future<void> saveCategories(List<Map<String, dynamic>> categories) async {
    // Ideally we shouldn't use this anymore, but if the UI sends a full list,
    // we might need to handle it. For now, let's just log a warning or
    // implement a bulk update if strictly necessary.
    // Given the new architecture, we should prefer addCategory.
    debugPrint('Warning: saveCategories called. Prefer using addCategory.');
  }

  // --- Expenses ---

  Future<void> addExpense(Expense expense) async {
    await _expensesRef.add({
      'category': expense.category,
      'amount': expense.amount,
      'date': expense.date ?? DateTime.now(), // Ensure date is saved
      'note': expense.note,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Expense>> getExpensesStream() {
    return _expensesRef.orderBy('createdAt', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Expense(
          category: data['category'],
          amount: (data['amount'] as num).toDouble(),
          date: (data['date'] as Timestamp?)?.toDate(),
          note: data['note'],
        );
      }).toList();
    });
  }

  // Legacy support
  Future<List<Expense>> loadExpenses() async {
    final snapshot = await _expensesRef.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Expense(
        category: data['category'],
        amount: (data['amount'] as num).toDouble(),
        date: (data['date'] as Timestamp?)?.toDate(),
        note: data['note'],
      );
    }).toList();
  }

  Future<void> saveExpenses(List<Expense> expenses) async {
    debugPrint('Warning: saveExpenses called. Prefer using addExpense.');
  }

  // --- Incomes ---

  Future<void> addIncome(Expense income) async {
    await _incomesRef.add({
      'category': income.category,
      'amount': income.amount,
      'date': income.date ?? DateTime.now(),
      'note': income.note,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Expense>> getIncomesStream() {
    return _incomesRef.orderBy('createdAt', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Expense(
          category: data['category'],
          amount: (data['amount'] as num).toDouble(),
          date: (data['date'] as Timestamp?)?.toDate(),
          note: data['note'],
        );
      }).toList();
    });
  }

  // Legacy support
  Future<List<Expense>> loadIncomes() async {
    final snapshot = await _incomesRef.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Expense(
        category: data['category'],
        amount: (data['amount'] as num).toDouble(),
        date: (data['date'] as Timestamp?)?.toDate(),
        note: data['note'],
      );
    }).toList();
  }

  Future<void> saveIncomes(List<Expense> incomes) async {
    debugPrint('Warning: saveIncomes called. Prefer using addIncome.');
  }
}
