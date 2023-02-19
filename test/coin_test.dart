import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:wallet/src/coin.dart';

void main() {
  group('Address From Private Key.', () {
    test('Bitcoin Address from PrivateKey.', () {
      final seed = [
        4,
        51,
        163,
        189,
        216,
        243,
        43,
        6,
        119,
        135,
        59,
        192,
        19,
        98,
        88,
        65,
        161,
        44,
        154,
        79,
        107,
        109,
        201,
        89,
        76,
        96,
        141,
        182,
        90,
        218,
        14,
        64,
      ];
      var sk = bitcoin.createPrivateKey(Uint8List.fromList(seed));
      var pk = bitcoin.createPublicKey(sk);

      var address = bitcoin.createAddress(pk);

      expect(address, '17zosTvbKM1zo5BWoY5KrqYNUM2FKbs5Ld');
    });
    test('Ethereum Address from PrivateKey.', () {
      final seed = hex.decode(
          'd494dbd9472bc342acd2397a46ae225702bc3610a710e8c4cc0af3927ed585bd');
      var sk = ethereum.createPrivateKey(Uint8List.fromList(seed));
      var pk = ethereum.createPublicKey(sk);

      var address = ethereum.createAddress(pk);

      expect(address, '0x13EBC8Ed3784342F4F9bbEF80179d834C2F03C85');
    });

    test('Tron Address from PrivateKey.', () {
      final seed = hex.decode(
          'c8fbaa501db9a87b5af2494927c5d0e95ec9ec0e7369cb0c77da6232ab09cf0b');
      var sk = tron.createPrivateKey(Uint8List.fromList(seed));
      var pk = tron.createPublicKey(sk);

      var address = tron.createAddress(pk);

      expect(address, 'TWtUKD9Ztk5WtDeWH8pVGe4mVSH23pFzdn');
    });
  });
}
