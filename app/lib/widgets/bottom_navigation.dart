import 'package:flutter/widgets.dart';

class BottomNavigation extends StatelessWidget implements PreferredSizeWidget {

  BottomNavigation({
    Key? key,
    required this.items,
    this.onTap,
    this.currentIndex = 0,
    required this.activeColor,
    required this.inactiveColor,
    this.iconSize = 30.0,
    double height = kDefaultHeight,
  }) : assert(items.length >= 2),
       assert(0 <= currentIndex && currentIndex < items.length),
       this.preferredSize = Size.fromHeight(height),
       super(key: key);

  static const double kDefaultHeight = 48.0;

  final List<BottomNavigationBarItem> items;

  final ValueChanged<int>? onTap;

  final int currentIndex;

  final Color activeColor;

  final Color inactiveColor;

  final double iconSize;

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    Widget result = SizedBox(
      height: preferredSize.height + bottomPadding,
      child: IconTheme.merge(
        data: IconThemeData(color: inactiveColor, size: iconSize),
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _buildTabItems(context)))));

    return result;
  }

  List<Widget> _buildTabItems(BuildContext context) {
    final List<Widget> result = <Widget>[];

    for (int index = 0; index < items.length; index += 1) {
      final bool active = index == currentIndex;
      result.add(
        _wrapActiveItem(
          context,
          Expanded(
            child: Semantics(
              selected: active,
              hint: 'tab, ${index + 1} of ${items.length}',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap == null ? null : () { onTap!(index); },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: _buildSingleTabItem(items[index], active),
                  ),
                ),
              ),
            ),
          ),
          active: active,
        ),
      );
    }

    return result;
  }

  List<Widget> _buildSingleTabItem(BottomNavigationBarItem item, bool active) {
    return <Widget>[
      Expanded(
        child: Center(child: active ? item.activeIcon : item.icon),
      ),
      if (item.title != null) item.title!,
    ];
  }

  /// Change the active tab item's icon and title colors to active.
  Widget _wrapActiveItem(BuildContext context, Widget item, { required bool active }) {
    if (!active)
      return item;

    return IconTheme.merge(
      data: IconThemeData(color: activeColor),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: activeColor),
        child: item,
      ),
    );
  }
}
