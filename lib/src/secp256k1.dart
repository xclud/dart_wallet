import 'dart:math';
import 'dart:typed_data';

import "package:pointycastle/export.dart" as p;
// ignore: implementation_imports
import "package:web3dart/src/crypto/secp256k1.dart" as x;
import 'package:wallet/src/private_key.dart';
import 'package:wallet/src/public_key.dart';
// ignore: implementation_imports
import 'package:pointycastle/src/utils.dart' as utils;
import 'package:web3dart/crypto.dart';

final _domainParams = p.ECCurve_secp256k1();

class Secp256k1 {
  Secp256k1._();

  static p.ECPoint? decodePoint(Uint8List encoded) =>
      _domainParams.curve.decodePoint(encoded);
  static p.ECPublicKey createECPublicKey(Uint8List encoded) =>
      p.ECPublicKey(decodePoint(encoded), _domainParams);

  static PublicKey createPublicKey(PrivateKey privateKey, bool compressed) {
    final q = _domainParams.G * privateKey.value;
    final publicParams = p.ECPublicKey(q, _domainParams);

    return PublicKey(publicParams.Q!.getEncoded(compressed));
  }

  static MsgSignature sign(PrivateKey privateKey, Uint8List message) {
    return x.sign(message, utils.encodeBigIntAsUnsigned(privateKey.value));
  }

  static p.ECSignature generateSignature(
      PrivateKey privateKey, Uint8List message,
      [bool makeCanonical = true]) {
    var signer = p.ECDSASigner();

    var priv =
        p.PrivateKeyParameter(p.ECPrivateKey(privateKey.value, _domainParams));

    final sGen = Random.secure();
    var ran = p.SecureRandom('Fortuna');
    ran.seed(p.KeyParameter(
        Uint8List.fromList(List.generate(32, (_) => sGen.nextInt(255)))));

    signer.init(true, p.ParametersWithRandom(priv, ran));
    var rs = signer.generateSignature(message);
    final signature = rs as p.ECSignature;

    if (makeCanonical) {
      final canonical = signature.normalize(_domainParams);

      return canonical;
    } else {
      return signature;
    }
  }

  static bool verifySignature(
      PublicKey publicKey, Uint8List message, p.ECSignature signature) {
    var signer = p.ECDSASigner();

    var q = _domainParams.curve.decodePoint(publicKey.value);
    var pub = p.PublicKeyParameter(p.ECPublicKey(q, _domainParams));
    signer.init(false, pub);

    var result = signer.verifySignature(message, signature);
    return result;
  }

  static int calculateRecoveryId(MsgSignature signature) {
    final header = signature.v & 0xFF;
    // The header byte: 0x1B = first key with even y, 0x1C = first key with odd y,
    //                  0x1D = second key with even y, 0x1E = second key with odd y
    if (header < 27 || header > 34) {
      throw Exception('Header byte out of range: $header');
    }

    final recId = header - 27;
    return recId;
  }
}
