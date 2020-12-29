import 'package:flutter/material.dart';
import 'package:reddit/reddit.dart';

import '../models/votable.dart';

Color getVoteDirColor(VoteDir voteDir, [Color defaultColor = Colors.black54]) {
  switch (voteDir) {
    case VoteDir.up:
      return Colors.deepOrange;
    case VoteDir.down:
      return Colors.indigoAccent;
    default:
      return defaultColor;
  }
}

Color getVotableColor(Votable votable, [Color defaultColor = Colors.black54]) {
  return getVoteDirColor(votable.voteDir);
}

