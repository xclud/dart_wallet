import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/digests/sha256.dart';
import 'pbkdf2.dart';
import 'words/english.dart';

const int _sizeByte = 255;
const _invalidMnemonic = 'Invalid mnemonic';
const _invalidEntropy = 'Invalid entropy';
const _invalidChecksum = 'Invalid mnemonic checksum';

int _binaryToByte(String binary) {
  return int.parse(binary, radix: 2);
}

String _bytesToBinary(Uint8List bytes) {
  return bytes.map((byte) => byte.toRadixString(2).padLeft(8, '0')).join('');
}

String _deriveChecksumBits(Uint8List entropy) {
  final ent = entropy.length * 8;
  final cs = ent ~/ 32;
  final hash = SHA256Digest().process(entropy);
  return _bytesToBinary(hash).substring(0, cs);
}

Uint8List _randomBytes(int size) {
  final rng = Random.secure();
  final bytes = Uint8List(size);
  for (var i = 0; i < size; i++) {
    bytes[i] = rng.nextInt(_sizeByte);
  }
  return bytes;
}

List<String> generateMnemonic({
  int strength = 128,
  Uint8List Function(int size) randomBytes = _randomBytes,
}) {
  assert(strength % 32 == 0);
  final entropy = randomBytes(strength ~/ 8);
  return entropyToMnemonic(entropy);
}

List<String> entropyToMnemonic(Uint8List entropy) {
  if (entropy.length < 16) {
    throw ArgumentError(_invalidEntropy);
  }
  if (entropy.length > 32) {
    throw ArgumentError(_invalidEntropy);
  }
  if (entropy.length % 4 != 0) {
    throw ArgumentError(_invalidEntropy);
  }
  final entropyBits = _bytesToBinary(entropy);
  final checksumBits = _deriveChecksumBits(entropy);
  final bits = entropyBits + checksumBits;
  final regex = RegExp(r'.{1,11}', caseSensitive: false, multiLine: false);
  final chunks = regex
      .allMatches(bits)
      .map((match) => match.group(0)!)
      .toList(growable: false);

  final wordlist = english;

  final words = chunks
      .map((binary) => wordlist[_binaryToByte(binary)])
      .toList(growable: false);

  return words;
}

Uint8List mnemonicToSeed(List<String> mnemonic, {String passphrase = ''}) {
  return pbkdf2(mnemonic, passphrase: passphrase);
}

String mnemonicToSeedHex(List<String> mnemonic, {String passphrase = ''}) {
  return mnemonicToSeed(mnemonic, passphrase: passphrase).map((byte) {
    return byte.toRadixString(16).padLeft(2, '0');
  }).join('');
}

bool validateMnemonic(List<String> words) {
  try {
    mnemonicToEntropy(words);
  } catch (e) {
    return false;
  }
  return true;
}

Uint8List mnemonicToEntropy(List<String> mnemonic) {
  if (mnemonic.length % 3 != 0) {
    throw ArgumentError(_invalidMnemonic);
  }
  final wordlist = english;
  // convert word indices to 11 bit binary strings
  final bits = mnemonic.map((word) {
    final index = wordlist.indexOf(word);
    if (index == -1) {
      throw ArgumentError(_invalidMnemonic);
    }
    return index.toRadixString(2).padLeft(11, '0');
  }).join('');
  // split the binary string into ENT/CS
  final dividerIndex = (bits.length / 33).floor() * 32;
  final entropyBits = bits.substring(0, dividerIndex);
  final checksumBits = bits.substring(dividerIndex);

  // calculate the checksum and compare
  final regex = RegExp(r'.{1,8}');
  final entropyBytes = Uint8List.fromList(regex
      .allMatches(entropyBits)
      .map((match) => _binaryToByte(match.group(0)!))
      .toList(growable: false));
  if (entropyBytes.length < 16) {
    throw StateError(_invalidEntropy);
  }
  if (entropyBytes.length > 32) {
    throw StateError(_invalidEntropy);
  }
  if (entropyBytes.length % 4 != 0) {
    throw StateError(_invalidEntropy);
  }
  final newChecksum = _deriveChecksumBits(entropyBytes);
  if (newChecksum != checksumBits) {
    throw StateError(_invalidChecksum);
  }

  return entropyBytes;
}
