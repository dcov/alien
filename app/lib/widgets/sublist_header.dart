import 'package:flutter/material.dart';

class SublistHeader extends StatelessWidget {

  SublistHeader({
    Key? key,
    required this.name
  }) : super(key: key);

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: theme.cardColor),
      child: SizedBox(
        height: 30.0,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              name,
              style: theme.textTheme.overline)))));
  }
}
