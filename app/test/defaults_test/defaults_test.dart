import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:reddit/reddit.dart';
import 'package:alien/defaults/defaults.dart';

import '../base_test/base_test.dart';

part 'defaults_effects_test.dart';
part 'defaults_model_test.dart';

void testDefaults() {
  group('Defaults Test', () {
    testDefaultsEffects();
  });
}

