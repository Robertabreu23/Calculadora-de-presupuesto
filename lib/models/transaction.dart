import 'package:flutter/material.dart';

/// Tipo de movimiento: dinero que entra o que sale.
enum TransactionType { income, expense }

/// Categorías disponibles, cada una con su ícono y color para la UI.
enum Category {
  salary('Salario', Icons.payments_rounded, Color(0xFF22C55E), TransactionType.income),
  gift('Regalo / Extra', Icons.card_giftcard_rounded, Color(0xFF10B981), TransactionType.income),
  food('Comida', Icons.restaurant_rounded, Color(0xFFF97316), TransactionType.expense),
  transport('Transporte', Icons.directions_bus_rounded, Color(0xFF3B82F6), TransactionType.expense),
  home('Hogar', Icons.home_rounded, Color(0xFF8B5CF6), TransactionType.expense),
  fun('Ocio', Icons.sports_esports_rounded, Color(0xFFEC4899), TransactionType.expense),
  health('Salud', Icons.favorite_rounded, Color(0xFFEF4444), TransactionType.expense),
  other('Otros', Icons.category_rounded, Color(0xFF64748B), TransactionType.expense);

  const Category(this.label, this.icon, this.color, this.type);

  final String label;
  final IconData icon;
  final Color color;
  final TransactionType type;

  static List<Category> byType(TransactionType type) =>
      Category.values.where((c) => c.type == type).toList();
}

/// Una transacción individual del presupuesto.
class Transaction {
  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });

  final String id;
  final String title;
  final double amount;
  final Category category;
  final DateTime date;

  TransactionType get type => category.type;
}
