import 'package:flutter/material.dart';
import 'package:reddit/reddit.dart';

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

class _SortBottomSheet<T extends Parameter> extends StatelessWidget {

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

  void _handleSelection(BuildContext context, T parameter) {
    Navigator.pop(context);
    onSelection(parameter);
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
          children: parameters.map((T parameter){
              return _ParameterTile(
                parameter: parameter,
                isCurrentSelection: parameter == currentSelection,
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

