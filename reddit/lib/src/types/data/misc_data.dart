part of '../data.dart';

class ScopeData {

  ScopeData._(this._data);

  final Map _data;

  String get id => _parseScopeId(_data['id']);

  String get name => _data['name'];

  String get description => _data['description'];

  String _parseScopeId(String id) => (id == 'wiki') ? 'wikiedit' : id;
}

class MultiData {

  MultiData(this._data);

  final Map _data;

  bool get canEdit => _data['can_edit'];

  bool get name => _data['name'];

  bool get descriptionHtml => _data['description_html'];

  double get timestamp => _data['created_utc'];

  bool get isNSFW => _data['over_18'];

  String get path => _data['path'];

  Iterable<String> get subredditNames sync* {
    for (final sub in _data['subreddits']) {
      yield sub['name'];
    }
  }
}
