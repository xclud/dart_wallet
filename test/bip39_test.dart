import 'package:convert/convert.dart';
import 'package:test/test.dart';
import 'package:wallet/src/bip39/pbkdf2.dart';

void main() {
  test('PBKDF2', () {
    final x = pbkdf2(['123', '456']);
    final hx = hex.encode(x);

    expect(hx,
        '6a57a5147c6fbca3e4893dfb615bebda43f2c9463e59c2df6ecfe6f3beb60f44f2b75fd1cabc6e5bc99be9413ddbae941ccbad33e4fc192f0dd0e171d7976d88');
  });
}
