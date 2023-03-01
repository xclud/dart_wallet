Crypto wallet package for Bitcoin, Ethereum and Tron written in pure Dart.

## Getting started

In your `pubspec.yaml` file add:

```dart
dependencies:
  wallet: any
```

## Usage

### Create Tron address from Mnemonic and Passphrase

```dart
import 'package:wallet/wallet.dart' as wallet;

final mnemonic = '<YOUR MNEMONIC>';
final passphrase = '';

final seed = wallet.mnemonicToSeed(mnemonic, passphrase: passphrase);
final master = wallet.ExtendedPrivateKey.master(seed, wallet.xprv);
final root = master.forPath("m/44'/195'/0'/0/0");

final privateKey = wallet.PrivateKey((root as wallet.ExtendedPrivateKey).key);
final publicKey = wallet.tron.createPublicKey(privateKey);
final address = wallet.tron.createAddress(publicKey);

print(address);
```

### Validate a Tron address

```dart
import 'package:wallet/wallet.dart' as wallet;

const address = 'TCB9WxaRSMEXiVaVys9DEAXbRc6JNuKpjA';
final isValid = wallet.isValidTronAddress(address);

print(isValid); // True
```
