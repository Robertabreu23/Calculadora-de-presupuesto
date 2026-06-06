import 'package:flutter/material.dart';

import '../state/budget_controller.dart';
import '../utils/formatters.dart';
import '../utils/validators.dart';

/// Tarjeta que muestra el límite de gasto y una barra de progreso.
/// Cambia de color y muestra alerta cuando se acerca o supera el límite.
class LimitCard extends StatelessWidget {
  const LimitCard({super.key, required this.controller});

  final BudgetController controller;

  Color _barColor() {
    if (controller.isOverLimit) return const Color(0xFFF43F5E);
    if (controller.isNearLimit) return const Color(0xFFF59E0B);
    return const Color(0xFF22C55E);
  }

  @override
  Widget build(BuildContext context) {
    final limit = controller.spendingLimit;
    final fraction = controller.limitUsedFraction.clamp(0.0, 1.0);
    final hasLimit = limit > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag_rounded, color: Color(0xFF6D5DF6)),
                const SizedBox(width: 8),
                const Text(
                  'Límite de gasto',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _editLimit(context),
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: Text(hasLimit ? 'Editar' : 'Definir'),
                ),
              ],
            ),
            if (!hasLimit)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Aún no defines un límite. Pulsa "Definir" para controlar tus gastos.',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
              )
            else ...[
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: fraction,
                  minHeight: 14,
                  backgroundColor: const Color(0xFFE9E8F4),
                  valueColor: AlwaysStoppedAnimation(_barColor()),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${formatMoney(controller.totalExpense)} de ${formatMoney(limit)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  Text(
                    '${(controller.limitUsedFraction * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _barColor(),
                    ),
                  ),
                ],
              ),
              if (controller.isOverLimit || controller.isNearLimit) ...[
                const SizedBox(height: 14),
                _AlertBanner(
                  over: controller.isOverLimit,
                  exceso: controller.totalExpense - limit,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  void _editLimit(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final ctrl = TextEditingController(
      text: controller.spendingLimit > 0
          ? controller.spendingLimit.toStringAsFixed(0)
          : '',
    );

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Límite de gasto'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctrl,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: Validators.limit,
            decoration: const InputDecoration(
              prefixText: '\$ ',
              hintText: 'Deja vacío para quitar el límite',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final text = ctrl.text.trim();
              controller.setSpendingLimit(
                text.isEmpty ? 0 : Validators.parseAmount(text),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

class _AlertBanner extends StatelessWidget {
  const _AlertBanner({required this.over, required this.exceso});

  final bool over;
  final double exceso;

  @override
  Widget build(BuildContext context) {
    final color = over ? const Color(0xFFF43F5E) : const Color(0xFFF59E0B);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(over ? Icons.error_rounded : Icons.warning_amber_rounded,
              color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              over
                  ? '¡Límite superado por ${formatMoney(exceso)}! Controla tus gastos.'
                  : 'Estás cerca de tu límite de gasto.',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
