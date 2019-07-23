import 'dart:async';

import 'package:flutter/material.dart';

Future<T> showMenuAt<T>({
  BuildContext context,
  double elevation = 8.0,
  T initialValue,
  List<PopupMenuEntry<T>> items,
  String semanticLabel
}) {
  final RenderBox box = context.findRenderObject();
  final RenderBox overlay = Overlay.of(context).context.findRenderObject();
  final RelativeRect position = RelativeRect.fromRect(
    Rect.fromPoints(
      box.localToGlobal(Offset.zero, ancestor: overlay),
      box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
    ),
    Offset.zero & overlay.size,
  );
  return showMenu<T>(
    context: context,
    position: position,
    elevation: elevation,
    initialValue: initialValue,
    items: items,
    semanticLabel: semanticLabel
  );
}