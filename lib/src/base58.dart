import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' show sha256;
import 'package:collection/collection.dart' show ListEquality;

/// Encode and decode bytes to base58 strings.
///
/// An alphabet must be provided.
///
/// In order to comply with Bitcoin and Ripple standard encoding Base58Check,
/// use [Base58CheckCodec].

class Base58Codec extends Codec<List<int>, String> {
  const Base58Codec(this.alphabet);
  final String alphabet;

  @override
  Converter<List<int>, String> get encoder => Base58Encoder(alphabet);

  @override
  Converter<String, List<int>> get decoder => Base58Decoder(alphabet);
}

/// Encode bytes to a base58 string.
class Base58Encoder extends Converter<List<int>, String> {
  const Base58Encoder(this.alphabet);
  final String alphabet;

  @override
  String convert(List<int> input) {
    if (input.isEmpty) return '';

    // copy bytes because we are going to change it
    input = Uint8List.fromList(input);

    // count number of leading zeros
    int leadingZeroes = 0;
    while (leadingZeroes < input.length && input[leadingZeroes] == 0) {
      leadingZeroes++;
    }

    String output = '';
    int startAt = leadingZeroes;
    while (startAt < input.length) {
      int mod = _divmod58(input, startAt);
      if (input[startAt] == 0) startAt++;
      output = alphabet[mod] + output;
    }

    if (output.isNotEmpty) {
      while (output[0] == alphabet[0]) {
        output = output.substring(1, output.length);
      }
    }
    while (leadingZeroes-- > 0) {
      output = alphabet[0] + output;
    }

    return output;
  }

  /// number -> number / 58
  /// returns number % 58
  static int _divmod58(List<int> number, int startAt) {
    int remaining = 0;
    for (int i = startAt; i < number.length; i++) {
      int num = (0xFF & remaining) * 256 + number[i];
      number[i] = num ~/ 58;
      remaining = num % 58;
    }
    return remaining;
  }
}

/// Decode base58 strings to bytes.
class Base58Decoder extends Converter<String, List<int>> {
  const Base58Decoder(this.alphabet);
  final String alphabet;

  @override
  List<int> convert(String input) {
    if (input.isEmpty) return Uint8List(0);

    // generate base 58 index list from input string
    var input58 = List<int>.filled(input.length, 0);
    for (int i = 0; i < input.length; i++) {
      int charint = alphabet.indexOf(input[i]);
      if (charint < 0) {
        throw FormatException('Invalid input formatting for Base58 decoding.');
      }
      input58[i] = charint;
    }

    // count leading zeroes
    int leadingZeroes = 0;
    while (leadingZeroes < input58.length && input58[leadingZeroes] == 0) {
      leadingZeroes++;
    }

    // decode
    Uint8List output = Uint8List(input.length);
    int j = output.length;
    int startAt = leadingZeroes;
    while (startAt < input58.length) {
      int mod = _divmod256(input58, startAt);
      if (input58[startAt] == 0) startAt++;
      output[--j] = mod;
    }

    // remove unnecessary leading zeroes
    while (j < output.length && output[j] == 0) {
      j++;
    }
    return output.sublist(j - leadingZeroes);
  }

  /// number -> number / 256
  /// returns number % 256
  static int _divmod256(List<int> number58, int startAt) {
    int remaining = 0;
    for (int i = startAt; i < number58.length; i++) {
      int num = 58 * remaining + (number58[i] & 0xFF);
      number58[i] = num ~/ 256;
      remaining = num % 256;
    }
    return remaining;
  }
}

class Base58CheckPayload {
  const Base58CheckPayload(this.version, this.payload);
  final int version;
  final List<int> payload;
  @override
  bool operator ==(Object other) =>
      other is Base58CheckPayload &&
      version == other.version &&
      const ListEquality().equals(payload, other.payload);
  @override
  int get hashCode => version.hashCode ^ const ListEquality().hash(payload);
}

/// A codec for Base58Check, a binary-to-string encoding used
/// in cryptocurrencies like Bitcoin and Ripple.
///
/// The constructor requires the alphabet and a function that
/// performs a SINGLE-round SHA-256 digest on a [List<int>] and
/// returns a [List<int>] as result.
///
/// For all details about Base58Check, see the Bitcoin wiki page:
/// https://en.bitcoin.it/wiki/Base58Check_encoding
class Base58CheckCodec extends Codec<Base58CheckPayload, String> {
  Base58CheckCodec(this.alphabet)
      : _encoder = Base58CheckEncoder(alphabet),
        _decoder = Base58CheckDecoder(alphabet);

  /// A codec that works with the Ripple alphabet and the SHA256 hash function.
  Base58CheckCodec.ripple() : this(rippleAlphabet);

  /// A codec that works with the Bitcoin alphabet and the SHA256 hash function.
  Base58CheckCodec.bitcoin() : this(bitcoinAlphabet);

  static const bitcoinAlphabet =
      '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

  static const rippleAlphabet =
      'rpshnaf39wBUDNEGHJKLM4PQRST7VWXYZ2bcdeCg65jkm8oFqi1tuvAxyz';

  final String alphabet;

  Base58CheckEncoder _encoder;
  Base58CheckDecoder _decoder;

  @override
  Converter<Base58CheckPayload, String> get encoder => _encoder;

  @override
  Converter<String, Base58CheckPayload> get decoder => _decoder;

  Base58CheckPayload decodeUnchecked(String encoded) =>
      _decoder.convertUnchecked(encoded);
}

class Base58CheckEncoder extends Converter<Base58CheckPayload, String> {
  const Base58CheckEncoder(this.alphabet);
  final String alphabet;

  @override
  String convert(Base58CheckPayload input) {
    Uint8List bytes = Uint8List(input.payload.length + 1 + 4);
    bytes[0] = 0xFF & input.version;
    bytes.setRange(1, bytes.length - 4, input.payload);
    List<int> checksum = _hash(bytes.sublist(0, bytes.length - 4));
    bytes.setRange(bytes.length - 4, bytes.length, checksum.getRange(0, 4));
    return Base58Encoder(alphabet).convert(bytes);
  }
}

List<int> _hash(List<int> b) => sha256.convert(sha256.convert(b).bytes).bytes;

class Base58CheckDecoder extends Converter<String, Base58CheckPayload> {
  const Base58CheckDecoder(this.alphabet);
  final String alphabet;

  @override
  Base58CheckPayload convert(String input) => _convert(input, true);

  Base58CheckPayload convertUnchecked(String encoded) =>
      _convert(encoded, false);

  Base58CheckPayload _convert(String encoded, bool validateChecksum) {
    List<int> bytes = Base58Decoder(alphabet).convert(encoded);
    if (bytes.length < 5) {
      throw FormatException(
          'Invalid Base58Check encoded string: must be at least size 5');
    }
    List<int> checksum = _hash(bytes.sublist(0, bytes.length - 4));
    List<int> providedChecksum = bytes.sublist(bytes.length - 4, bytes.length);
    if (validateChecksum &&
        !ListEquality().equals(providedChecksum, checksum.sublist(0, 4))) {
      throw FormatException('Invalid checksum in Base58Check encoding.');
    }
    return Base58CheckPayload(bytes[0], bytes.sublist(1, bytes.length - 4));
  }
}
