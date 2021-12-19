import 'dart:typed_data';

import 'package:hex/hex.dart';
import 'package:wallet/src/keccak.dart';

String toChecksumAddress(String data) {
  var o = Uint8List(data.length);
  var w = Uint8List.fromList(data.toLowerCase().codeUnits);
  var sha = HEX.encode(keccak(w));

  for (int i = 0; i < data.length; i++) {
    var n = int.parse(sha[i], radix: 16);
    if (n > 8) {
      o[i] = data[i].toUpperCase().codeUnits[0];
    } else {
      o[i] = data[i].toLowerCase().codeUnits[0];
    }
  }

  return String.fromCharCodes(o);
}
