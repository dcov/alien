import 'package:flutter_test/flutter_test.dart';

import 'defaults_test/defaults_test.dart';
import 'base_test/base_test.dart';
import 'routing_test/routing_test.dart';

void main() {
  group('App Tests', () {
    testBase();
    testDefaults();
    testRouting();
  });
}

