part of 'snudown.dart';

/// An [InlineSyntax] that matches reddit usernames.
class AccountSyntax extends InlineSyntax {

  AccountSyntax() : super(r'(/?u/)[A-Za-z0-9_]{3,21}(?=\s)');

  @override
  bool onMatch(InlineParser parser, Match match) {
    final String username = match[0];
    final Element anchor = Element.text('a', username);
    anchor.attributes['href'] = username;
    parser.addNode(anchor);

    return true;
  }
}

/// An [InlineSyntax] that matches reddit subreddit names.
class SubredditSyntax extends InlineSyntax {

  SubredditSyntax() : super(r'(/?r/)[A-Za-z0-9_]{3,21}(?=\s)');

  @override
  bool onMatch(InlineParser parser, Match match) {
    final String subredditName = match[0];
    final Element anchor = Element.text('a', subredditName);
    anchor.attributes['href'] = subredditName;
    parser.addNode(anchor);

    return true;
  }
}

/// A reddit flavored markdown syntax.
final ExtensionSet snudownSyntax = ExtensionSet(
  <BlockSyntax>[
    const FencedCodeBlockSyntax(),
    const TableSyntax()
  ],
  <InlineSyntax>[
    InlineHtmlSyntax(),
    AutolinkExtensionSyntax(),
    AccountSyntax(),
    SubredditSyntax()
  ]
);
