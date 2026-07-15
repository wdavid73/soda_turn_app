/// Formatea pesos colombianos sin decimales, ej. 7000 → "$7.000".
String formatCop(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  final sign = value < 0 ? '-' : '';
  return '$sign\$$buffer';
}
