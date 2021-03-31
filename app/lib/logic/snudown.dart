import 'package:markdown/markdown.dart';
import 'package:reddit/reddit.dart';

import '../model/media.dart';
import '../model/snudown.dart';

typedef _OnLinkMatched<L extends Link> = void Function(String href, L link);

class _SnudownMatcher implements NodeVisitor {

  _SnudownMatcher({
    required this.onAccountLink,
    required this.onPostLink,
    required this.onSubredditLink,
    required this.onExternalLink,
  });

  final _OnLinkMatched<AccountLink> onAccountLink;
  final _OnLinkMatched<PostLink> onPostLink;
  final _OnLinkMatched<SubredditLink> onSubredditLink;
  final _OnLinkMatched<ExternalLink> onExternalLink;

  @override
  bool visitElementBefore(Element element) {
    if (element.tag == 'a') {
      final href = element.attributes['href']!;
      final link = matchLink(href);
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
    final username = match[0]!;
    final anchor = Element.text('a', username);
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
    final subredditName = match[0]!;
    final anchor = Element.text('a', subredditName);
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

  void put<T>(String href, { required bool checkIfMatches(T link), required T onAbsent() }) {
    hrefsToRemove.remove(href);
    if (snudown.links[href] == null) {
      T? link;
      for (final value in snudown.links.values) {
        final T? tv = value is T ? value as T : null;
        if (tv != null && checkIfMatches(tv)) {
          link = tv;
          break;
        }
      }
      link ??= onAbsent();
      snudown.links[href] = link as Object;
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
        onAbsent: () => Media(source: link.ref, thumbnailStatus: ThumbnailStatus.notLoaded));
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
