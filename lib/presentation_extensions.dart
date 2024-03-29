import 'package:flutter/widgets.dart';
import 'package:muex_flutter/muex_flutter.dart';

import 'core/accounts.dart';

extension PresentationExtensions on BuildContext {

  bool get userIsSignedIn {
    final accounts = (this.state as AccountsOwner).accounts;
    return accounts.currentUser != null;
  }
}
