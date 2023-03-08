import 'dart:typed_data';

const _standardAlphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
const _hexAlphabet = '0123456789ABCDEFGHIJKLMNOPQRSTUV';
const _crockfordAlphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
const _zbase32Alphabet = 'ybndrfg8ejkmcpqxot1uwisza345h769';
const _geohashAlphabet = '0123456789bcdefghjkmnpqrstuvwxyz';

final base32 = Base32();
final base32Hex = Base32.hex();
final crockford = Base32.crockford();
final zbase32 = Base32.zbase32();
final geohash = Base32.geohash();

class Base32 {
  Base32()
      : _alphabet = _standardAlphabet,
        _validator = RegExp(r'^[A-Z2-7=]+$'),
        _charToIndex = _buildCharToIndexMap(_standardAlphabet),
        _padded = true;

  Base32.hex()
      : _alphabet = _hexAlphabet,
        _validator = RegExp(r'^[0-9A-V=]+$'),
        _charToIndex = _buildCharToIndexMap(_hexAlphabet),
        _padded = true;

  Base32.crockford()
      : _alphabet = _crockfordAlphabet,
        _validator = RegExp(r'^[0123456789ABCDEFGHJKMNPQRSTVWXYZ-]+$'),
        _charToIndex = _buildCharToIndexMap(_crockfordAlphabet),
        _padded = false;

  Base32.zbase32()
      : _alphabet = _zbase32Alphabet,
        _validator = RegExp(r'^[ybndrfg8ejkmcpqxot1uwisza345h769]+$'),
        _charToIndex = _buildCharToIndexMap(_zbase32Alphabet),
        _padded = false;

  Base32.geohash()
      : _alphabet = _geohashAlphabet,
        _validator = RegExp(r'^[0123456789bcdefghjkmnpqrstuvwxyz=]+$'),
        _charToIndex = _buildCharToIndexMap(_geohashAlphabet),
        _padded = true;

  final String _alphabet;
  final RegExp _validator;
  final Map<String, int> _charToIndex;
  final bool _padded;

  static Map<String, int> _buildCharToIndexMap(String alphabet) {
    final map = <String, int>{};
    for (var i = 0; i < 32; i++) {
      map[alphabet[i]] = i;
    }
    return map;
  }

  /// Takes in an input and converts it to a Uint8List so that we can run
  /// bit operations on it, then outputs a [String] representation of the
  /// base32.
  String encode(Uint8List input) {
    var base32Chars = _alphabet;
    var i = 0;
    var count = (input.length ~/ 5) * 5;
    var base32str = '';
    while (i < count) {
      var v1 = input[i++];
      var v2 = input[i++];
      var v3 = input[i++];
      var v4 = input[i++];
      var v5 = input[i++];

      base32str += base32Chars[v1 >> 3] +
          base32Chars[(v1 << 2 | v2 >> 6) & 31] +
          base32Chars[(v2 >> 1) & 31] +
          base32Chars[(v2 << 4 | v3 >> 4) & 31] +
          base32Chars[(v3 << 1 | v4 >> 7) & 31] +
          base32Chars[(v4 >> 2) & 31] +
          base32Chars[(v4 << 3 | v5 >> 5) & 31] +
          base32Chars[v5 & 31];
    }

    var remain = input.length - count;
    if (remain == 1) {
      var v1 = input[i];
      base32str += base32Chars[v1 >> 3] + base32Chars[(v1 << 2) & 31];
      if (_padded) {
        base32str += '======';
      }
    } else if (remain == 2) {
      var v1 = input[i++];
      var v2 = input[i];
      base32str += base32Chars[v1 >> 3] +
          base32Chars[(v1 << 2 | v2 >> 6) & 31] +
          base32Chars[(v2 >> 1) & 31] +
          base32Chars[(v2 << 4) & 31];
      if (_padded) {
        base32str += '====';
      }
    } else if (remain == 3) {
      var v1 = input[i++];
      var v2 = input[i++];
      var v3 = input[i];
      base32str += base32Chars[v1 >> 3] +
          base32Chars[(v1 << 2 | v2 >> 6) & 31] +
          base32Chars[(v2 >> 1) & 31] +
          base32Chars[(v2 << 4 | v3 >> 4) & 31] +
          base32Chars[(v3 << 1) & 31];
      if (_padded) {
        base32str += '===';
      }
    } else if (remain == 4) {
      var v1 = input[i++];
      var v2 = input[i++];
      var v3 = input[i++];
      var v4 = input[i];
      base32str += base32Chars[v1 >> 3] +
          base32Chars[(v1 << 2 | v2 >> 6) & 31] +
          base32Chars[(v2 >> 1) & 31] +
          base32Chars[(v2 << 4 | v3 >> 4) & 31] +
          base32Chars[(v3 << 1 | v4 >> 7) & 31] +
          base32Chars[(v4 >> 2) & 31] +
          base32Chars[(v4 << 3) & 31];
      if (_padded) {
        base32str += '=';
      }
    }
    return base32str;
  }

  static Uint8List _hexDecode(final String input) => Uint8List.fromList([
        for (int i = 0; i < input.length; i += 2)
          int.parse(input.substring(i, i + 2), radix: 16),
      ]);

  static String _hexEncode(final Uint8List input) => [
        for (int i = 0; i < input.length; i++)
          input[i].toRadixString(16).padLeft(2, '0')
      ].join();

  /// Takes in a hex string, converts the string to a byte list
  /// and runs a normal encode() on it. Returning a [String] representation
  /// of the base32.
  String encodeHexString(String input) {
    return encode(_hexDecode(input));
  }

  /// Takes in a [utf8string], converts the string to a byte list
  /// and runs a normal encode() on it. Returning a [String] representation
  /// of the base32.
  String encodeString(String utf8string) {
    return encode(Uint8List.fromList(utf8string.codeUnits));
  }

  /// Takes in an [input] string and decodes it back to a [String] in hex format.
  String decodeAsHexString(
    String input,
  ) {
    return _hexEncode(decode(input));
  }

  /// Takes in a [base32] string and decodes it back to a [String].
  String decodeAsString(String base32) {
    return decode(base32)
        .toList()
        .map((charCode) => String.fromCharCode(charCode))
        .join();
  }

  /// Takes in a [input] string and decodes it back to a [Uint8List] that can be
  /// converted to a hex string using hexEncode
  Uint8List decode(String input) {
    if (input.isEmpty) {
      return Uint8List(0);
    }
    if (!_isValid(input)) {
      throw FormatException('Invalid Base32 characters');
    }

    // Handle crockford dashes.
    input = input.replaceAll('-', '');

    var base32Decode = _charToIndex;
    var length = input.indexOf('=');
    if (length == -1) {
      length = input.length;
    }

    var i = 0;
    var count = length >> 3 << 3;
    var bytes = <int>[];
    while (i < count) {
      var v1 = base32Decode[input[i++]] ?? 0;
      var v2 = base32Decode[input[i++]] ?? 0;
      var v3 = base32Decode[input[i++]] ?? 0;
      var v4 = base32Decode[input[i++]] ?? 0;
      var v5 = base32Decode[input[i++]] ?? 0;
      var v6 = base32Decode[input[i++]] ?? 0;
      var v7 = base32Decode[input[i++]] ?? 0;
      var v8 = base32Decode[input[i++]] ?? 0;
      bytes.add((v1 << 3 | v2 >> 2) & 255);
      bytes.add((v2 << 6 | v3 << 1 | v4 >> 4) & 255);
      bytes.add((v4 << 4 | v5 >> 1) & 255);
      bytes.add((v5 << 7 | v6 << 2 | v7 >> 3) & 255);
      bytes.add((v7 << 5 | v8) & 255);
    }

    var remain = length - count;
    if (remain == 2) {
      var v1 = base32Decode[input[i++]] ?? 0;
      var v2 = base32Decode[input[i++]] ?? 0;
      bytes.add((v1 << 3 | v2 >> 2) & 255);
    } else if (remain == 4) {
      var v1 = base32Decode[input[i++]] ?? 0;
      var v2 = base32Decode[input[i++]] ?? 0;
      var v3 = base32Decode[input[i++]] ?? 0;
      var v4 = base32Decode[input[i++]] ?? 0;
      bytes.add((v1 << 3 | v2 >> 2) & 255);
      bytes.add((v2 << 6 | v3 << 1 | v4 >> 4) & 255);
    } else if (remain == 5) {
      var v1 = base32Decode[input[i++]] ?? 0;
      var v2 = base32Decode[input[i++]] ?? 0;
      var v3 = base32Decode[input[i++]] ?? 0;
      var v4 = base32Decode[input[i++]] ?? 0;
      var v5 = base32Decode[input[i++]] ?? 0;
      bytes.add((v1 << 3 | v2 >> 2) & 255);
      bytes.add((v2 << 6 | v3 << 1 | v4 >> 4) & 255);
      bytes.add((v4 << 4 | v5 >> 1) & 255);
    } else if (remain == 7) {
      var v1 = base32Decode[input[i++]] ?? 0;
      var v2 = base32Decode[input[i++]] ?? 0;
      var v3 = base32Decode[input[i++]] ?? 0;
      var v4 = base32Decode[input[i++]] ?? 0;
      var v5 = base32Decode[input[i++]] ?? 0;
      var v6 = base32Decode[input[i++]] ?? 0;
      var v7 = base32Decode[input[i++]] ?? 0;
      bytes.add((v1 << 3 | v2 >> 2) & 255);
      bytes.add((v2 << 6 | v3 << 1 | v4 >> 4) & 255);
      bytes.add((v4 << 4 | v5 >> 1) & 255);
      bytes.add((v5 << 7 | v6 << 2 | v7 >> 3) & 255);
    }
    return Uint8List.fromList(bytes);
  }

  bool _isValid(String b32str) {
    var regex = _validator;
    if (b32str.length % 2 != 0 || !regex.hasMatch(b32str)) {
      return false;
    }
    return true;
  }
}
