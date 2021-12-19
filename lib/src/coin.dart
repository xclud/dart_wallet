import 'dart:typed_data';

import 'package:wallet/src/bigint.dart';
import 'package:wallet/src/eip55.dart';
import 'package:wallet/src/keccak.dart';
import 'package:wallet/src/private_key.dart';
import 'package:wallet/src/public_key.dart';
import 'package:wallet/src/secp256k1.dart' as secp256k1;
import 'package:hex/hex.dart' as hex;

const ethereum = Ethereum();

abstract class Coin {
  const Coin();

  /// Creates a public key from the given private key.
  PrivateKey createPrivateKey(Uint8List seed);
  PublicKey createPublicKey(PrivateKey privateKey);
  String createAddress(PublicKey publicKey);

  Uint8List generateSignature(PrivateKey privateKey, Uint8List message);
  bool verifySignature(
      PublicKey publicKey, Uint8List message, Uint8List signature);
}

class Ethereum extends Coin {
  const Ethereum();

  @override
  PrivateKey createPrivateKey(Uint8List seed) {
    final bn = bigIntFromUint8List(seed);

    return PrivateKey(bn);
  }

  @override
  PublicKey createPublicKey(PrivateKey privateKey) =>
      secp256k1.createPublicKey(privateKey, false);

  @override
  String createAddress(PublicKey publicKey) {
    final input = Uint8List.fromList(publicKey.value.skip(1).toList());

    final address = keccak(input);
    final w = address.skip(address.length - 20).toList();

    final h = hex.HEX.encode(w);
    final f = toChecksumAddress(h);

    return '0x$f';
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
