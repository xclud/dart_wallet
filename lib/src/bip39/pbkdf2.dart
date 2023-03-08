import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

const _saltPrefix = 'mnemonic';

/// Password-Based Key Derivation Function 2.
Uint8List pbkdf2(
  List<String> mnemonic, {
  String passphrase = '',
  int blockLength = 128,
  int iterationCount = 2048,
  int desiredKeyLength = 64,
}) {
  final derivator = PBKDF2KeyDerivator(HMac(SHA512Digest(), blockLength));
  final salt = Uint8List.fromList(utf8.encode(_saltPrefix + passphrase));

  derivator.init(Pbkdf2Parameters(salt, iterationCount, desiredKeyLength));

  final codeUnits = <int>[];
  for (final word in mnemonic) {
    codeUnits.addAll(word.codeUnits);
    codeUnits.add(32); //Space.
  }

  codeUnits.removeLast();

  return derivator.process(Uint8List.fromList(codeUnits));
}
