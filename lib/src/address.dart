part of wallet;

/// Represents an address.
class Address {
  /// Creates an address.
  const Address(this.value);

  /// Value of the public key.
  final Uint8List value;
}
