import 'package:muex/muex.dart';

import '../models/user.dart';

part 'accounts.g.dart';

abstract class Accounts implements Model {

  factory Accounts({
    List<User> users,
    User currentUser,
    bool isInScriptMode
  }) = _$Accounts;

  List<User> get users;

  User currentUser;

  bool get isInScriptMode;
}

abstract class AccountsOwner {
  Accounts get accounts;
}

