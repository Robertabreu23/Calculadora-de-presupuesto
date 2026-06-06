import 'package:flutter/material.dart';

import '../state/budget_controller.dart';
import '../widgets/add_transaction_sheet.dart';
import '../widgets/balance_header.dart';
import '../widgets/category_chart.dart';
import '../widgets/limit_card.dart';
import '../widgets/transaction_list.dart';

/// Pantalla principal: une el encabezado, el límite, el gráfico
/// y la lista de movimientos. Se reconstruye sola al cambiar los datos.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});

  final BudgetController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Escucha al controlador: cualquier cambio refresca la UI.
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: BalanceHeader(controller: controller)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    LimitCard(controller: controller),
                    const SizedBox(height: 16),
                    CategoryChart(controller: controller),
                    const SizedBox(height: 8),
                    TransactionList(controller: controller),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddTransactionSheet.show(context, controller),
        backgroundColor: const Color(0xFF6D5DF6),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Agregar',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
