import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:wallet/src/base32.dart';

void main() {
  String hexEncode(final Uint8List input) => [
        for (int i = 0; i < input.length; i++)
          input[i].toRadixString(16).padLeft(2, '0')
      ].join();

  group('[Decode]', () {
    test('[RFC4648] JBSWY3DPEHPK3PXP -> 48656c6c6f21deadbeef', () {
      var decoded = base32.decode('JBSWY3DPEHPK3PXP');
      var decodedString = hexEncode(decoded);

      expect(decodedString.toString(), equals('48656c6c6f21deadbeef'));
    });

    test('[RFC4648] JBSWY3DPEHPK3PXPF throws FormatException', () {
      expect(() => base32.decode('JBSWY3DPEHPK3PXPF'),
          throwsA(TypeMatcher<FormatException>()));
    });

    test('[base32Hex] 91IMOR3F47FARFNF -> 48656c6c6f21deadbeef', () {
      var decoded = base32Hex.decode('91IMOR3F47FARFNF');
      var decodedString = hexEncode(decoded);

      expect(decodedString.toString(), equals('48656c6c6f21deadbeef'));
    });

    test('[base32Hex] 91IMOR3F47FARFNFF throws FormatException', () {
      expect(() => base32Hex.decode('91IMOR3F47FARFNFF'),
          throwsA(TypeMatcher<FormatException>()));
    });

    test('[crockford] 91JPRV3F47FAVFQF -> 48656c6c6f21deadbeef', () {
      var decoded = crockford.decode('91JPRV3F47FAVFQF');
      var decodedString = hexEncode(decoded);

      expect(decodedString.toString(), equals('48656c6c6f21deadbeef'));
    });

    test('[crockford] 91JP-RV3F-47FA-VFQF- -> 48656c6c6f21deadbeef', () {
      var decoded = crockford.decode('91JP-RV3F-47FA-VFQF-');
      var decodedString = hexEncode(decoded);

      expect(decodedString.toString(), equals('48656c6c6f21deadbeef'));
    });

    test('[crockford] 91JPRV3F47FAVFQFF throws FormatException', () {
      expect(() => crockford.decode('91JPRV3F47FAVFQFF'),
          throwsA(TypeMatcher<FormatException>()));
    });

    test('[zbase32] jb1sa5dxr8xk5xzx -> 48656c6c6f21deadbeef', () {
      var decoded = zbase32.decode('jb1sa5dxr8xk5xzx');
      var decodedString = hexEncode(decoded);

      expect(decodedString.toString(), equals('48656c6c6f21deadbeef'));
    });

    test('[zbase32] jb1sa5dxr8xk5xz= throws FormatException', () {
      expect(() => zbase32.decode('jb1sa5dxr8xk5xz='),
          throwsA(TypeMatcher<FormatException>()));
    });

    test('[geohash] 91kqsv3g47gbvgrg -> 48656c6c6f21deadbeef', () {
      var decoded = geohash.decode('91kqsv3g47gbvgrg');
      var decodedString = hexEncode(decoded);

      expect(decodedString.toString(), equals('48656c6c6f21deadbeef'));
    });

    test('[geohash] 91kqsv3g47gbvgrgF throws FormatException', () {
      expect(() => geohash.decode('91kqsv3g47gbvgrgF'),
          throwsA(TypeMatcher<FormatException>()));
    });
  });

  group('[Encode]', () {
    test('[RFC4648] 48656c6c6f21deadbeef -> JBSWY3DPEHPK3PXP', () {
      var encoded = base32.encodeHexString('48656c6c6f21deadbeef');
      expect(encoded, equals('JBSWY3DPEHPK3PXP'));
    });

    test('[base32Hex] 48656c6c6f21deadbeef -> 91IMOR3F47FARFNF', () {
      var encoded = base32Hex.encodeHexString('48656c6c6f21deadbeef');
      expect(encoded, equals('91IMOR3F47FARFNF'));
    });

    test('[crockford] 48656c6c6f21deadbeef -> 91JPRV3F47FAVFQF', () {
      var encoded = crockford.encodeHexString('48656c6c6f21deadbeef');
      expect(encoded, equals('91JPRV3F47FAVFQF'));
    });

    test('[zbase32] 48656c6c6f21deadbeef -> jb1sa5dxr8xk5xzx', () {
      var encoded = zbase32.encodeHexString('48656c6c6f21deadbeef');
      expect(encoded, equals('jb1sa5dxr8xk5xzx'));
    });

    test('[geohash] 48656c6c6f21deadbeef -> 91kqsv3g47gbvgrg', () {
      var encoded = geohash.encodeHexString('48656c6c6f21deadbeef');
      expect(encoded, equals('91kqsv3g47gbvgrg'));
    });
  });

  group('[Padding]', () {
    test('[RFC4648] 48656c6c6f21deadbe -> JBSWY3DPEHPK3PQ=', () {
      var encoded = base32.encodeHexString('48656c6c6f21deadbe');
      expect(encoded, equals('JBSWY3DPEHPK3PQ='));
    });

    test('[base32Hex] 48656c6c6f21deadbe -> 91IMOR3F47FARFG=', () {
      var encoded = base32Hex.encodeHexString('48656c6c6f21deadbe');
      expect(encoded, equals('91IMOR3F47FARFG='));
    });

    test('[crockford] 48656c6c6f21deadbe -> 91JPRV3F47FAVFG (no padding)', () {
      var encoded = crockford.encodeHexString('48656c6c6f21deadbe');
      expect(encoded, equals('91JPRV3F47FAVFG'));
    });

    test('[zbase32] 48656c6c6f21deadbe -> jb1sa5dxr8xk5xo (no padding)', () {
      var encoded = zbase32.encodeHexString('48656c6c6f21deadbe');
      expect(encoded, equals('jb1sa5dxr8xk5xo'));
    });

    test('[geohash] 48656c6c6f21deadbe -> 91kqsv3g47gbvgh=', () {
      var encoded = geohash.encodeHexString('48656c6c6f21deadbe');
      expect(encoded, equals('91kqsv3g47gbvgh='));
    });
  });

  group('[RFC4648 Testcase][Encode]', () {
    test('"" -> ""', () {
      var encoded = base32.encodeString('');
      expect(encoded, equals(''));
    });
    test('f -> MY======', () {
      var encoded = base32.encodeString('f');
      expect(encoded, equals('MY======'));
    });
    test('fo -> MZXQ====', () {
      var encoded = base32.encodeString('fo');
      expect(encoded, equals('MZXQ===='));
    });
    test('foo -> MZXW6===', () {
      var encoded = base32.encodeString('foo');
      expect(encoded, equals('MZXW6==='));
    });
    test('foob -> MZXW6YQ=', () {
      var encoded = base32.encodeString('foob');
      expect(encoded, equals('MZXW6YQ='));
    });
    test('fooba -> MZXW6YTB', () {
      var encoded = base32.encodeString('fooba');
      expect(encoded, equals('MZXW6YTB'));
    });
    test('foobar -> MZXW6YTBOI======', () {
      var encoded = base32.encodeString('foobar');
      expect(encoded, equals('MZXW6YTBOI======'));
    });
  });

  group('[RFC4648 Testcase][Decode]', () {
    test('"" -> ""', () {
      var decoded = base32.decodeAsString('');
      expect(decoded, equals(''));
    });
    test('MY====== -> f', () {
      var decoded = base32.decodeAsString('MY======');
      expect(decoded, equals('f'));
    });
    test('MZXQ==== -> fo', () {
      var decoded = base32.decodeAsString('MZXQ====');
      expect(decoded, equals('fo'));
    });
    test('MZXW6=== -> foo', () {
      var decoded = base32.decodeAsString('MZXW6===');
      expect(decoded, equals('foo'));
    });
    test('MZXW6YQ= -> foob', () {
      var decoded = base32.decodeAsString('MZXW6YQ=');
      expect(decoded, equals('foob'));
    });
    test('MZXW6YTB -> fooba', () {
      var decoded = base32.decodeAsString('MZXW6YTB');
      expect(decoded, equals('fooba'));
    });
    test('MZXW6YTBOI====== -> foobar', () {
      var decoded = base32.decodeAsString('MZXW6YTBOI======');
      expect(decoded, equals('foobar'));
    });
  });
}
