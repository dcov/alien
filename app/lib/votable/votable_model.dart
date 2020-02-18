import 'package:elmer/elmer.dart';
import 'package:reddit/reddit.dart' show VoteDir;

import '../thing/thing_model.dart';

@abs
abstract class Votable implements Thing {

  int score;

  VoteDir voteDir;
}
