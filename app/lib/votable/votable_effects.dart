import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart' show VoteDir;

import '../effects/effect_context.dart';
import '../thing/thing_utils.dart' as utils;
import '../user/user_model.dart';

import 'votable_model.dart';

class PostVote extends Effect {

  PostVote({
    @required this.votable,
    @required this.user,
    @required this.oldVoteDir,
  });

  final Votable votable;
  final User user;
  final VoteDir oldVoteDir;

  @override
  Future<Event> perform(EffectContext context) {
    return context.client
      .asUser(user.token)
      .postVote(utils.makeFullId(votable), votable.voteDir)
      .catchError((e) {
      });
  }
}
