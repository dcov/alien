import '../reddit/client.dart';

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
      return this.redditScriptClient!;
    else if (user is AppUser)
      return this.reddit.asUser(user.token);
    else 
      return this.reddit.asDevice();
  }
}
