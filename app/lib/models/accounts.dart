import 'package:muex/muex.dart';

import '../models/user.dart';

part 'accounts.g.dart';

abstract class Accounts implements Model {

  factory Accounts({
    List<User> users,
    User? currentUser,
    required bool isInScriptMode
  }) = _$Accounts;

  List<User> get users;

  User? get currentUser;
  set currentUser(User? value);

  bool get isInScriptMode;
}

abstract class AccountsOwner {
  Accounts get accounts;
}
