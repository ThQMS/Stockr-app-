import 'package:equatable/equatable.dart';

final class Money extends Equatable {
  const Money._(this.cents);

  final int cents;

  factory Money.fromCents(int cents) => Money._(cents);

  factory Money.ofReais(String formatted) {
    final normalized = formatted.replaceAll(RegExp(r'[^0-9,-]'), '');
    final isNegative = normalized.startsWith('-');
    final digits = normalized.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      return Money.zero;
    }

    final cents = int.parse(digits);
    return Money._(isNegative ? -cents : cents);
  }

  static const zero = Money._(0);

  String get formatted {
    final absolute = cents.abs();
    final reais = absolute ~/ 100;
    final centavos = absolute % 100;
    final reaisFormatted = _formatThousands(reais);
    final prefix = cents < 0 ? '-R\$' : 'R\$';

    return '$prefix $reaisFormatted,${centavos.toString().padLeft(2, '0')}';
  }

  Money operator +(Money other) => Money._(cents + other.cents);

  Money operator *(int factor) => Money._(cents * factor);

  @override
  List<Object> get props => [cents];

  static String _formatThousands(int value) {
    final raw = value.toString();
    final buffer = StringBuffer();

    for (var index = 0; index < raw.length; index++) {
      final remaining = raw.length - index;
      buffer.write(raw[index]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write('.');
      }
    }

    return buffer.toString();
  }
}
