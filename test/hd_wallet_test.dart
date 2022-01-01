import 'package:test/test.dart';

import 'package:bip39/bip39.dart';
import 'package:wallet/wallet.dart';

void main() {
  test('BIP84 HD Wallet generation.', () {
    const mnemonic =
        'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
    final seed = mnemonicToSeed(mnemonic);
    final root = ExtendedPrivateKey.master(seed, zprv);
    final r = root.forPath("m/84'/0'/0'");

    print(root);
    print(root.publicKey);

    print(r);
    print(r.publicKey);
  });
}
