import 'package:flutter/widgets.dart';
import 'package:mal_flutter/mal_flutter.dart';

import '../models/accounts.dart';

extension ViewExtensions on BuildContext {

  bool get userIsSignedIn {
    final accounts = (this.state as AccountsOwner).accounts;
    return accounts.currentUser != null;
  }
}

