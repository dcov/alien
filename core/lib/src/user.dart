import 'package:reddit/reddit.dart';

import 'context.dart';

abstract class User {

  User(this.name);

  final String name;
}

class AppUser extends User {

  AppUser({
    required String name,
    required this.token
  }) : super(name);

  final String token;
}

class ScriptUser extends User {

  ScriptUser({
    required String name
  }) : super(name);
}

extension UserContextExtension on CoreContext {

  RedditClient clientFromUser(User? user) {
    if (user is ScriptUser)
      return this.scriptClient!;
    else if (user is AppUser)
      return this.redditApp.asUser(user.token);
    else 
      return this.redditApp.asDevice();
  }
}
