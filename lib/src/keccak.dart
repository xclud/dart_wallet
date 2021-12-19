import 'dart:typed_data';

import 'package:pointycastle/export.dart';

Uint8List keccak(Uint8List input) {
  var digest = KeccakDigest(256);
  var result = Uint8List(digest.digestSize);
  digest.update(input, 0, input.length);
  digest.doFinal(result, 0);

  return result;
}
