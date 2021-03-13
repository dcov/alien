import 'package:flutter/material.dart';

import '../widgets/theming.dart';

class SublistHeader extends StatelessWidget {

  SublistHeader({
    Key? key,
    required this.name
  }) : super(key: key);

  final String name;

  @override
  Widget build(BuildContext context) {
    final theming = Theming.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theming.altCanvasColor),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 16.0),
        child: Text(
          name,
          style: theming.captionText)));
  }
}
