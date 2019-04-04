import 'package:flutter/widgets.dart';

import 'base.dart';

mixin ScrollableModelMixin on Model {
  double offset;
}

@optionalTypeArgs
mixin ScrollableStateMixin<M extends ScrollableModelMixin, W extends View<M>> on ViewState<M, W> {

  @protected
  ScrollController get controller => _controller;
  ScrollController _controller;

  @override
  void initModel() {
    super.initModel();
    initController();
  }

  @protected
  @mustCallSuper
  void initController() {
    _controller = ScrollController(
      initialScrollOffset: model.offset ?? 0.0,
    );
    _controller.addListener(onScrollUpdate);
  }

  @protected
  @mustCallSuper
  void onScrollUpdate() {
    model.offset = _controller.offset;
  }

  @override
  void didUpdateModel(M oldModel) {
    super.didUpdateModel(oldModel);
    disposeController(oldModel);
    initController();
  }

  @protected
  @mustCallSuper
  void disposeController(M model) {
    _controller.removeListener(onScrollUpdate);
    _controller.dispose();
  }

  @override
  void disposeModel() {
    disposeController(model);
    super.disposeModel();
  }

  @protected
  ScrollPhysics getPhysics(BuildContext context) => null;

  @protected
  List<Widget> buildSlivers(BuildContext context);

  @protected
  Widget buildScrollView(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      physics: getPhysics(context),
      slivers: buildSlivers(context),
    ); 
  }
}