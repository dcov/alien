import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:alien/listing/listing_events.dart';
import 'package:alien/listing/listing_model.dart';
import 'package:alien/thing/thing_model.dart';

class _MockThing extends Mock implements Thing {

  static _MockThing generateWithId(int id) {
    final thing = _MockThing();
    when(thing.id).thenReturn(id.toString());
  }
}

class _MockListing extends Mock implements Listing<_MockThing> { }

// This class is needed to be able to call the [updateListing] method because
// [UpdateListing] is abstract and thus can't be instantiated on its own.
class _TestUpdateListing extends UpdateListing {

  const _TestUpdateListing();

  /// We don't use this method in tests, we just call [updateListing] directly.
  @override
  dynamic update(_) { }
}

void testListingEvents() {
  test('Test Listing Events', () {
    final UpdateListing updateEvent = _TestUpdateListing();

    final List<_MockThing> mockData = List.generate(50, _MockThing.generateWithId);
  });
}

