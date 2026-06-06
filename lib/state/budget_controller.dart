import 'package:flutter/foundation.dart' hide Category;

import '../models/transaction.dart';

/// Cerebro de la app: aquí vive TODA la lógica de negocio.
/// Suma ingresos/gastos, calcula el saldo, agrupa por categoría
/// y avisa cuando se supera el límite de gasto.
class BudgetController extends ChangeNotifier {
  final List<Transaction> _transactions = [];
  double _spendingLimit = 0; // 0 = sin límite definido

  int _idCounter = 0;

  List<Transaction> get transactions => List.unmodifiable(
    _transactions..sort((a, b) => b.date.compareTo(a.date)),
  );

  double get spendingLimit => _spendingLimit;

  // ----- Cálculos principales -----

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  /// Saldo disponible = ingresos - gastos.
  double get balance => totalIncome - totalExpense;

  bool get hasTransactions => _transactions.isNotEmpty;

  /// Gasto total por categoría (solo categorías con gasto > 0).
  Map<Category, double> get expensesByCategory {
    final map = <Category, double>{};
    for (final t in _transactions.where(
      (t) => t.type == TransactionType.expense,
    )) {
      map.update(t.category, (v) => v + t.amount, ifAbsent: () => t.amount);
    }
    return map;
  }

  /// Porcentaje del límite ya consumido
  /// Protegido contra división por cero: si no hay límite, devuelve 0.
  double get limitUsedFraction {
    if (_spendingLimit <= 0) return 0;
    return totalExpense / _spendingLimit;
  }

  /// True cuando el gasto supera el límite configurado.
  bool get isOverLimit => _spendingLimit > 0 && totalExpense > _spendingLimit;

  /// True cuando el gasto está cerca del límite (>= 80%) pero aún no lo pasa.
  bool get isNearLimit =>
      _spendingLimit > 0 && !isOverLimit && limitUsedFraction >= 0.8;

  // ----- Acciones -----

  void addTransaction({
    required String title,
    required double amount,
    required Category category,
  }) {
    _transactions.add(
      Transaction(
        id: 'tx_${_idCounter++}',
        title: title.trim(),
        amount: amount,
        category: category,
        date: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void removeTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void setSpendingLimit(double limit) {
    _spendingLimit = limit < 0 ? 0 : limit;
    notifyListeners();
  }

  void clearAll() {
    _transactions.clear();
    notifyListeners();
  }
}
