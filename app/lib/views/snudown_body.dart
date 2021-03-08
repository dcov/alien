import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:muex_flutter/muex_flutter.dart';

import '../models/media.dart';
import '../models/snudown.dart';

MarkdownStyleSheet _createStyleSheet(BuildContext context) {
  final ThemeData theme = Theme.of(context);
  return MarkdownStyleSheet(
    a: const TextStyle(
      color: Colors.blue,
      decoration: TextDecoration.underline),
    p: theme.textTheme.bodyText2,
    code: TextStyle(
      color: Colors.grey.shade700,
      fontFamily: "monospace",
      fontSize: theme.textTheme.bodyText2!.fontSize! * 0.85),
    h1: theme.textTheme.headline5,
    h2: theme.textTheme.headline6,
    h3: theme.textTheme.subtitle1,
    h4: theme.textTheme.bodyText1,
    h5: theme.textTheme.bodyText1,
    h6: theme.textTheme.bodyText1,
    em: const TextStyle(fontStyle: FontStyle.italic),
    strong: const TextStyle(fontWeight: FontWeight.bold),
    blockquote: theme.textTheme.bodyText2,
    img: theme.textTheme.bodyText2,
    blockSpacing: 8.0,
    listIndent: 32.0,
    blockquotePadding: EdgeInsets.all(8.0),
    blockquoteDecoration: const BoxDecoration(
      border: Border(
        left: BorderSide(
          color: Colors.blue,
          width: 2.0))),
    codeblockPadding: EdgeInsets.all(8.0),
    codeblockDecoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(4.0)),
    horizontalRuleDecoration: BoxDecoration(
      border: Border(
        top: BorderSide(
          width: 5.0,
          color: Colors.grey.shade300))));
}

class SnudownBody extends StatelessWidget {

  SnudownBody({
    Key? key,
    required this.snudown,
    required this.scrollable,
  }) : super(key: key);

  final Snudown snudown;

  final bool scrollable;

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context) {
      return Markdown(
        nodes: snudown.nodes,
        styleSheet: _createStyleSheet(context),
        onTapLink: (String text, String? ref, String title) {
          final link = snudown.links[ref!];
          if (link is Media) {
          }
        },
        scrollable: scrollable);
    });
}
