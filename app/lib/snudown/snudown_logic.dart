part of 'snudown.dart';

void parseSnudown(Snudown snudown, String data) {
    final List<String> lines = data.replaceAll('\r\n', '\n').split('\n');
    final Document document = Document(
      encodeHtml: false,
      extensionSet: snudownSyntax
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

    final SnudownMatcher matcher = SnudownMatcher(
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
