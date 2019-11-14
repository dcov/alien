import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:meta/meta.dart';
import 'package:alien/routing/routing.dart';
import 'package:alien/base/base.dart';

part 'routing_events_test.dart';
part 'routing_model_test.dart';
part 'routing_widgets_test.dart';

void testRouting() {
  group('Routing Tests', () {
    testRoutingEvents();
    testRoutingWidgets();
  });
}

