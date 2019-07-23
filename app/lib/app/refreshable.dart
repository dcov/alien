import 'dart:async';

import 'package:reddit/values.dart';
import 'package:flutter/material.dart';

import 'base.dart';
import 'scrollable.dart';
import 'thing.dart';

abstract class RefreshableModel extends Model with UndisposedStoreMixin, ScrollableModelMixin {

  bool get isRefreshing => _isRefreshing;
  bool _isRefreshing = false;

  ImmutableList<Model> get children {
    _children ??= ImmutableList(childList);
    return _children;
  }
  ImmutableList<Model> _children;

  @protected
  final List<Model> childList = List<Model>();
  
  void refresh() {
    if (_isRefreshing)
      return;
    setRefreshing();
    loadItems().then(
      finishRefresh,
      onError: finishError
    );
  }

  @protected
  void setRefreshing() {
    if (_isRefreshing)
      return;
    _isRefreshing = true;
    clearItems();
    notifyListeners();
  }

  @protected
  void clearItems() {
    disposeChildren();
    childList.clear();
  }

  @protected
  Future<Iterable<Object>> loadItems();

  @protected
  void finishRefresh(covariant Iterable<Object> items) {
    assert(items != null);
    if (!_isRefreshing)
      return;
    _isRefreshing = false;
    addItems(items);
    notifyListeners();
  }

  @protected
  void addItems(covariant Iterable<Object> items) {
    final newChildren = mapItems(items);
    childList.addAll(newChildren);
  }

  @protected
  Iterable<Model> mapItems(covariant Iterable<Object> items) {
    List<Model> list = List<Model>();
    for (final item in items) {
      Model child = takeUndisposedIf((Model child) => itemMapsToChild(item, child))
                  ?? createItem(item);
      list.add(child);
    }
    return list;
  }

  @protected
  bool itemMapsToChild(covariant Object item, covariant Model child);

  @protected
  Model createItem(covariant Object item);

  @protected
  void finishError(dynamic error) { }

  @override
  void visitChildren(ModelVisitor visitor) {
    super.visitChildren(visitor);
    childList.forEach(visitor);
  }

  @override
  bool dispose() {
    bool result = super.dispose();
    childList.clear();
    return result;
  }
}

abstract class RefreshableThingsModel extends RefreshableModel {

  @override
  bool itemMapsToChild(Thing thing, ThingModelMixin child) {
    return child.matchThing(thing);
  }
}

class RefreshableConfiguration extends InheritedWidget {

  static RefreshableConfiguration of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(RefreshableConfiguration)
        ?? const RefreshableConfiguration();
  }

  const RefreshableConfiguration({
    Key key,
    this.indicatorColor,
    Widget child
  }) : super(key: key, child: child);

  final Color indicatorColor;

  @override
  bool updateShouldNotify(RefreshableConfiguration oldWidget) {
    return this.indicatorColor != oldWidget.indicatorColor;
  }
}

abstract class RefreshableScrollViewState<M extends RefreshableModel, W extends View<M>>
  extends ViewState<M, W>
  with ScrollableStateMixin<M, W> { 

  @override
  bool get rebuildOnChanges => true;

  @protected
  Color getIndicatorColor(BuildContext context) {
    return RefreshableConfiguration.of(context).indicatorColor;
  }

  /// The user should always be able to scroll so that they can overscroll to refresh.
  @override
  ScrollPhysics getPhysics(BuildContext context) {
    switch (Theme.of(context).platform) {
      case TargetPlatform.iOS:
        return const AlwaysScrollableScrollPhysics();
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return const AlwaysScrollableScrollPhysics(
          parent: CustomClampingScrollPhysics(
            canUnderscroll: true,
          )
        );
    }
    return null;
  }

  @protected
  Widget buildDragIndicator() {
    return SliverIndicator(
      onTriggered: model.refresh,
      triggerFeedback: Theme.of(context).platform == TargetPlatform.iOS,
      builder: model.isRefreshing ? Indicator.emptyBuilder : Indicator.builder,
    );
  }

  @protected
  Widget buildRefreshIndicator() {
    return model.isRefreshing
      ? SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(getIndicatorColor(context)),
            )
          )
        )
      : SliverToBoxAdapter(child: const EmptyBox());
  }

  @protected
  Widget buildChildList() {
    return SliverList(delegate: getChildDelegate(context));
  }

  @protected
  SliverChildDelegate getChildDelegate(BuildContext context) {
    return SliverChildBuilderDelegate(
      (BuildContext context, int index) => buildChild(context, model.children[index]),
      childCount: model.children.length
    );
  }

  @protected
  Widget buildChild(BuildContext context, covariant Model child);

  @override
  List<Widget> buildSlivers(BuildContext context) {
    return <Widget>[
      buildDragIndicator(),
      buildChildList(),
      buildRefreshIndicator()
    ];
  }
}