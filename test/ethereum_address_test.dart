import 'package:test/test.dart';
import 'package:wallet/wallet.dart';

void main() {
  const eip55MixedCase = '0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed';
  const eip55InvalidMixedCase = '0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAED';

  group('fromHex with enforceEip55=true', () {
    test('accepts valid EIP-55 mixed-case address', () {
      final addr = EthereumAddress.fromHex(eip55MixedCase, enforceEip55: true);
      expect(addr.eip55With0x, equals(eip55MixedCase));
    });

    test('accepts all-lowercase address', () {
      final lowerCase = eip55MixedCase.toLowerCase();
      final addr = EthereumAddress.fromHex(lowerCase, enforceEip55: true);
      expect(addr.eip55With0x, equals(eip55MixedCase));
    });

    test('accepts all-uppercase address', () {
      final upperCase = eip55MixedCase.toUpperCase();
      final addr = EthereumAddress.fromHex(upperCase, enforceEip55: true);
      expect(addr.eip55With0x, equals(eip55MixedCase));
    });

    test('rejects invalid mixed-case checksum', () {
      expect(
        () => EthereumAddress.fromHex(eip55InvalidMixedCase, enforceEip55: true),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('fromHex without enforceEip55 (default/enforced=false)', () {
    test('accepts valid EIP-55 mixed-case address', () {
      final addr = EthereumAddress.fromHex(eip55MixedCase);
      expect(addr.eip55With0x, equals(eip55MixedCase));
    });

    test('accepts all-lowercase address', () {
      final lowerCase = eip55MixedCase.toLowerCase();
      final addr = EthereumAddress.fromHex(lowerCase);
      expect(addr.eip55With0x, equals(eip55MixedCase));
    });

    test('accepts all-uppercase address', () {
      final upperCase = eip55MixedCase.toUpperCase();
      final addr = EthereumAddress.fromHex(upperCase);
      expect(addr.eip55With0x, equals(eip55MixedCase));
    });

    test('accepts invalid mixed-case checksum!', () {
      final addr = EthereumAddress.fromHex(eip55InvalidMixedCase);
      expect(addr.eip55With0x, equals(eip55MixedCase));
    });
  });
}
