import 'dart:typed_data';

/// Represents a public key.
class PublicKey {
  /// Creates a public key.
  const PublicKey(this.value);

  /// Value of the public key.
  final Uint8List value;
}
