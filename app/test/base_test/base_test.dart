import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:reddit/reddit.dart';
import 'package:scraper/scraper.dart';
import 'package:alien/base/base.dart';

part 'base_deps_test.dart';
part 'base_widgets_test.dart';

part 'base_widgets_test/scaffold_test.dart';

void testBase() {
  group('Base Test', () {
    testScaffold();
  });
}

