import 'package:elmer/elmer.dart';
import 'package:markdown/markdown.dart';
import 'package:reddit/reddit.dart';

import '../models/snudown.dart';

typedef _OnLinkMatched<L extends Link> = void Function(String href, Link link);

class _SnudownMatcher implements NodeVisitor {

  _SnudownMatcher({
    this.onAccountLink,
    this.onPostLink,
    this.onSubredditLink,
    this.onExternalLink,
  });

  final _OnLinkMatched<AccountLink> onAccountLink;
  final _OnLinkMatched<PostLink> onPostLink;
  final _OnLinkMatched<SubredditLink> onSubredditLink;
  final _OnLinkMatched<ExternalLink> onExternalLink;

  @override
  bool visitElementBefore(Element element) {
    if (element.tag == 'a') {
      final String href = element.attributes['href'];
      final Link link = matchLink(href);
      if (link is AccountLink)
        onAccountLink(href, link);
      else if (link is PostLink)
        onPostLink(href, link);
      else if (link is SubredditLink)
        onSubredditLink(href, link);
      else if (link is ExternalLink)
        onExternalLink(href, link);
    }

    return true;
  }

  @override
  void visitElementAfter(_) { }

  @override
  void visitText(_) { }
}

/// An [InlineSyntax] that matches reddit usernames.
class _AccountSyntax extends InlineSyntax {

  _AccountSyntax() : super(r'(/?u/)[A-Za-z0-9_]{3,21}(?=\s)');

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
class _SubredditSyntax extends InlineSyntax {

  _SubredditSyntax() : super(r'(/?r/)[A-Za-z0-9_]{3,21}(?=\s)');

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
final ExtensionSet _snudownSyntax = ExtensionSet(
  <BlockSyntax>[
    const FencedCodeBlockSyntax(),
    const TableSyntax()
  ],
  <InlineSyntax>[
    InlineHtmlSyntax(),
    AutolinkExtensionSyntax(),
    _AccountSyntax(),
    _SubredditSyntax()
  ]
);

void _parseRawInto(String data, Snudown snudown) {
    final List<String> lines = data.replaceAll('\r\n', '\n').split('\n');
    final Document document = Document(
      encodeHtml: false,
      extensionSet: _snudownSyntax
    );

    snudown.nodes..clear()
                 ..addAll(document.parseLines(lines));

    final List<String> hrefsToRemove = snudown.models.keys.toList();

    void put<T extends Model>(String href,
        { bool checkIfMatches(T model), T onAbsent() }) {

      hrefsToRemove.remove(href);

      if (snudown.models[href] == null) {
        T model;
        for (final Model value in snudown.models.values) {
          if (value is T && checkIfMatches(value)) {
            model = value;
            break;
          }
        }
        model ??= onAbsent();
        snudown.models[href] = model;
      }
    }

    final _SnudownMatcher matcher = _SnudownMatcher(
      onAccountLink: (href, link) {},
      onPostLink: (href, link) {},
      onSubredditLink: (href, link) {},
      onExternalLink: (href, link) {}
    );

    snudown.nodes.forEach((Node node) {
      node.accept(matcher);
    });

    hrefsToRemove.forEach(snudown.models.remove);
}

Snudown snudownFrom(String markdown) {
  final snudown = Snudown();
  _parseRawInto(markdown, snudown);
  return snudown;
}

