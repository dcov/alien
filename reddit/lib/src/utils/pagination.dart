import 'dart:math' as math;

import '../types/args.dart';
import '../types/data.dart';

enum _PaginationState {
  normal,
  before,
}

// Tracks a handful of variables needed to page through listings.
class Pagination {

  factory Pagination.maxLimit() {
    return Pagination(limit: Page.kMaxLimit);
  }

  factory Pagination({ int limit = Page.kDefaultLimit }) {
    limit = math.min(math.max(limit, 0), Page.kMaxLimit);
    return Pagination._(
      limit: limit,
      count: 0,
      nextPage: Page.next(limit: limit),
      previousPage: null,
      state: _PaginationState.normal
    );
  }
  
  Pagination._({
    required this.limit,
    required this.count,
    this.nextPage,
    this.previousPage,
    required this.state
  });

  final int limit;
  final int count;
  final Page? nextPage;
  final Page? previousPage;
  final _PaginationState state;

  bool get nextPageExists => nextPage != null;
  bool get previousPageExists => previousPage != null;

  Page? _buildNextPage(ListingData listing, int count) {
    if (listing.nextId != null)
      return Page.next(limit: limit, count: count, id: listing.nextId!);
    return null;
  }
  
  Page? _buildPreviousPage(ListingData listing, int count) {
    if (listing.previousId != null)
      return Page.previous(limit: limit, count: count, id: listing.previousId!);
    return null;
  }

  Pagination forward(ListingData listing) {
    final int newCount = (){
      switch (state) {
        case _PaginationState.normal:
          return this.count + this.limit;
        case _PaginationState.before:
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
      state: _PaginationState.normal
   );
  }

  Pagination backward(ListingData listing) {
    final int newCount = () {
      switch (state) {
        case _PaginationState.normal:
          return count + 1;
        case _PaginationState.before:
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
      state: _PaginationState.before
    );
  }
}
