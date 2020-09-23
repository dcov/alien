import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/user.dart';

extension UserEffectContextExtensions on EffectContext {

  RedditClient clientFromUser(User user) {
    return user != null ? this.reddit.asUser(user.token) : this.reddit.asDevice();
  }
}

