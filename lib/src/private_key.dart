import 'random_bigint.dart';

/// Represents a private key.
class PrivateKey {
  /// Secret value.
  final BigInt value;

  /// Creates a random private key.
  PrivateKey.random({int length = 32, BigInt? max = null})
      : value = generateRandomBigInt(length, max);
}
