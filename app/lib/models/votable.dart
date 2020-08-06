import 'package:reddit/reddit.dart' show VoteDir;

import 'thing.dart';

export 'package:reddit/reddit.dart' show VoteDir;
export 'thing.dart';

mixin Votable implements Thing {

  int score;

  VoteDir voteDir;
}

