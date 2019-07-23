import 'dart:convert';
import 'package:reddit/values.dart';

String _parseScopeId(String id) =>
  id == 'wiki' ? 'wikiedit' : id;

ScopeInfo buildScopeInfo(Map obj) {
  return ScopeInfo((b) => b
    ..id = _parseScopeId(obj['id'])
    ..name = obj['name']
    ..description = obj['description']
  );
}

ScopeInfo decodeScopeInfo(String json) {
  return buildScopeInfo(jsonDecode(json));
}

Iterable<ScopeInfo> decodeScopeInfoIterable(String json) {
  final obj = jsonDecode(json);
  final list = List<ScopeInfo>();
  final possibleKeys = Scope.values;
  for (final key in possibleKeys) {
    final data = obj[key.toString()];
    if (data != null) {
      list.add(buildScopeInfo(data));
    }
  }
  list.sort((s1, s2) => s1.id.compareTo(s2.id));
  return list;
}

Multi buildMulti(Map obj) {
  final data = obj['data'];
  return Multi((b) => b
    ..canEdit = data['can_edit']
    ..name = data['name']
    ..descriptionHtml = data['description_html']
    ..timestamp = data['created_utc']
    ..isNSFW = data['over_18']
    ..path = data['path']
    ..subreddits = (data['subreddits'] as List)
        .map((sub) => sub['name'])
  );
}

Multi decodeMulti(String json) =>
  buildMulti(jsonDecode(json));

Iterable<Multi> decodeMultiIterable(String json) {
  final data = jsonDecode(json);
  final list = List<Multi>();
  for (final obj in data) {
    list.add(buildMulti(obj));
  }
  return list;
}