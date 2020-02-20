import 'package:elmer/elmer.dart';
import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'snudown_model.dart';

MarkdownStyleSheet _createStyleSheet(BuildContext context) {
  final ThemeData theme = Theme.of(context);
  return MarkdownStyleSheet(
    a: const TextStyle(
      color: Colors.blue,
      decoration: TextDecoration.underline,
    ),
    p: theme.textTheme.body1,
    code: TextStyle(
      color: Colors.grey.shade700,
      fontFamily: "monospace",
      fontSize: theme.textTheme.body1.fontSize * 0.85
    ),
    h1: theme.textTheme.headline,
    h2: theme.textTheme.title,
    h3: theme.textTheme.subhead,
    h4: theme.textTheme.body2,
    h5: theme.textTheme.body2,
    h6: theme.textTheme.body2,
    em: const TextStyle(fontStyle: FontStyle.italic),
    strong: const TextStyle(fontWeight: FontWeight.bold),
    blockquote: theme.textTheme.body1,
    img: theme.textTheme.body1,
    blockSpacing: 8.0,
    listIndent: 32.0,
    blockquotePadding: 8.0,
    blockquoteDecoration: const BoxDecoration(
      border: Border(
        left: BorderSide(
          color: Colors.blue,
          width: 2.0
        )
      )
    ),
    codeblockPadding: 8.0,
    codeblockDecoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(4.0)
    ),
    horizontalRuleDecoration: BoxDecoration(
      border: Border(
        top: BorderSide(width: 5.0, color: Colors.grey.shade300)
      ),
    ),
  );
}

class SnudownBody extends StatelessWidget {

  SnudownBody({
    Key key,
    @required this.snudown,
    @required this.scrollable,
  }) : super(key: key);

  final Snudown snudown;

  final bool scrollable;

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context, EventDispatch dispatch) {
      return Markdown(
        nodes: snudown.nodes,
        styleSheet: _createStyleSheet(context),
        onTapLink: (link) {},
        scrollable: scrollable,
      );
    }
  );
}
