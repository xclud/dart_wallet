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

### Validate an Ethereum address

```dart
import 'package:wallet/wallet.dart' as wallet;

const ethAddress = '0x52908400098527886E0F7030069857D2E4169EE7';
// Verify EIP-55 checksum (accepts lowercase or uppercase as valid)
final isValidEth = wallet.EthereumAddress.isEip55ValidEthereumAddress(ethAddress);
print(isValidEth); // True

// Parse and optionally enforce checksum
final address = wallet.EthereumAddress.fromHex(
  ethAddress,
  enforceEip55: true,
);
print(address); // Mixed-case checksummed address without 0x prefix
```
