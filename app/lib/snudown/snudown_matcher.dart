part of 'snudown.dart';

typedef OnLinkMatched<L extends Link> = void Function(String href, Link link);

class SnudownMatcher implements NodeVisitor {

  SnudownMatcher({
    this.onAccountLink,
    this.onPostLink,
    this.onSubredditLink,
    this.onExternalLink,
  });

  final OnLinkMatched<AccountLink> onAccountLink;
  final OnLinkMatched<PostLink> onPostLink;
  final OnLinkMatched<SubredditLink> onSubredditLink;
  final OnLinkMatched<ExternalLink> onExternalLink;

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
