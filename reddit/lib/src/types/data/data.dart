import 'dart:convert';

import '../parameters/parameters.dart';

part 'auth_data.dart';
part 'misc_data.dart';
part 'thing_data.dart';

typedef DataExtractor = dynamic Function(dynamic obj);

Map _extractData(dynamic obj) {
  return obj['data'] ?? obj;
}

Map _extractNothing(dynamic obj) => obj;

