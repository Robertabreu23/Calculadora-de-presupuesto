import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/transaction.dart';
import '../state/budget_controller.dart';
import '../utils/validators.dart';

/// Hoja inferior con el formulario para crear un ingreso o gasto.
/// Valida todos los campos antes de guardar (Manejo de errores).
class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key, required this.controller});

  final BudgetController controller;

  /// Abre la hoja modal.
  static Future<void> show(
      BuildContext context, BudgetController controller) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTransactionSheet(controller: controller),
    );
  }

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  TransactionType _type = TransactionType.expense;
  late Category _category = Category.byType(_type).first;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _switchType(TransactionType type) {
    setState(() {
      _type = type;
      // Ajusta la categoría seleccionada al nuevo tipo.
      _category = Category.byType(type).first;
    });
  }

  void _submit() {
    // Valida todo el formulario; si algo falla, no continúa.
    if (!_formKey.currentState!.validate()) return;

    widget.controller.addTransaction(
      title: _titleCtrl.text,
      amount: Validators.parseAmount(_amountCtrl.text),
      category: _category,
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Movimiento guardado ✅')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final categories = Category.byType(_type);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF7F6FD),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Nuevo movimiento',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 18),

                // Selector ingreso / gasto
                _TypeSelector(type: _type, onChanged: _switchType),
                const SizedBox(height: 20),

                const _FieldLabel('Descripción'),
                TextFormField(
                  controller: _titleCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: 40,
                  validator: Validators.title,
                  decoration: const InputDecoration(
                    hintText: 'Ej: Sueldo, Supermercado, Café...',
                    counterText: '',
                    prefixIcon: Icon(Icons.edit_note_rounded),
                  ),
                ),
                const SizedBox(height: 14),

                const _FieldLabel('Monto'),
                TextFormField(
                  controller: _amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  // Solo deja teclear números, punto y coma.
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  validator: Validators.amount,
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    prefixText: '\$ ',
                    prefixIcon: Icon(Icons.attach_money_rounded),
                  ),
                ),
                const SizedBox(height: 14),

                const _FieldLabel('Categoría'),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in categories)
                      _CategoryChip(
                        category: c,
                        selected: _category == c,
                        onTap: () => setState(() => _category = c),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: _type == TransactionType.income
                          ? const Color(0xFF22C55E)
                          : const Color(0xFF6D5DF6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.check_rounded),
                    label: Text(
                      _type == TransactionType.income
                          ? 'Guardar ingreso'
                          : 'Guardar gasto',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
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

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.type, required this.onChanged});

  final TransactionType type;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFECEAF8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _segment('Gasto', Icons.south_west_rounded, TransactionType.expense,
              const Color(0xFFF43F5E)),
          _segment('Ingreso', Icons.north_east_rounded,
              TransactionType.income, const Color(0xFF22C55E)),
        ],
      ),
    );
  }

  Widget _segment(
      String label, IconData icon, TransactionType value, Color color) {
    final selected = type == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? const [
                    BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 8,
                        offset: Offset(0, 2))
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? color : Colors.black45),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.black87 : Colors.black45,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final Category category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? category.color : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? category.color : const Color(0xFFE2E0F0),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(category.icon,
                size: 18, color: selected ? Colors.white : category.color),
            const SizedBox(width: 6),
            Text(
              category.label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Text(
        text,
        style: const TextStyle(
            fontWeight: FontWeight.w700, fontSize: 13, color: Colors.black54),
      ),
    );
  }
}
