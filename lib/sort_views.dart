import 'package:flutter/material.dart';

import 'reddit/types.dart';
import 'widgets/hover_highlight.dart';
import 'widgets/popup_menu_anchor.dart';

class SortButton<T extends RedditArg> extends StatelessWidget {

  SortButton({
    Key? key,
    required this.onSortChanged,
    required this.sortArgs,
    required this.currentSort,
  }) : super(key: key);

  final PopupMenuItemSelected<T> onSortChanged;

  final List<T> sortArgs;

  final T currentSort;

  @override
  Widget build(BuildContext context) {
    return HoverHighlight(
      child: PopupMenuAnchor(
        onItemSelected: onSortChanged,
        itemsBuilder: (BuildContext _) {
          return sortArgs.map<PopupMenuItem<T>>((T arg) {
            return PopupMenuItem<T>(
              value: arg,
              child: ListTile(
                title: Text(arg.name),
              ),
            );
          }).toList();
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(currentSort.name.toUpperCase()),
              Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}

class TimeSortButton extends StatelessWidget {

  TimeSortButton({
    Key? key,
    required this.onSortChanged,
    required this.currentSort,
  }) : super(key: key);

  final PopupMenuItemSelected<TimeSort> onSortChanged;

  final TimeSort currentSort;

  @override
  Widget build(BuildContext context) {
    return SortButton<TimeSort>(
      onSortChanged: onSortChanged,
      sortArgs: const <TimeSort>[
        TimeSort.hour,
        TimeSort.day,
        TimeSort.week,
        TimeSort.month,
        TimeSort.year,
        TimeSort.all,
      ],
      currentSort: currentSort,
    );
  }
}