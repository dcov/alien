import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:muex_flutter/muex_flutter.dart';

import '../model/media.dart';
import '../model/snudown.dart';
import '../ui/theming.dart';

MarkdownStyleSheet _createStyleSheet(BuildContext context) {
  final theming = Theming.of(context);
  return MarkdownStyleSheet(
    a: theming.bodyText.copyWith(
      color: Colors.blue,
      decoration: TextDecoration.underline),
    p: theming.bodyText,
    code: theming.bodyText.copyWith(
      color: Colors.grey[600]!,
      fontFamily: "monospace"),
    h1: theming.headerText.apply(fontSizeFactor: 4.0),
    h2: theming.headerText.apply(fontSizeFactor: 3.5),
    h3: theming.headerText.apply(fontSizeFactor: 3.0),
    h4: theming.headerText.apply(fontSizeFactor: 2.5),
    h5: theming.headerText.apply(fontSizeFactor: 2.0),
    h6: theming.headerText.apply(fontSizeFactor: 1.5),
    em: theming.bodyText.copyWith(fontStyle: FontStyle.italic),
    strong: theming.bodyText.copyWith(fontWeight: FontWeight.w600),
    blockquote: theming.bodyText,
    img: theming.bodyText,
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
