import 'package:markdown/markdown.dart';
import 'package:reddit/reddit.dart';

import '../models/media.dart';
import '../models/snudown.dart';

import 'media.dart';

typedef _OnLinkMatched<L extends Link> = void Function(String href, L link);

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
final _snudownSyntax = ExtensionSet(
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

void parseMarkdownIntoSnudown(String data, Snudown snudown) {
  final lines = data.replaceAll('\r\n', '\n').split('\n');
  final document = Document(
    encodeHtml: false,
    extensionSet: _snudownSyntax);

  snudown.nodes..clear()
               ..addAll(document.parseLines(lines));

  final hrefsToRemove = snudown.links.keys.toList();

  void put<T>(String href, { bool checkIfMatches(T link), T onAbsent() }) {
    hrefsToRemove.remove(href);
    if (snudown.links[href] == null) {
      T link;
      for (final Object value in snudown.links.values) {
        if (value is T && checkIfMatches(value)) {
          link = value;
          break;
        }
      }
      link ??= onAbsent();
      snudown.links[href] = link;
    }
  }

  final matcher = _SnudownMatcher(
    onAccountLink: (String href, AccountLink link) {
      /// TODO: Implement AccountLink handling
    },
    onPostLink: (String href, PostLink link) {
      /// TODO: Implement PostLink handling
    },
    onSubredditLink: (String href, SubredditLink link) {
      /// TODO: Implement SubredditLink handling
    },
    onExternalLink: (String href, ExternalLink link) {
      put(
        href,
        checkIfMatches: (Media media) => media.source == link.ref,
        onAbsent: () => Media(source: link.ref));
    });

  snudown.nodes.forEach((Node node) {
    node.accept(matcher);
  });

  hrefsToRemove.forEach(snudown.links.remove);
}

Snudown snudownFromMarkdown(String markdown) {
  final snudown = Snudown();
  parseMarkdownIntoSnudown(markdown, snudown);
  return snudown;
}

