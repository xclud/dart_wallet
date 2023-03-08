/// Crypto wallet package for Bitcoin, Ethereum and Tron written in pure Dart.
library wallet;

import 'dart:typed_data';

import 'package:convert/convert.dart' as convert;
import 'package:eip55/eip55.dart';
import 'src/base58.dart';
import 'src/equality.dart' as eq;
import 'wallet.dart' as wallet;

export 'src/bech32/bech32.dart';
export 'src/bech32/exceptions.dart';
export 'src/bech32/segwit.dart';
export 'src/bip32/bip32.dart';
export 'src/bip32/exceptions.dart';
export 'src/bip39/bip39.dart';
export 'src/coin.dart';
export 'src/private_key.dart';
export 'src/public_key.dart';

part 'src/address.dart';
part 'src/ethereum_address.dart';
part 'src/helpers/tron_helpers.dart';

const zpub = [0x04, 0xb2, 0x47, 0x46];
const zprv = [0x04, 0xb2, 0x43, 0x0c];
const vpub = [0x04, 0x5f, 0x1c, 0xf6];
const vprv = [0x04, 0x5f, 0x18, 0xbc];

const xpub = [0x04, 0x88, 0xB2, 0x1E];
const xprv = [0x04, 0x88, 0xAD, 0xE4];
const tpub = [0x04, 0x35, 0x87, 0xCF];
const tprv = [0x04, 0x35, 0x83, 0x94];
