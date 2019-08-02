part of 'votable.dart';

mixin Votable on Thing {

  int get score => _score;
  int _score;
  set score(int value) {
    _score = set(_score, value);
  }

  VoteDir get voteDir => _voteDir;
  VoteDir _voteDir;
  set voteDir(VoteDir value) {
    _voteDir = set(_voteDir, value);
  }
}
