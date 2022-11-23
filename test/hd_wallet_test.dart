import 'package:test/test.dart';
import 'package:wallet/wallet.dart';

void main() {
  group('BIP84 Test Vectors.', () {
    final mnemonic = [
      'abandon',
      'abandon',
      'abandon',
      'abandon',
      'abandon',
      'abandon',
      'abandon',
      'abandon',
      'abandon',
      'abandon',
      'abandon',
      'about',
    ];

    final seed = mnemonicToSeed(mnemonic);
    final root = ExtendedPrivateKey.master(seed, zprv);
    final r = root.forPath("m/84'/0'/0'/0/0");

    final sk = PrivateKey((r as ExtendedPrivateKey).key);
    final pk = bitcoinbech32.createPublicKey(sk);
    final bc = bitcoinbech32.createAddress(pk);

    test('BIP32 Root Key.', () {
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

  group('BIP84 Ethereum Test Vectors', () {
    final mnemonic = [
      'kangaroo',
      'surface',
      'fuel',
      'you',
      'list',
      'inflict',
      'fatigue',
      'exist',
      'aspect',
      'appear',
      'oven',
      'cloud',
    ];

    final seed = mnemonicToSeed(mnemonic);
    final root = ExtendedPrivateKey.master(seed, zprv);

    final r = root.forPath("m/84'/60'/0'/0/0");

    final sk = PrivateKey((r as ExtendedPrivateKey).key);
    final pk = bitcoinbech32.createPublicKey(sk);
    final bc = bitcoinbech32.createAddress(pk);

    test('BIP32 Root Key.', () {
      expect(root.toString(),
          'zprvAWgYBBk7JR8GkWZ2T5rYpnrQd3w2DAM1KUExEQ7SaNPVBCYSoB9TuagXppgggUPUefe3j8fhSEQRyprPqn8HuDrprTA9rwTyWME8adsjXHC');
    });

    test('First Address Derivation.', () {
      expect(bc, 'bc1qudg65a5l2savj42mtxkxzz0058qzmf8pp72yh8');
    });
  });

  group('BIP44 Ethereum Test Vectors', () {
    final mnemonic = [
      'into',
      'feed',
      'allow',
      'salt',
      'consider',
      'rebuild',
      'agree',
      'light',
      'lizard',
      'word',
      'foil',
      'bar',
    ];
    final seed = mnemonicToSeed(mnemonic);
    final root = ExtendedPrivateKey.master(seed, xprv);

    final r = root.forPath("m/44'/60'/0'/0/0");

    final sk = PrivateKey((r as ExtendedPrivateKey).key);
    final pk = ethereum.createPublicKey(sk);
    final bc = ethereum.createAddress(pk);

    test('First Address Derivation.', () {
      expect(bc, '0xc5fa0416d75D4e370c9ab865275a0D336F0c043f');
    });
  });

  group('BIP44 Tron Test Vectors', () {
    final mnemonic = [
      'into',
      'feed',
      'allow',
      'salt',
      'consider',
      'rebuild',
      'agree',
      'light',
      'lizard',
      'word',
      'foil',
      'bar',
    ];

    final seed = mnemonicToSeed(mnemonic);
    final root = ExtendedPrivateKey.master(seed, xprv);

    final r = root.forPath("m/44'/195'/0'/0/0");

    final sk = PrivateKey((r as ExtendedPrivateKey).key);
    final pk = tron.createPublicKey(sk);
    final bc = tron.createAddress(pk);

    test('First Address Derivation.', () {
      expect(bc, 'TNFRxT9A4Nx2wDU69keYpLcE8TCSyFztgi');
    });
  });
}
