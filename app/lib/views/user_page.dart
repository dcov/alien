import 'package:flutter/material.dart' hide Page;

import '../models/user.dart';
import '../widgets/page.dart';

class UserPage extends Page {

  UserPage({
    RouteSettings settings,
    @required this.user,
  }) : super(settings: settings);

  final User user;

  @override
  Widget buildPage(BuildContext context, _, __) {
    return Material();
  }
}

