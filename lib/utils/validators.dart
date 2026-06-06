/// Validaciones de los formularios (Manejo de errores).
/// Devuelven `null` cuando el dato es válido, o un mensaje de error si no.
class Validators {
  /// El título no puede estar vacío.
  static String? title(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Escribe una descripción';
    }
    if (value.trim().length > 40) {
      return 'Máximo 40 caracteres';
    }
    return null;
  }

  /// El monto debe ser numérico, no vacío y mayor que cero.
  /// Rechaza letras, montos negativos y el cero.
  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa un monto';
    }
    final normalized = value.trim().replaceAll(',', '.');

    // Rechaza letras o cualquier carácter no numérico.
    final parsed = double.tryParse(normalized);
    if (parsed == null) {
      return 'Solo se permiten números';
    }
    if (parsed <= 0) {
      return 'El monto debe ser mayor que 0';
    }
    if (parsed > 1000000000) {
      return 'El monto es demasiado grande';
    }
    return null;
  }

  /// Convierte el texto del monto a double (ya validado).
  static double parseAmount(String value) =>
      double.parse(value.trim().replaceAll(',', '.'));

  /// El límite puede estar vacío (sin límite) pero si se escribe
  /// debe ser un número no negativo.
  static String? limit(String? value) {
    if (value == null || value.trim().isEmpty) return null; // sin límite
    final normalized = value.trim().replaceAll(',', '.');
    final parsed = double.tryParse(normalized);
    if (parsed == null) return 'Solo se permiten números';
    if (parsed < 0) return 'No puede ser negativo';
    return null;
  }
}
