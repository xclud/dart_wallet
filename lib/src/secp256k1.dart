import 'dart:math';
import 'dart:typed_data';

import "package:pointycastle/export.dart" as p;
import 'package:wallet/src/private_key.dart';
import 'package:wallet/src/public_key.dart';
import 'package:collection/collection.dart';

final _domainParams = p.ECCurve_secp256k1();

class Secp256k1 {
  Secp256k1._();

  static PublicKey createPublicKey(PrivateKey privateKey, bool compressed) {
    final q = _domainParams.G * privateKey.value;

    final publicParams = p.ECPublicKey(q, _domainParams);

    return PublicKey(publicParams.Q!.getEncoded(compressed));
  }

  static p.ECSignature generateSignature(
      PrivateKey privateKey, Uint8List message,
      [bool makeCanonical = true]) {
    var signer = p.ECDSASigner();

    var priv =
        p.PrivateKeyParameter(p.ECPrivateKey(privateKey.value, _domainParams));

    final _sGen = Random.secure();
    var ran = p.SecureRandom('Fortuna');
    ran.seed(p.KeyParameter(
        Uint8List.fromList(List.generate(32, (_) => _sGen.nextInt(255)))));

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

  static int calculateRecoveryId(
      p.ECSignature signature, BigInt hash, Uint8List uncompressedPublicKey) {
    var recId = -1;

    for (var i = 0; i < 4; i++) {
      var rec = recoverPubKey(i, signature, hash);
      if (rec != null) {
        var k = rec.getEncoded(false);
        final eq = const ListEquality<int>().equals;
        if (eq(k, uncompressedPublicKey)) {
          recId = i;
          break;
        }
      }
    }
    if (recId == -1) {
      throw Exception(
          'Could not construct a recoverable key. This should never happen.');
    }
    return recId;
  }

  static p.ECPoint? recoverPubKey(int i, p.ECSignature ecSig, BigInt e) {
    final n = _domainParams.n;
    final G = _domainParams.G;

    BigInt r = ecSig.r;
    BigInt s = ecSig.s;

    // A set LSB signifies that the y-coordinate is odd
    int isYOdd = i & 1;

    // The more significant bit specifies whether we should use the
    // first or second candidate key.
    int isSecondKey = i >> 1;

    // 1.1 Let x = r + jn
    BigInt x = isSecondKey > 0 ? r + n : r;
    final R = _domainParams.curve.decompressPoint(isYOdd, x);
    final nR = (R * n)!;
    if (!nR.isInfinity) {
      throw Exception('nR is not a valid curve point');
    }

    BigInt eNeg = (-e) % n;
    BigInt rInv = r.modInverse(n);

    final Q = _sumOfTwoMultiplies(R, s, G, eNeg)! * rInv;
    return Q;
  }
}

p.ECPoint? _sumOfTwoMultiplies(p.ECPoint t, BigInt j, p.ECPoint x, BigInt k) {
  int i = max(j.bitLength, k.bitLength) - 1;
  var R = t.curve.infinity;
  final both = t + x;

  while (i >= 0) {
    bool jBit = _testBit(j, i);
    bool kBit = _testBit(k, i);

    R = R!.twice();

    if (jBit) {
      if (kBit) {
        R = R! + both;
      } else {
        R = R! + t;
      }
    } else if (kBit) {
      R = R! + x;
    }

    --i;
  }

  return R;
}

bool _testBit(BigInt j, int n) {
  return (j >> n).toUnsigned(1).toInt() == 1;
}
