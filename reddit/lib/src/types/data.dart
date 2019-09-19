import 'dart:convert';

import 'parameters.dart';

part 'data/auth_data.dart';
part 'data/misc_data.dart';
part 'data/thing_data.dart';

typedef DataExtractor = dynamic Function(dynamic obj);

Map _extractData(dynamic obj) {
  return obj['data'] ?? obj;
}

Map _extractNothing(dynamic obj) => obj;
