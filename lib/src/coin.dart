import 'dart:typed_data';

import 'package:wallet/src/private_key.dart';
import 'package:wallet/src/public_key.dart';

abstract class Coin {
  /// Creates a public key from the given private key.
  PrivateKey createPrivateKey(Uint8List seed);
  PublicKey createPublicKey(PrivateKey privateKey);
  String createAddress(PublicKey publicKey);

  Uint8List generateSignature(PrivateKey privateKey, Uint8List message);
  bool verifySignature(
      PublicKey publicKey, Uint8List message, Uint8List signature);
}

class Ethereum extends Coin {
  @override
  PrivateKey createPrivateKey(Uint8List seed) {
    throw UnimplementedError();
  }

  @override
  PublicKey createPublicKey(PrivateKey privateKey) {
    throw UnimplementedError();
  }

  @override
  String createAddress(PublicKey publicKey) {
    throw UnimplementedError();
  }

  @override
  Uint8List generateSignature(PrivateKey privateKey, Uint8List message) {
    throw UnimplementedError();
  }

  @override
  bool verifySignature(
      PublicKey publicKey, Uint8List message, Uint8List signature) {
    throw UnimplementedError();
  }
}

class Tron extends Coin {
  @override
  PrivateKey createPrivateKey(Uint8List seed) {
    throw UnimplementedError();
  }

  @override
  PublicKey createPublicKey(PrivateKey privateKey) {
    throw UnimplementedError();
  }

  @override
  String createAddress(PublicKey publicKey) {
    throw UnimplementedError();
  }

  @override
  Uint8List generateSignature(PrivateKey privateKey, Uint8List message) {
    throw UnimplementedError();
  }

  @override
  bool verifySignature(
      PublicKey publicKey, Uint8List message, Uint8List signature) {
    throw UnimplementedError();
  }
}
