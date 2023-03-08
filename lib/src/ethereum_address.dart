part of wallet;

String _hexNo0x(Uint8List value) {
  return convert.hex.encode(value);
}

String _hexWith0x(Uint8List value) {
  final h = _hexNo0x(value);
  return '0x$h';
}

String _hexEip55(Uint8List value) {
  final h = _hexNo0x(value);
  return toChecksumAddress(h);
}

/// Represents an Ethereum address.
class EthereumAddress extends Address implements Comparable<EthereumAddress> {
  /// An ethereum address from the raw address bytes.
  EthereumAddress(Uint8List value)
      : assert(value.length == _addressByteLength),
        without0x = _hexNo0x(value),
        with0x = _hexWith0x(value),
        eip55 = _hexEip55(value),
        super(value);

  const EthereumAddress._({
    required Uint8List value,
    required this.without0x,
    required this.with0x,
    required this.eip55,
  })  : assert(value.length == _addressByteLength),
        super(value);

  /// Constructs an Ethereum address from a public key. The address is formed by
  /// the last 20 bytes of the keccak hash of the public key.
  factory EthereumAddress.fromPublicKey(wallet.PublicKey publicKey) {
    final address = wallet.ethereum.createAddress(publicKey);
    return EthereumAddress.fromHex(address);
  }

  /// Parses an Ethereum address from the hexadecimal representation. The
  /// representation must have a length of 20 bytes (or 40 hexadecimal chars),
  /// and can optionally be prefixed with "0x".
  factory EthereumAddress.fromHex(String hex) {
    if (!_basicAddress.hasMatch(hex)) {
      throw ArgumentError.value(
        hex,
        'address',
        'Must be a hex string with a length of 40, optionally prefixed with "0x"',
      );
    }

    final startsWith0x = hex.startsWith('0x') || hex.startsWith('0X');

    final hexNo0x = startsWith0x ? hex.substring(2) : hex;
    final hexWith0x = startsWith0x ? hex : '0x$hex';

    final hexEip55 = toChecksumAddress(hexNo0x);
    final bytes = convert.hex.decode(hexNo0x);

    return EthereumAddress._(
      value: Uint8List.fromList(bytes),
      without0x: hexNo0x.toLowerCase(),
      with0x: hexWith0x.toLowerCase(),
      eip55: hexEip55,
    );
  }

  static final RegExp _basicAddress =
      RegExp(r'^(0x)?[0-9a-f]{40}', caseSensitive: false);

  /// The length of an ethereum address, in bytes.
  static const _addressByteLength = 20;

  /// A hexadecimal representation of this address, padded to a length of 40
  /// characters or 20 bytes, and prefixed with "0x".
  final String with0x;

  /// A hexadecimal representation of this address, padded to a length of 40
  /// characters or 20 bytes, but not prefixed with "0x".
  final String without0x;

  /// Returns this address in a hexadecimal representation, like with [convert.hex].
  /// The hexadecimal characters A-F in the address will be in lower- or
  /// uppercase depending on [EIP 55](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-55.md).
  final String eip55;

  @override
  String toString() => eip55;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is EthereumAddress && eq.equals(value, other.value));
  }

  @override
  int get hashCode {
    return eip55.hashCode;
  }

  @override
  int compareTo(EthereumAddress other) {
    return without0x.compareTo(other.without0x);
  }
}
