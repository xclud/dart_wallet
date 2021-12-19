import "package:pointycastle/export.dart" as p;
import 'package:wallet/src/private_key.dart';
import 'package:wallet/src/public_key.dart';

final _domainParams = p.ECCurve_secp256k1();
final _keyParams = p.ECKeyGeneratorParameters(_domainParams);
final _generator = p.ECKeyGenerator()..init(_keyParams);

PublicKey createPublicKey(PrivateKey privateKey, bool compressed) {
  final q = _domainParams.G * privateKey.value;

  final publicParams = p.ECPublicKey(q, _domainParams);

  return PublicKey(publicParams.Q!.getEncoded(compressed));
}
