import 'dart:async';

import 'package:meta/meta.dart';
import 'package:reddit/endpoints.dart';
import 'package:reddit/helpers.dart';
import 'package:reddit/values.dart';
import 'package:flutter/widgets.dart';

import 'refreshable.dart';
import 'thing.dart';

abstract class PaginationBehaviorModelSideEffects {

  Future<Listing> loadPage(Page page);

  ThingModelMixin createThing(covariant Thing thing);
}

enum _PageOp {
  first,
  next,
  previous
}

abstract class PaginationBehaviorModel extends RefreshableThingsModel {

  PaginationBehaviorModel(this._sideEffects);
  
  @protected
  Pagination get pagination => _pagination;
  Pagination _pagination;

  final PaginationBehaviorModelSideEffects _sideEffects;
  _PageOp _currOp;

  @override
  ThingModelMixin createItem(Thing item) {
    return _sideEffects.createThing(item);
  }

  /// The default override of [RefreshableModel.loadItems].
  /// 
  /// Loads the first page of content.
  @override
  Future<Iterable<Thing>> loadItems() {
    if (_currOp == _PageOp.first)
      return null;
    _currOp = _PageOp.first;
    _pagination = Pagination();
    return _sideEffects.loadPage(pagination.nextPage).then(_finishLoadFirst);
  }

  /// Is called once [loadItems] completes.
  /// 
  /// It updates all of the relevant values and returns the [Listing.things].
  Iterable<Thing> _finishLoadFirst(Listing listing) {
    _currOp = null;
    _pagination = _pagination.forward(listing);
    return listing.things;
  }

  /// Loads the next page of content if it exists.
  @protected
  Future<Iterable<Thing>> loadNextItems() {
    assert(pagination?.nextPageExists == true);
    if (_currOp != null || pagination?.nextPageExists != true)
      return null;

    _currOp = _PageOp.next;
    return _sideEffects.loadPage(pagination.nextPage).then(_finishLoadNext);
  }

  /// Is called once [loadNextItems] completes.
  /// 
  /// Before doing anything it checks whether we're still expecting this
  /// page, or if we've moved on i.e. if the user refreshed before this was
  /// called. If we're still expecting it then it updates the relevant values
  /// and returns the [Listing.things].
  Iterable<Thing> _finishLoadNext(Listing listing) {
    if (_currOp != _PageOp.next)
      return null;

    _currOp = null;
    _pagination = _pagination.forward(listing);
    return listing.things;
  }

  /// Loads the previous page of content if it exists.
  @protected
  Future<Iterable<Thing>> loadPreviousItems() {
    assert(pagination?.previousPageExists == true);
    if (_currOp != null || pagination?.previousPageExists != true)
      return null;

    _currOp = _PageOp.previous;
    return _sideEffects.loadPage(pagination.previousPage).then(_finishLoadPrevious);
  }

  /// Is called once [loadPreviousItems] completes.
  /// 
  /// Like [_finishLoadNext], it checks whether this page is still expected
  /// before updating any values.
  Iterable<Thing> _finishLoadPrevious(Listing listing) {
    if (_currOp != _PageOp.previous)
      return null;

    _currOp = null;
    _pagination = _pagination.backward(listing);
    return listing.things;
  }
}

class CurrentPageNotification extends Notification {

  const CurrentPageNotification(this.value);

  final int value;
}