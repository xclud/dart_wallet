import 'dart:typed_data';

import 'package:hex/hex.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:wallet/src/coin.dart';

void main() {
  test('Ethereum Address from PrivateKey', () {
    final seed = HEX.decode(
        'd494dbd9472bc342acd2397a46ae225702bc3610a710e8c4cc0af3927ed585bd');
    var sk = ethereum.createPrivateKey(Uint8List.fromList(seed));
    var pk = ethereum.createPublicKey(sk);

    var address = ethereum.createAddress(pk);

    expect(address, '0xC26B643D02817FeCEE8aDabd2745e33bc0bA0DED');
  });
}
