part of '../../wallet.dart';

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
        eip55Without0x = _hexEip55(value),
        eip55With0x = '0x${_hexEip55(value)}',
        super(value);

  const EthereumAddress._({
    required Uint8List value,
    required this.without0x,
    required this.with0x,
    required this.eip55Without0x,
    required this.eip55With0x,
  })  : assert(value.length == _addressByteLength),
        super(value);

  /// Constructs an Ethereum address from a public key. The address is formed by
  /// the last 20 bytes of the keccak hash of the public key.
  factory EthereumAddress.fromPublicKey(wallet.PublicKey publicKey) {
    final address = wallet.ethereum.createAddress(publicKey);
    return EthereumAddress.fromHex(address);
  }

  /// Parses an Ethereum address from the hexadecimal representation.
  /// The representation must have a length of 20 bytes (or 40 hexadecimal chars),
  /// and can optionally be prefixed with "0x". If [enforceEip55] is true,
  /// mixed-case addresses must match the EIP-55 checksum; lowercase or
  /// uppercase-only addresses are also accepted.
  factory EthereumAddress.fromHex(
    String hex, {
    bool enforceEip55 = false,
  }) {
    if (!_basicAddress.hasMatch(hex)) {
      throw ArgumentError.value(
        hex,
        'address',
        'Must be a hex string with a length of 40, optionally prefixed with "0x"',
      );
    }
    if (enforceEip55 && !isEip55ValidEthereumAddress(hex)) {
      throw ArgumentError.value(
        hex,
        'address',
        'Address does not conform to EIP-55 checksum',
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
      eip55Without0x: hexEip55,
      eip55With0x: '0x$hexEip55',
    );
  }

  static final RegExp _basicAddress =
      RegExp(r'^(0x)?[0-9a-f]{40}', caseSensitive: false);

  /// The length of an ethereum address, in bytes.
  static const _addressByteLength = 20;
  /// Returns true if the Ethereum address is valid and conforms to the rules of EIP-55.
  /// Fully lowercase or uppercase addresses are accepted. Mixed-case addresses
  /// must match the checksum defined by EIP-55.
  static bool isEip55ValidEthereumAddress(String address) {
    // Basic hex string validation (40 hex chars, optional 0x prefix).
    if (!_basicAddress.hasMatch(address)) {
      return false;
    }
    // Remove 0x prefix if present.
    final noPrefix = address.startsWith('0x') || address.startsWith('0X')
        ? address.substring(2)
        : address;
    // All lowercase or all uppercase are valid without checksum.
    if (noPrefix.toLowerCase() == noPrefix || noPrefix.toUpperCase() == noPrefix) {
      return true;
    }
    // Mixed-case: verify against checksum.
    try {
      return toChecksumAddress(noPrefix) == noPrefix;
    } catch (_) {
      return false;
    }
  }

  /// A hexadecimal representation of this address, padded to a length of 40
  /// characters or 20 bytes, and prefixed with "0x".
  final String with0x;

  /// A hexadecimal representation of this address, padded to a length of 40
  /// characters or 20 bytes, but not prefixed with "0x".
  final String without0x;

  /// Returns this address in a hexadecimal representation, like with [convert.hex].
  /// The hexadecimal characters A-F in the address will be in lower- or
  /// uppercase depending on [EIP 55](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-55.md).
  final String eip55Without0x;

  /// Returns this address in a hexadecimal representation, like with [convert.hex].
  /// The hexadecimal characters A-F in the address will be in lower- or
  /// uppercase depending on [EIP 55](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-55.md).
  final String eip55With0x;

  @override
  String toString() => eip55Without0x;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is EthereumAddress && eq.equals(value, other.value));
  }

  @override
  int get hashCode {
    return eip55Without0x.hashCode;
  }

  @override
  int compareTo(EthereumAddress other) {
    return without0x.compareTo(other.without0x);
  }
}
