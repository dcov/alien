import 'package:reddit/reddit.dart' show VoteDir;

import '../model/thing.dart';

abstract class Votable implements Thing {

  int get score;
  set score(int value);

  VoteDir get voteDir;
  set voteDir(VoteDir value);
}
