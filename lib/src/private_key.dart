import 'random_bigint.dart';

/// Represents a private key.
class PrivateKey {
  /// Creates a random private key.
  PrivateKey.random({int length = 32, BigInt? max})
      : value = generateRandomBigInt(length, max);

  /// Secret value.
  final BigInt value;
}
