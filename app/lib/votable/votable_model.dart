part of 'votable.dart';

abstract class Votable extends Model implements Thing {

  int score;

  VoteDir voteDir;
}
