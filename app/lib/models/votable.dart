import 'package:elmer/elmer.dart';
import 'package:reddit/reddit.dart' show VoteDir;

import 'thing.dart';

export 'thing.dart';

@abs
abstract class Votable implements Thing {

  int score;

  VoteDir voteDir;
}

class _Model { const _Model(); }
const model = _Model();

@model mixin $Votable {

  int score;

  VoteDir voteDir;
}

@model
mixin $Listing {
  
  List<$Votable> get things;
}

class GVotable extends Model with $Votable {

  int score;

  VoteDir voteDir;
}

class GListing extends Model with $Listing {

  @override
  List<GVotable> get things => _things;
  List<GVotable> _things;
}

