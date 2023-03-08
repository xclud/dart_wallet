import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:eip55/eip55.dart';
import 'package:pointycastle/digests/keccak.dart';
import 'package:pointycastle/digests/ripemd160.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:sec/sec.dart';
import 'base58.dart';
import 'bech32/segwit.dart';
import 'bigint.dart';
import 'der.dart';
import 'private_key.dart';
import 'public_key.dart';

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
      PublicKey(EC.secp256k1.createPublicKey(privateKey.value, true));

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
    final sgn = fromDER(signature);

    final result = EC.secp256k1.verifySignature(publicKey.value, message, sgn);

    return result;
  }
}

class BitcoinBech32 extends Coin {
  const BitcoinBech32([this.version = 0]);

  final int version;

  @override
  PrivateKey createPrivateKey(Uint8List seed) {
    final bn = decodeBigIntWithSign(seed);

    return PrivateKey(bn);
  }

  @override
  PublicKey createPublicKey(PrivateKey privateKey) =>
      PublicKey(EC.secp256k1.createPublicKey(privateKey.value, true));

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
    final sgn = fromDER(signature);

    final result = EC.secp256k1.verifySignature(publicKey.value, message, sgn);

    return result;
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
      PublicKey(EC.secp256k1.createPublicKey(privateKey.value, true));

  @override
  String createAddress(PublicKey publicKey) {
    var compressed = EC.secp256k1.uncompressPublicKey(publicKey.value);
    final input = compressed.sublist(1);

    final address = KeccakDigest(256).process(input);
    final w = address.skip(address.length - 20).toList();

    final h = hex.encode(w);
    final f = toChecksumAddress(h);

    return '0x$f';
  }

  @override
  Uint8List generateSignature(PrivateKey privateKey, Uint8List message) {
    final signature = EC.secp256k1.generateSignature(privateKey.value, message);

    final sgn = toDER(signature);

    return sgn;
  }

  @override
  bool verifySignature(
    PublicKey publicKey,
    Uint8List message,
    Uint8List signature,
  ) {
    final sgn = fromDER(signature);

    final result = EC.secp256k1.verifySignature(publicKey.value, message, sgn);

    return result;
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
      PublicKey(EC.secp256k1.createPublicKey(privateKey.value, false));

  @override
  String createAddress(PublicKey publicKey) {
    var input = Uint8List.fromList(publicKey.value.skip(1).toList());
    var address = KeccakDigest(256).process(input);

    final addr = address.skip(address.length - 20).toList();
    var end = Base58CheckCodec.bitcoin().encode(Base58CheckPayload(0x41, addr));
    return end;
  }

  @override
  Uint8List generateSignature(PrivateKey privateKey, Uint8List message) {
    final signature = EC.secp256k1.generateSignature(privateKey.value, message);

    final sgn = toDER(signature);

    return sgn;
  }

  @override
  bool verifySignature(
    PublicKey publicKey,
    Uint8List message,
    Uint8List signature,
  ) {
    final sgn = fromDER(signature);

    final result = EC.secp256k1.verifySignature(publicKey.value, message, sgn);

    return result;
  }
}
