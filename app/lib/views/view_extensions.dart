import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/widgets.dart';

import '../models/accounts.dart';

extension ViewExtensions on BuildContext {

  bool get userIsSignedIn {
    final accounts = (this.state as AccountsOwner).accounts;
    return accounts.currentUser != null;
  }
}

