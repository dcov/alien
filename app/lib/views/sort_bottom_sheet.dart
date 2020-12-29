import 'package:flutter/material.dart';
import 'package:reddit/reddit.dart';

import '../widgets/pressable.dart';
import '../widgets/tile.dart';

class _ParameterTile extends StatelessWidget {

  _ParameterTile({
    Key key,
    @required this.parameter,
    @required this.isCurrentSelection,
    @required this.onTap,
  }) : assert(parameter != null),
       assert(isCurrentSelection != null),
       assert(onTap != null),
       super(key: key);

  final Parameter parameter;

  final bool isCurrentSelection;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomTile(
      onTap: onTap,
      title: Text(
        parameter.name,
        style: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          color: isCurrentSelection ? Colors.blue.shade900 : Colors.grey.shade600)));
  }
}

typedef SortParameterCallback<T extends Parameter> = void Function(T sortBy, TimeSort sortFrom);

class _SortBottomSheet<T extends Parameter> extends StatefulWidget {

  _SortBottomSheet({
    Key key,
    @required this.parameters,
    @required this.currentSortBy,
    this.currentSortFrom,
    @required this.onSort
  }) : assert(parameters != null),
       assert(currentSortBy != null),
       assert(onSort != null),
       super(key: key);

  final List<T> parameters;

  final T currentSortBy;

  final TimeSort currentSortFrom;

  final SortParameterCallback<T> onSort;

  @override
  _SortBottomSheetState<T> createState() => _SortBottomSheetState<T>();
}

class _SortBottomSheetState<T extends Parameter> extends State<_SortBottomSheet<T>> {

  List<Parameter> _currentParameters;
  Parameter _selectedTimedParameter;

  @override
  void initState() {
    super.initState();
    _currentParameters = widget.parameters;
  }

  void _handleSelection(BuildContext context, Parameter parameter) {
    if (parameter is TimeSort) {
      assert(_selectedTimedParameter != null);
      Navigator.pop(context);
      widget.onSort(_selectedTimedParameter, parameter);
    } else if (parameter is TimedParameter && parameter.isTimed) {
      setState(() {
        _currentParameters = const <Parameter>[
          TimeSort.hour,
          TimeSort.day,
          TimeSort.week,
          TimeSort.month,
          TimeSort.year,
          TimeSort.all
        ];
        _selectedTimedParameter = parameter;
      });
    } else {
      Navigator.pop(context);
      widget.onSort(parameter, null);
    }
  }

  @override
  Widget build(_) {
    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 2/3,
      builder: (BuildContext context, ScrollController controller) {
        return AnimatedSwitcher(
          key: ValueKey(_currentParameters),
          duration: const Duration(milliseconds: 250),
          child: ListView(
            controller: controller,
            shrinkWrap: true,
            children: _currentParameters.map((Parameter parameter) {
              return _ParameterTile(
                parameter: parameter,
                isCurrentSelection: parameter is TimeSort 
                    ? parameter == widget.currentSortFrom
                    : parameter == widget.currentSortBy,
                onTap: () => _handleSelection(context, parameter));
            }).toList()));
      });
  }
}

void showSortBottomSheet<T extends Parameter>({
    @required BuildContext context,
    @required List<T> parameters,
    @required T currentSortBy,
    TimeSort currentSortFrom,
    @required SortParameterCallback<T> onSort,
  }) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return _SortBottomSheet<T>(
        parameters: parameters,
        currentSortBy: currentSortBy,
        currentSortFrom: currentSortFrom,
        onSort: onSort);
    });
}

class SortSliver<T extends Parameter> extends StatelessWidget {

  SortSliver({
    Key key,
    @required this.parameters,
    @required this.currentSortBy,
    this.currentSortFrom,
    @required this.onSort
  }) : assert(parameters != null),
       assert(currentSortBy != null),
       assert(onSort != null),
       super(key: key);

  final List<T> parameters;

  final T currentSortBy;

  final TimeSort currentSortFrom;

  final SortParameterCallback <T> onSort;

  @override
  Widget build(BuildContext context) {

    final title = StringBuffer(currentSortBy.name.toUpperCase());
    if (currentSortFrom != null) {
      title..write(' ')
           ..write(currentSortFrom.name.toUpperCase());
    }

    return SliverToBoxAdapter(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.grey.shade200),
        child: Pressable(
          onPress: () {
            showSortBottomSheet<T>(
              context: context,
              parameters: parameters,
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

