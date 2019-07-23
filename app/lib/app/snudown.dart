import 'package:markdown/markdown.dart' as md;
import 'package:reddit/helpers.dart' as rd;
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'base.dart';
import 'account.dart';
import 'link.dart';
import 'media.dart';
import 'subreddit.dart';

class SnudownModelSideEffects {
  
  const SnudownModelSideEffects();

  AccountModel createAccount(String username) {
    /// TODO: Implement AccountModel.fromUsername functionality.
  }

  LinkModel createLink(String linkId, String permalink) {
    /// TODO: Implement LinkModel.fromId functionality
  }

  MediaModel createMedia(String ref) {
    return MediaModel(ref);
  }

  SubredditModel createSubreddit(String subredditName) {
    /// TODO: Implement SubredditModel.fromName functionality.
  }
}

/// An [InlineSyntax] that matches reddit usernames.
class AccountSyntax extends md.InlineSyntax {

  AccountSyntax() : super(r'(/?u/)[A-Za-z0-9_]{3,21}(?=\s)');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final String username = match[0];
    final md.Element anchor = md.Element.text('a', username);
    anchor.attributes['href'] = username;
    parser.addNode(anchor);

    return true;
  }
}

/// An [InlineSyntax] that matches reddit subreddit names.
class SubredditSyntax extends md.InlineSyntax {

  SubredditSyntax() : super(r'(/?r/)[A-Za-z0-9_]{3,21}(?=\s)');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final String subredditName = match[0];
    final md.Element anchor = md.Element.text('a', subredditName);
    anchor.attributes['href'] = subredditName;
    parser.addNode(anchor);

    return true;
  }
}

/// A reddit flavored markdown syntax.
final md.ExtensionSet snudown = md.ExtensionSet(
  <md.BlockSyntax>[
    const md.FencedCodeBlockSyntax(),
    const md.TableSyntax()
  ],
  <md.InlineSyntax>[
    md.InlineHtmlSyntax(),
    md.AutolinkExtensionSyntax(),
    AccountSyntax(),
    SubredditSyntax()
  ]
);

typedef OnReferenceMatched<R extends rd.Reference> = void Function(String href, R reference);

class ReferenceMatcher implements md.NodeVisitor {

  ReferenceMatcher({
    this.onAccountReference,
    this.onExternalReference,
    this.onLinkReference,
    this.onSubredditReference,
  });

  final OnReferenceMatched<rd.AccountReference> onAccountReference;
  final OnReferenceMatched<rd.ExternalReference> onExternalReference;
  final OnReferenceMatched<rd.LinkReference> onLinkReference;
  final OnReferenceMatched<rd.SubredditReference> onSubredditReference;

  @override
  bool visitElementBefore(md.Element element) {
    if (element.tag == 'a') {
      final String href = element.attributes['href'];
      final rd.Reference reference = rd.matchReference(href);
      if (reference is rd.AccountReference)
        onAccountReference(href, reference);
      else if (reference is rd.ExternalReference)
        onExternalReference(href, reference);
      else if (reference is rd.LinkReference)
        onLinkReference(href, reference);
      else if (reference is rd.SubredditReference)
        onSubredditReference(href, reference);
    }

    return true;
  }

  @override
  void visitElementAfter(md.Element element) { }

  @override
  void visitText(md.Text text) { }
}

class SnudownModel extends Model {

  SnudownModel(String data, [ this._sideEffects = const SnudownModelSideEffects() ]) {
    final List<String> lines = data.replaceAll('\r\n', '\n').split('\n');
    final md.Document document = md.Document(
      encodeHtml: false,
      extensionSet: snudown,
    );
    _nodes = List.unmodifiable(document.parseLines(lines));
    _parseModels();
  }

  List<md.Node> get nodes => _nodes;
  List<md.Node> _nodes;

  ImmutableMap<String, Model> get hrefToModel {
    _refToModel = ImmutableMap(_models);
    return _refToModel;
  }
  ImmutableMap<String, Model> _refToModel;

  final Map<String, Model> _models = Map<String, Model>();
  final SnudownModelSideEffects _sideEffects;

  void _putIfAbsent<T extends Model>(String href, { bool onCheckIfModelMatches(T model), T onAbsent() }) {
    if (_models[href] == null) {
      T model;
      for (final Model value in _models.values) {
        if (value is T && onCheckIfModelMatches(value)) {
          // The model is already in [_models] under a different reference.
          model = value;
          break;
        }
      }
      model ??= onAbsent();
      _models[href] = model;
    }
  }

  /// Iterates over [_nodes] and visits them with [ReferenceMatcher] in order
  /// to link all matched [rd.Reference]s to a [Model] so that they can be
  /// accessed through [getModel].
  void _parseModels() {
    final List<String> hrefsToRemove = _models.keys.toList();

    void put<T extends Model>(String href, { bool onCheckIfModelMatches(T model), T onAbsent() }) {
      hrefsToRemove.remove(href);
      _putIfAbsent(
        href,
        onCheckIfModelMatches: onCheckIfModelMatches,
        onAbsent: onAbsent
      );
    }

    final ReferenceMatcher matcher = ReferenceMatcher(
      onAccountReference: (String href, rd.AccountReference reference) {
        put(
          href,
          onCheckIfModelMatches: (AccountModel model) => model.username == reference.username,
          onAbsent: () => _sideEffects.createAccount(reference.username)
        );
      },
      onExternalReference: (String href, rd.ExternalReference reference) {
        put(
          href,
          onCheckIfModelMatches: (MediaModel model) => model.source == reference.ref,
          onAbsent: () => _sideEffects.createMedia(reference.ref)
        );
      }, 
      onLinkReference: (String href, rd.LinkReference reference) {
        put(
          href,
          onCheckIfModelMatches: (LinkModel model) => rd.makeIdFromFullId(model.fullId) == reference.linkId,
          onAbsent: () => _sideEffects.createLink(reference.linkId, reference.permalink)
        );
      },
      onSubredditReference: (String href, rd.SubredditReference reference) {
        put(
          href,
          onCheckIfModelMatches: (SubredditModel model) => model.displayName == reference.subredditName,
          onAbsent: () => _sideEffects.createSubreddit(reference.subredditName)
        );
      },
    );
    _nodes.forEach((md.Node node) {
      node.accept(matcher);
    });
    for (final String href in hrefsToRemove) {
      final Model removed = _models.remove(href);
      removed.dispose();
    }
  }
}

class Snudown extends StatelessWidget {

  Snudown({
    Key key,
    @required this.scrollable,
    @required this.model
  }) : super(key: key);

  final bool scrollable;
  final SnudownModel model;

  MarkdownStyleSheet _getStyleSheet(BuildContext context) {
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

  void _onChildRef(BuildContext context, String href) {
    final Model hrefModel = model.hrefToModel[href];
    if (hrefModel is MediaModel) {
      showMedia(context: context, model: hrefModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Markdown(
      nodes: model.nodes,
      styleSheet: _getStyleSheet(context),
      onTapLink: (String link) => _onChildRef(context, link),
      scrollable: scrollable,
    );
  }
}