import 'package:wallet/wallet.dart';

/// The elliptic curve domain parameters over Fp associated with a Koblitz curve secp256k1 as describe here: https://www.secg.org/sec2-v2.pdf
class Secp256K1 {
  /// 'a' as in the curve E: y2 = x3+ax+b over Fp.
  static final BigInt a = BigInt.from(0);

  /// 'b' as in the curve E: y2 = x3+ax+b over Fp.
  static final BigInt b = BigInt.from(7);

  /// X Component of Generator point G.
  static final BigInt gx = BigInt.parse(
      '79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798',
      radix: 16);

  /// Y Component of Generator point G.
  static final BigInt gy = BigInt.parse(
      '483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8',
      radix: 16);

  /// Order n of the subgroup of EC points.
  static final BigInt n = BigInt.parse(
      'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141',
      radix: 16);

  /// The curve E: y2 = x3+ax+b over Fp is defined by:
  static final BigInt p = BigInt.parse(
      'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F',
      radix: 16);
  static final h = BigInt.from(1);

  PrivateKey generatePrivateKey() {
    return PrivateKey.random();
  }
}
