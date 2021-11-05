import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef PopupMenuItemsBuilder<T> = List<PopupMenuEntry<T>> Function(BuildContext context);

class PopupMenuAnchor<T> extends StatelessWidget {

  PopupMenuAnchor({
    Key? key,
    this.offset = Offset.zero,
    this.initialValue,
    required this.onItemSelected,
    required this.itemsBuilder,
    required this.child,
  }) : super(key: key);

  final Offset offset;

  final T? initialValue;

  final PopupMenuItemSelected<T> onItemSelected;

  final PopupMenuItemsBuilder<T> itemsBuilder;

  final Widget child;

  void _showPopupMenu(BuildContext context) {
    final anchor = context.findRenderObject()! as RenderBox;
    final overlay = Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        anchor.localToGlobal(offset, ancestor: overlay),
        anchor.localToGlobal(anchor.size.bottomRight(Offset.zero) + offset, ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<T>(
      context: context,
      position: position,
      items: itemsBuilder(context),
      initialValue: initialValue,
    ).then((T? newValue) {
      if (newValue != null) {
        onItemSelected(newValue);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showPopupMenu(context),
      child: child,
    );
  }
}