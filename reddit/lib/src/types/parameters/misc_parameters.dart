part of '../parameters.dart';

class VoteDir extends Parameter {
  static const VoteDir up = VoteDir._('up', '1');
  static const VoteDir down = VoteDir._('down', '-1');
  static const VoteDir none = VoteDir._('none', '0');

  const VoteDir._(String name, String value) : super._(name, value);
}
