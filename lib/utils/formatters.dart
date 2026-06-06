import 'package:intl/intl.dart';

/// Formateador de moneda reutilizable en toda la app.
final NumberFormat _currency = NumberFormat.currency(
  locale: 'es_ES',
  symbol: '\$',
  decimalDigits: 2,
);

String formatMoney(double value) => _currency.format(value);

final DateFormat _dateFmt = DateFormat("d 'de' MMM, HH:mm", 'es');

String formatDate(DateTime date) => _dateFmt.format(date);
