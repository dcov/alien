import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects/effect_context.dart';
import '../models/auth_model.dart';
import '../models/votable_model.dart';
import '../models/user_model.dart';
import '../utils/thing_utils.dart' as utils;

class Upvote implements Event {

  Upvote({
    @required this.votable,
    this.user,
  });

  /// The thing to post an upvote to.
  final Votable votable;

  /// The user to upvote on behalf of. If null will default to the currently signed in user.
  final User user;

  @override
  Effect update(RootAuth root) {
    final VoteDir oldVoteDir = votable.voteDir;

    if (votable.voteDir == VoteDir.up) {
      votable..score -= 1
             ..voteDir = VoteDir.none;
    } else {
      votable..score += votable.voteDir == VoteDir.down ? 2 : 1
             ..voteDir = VoteDir.up;
    }

    return PostVoteUpdate(
      votable: votable,
      user: user ?? root.auth.currentUser,
      oldVoteDir: oldVoteDir);
  }
}

class Downvote implements Event {

  Downvote({
    @required this.votable,
    this.user
  });

  final Votable votable;

  final User user;

  @override
  Effect update(RootAuth root) {
    final VoteDir oldVoteDir = votable.voteDir;

    if (votable.voteDir == VoteDir.down) {
      votable..score += 1
             ..voteDir = VoteDir.none;
    } else {
      votable..score -= votable.voteDir == VoteDir.up ? 2 : 1
             ..voteDir = VoteDir.down;
    }

    return PostVoteUpdate(
      votable: votable,
      user: user ?? root.auth.currentUser,
      oldVoteDir: oldVoteDir);
  }
}

class PostVoteUpdate implements Effect {

  PostVoteUpdate({
    @required this.votable,
    @required this.user,
    @required this.oldVoteDir,
  });

  final Votable votable;
  final User user;
  final VoteDir oldVoteDir;

  @override
  Future<Event> perform(EffectContext context) {
    return context.reddit
      .asUser(user.token)
      .postVote(utils.makeFullId(votable), votable.voteDir)
      .catchError(() {
        return PostVoteUpdateFailure(
          votable: votable,
          oldVoteDir: oldVoteDir);
      });
  }
}

class PostVoteUpdateFailure implements Event {

  PostVoteUpdateFailure({
    @required this.votable,
    @required this.oldVoteDir
  });

  final Votable votable;

  final VoteDir oldVoteDir;

  @override
  void update(_) {
    switch (oldVoteDir) {
      // votable was previously not voted in any direction so we have to add or remove a point.
      case VoteDir.none:
        votable.score += votable.voteDir == VoteDir.down ? 1 : -1;
        break;
      // votable was previously upvoted so we have to add back points.
      case VoteDir.up:
        votable.score += votable.voteDir == VoteDir.none ? 1 : 2;
        break;
      // votable was previously downvoted so we have to remove points.
      case VoteDir.down:
        votable.score -= votable.voteDir == VoteDir.none ? 1 : 2;
    }
  }
}

