import 'package:flutter/material.dart';

import 'reddit/types.dart';
import 'widgets/pressable.dart';
import 'widgets/tile.dart';

class _SortArgTile extends StatelessWidget {

  _SortArgTile({
    Key? key,
    required this.sortArg,
    required this.isCurrentSelection,
    required this.onTap,
  }) : super(key: key);

  final RedditArg sortArg;

  final bool isCurrentSelection;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomTile(
      onTap: onTap,
      title: Text(
        sortArg.name,
        style: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          color: isCurrentSelection ? Colors.blue.shade900 : Colors.grey.shade600)));
  }
}

typedef SortArgCallback<T extends RedditArg> = void Function(T sortBy, TimeSort? sortFrom);

class _SortBottomSheet<T extends RedditArg> extends StatefulWidget {

  _SortBottomSheet({
    Key? key,
    required this.sortArgs,
    required this.currentSortBy,
    this.currentSortFrom,
    required this.onSort
  }) : super(key: key);

  final List<T> sortArgs;

  final T currentSortBy;

  final TimeSort? currentSortFrom;

  final SortArgCallback<T> onSort;

  @override
  _SortBottomSheetState<T> createState() => _SortBottomSheetState<T>();
}

class _SortBottomSheetState<T extends RedditArg> extends State<_SortBottomSheet<T>> {

  late List<RedditArg> _currentSortArgs;

  // A sort arg that is being further sorted by a TimeSort value.
  T? _selectedTimedArg;

  @override
  void initState() {
    super.initState();
    _currentSortArgs = widget.sortArgs;
  }

  void _handleSelection(BuildContext context, RedditArg sortArg) {
    if (sortArg is TimeSort) {
      assert(_selectedTimedArg != null);
      Navigator.pop(context);
      widget.onSort(_selectedTimedArg!, sortArg);
    } else {
      assert(sortArg is T);
      if (sortArg is TimedParameter && sortArg.isTimed) {
        setState(() {
          // TODO: Move this const list to be a property of TimeSort instead.
          _currentSortArgs = const <RedditArg>[
            TimeSort.hour,
            TimeSort.day,
            TimeSort.week,
            TimeSort.month,
            TimeSort.year,
            TimeSort.all
          ];
          _selectedTimedArg = sortArg as T;
        });
      } else {
        Navigator.pop(context);
        widget.onSort(sortArg as T, null);
      }
    }
  }

  bool _isCurrentSelection(RedditArg sortArg) {
    if (sortArg is TimeSort) {
      return sortArg == widget.currentSortFrom;
    }
    return sortArg == widget.currentSortBy;
  }

  @override
  Widget build(_) {
    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 2/3,
      builder: (BuildContext context, ScrollController controller) {
        return AnimatedSwitcher(
          // We ensure that it only animates when _currentSortArgs changes by
          // using a ValueKey with it.
          key: ValueKey(_currentSortArgs),
          duration: const Duration(milliseconds: 250),
          child: ListView(
            controller: controller,
            shrinkWrap: true,
            children: _currentSortArgs.map((RedditArg sortArg) {
              return _SortArgTile(
                sortArg: sortArg,
                isCurrentSelection: _isCurrentSelection(sortArg),
                onTap: () => _handleSelection(context, sortArg));
            }).toList()));
      });
  }
}

void showSortBottomSheet<T extends RedditArg>({
    required BuildContext context,
    required List<T> sortArgs,
    required T currentSortBy,
    TimeSort? currentSortFrom,
    required SortArgCallback<T> onSort,
  }) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return _SortBottomSheet<T>(
        sortArgs: sortArgs,
        currentSortBy: currentSortBy,
        currentSortFrom: currentSortFrom,
        onSort: onSort);
    });
}

class SortSliver<T extends RedditArg> extends StatelessWidget {

  SortSliver({
    Key? key,
    required this.sortArgs,
    required this.currentSortBy,
    this.currentSortFrom,
    required this.onSort
  }) : super(key: key);

  final List<T> sortArgs;

  final T currentSortBy;

  final TimeSort? currentSortFrom;

  final SortArgCallback <T> onSort;

  @override
  Widget build(BuildContext context) {

    final title = StringBuffer(currentSortBy.name.toUpperCase());
    if (currentSortFrom != null) {
      title..write(' ')
           ..write(currentSortFrom!.name.toUpperCase());
    }

    return SliverToBoxAdapter(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.grey.shade200),
        child: Pressable(
          onPress: () {
            showSortBottomSheet<T>(
              context: context,
              sortArgs: sortArgs,
              currentSortBy: currentSortBy,
              currentSortFrom: currentSortFrom,
              onSort: onSort);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.sort,
                  size: 14.0,
                  color: Colors.grey.shade600),
                Padding(
                  padding: EdgeInsets.only(left: 4.0),
                  child: Text(
                    title.toString(),
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey.shade600))),
              ])))));
  }
}
