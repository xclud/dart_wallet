import 'dart:typed_data';

import "package:pointycastle/export.dart" as p;
import 'package:wallet/src/der.dart';
import 'package:wallet/src/private_key.dart';
import 'package:wallet/src/public_key.dart';

final _domainParams = p.ECCurve_secp256r1();

PublicKey createPublicKey(PrivateKey privateKey, bool compressed) {
  final q = _domainParams.G * privateKey.value;

  final publicParams = p.ECPublicKey(q, _domainParams);

  return PublicKey(publicParams.Q!.getEncoded(compressed));
}

Uint8List generateSignature(PrivateKey privateKey, Uint8List message) {
  var signer = p.ECDSASigner();

  var priv =
      p.PrivateKeyParameter(p.ECPrivateKey(privateKey.value, _domainParams));
  signer.init(true, priv);
  var rs = signer.generateSignature(message);

  return toDER(rs as p.ECSignature);
}

bool verifySignature(
    PublicKey publicKey, Uint8List message, Uint8List signature) {
  var signer = p.ECDSASigner();

  var q = _domainParams.curve.decodePoint(publicKey.value);
  var pub = p.PublicKeyParameter(p.ECPublicKey(q, _domainParams));
  signer.init(false, pub);

  var rs = fromDER(signature);

  var r = rs[0];
  var s = rs[1];

  var result = signer.verifySignature(message, p.ECSignature(r, s));
  return result;
}
