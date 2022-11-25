import 'dart:typed_data';

import 'package:pointycastle/asn1.dart';
import 'package:pointycastle/export.dart';

Uint8List toDER(ECSignature rs) {
  final seq = ASN1Sequence()
    ..add(ASN1Integer(rs.r))
    ..add(ASN1Integer(rs.s));

  return seq.encode(encodingRule: ASN1EncodingRule.ENCODING_DER);
}

ECSignature fromDER(Uint8List input) {
  final parser = ASN1Parser(input);

  final r = parser.nextObject() as ASN1Integer;
  final s = parser.nextObject() as ASN1Integer;

  return ECSignature(r.integer!, s.integer!);
}
