import 'package:flutter/material.dart';
import 'package:reddit/reddit.dart';

import '../models/votable.dart';

Color getVoteColor(Votable votable, [Color defaultColor = Colors.black54]) {
  switch (votable.voteDir) {
    case VoteDir.up:
      return Colors.deepOrange;
    case VoteDir.down:
      return Colors.indigoAccent;
    default:
      return defaultColor;
  }
}

