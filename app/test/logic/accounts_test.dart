import 'package:flutter_test/flutter_test.dart';
import 'package:alien/logic/accounts.dart';
import 'package:alien/models/user.dart';

void accountsTest() {
  group('accounts tests', () {
    test('pack/unpack logic', () {
      final users = [
        AppUser(token: '1', name: 'one'),
        AppUser(token: '2', name: 'two')
      ];

      final result = unpackUsersList(packUsersList(users));
      expect(result.length, users.length);
      expect(result.first.token, users.first.token);
      expect(result.first.name, users.first.name);
      expect(result.last.token, users.last.token);
      expect(result.last.name, users.last.name);
    });
  });
}

