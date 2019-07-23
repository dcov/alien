import 'dart:async';

import 'package:alien/app/subreddit.dart';
import 'package:reddit/values.dart';
import 'package:flutter/material.dart';

import 'base.dart';
import 'route.dart';

class SearchModelSideEffects with RedditMixin {

  const SearchModelSideEffects();

  SubredditModel createSubredditModel(Subreddit thing) {
    return SubredditModel(thing);
  }

  Future<Iterable<Subreddit>> postSearchSubreddits(String query) {
    return getInteractor().postSearchSubreddits(
      query: query,
      exact: false,
      includeOver18: true
    );
  }
}

class SearchModel extends RouteModel {

  SearchModel([
    this._sideEffects = const SearchModelSideEffects()
  ]);

  String query;

  bool get isLoading => _isLoading;
  bool _isLoading = false;

  ImmutableList get results => _results;
  final MutableList<SubredditModel> _results = MutableList();

  final SearchModelSideEffects _sideEffects;

  void submit() {
    if (query == null || query.isEmpty)
        return;

    String submittedQuery = query;
    _isLoading = true;
    notifyListeners();
    _sideEffects.postSearchSubreddits(submittedQuery)
      .then((Iterable<Subreddit> subreddits) {
        if (submittedQuery != query || !_isLoading)
          return;
        _isLoading = false;
        _results.it.clear();
        _results.it.addAll(subreddits.map(_sideEffects.createSubredditModel));
        notifyListeners();
      });
  }
}

class SearchPageRoute<T> extends ModelPageRoute<T, SearchModel> {

  SearchPageRoute({ RouteSettings settings, @required SearchModel model })
    : super(settings: settings, model: model);

  @override
  Widget build(BuildContext context) {
    return _SearchPage(model: model);
  }

  @override
  Widget buildBottomHandle(BuildContext context) {
    return _SearchPageBottomHandle(model: model);
  }
}

class _SearchPage extends View<SearchModel> {

  _SearchPage({ Key key, @required SearchModel model })
    : super(key: key, model: model);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends ViewState<SearchModel, _SearchPage> {

  @override
  bool get rebuildOnChanges => true;

  TextEditingController _controller;
  FocusNode _focusNode;

  @override
  void initModel() {
    super.initModel();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void disposeModel() {
    _focusNode.dispose();
    _controller.dispose();
    super.disposeModel();
  }

  @override
  Widget build(BuildContext context) {
    return MediaPadding(
      child: Column(
        children: <Widget>[
          Material(
            color: Theme.of(context).canvasColor.withOpacity(0.54),
            child: Padding(
              padding: Insets.fullHorizontal,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                textInputAction: TextInputAction.search,
                onChanged: (String text) => model.query = text,
                onEditingComplete: () {
                  _focusNode.unfocus();
                  model.submit();
                },
                decoration: InputDecoration(
                  labelText: 'Search Subreddits',
                  prefixText: 'r/'
                ),
              )
            )
          ),
          Expanded(
            child: model.isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: EdgeInsets.only(
                    top: 12.0,
                    bottom: 48.0
                  ),
                  itemBuilder: (_, int index) {
                    return SubredditTile(model: model.results[index]);
                  },
                  itemCount: model.results.length,
                )
          )
        ],
      )
    );
  }
}

class _SearchPageBottomHandle extends StatelessWidget {

  _SearchPageBottomHandle({ Key key, @required this.model })
    : super(key: key);

  final SearchModel model;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        IconButton(
          onPressed: () { },
          icon: Icon(Icons.more_vert),
        )
      ],
    );
  }
}