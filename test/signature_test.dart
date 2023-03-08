import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:pointycastle/export.dart';
import 'package:sec/sec.dart';
import 'package:test/test.dart';
import 'package:wallet/src/bigint.dart';
import 'package:wallet/wallet.dart' as w;

void main() {
  test('Tron transaction signature verification.', () {
    final sk = w.PrivateKey(BigInt.parse(
        'c57304b3a53051600d7035fc593083810a8fa250e6a7a2803cf6a0f3c2750503',
        radix: 16));
    final pk = w.tron.createPublicKey(sk);
    final message = Uint8List.fromList(hex.decode(
        '491c81e567b1cc3194e3c573fb433546b4f51c8ad7a363e7dfbbaea78d26aedc'));

    final signature = EC.secp256k1.generateSignature(sk.value, message);

    final result = EC.secp256k1.verifySignature(pk.value, message, signature);

    expect(result, true);
  });

  test('Tron transaction signature verification.', () {
    final sk = w.PrivateKey(BigInt.parse(
        'c57304b3a53051600d7035fc593083810a8fa250e6a7a2803cf6a0f3c2750503',
        radix: 16));
    final pk = w.tron.createPublicKey(sk);
    final message = Uint8List.fromList(hex.decode(
        '491c81e567b1cc3194e3c573fb433546b4f51c8ad7a363e7dfbbaea78d26aedc'));

    final signatureBytes = Uint8List.fromList(hex.decode(
        '9a941ec8e4fd80a881ab8d32073597a55ec0ae1c62739d46bdc7ccd10ca0439f337efbaa0e5ab981baeb8196fbaec57cca9667e8404d47afcf1331d30f97495e00'));

    final r = decodeBigIntWithSign(signatureBytes.take(32).toList());
    final s = decodeBigIntWithSign(signatureBytes.skip(32).take(32).toList());
    final signature = ECSignature(r, s);

    final result = EC.secp256k1.verifySignature(pk.value, message, signature);

    expect(result, true);
  });
}
