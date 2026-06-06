// Pruebas de la lógica de negocio del presupuesto.
import 'package:flutter_test/flutter_test.dart';
import 'package:presupuesto_app/models/transaction.dart';
import 'package:presupuesto_app/state/budget_controller.dart';
import 'package:presupuesto_app/utils/validators.dart';

void main() {
  group('BudgetController', () {
    test('calcula saldo = ingresos - gastos', () {
      final c = BudgetController();
      c.addTransaction(title: 'Sueldo', amount: 1000, category: Category.salary);
      c.addTransaction(title: 'Comida', amount: 250, category: Category.food);

      expect(c.totalIncome, 1000);
      expect(c.totalExpense, 250);
      expect(c.balance, 750);
    });

    test('agrupa gastos por categoría', () {
      final c = BudgetController();
      c.addTransaction(title: 'Bus', amount: 20, category: Category.transport);
      c.addTransaction(title: 'Taxi', amount: 30, category: Category.transport);
      c.addTransaction(title: 'Pizza', amount: 15, category: Category.food);

      expect(c.expensesByCategory[Category.transport], 50);
      expect(c.expensesByCategory[Category.food], 15);
    });

    test('detecta cuando se supera el límite', () {
      final c = BudgetController();
      c.setSpendingLimit(100);
      c.addTransaction(title: 'Compra', amount: 120, category: Category.home);

      expect(c.isOverLimit, isTrue);
    });

    test('sin límite no hay división por cero', () {
      final c = BudgetController();
      c.addTransaction(title: 'Compra', amount: 50, category: Category.home);

      expect(c.limitUsedFraction, 0);
      expect(c.isOverLimit, isFalse);
    });
  });

  group('Validators', () {
    test('rechaza letras en el monto', () {
      expect(Validators.amount('abc'), isNotNull);
    });

    test('rechaza monto vacío', () {
      expect(Validators.amount(''), isNotNull);
    });

    test('rechaza monto negativo o cero', () {
      expect(Validators.amount('-5'), isNotNull);
      expect(Validators.amount('0'), isNotNull);
    });

    test('acepta monto válido con coma o punto', () {
      expect(Validators.amount('19.99'), isNull);
      expect(Validators.amount('19,99'), isNull);
      expect(Validators.parseAmount('19,99'), 19.99);
    });

    test('rechaza descripción vacía', () {
      expect(Validators.title('   '), isNotNull);
    });
  });
}
