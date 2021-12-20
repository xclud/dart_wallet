import 'dart:typed_data';

import 'package:hex/hex.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:wallet/src/coin.dart';

void main() {
  group('Address From Private Key', () {
    test('Ethereum Address from PrivateKey', () {
      final seed = HEX.decode(
          'd494dbd9472bc342acd2397a46ae225702bc3610a710e8c4cc0af3927ed585bd');
      var sk = ethereum.createPrivateKey(Uint8List.fromList(seed));
      var pk = ethereum.createPublicKey(sk);

      var address = ethereum.createAddress(pk);

      expect(address, '0xC26B643D02817FeCEE8aDabd2745e33bc0bA0DED');
    });

    test('Tron Address from PrivateKey', () {
      final seed = HEX.decode(
          'c8fbaa501db9a87b5af2494927c5d0e95ec9ec0e7369cb0c77da6232ab09cf0b');
      var sk = tron.createPrivateKey(Uint8List.fromList(seed));
      var pk = tron.createPublicKey(sk);

      var address = tron.createAddress(pk);

      expect(address, 'TWtUKD9Ztk5WtDeWH8pVGe4mVSH23pFzdn');
    });
  });
}
