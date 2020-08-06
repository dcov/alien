import 'package:elmer/elmer.dart';

import 'saveable.dart';
import 'snudown.dart';
import 'votable.dart';

export 'saveable.dart';
export 'snudown.dart';
export 'votable.dart';

part 'comment.mdl.dart';

@model
mixin $Comment implements Saveable, Votable {

  String get authorFlairText;

  String get authorName;

  $Snudown get body;

  int get createdAtUtc;

  int get depth;

  int get editedAtUtc;

  bool get isSubmitter;
}

