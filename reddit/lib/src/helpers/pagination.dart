import 'dart:math' as math;

import 'package:reddit/endpoints.dart';
import 'package:reddit/values.dart';

enum PaginationState {
  normal,
  before,
}

const int kDefaultItemLimit = 25;
const int kMaxItemLimit = 100;

// Tracks a handful of variables needed to page through listings.
class Pagination {

  factory Pagination.maxLimit() => Pagination(limit: kMaxItemLimit);
  factory Pagination({ int limit = kDefaultItemLimit }) {
    limit = math.min(math.max(limit, 0), kMaxItemLimit);
    return Pagination._(
      limit: limit,
      count: 0,
      nextPage: Page.next(limit: limit),
      previousPage: null,
      state: PaginationState.normal
    );
  }
  
  Pagination._({
    this.limit,
    this.count,
    this.nextPage,
    this.previousPage,
    this.state
  });

  final int limit;
  final int count;
  final Page nextPage;
  final Page previousPage;
  final PaginationState state;

  bool get nextPageExists => nextPage != null;
  bool get previousPageExists => previousPage != null;

  Page _buildNextPage(Listing listing, int count) =>
    listing.nextId != null
      ? Page.next(limit: limit, count: count, id: listing.nextId)
      : null;
  
  Page _buildPreviousPage(Listing listing, int count) =>
    listing.previousId != null
      ? Page.previous(limit: limit, count: count, id: listing.previousId)
      : null;

  Pagination forward(Listing listing) {

    final int newCount = (){
      switch (state) {
        case PaginationState.normal:
          return this.count + this.limit;
        case PaginationState.before:
          return this.count - 1;
        default:
          throw StateError('PaginationState is null');
      }
    }();

    return Pagination._(
      limit: limit,
      count: newCount,
      nextPage: _buildNextPage(listing, newCount),
      previousPage: _buildPreviousPage(listing, newCount),
      state: PaginationState.normal
   );
  }

  Pagination backward(Listing listing) {

    final int newCount = () {
      switch (state) {
        case PaginationState.normal:
          return count + 1;
        case PaginationState.before:
          return count - limit;
        default:
          throw StateError('PaginationState is null');
      }
    }();

    return Pagination._(
      limit: limit,
      count: newCount,
      nextPage: _buildNextPage(listing, newCount),
      previousPage: _buildPreviousPage(listing, newCount),
      state: PaginationState.before
    );
  }
}