# Mi Presupuesto
Hecho con dedicacion por :
**Robert Abreu — Matrícula 23-0121**

Hola, esta es mi calculadora de presupuesto personal, hecha en Flutter.
La idea es simple: anotas lo que te entra y lo que gastas, y la app te dice
cuánto dinero te queda y si te estás pasando de la raya con los gastos.

## ¿Cómo funciona?

Es bien sencilla de usar:

1. Abres la app y arriba ves tu **saldo disponible** en grande (lo que te queda
   después de restar los gastos a los ingresos).
2. Le das al botón **+ Agregar** y se abre un formulario abajo. Ahí eliges si es
   un **gasto** o un **ingreso**, escribes una descripción (ej: "Sueldo" o
   "Supermercado"), pones el monto y le tocas a una categoría.
3. Le das a guardar y listo: el movimiento aparece en la lista y todos los
   números se actualizan solos.

### Lo que hace por dentro
- **Suma tus ingresos y gastos** y calcula el saldo automáticamente.
- **Categoriza** cada movimiento (comida, transporte, hogar, ocio, salud…) y te
  muestra un **gráfico de dona** para ver en qué se te va más el dinero.
- Le puedes poner un **límite de gasto**. Cuando te acercas (80%) te avisa en
  amarillo, y si te pasas te lo marca en rojo para que frenes.

### Validaciones
La app no me deja meter datos malos:
- Si escribo **letras** en el monto, no me deja.
- Si dejo un campo **vacío**, me lo dice.
- No acepta montos **negativos ni cero**.
- Y si no he puesto límite, no truena por **dividir entre cero** (lo deja en 0).

Para borrar un movimiento solo lo **deslizo hacia la izquierda** y desaparece.

## ¿Cómo la corro?

```bash
flutter pub get
flutter run        # y elijo mi emulador (Genymotion / Chrome / Linux)
```

Y si quiero correr las pruebas que hice de la lógica:

```bash
flutter test
```

## ¿Dónde está cada cosa?

```
lib/
├── main.dart                      # arranque y tema
├── models/transaction.dart        # el modelo y las categorías
├── state/budget_controller.dart   # toda la lógica (sumas, saldo, límite)
├── utils/
│   ├── validators.dart            # las validaciones de los campos
│   └── formatters.dart            # formato de dinero y fechas
├── theme/app_theme.dart           # los colores y el estilo bonito
├── screens/home_screen.dart       # la pantalla principal
└── widgets/                       # encabezado, gráfico, lista, formulario...
```

Usé los paquetes `fl_chart` (para el gráfico de dona) e `intl` (para mostrar el
dinero y las fechas en español).

## Explicación del código

Aquí explico las partes más importantes por si las quieren revisar.

### El modelo (models/transaction.dart)

Aquí defino qué es una transacción y las categorías. Lo interesante es que usé un
`enum` con datos adentro:

```dart
enum Category {
  food('Comida', Icons.restaurant_rounded, Color(0xFFF97316), TransactionType.expense),
  ...
}
```

Cada categoría ya trae su nombre, ícono, color y si es ingreso o gasto. Así no
tengo que andar haciendo `if (categoria == comida) color = naranja` por todos
lados, la categoría ya sabe cómo se ve. El método `Category.byType(tipo)` me
filtra solo las de ingreso o solo las de gasto.

### La lógica de negocio (state/budget_controller.dart)

Es el cerebro. Extiende `ChangeNotifier`, que es lo que hace que la pantalla se
actualice sola: cuando llamo `notifyListeners()`, Flutter redibuja todo lo que
esté escuchando.

Los cálculos son con `fold`, que va sumando una lista:

```dart
double get totalIncome => _transactions
    .where((t) => t.type == TransactionType.income)   // filtra ingresos
    .fold(0.0, (sum, t) => sum + t.amount);            // los suma
```

Y el saldo es simplemente `totalIncome - totalExpense`.

Para el límite, me protejo de dividir entre cero:

```dart
double get limitUsedFraction {
  if (_spendingLimit <= 0) return 0;   // si no hay límite, corto aquí
  return totalExpense / _spendingLimit;
}
```

Si no pusiera ese `if`, dividir entre 0 daría `Infinity` y rompería la barra de
progreso.

### Las validaciones (utils/validators.dart)

Son funciones que devuelven `null` si está bien, o un mensaje de error si está
mal. El truco para detectar letras es `double.tryParse`:

```dart
final parsed = double.tryParse(normalized);
if (parsed == null) return 'Solo se permiten números';  // tenía letras
if (parsed <= 0)   return 'El monto debe ser mayor que 0';
```

`tryParse` intenta convertir el texto a número; si tiene letras devuelve `null` y
ahí lo cacho. El `replaceAll(',', '.')` es para aceptar tanto `19,99` como
`19.99`.

### Cómo se conecta con la pantalla (screens/home_screen.dart)

El `ListenableBuilder` es el que escucha al controlador:

```dart
ListenableBuilder(
  listenable: controller,
  builder: (context, _) { ... }   // esto se redibuja cuando algo cambia
)
```

Por eso, apenas guardo o borro un movimiento, el saldo, el gráfico y la lista se
actualizan todos a la vez sin que yo tenga que refrescar nada a mano.

### Un detalle del formulario (widgets/add_transaction_sheet.dart)

Doble seguridad en el monto: además del validador, le puse un `inputFormatter`
que ni siquiera deja teclear letras:

```dart
inputFormatters: [
  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),  // solo números, punto y coma
],
```

Y antes de guardar, `_formKey.currentState!.validate()` revisa todos los campos
de un golpe; si algo falla, no guarda nada.

Cualquier cosa, ahí está el código comentado.
