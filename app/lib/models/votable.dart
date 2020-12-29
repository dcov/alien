import 'package:reddit/reddit.dart' show VoteDir;

import 'thing.dart';

abstract class Votable implements Thing {

  int score;

  VoteDir voteDir;
}

