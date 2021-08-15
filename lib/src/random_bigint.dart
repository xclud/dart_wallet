import 'dart:math';

/// Generates a random [BigInt] which is [length] bytes and is smaller than [max].
BigInt generateRandomBigInt(int length, [BigInt? max = null]) {
  final rnd = Random.secure();

  BigInt v;

  do {
    final buffer = StringBuffer();

    for (int i = 0; i < length * 2; i++) {
      final index = rnd.nextInt(16);
      final char = _hexValues[index];
      buffer.write(char);
    }

    v = BigInt.parse(buffer.toString(), radix: 16);
  } while (max != null && v >= max);

  return v;
}

final _hexValues = [
  '0',
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
];
