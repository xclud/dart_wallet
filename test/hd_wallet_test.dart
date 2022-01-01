import 'package:test/test.dart';

import 'package:bip39/bip39.dart';
import 'package:wallet/wallet.dart';

void main() {
  final mnemonic =
      'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
  final seed = mnemonicToSeed(mnemonic);
  final root = ExtendedPrivateKey.master(seed, zprv);
  final r = root.forPath("m/84'/0'/0'/0/0");

  final sk = PrivateKey((r as ExtendedPrivateKey).key);
  final pk = bitcoinbech32.createPublicKey(sk);
  final bc = bitcoinbech32.createAddress(pk);

  group('BIP84 Test Vectors.', () {
    test('ZPRV derivation.', () {
      expect(root.toString(),
          'zprvAWgYBBk7JR8Gjrh4UJQ2uJdG1r3WNRRfURiABBE3RvMXYSrRJL62XuezvGdPvG6GFBZduosCc1YP5wixPox7zhZLfiUm8aunE96BBa4Kei5');
    });

    test('ZPUB derivation.', () {
      expect(root.publicKey.toString(),
          'zpub6jftahH18ngZxLmXaKw3GSZzZsszmt9WqedkyZdezFtWRFBZqsQH5hyUmb4pCEeZGmVfQuP5bedXTB8is6fTv19U1GQRyQUKQGUTzyHACMF');
    });

    test('First Address Derivation.', () {
      expect(bc, 'bc1qcr8te4kr609gcawutmrza0j4xv80jy8z306fyu');
    });
  });
}
