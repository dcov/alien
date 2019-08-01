part of '../data.dart';

class ScopeData {

  static Iterable<ScopeData> iterableFromJson(String json, [DataExtractor extractor = _extractNothing]) sync* {
    final obj = extractor(jsonDecode(json));
    for (final data in obj.values) {
      yield ScopeData(data);
    }
  }

  ScopeData(this._data);

  final Map _data;

  String get id => _parseScopeId(_data['id']);

  String get name => _data['name'];

  String get description => _data['description'];

  String _parseScopeId(String id) => (id == 'wiki') ? 'wikiedit' : id;
}

class MultiData {

  factory MultiData.fromJson(String json, [DataExtractor extractor = _extractData]) {
    return MultiData(extractor(jsonDecode(json)));
  }

  static Iterable<MultiData> iterableFromJson(String json, [DataExtractor extractor = _extractNothing]) {
    final obj = extractor(jsonDecode(json));
    return obj.map((data) => MultiData(data));
  }

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
