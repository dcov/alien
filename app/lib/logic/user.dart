import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../model/user.dart';

extension UserEffectContextExtensions on EffectContext {

  RedditClient clientFromUser(User? user) {
    if (user is ScriptUser)
      return this.scriptClient!;
    else if (user is AppUser)
      return this.redditApp.asUser(user.token);
    else 
      return this.redditApp.asDevice();
  }
}
