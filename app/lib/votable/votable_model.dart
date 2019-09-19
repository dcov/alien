part of 'votable.dart';

@abs
abstract class Votable extends Model implements Thing {

  int score;

  VoteDir voteDir;
}
