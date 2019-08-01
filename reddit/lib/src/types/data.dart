import 'dart:convert';

part 'data/auth_data.dart';
part 'data/misc_data.dart';
part 'data/thing_data.dart';

typedef DataExtractor = dynamic Function(Map obj);

Map _extractData(Map obj) {
  return obj['data'] ?? obj;
}

Map _extractNothing(Map obj) => obj;
