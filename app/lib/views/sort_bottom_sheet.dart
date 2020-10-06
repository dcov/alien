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

typedef SortParameterCallback<T extends Parameter> = void Function(T parameter);

class _SortBottomSheet<T extends Parameter> extends StatefulWidget {

  _SortBottomSheet({
    Key key,
    @required this.parameters,
    @required this.currentSelection,
    @required this.onSelection
  }) : assert(parameters != null),
       assert(currentSelection != null),
       assert(onSelection != null),
       super(key: key);

  final List<T> parameters;

  final T currentSelection;

  final SortParameterCallback<T> onSelection;

  @override
  _SortBottomSheetState<T> createState() => _SortBottomSheetState<T>();
}

class _SortBottomSheetState<T extends Parameter> extends State<_SortBottomSheet<T>> {

  List<Parameter> _currentParameters;

  void _handleSelection(BuildContext context, T parameter) {
    if (parameter is TimedParameter && parameter.isTimed) {

    }
    Navigator.pop(context);
    widget.onSelection(parameter);
  }

  @override
  Widget build(_) {
    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 2/3,
      builder: (BuildContext context, ScrollController controller) {
        return ListView(
          controller: controller,
          shrinkWrap: true,
          children: widget.parameters.map((T parameter){
              return _ParameterTile(
                parameter: parameter,
                isCurrentSelection: parameter == widget.currentSelection,
                onTap: () => _handleSelection(context, parameter));
            }).toList());
      });
  }
}

void showSortBottomSheet<T extends Parameter>({
    @required BuildContext context,
    @required List<T> parameters,
    @required T currentSelection,
    @required SortParameterCallback<T> onSelection,
  }) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return _SortBottomSheet<T>(
        parameters: parameters,
        currentSelection: currentSelection,
        onSelection: onSelection);
    });
}

class SortSliver<T extends Parameter> extends StatelessWidget {

  SortSliver({
    Key key,
    @required this.parameters,
    @required this.currentSelection,
    @required this.onSelection
  }) : assert(parameters != null),
       assert(currentSelection != null),
       assert(onSelection != null),
       super(key: key);

  final List<T> parameters;

  final T currentSelection;

  final SortParameterCallback <T> onSelection;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.grey.shade200),
        child: Pressable(
          onPress: () {
            showSortBottomSheet<T>(
              context: context,
              parameters: parameters,
              currentSelection: currentSelection,
              onSelection: onSelection);
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
                    currentSelection.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey.shade600))),
              ])))));
  }
}

