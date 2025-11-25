import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracker_app/models/expense.dart';

import 'package:flutter/material.dart';

class StorageService {
  static const String _categoriesKey = 'categories';
  static const String _expensesKey = 'expenses';
  static const String _incomesKey = 'incomes';

  Future<void> saveCategories(List<Map<String, dynamic>> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = categories.map((c) {
      return jsonEncode({
        'name': c['name'],
        'icon': (c['icon'] as IconData).codePoint,
        'fontFamily': (c['icon'] as IconData).fontFamily,
        'fontPackage': (c['icon'] as IconData).fontPackage,
        'color': (c['color'] as Color).value,
      });
    }).toList();
    await prefs.setStringList(_categoriesKey, jsonList);
  }

  Future<List<Map<String, dynamic>>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_categoriesKey);

    if (jsonList == null) return [];

    return jsonList.map((str) {
      try {
        final Map<String, dynamic> data = jsonDecode(str);
        return {
          'name': data['name'],
          'icon': IconData(
            data['icon'],
            fontFamily: data['fontFamily'],
            fontPackage: data['fontPackage'],
          ),
          'color': Color(data['color']),
        };
      } catch (e) {
        // Fallback for legacy string-only categories
        return {
          'name': str,
          'icon': Icons.category, // Default icon
          'color': Colors.grey, // Default color
        };
      }
    }).toList();
  }

  Future<void> saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = expenses
        .map((e) => jsonEncode({'category': e.category, 'amount': e.amount}))
        .toList();
    await prefs.setStringList(_expensesKey, jsonList);
  }

  Future<List<Expense>> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_expensesKey);

    if (jsonList == null) return [];

    return jsonList.map((str) {
      final Map<String, dynamic> data = jsonDecode(str);
      return Expense(
        category: data['category'],
        amount: (data['amount'] as num).toDouble(),
      );
    }).toList();
  }

  Future<void> saveIncomes(List<Expense> incomes) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = incomes
        .map((e) => jsonEncode({'category': e.category, 'amount': e.amount}))
        .toList();
    await prefs.setStringList(_incomesKey, jsonList);
  }

  Future<List<Expense>> loadIncomes() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_incomesKey);

    if (jsonList == null) return [];

    return jsonList.map((str) {
      final Map<String, dynamic> data = jsonDecode(str);
      return Expense(
        category: data['category'],
        amount: (data['amount'] as num).toDouble(),
      );
    }).toList();
  }
}
