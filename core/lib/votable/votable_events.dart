import 'package:loux/loux.dart';

import 'votable_effect.dart';
import 'votable_model.dart';

class Upvote extends Event {

  const Upvote({
    this.key
  });

  final ModelKey key;

  @override
  Effect update(Store store) {
    final Votable votable = store.get(this.key);

    if (votable.voteDir == VoteDir.up) {
      votable..score -= 1
             ..voteDir = VoteDir.none;

      return PostUnvote(
        fullId: votable.fullId,
        key: this.key
      );
    } else {
      votable..score += votable.voteDir == VoteDir.down ? 2 : 1
             ..voteDir = VoteDir.up;

      return PostUpvote(
        fullId: votable.fullId,
        key: this.key
      );
    }
  }
}

class Downvote extends Event {

  const Downvote({
    this.key
  });

  final ModelKey key;

  @override
  Effect update(Store store) {
    final Votable votable = store.get(this.key);

    if (votable.voteDir == VoteDir.down) {
      votable..score += 1
             ..voteDir = VoteDir.none;
      
      return PostUnvote(
        fullId: votable.fullId,
        key: this.key
      );
    } else {
      votable..score -= votable.voteDir == VoteDir.up ? 2 : 1
             ..voteDir = VoteDir.down;
      
      return PostDownvote(
        fullId: votable.fullId,
        key: this.key
      );
    }
  }
}
