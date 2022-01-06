import 'dart:typed_data';

import 'package:bech32/bech32.dart';
import 'package:pointycastle/digests/ripemd160.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:wallet/src/base58.dart';
import 'package:wallet/src/bigint.dart';
import 'package:wallet/src/eip55.dart';
import 'package:wallet/src/keccak.dart';
import 'package:wallet/src/private_key.dart';
import 'package:wallet/src/public_key.dart';
import 'package:wallet/src/secp256k1.dart';
import 'package:hex/hex.dart' as hex;

const bitcoin = Bitcoin();
const bitcoinbech32 = BitcoinBech32();
const ethereum = Ethereum();
const tron = Tron();

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

class Bitcoin extends Coin {
  const Bitcoin();

  final int version = 0;

  @override
  PrivateKey createPrivateKey(Uint8List seed) {
    final bn = decodeBigIntWithSign(seed);

    return PrivateKey(bn);
  }

  @override
  PublicKey createPublicKey(PrivateKey privateKey) =>
      Secp256k1.createPublicKey(privateKey, true);

  @override
  String createAddress(PublicKey publicKey) {
    final input = publicKey.value;
    final address = RIPEMD160Digest().process(SHA256Digest().process(input));
    final addr =
        Base58CheckCodec.bitcoin().encode(Base58CheckPayload(version, address));
    return addr;
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

class BitcoinBech32 extends Coin {
  const BitcoinBech32();

  final int version = 0;

  @override
  PrivateKey createPrivateKey(Uint8List seed) {
    final bn = decodeBigIntWithSign(seed);

    return PrivateKey(bn);
  }

  @override
  PublicKey createPublicKey(PrivateKey privateKey) =>
      Secp256k1.createPublicKey(privateKey, true);

  @override
  String createAddress(PublicKey publicKey) {
    final input = publicKey.value;
    final address = RIPEMD160Digest().process(SHA256Digest().process(input));

    final sw = segwit.encode(Segwit('bc', version, address));
    return sw;
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

class Ethereum extends Coin {
  const Ethereum();

  @override
  PrivateKey createPrivateKey(Uint8List seed) {
    final bn = decodeBigIntWithSign(seed);

    return PrivateKey(bn);
  }

  @override
  PublicKey createPublicKey(PrivateKey privateKey) =>
      Secp256k1.createPublicKey(privateKey, false);

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
  const Tron();

  @override
  PrivateKey createPrivateKey(Uint8List seed) {
    final bn = decodeBigIntWithSign(seed);

    return PrivateKey(bn);
  }

  @override
  PublicKey createPublicKey(PrivateKey privateKey) =>
      Secp256k1.createPublicKey(privateKey, false);

  @override
  String createAddress(PublicKey publicKey) {
    var input = Uint8List.fromList(publicKey.value.skip(1).toList());
    var address = keccak(input);

    final addr = address.skip(address.length - 20).toList();
    var end = Base58CheckCodec.bitcoin().encode(Base58CheckPayload(0x41, addr));
    return end;
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
