import 'package:flutter/material.dart';

import 'reddit/types.dart';

TextStyle applyVoteDirColorToText(TextStyle parentStyle, VoteDir voteDir) {
  return voteDir == VoteDir.none
      ? parentStyle
      : parentStyle.copyWith(color: getVoteDirColor(voteDir));
}

Color getVoteDirColor(VoteDir voteDir, [Color defaultColor = Colors.black54]) {
  switch (voteDir) {
    case VoteDir.up:
      return Colors.deepOrange;
    case VoteDir.down:
      return Colors.indigoAccent;
    case VoteDir.none:
      return defaultColor;
  }
  throw ArgumentError('$voteDir was not a valid value.');
}
