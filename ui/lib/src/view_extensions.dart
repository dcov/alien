import 'package:alien_core/alien_core.dart';
import 'package:flutter/widgets.dart';
import 'package:muex_flutter/muex_flutter.dart';

extension ViewExtensions on BuildContext {

  bool get userIsSignedIn {
    final accounts = (this.state as AccountsOwner).accounts;
    return accounts.currentUser != null;
  }
}
