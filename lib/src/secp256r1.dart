import "package:pointycastle/export.dart";

final _domainParams = ECCurve_secp256r1();
final _keyParams = ECKeyGeneratorParameters(_domainParams);
final _generator = ECKeyGenerator();
