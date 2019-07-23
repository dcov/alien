import 'package:flutter/widgets.dart';

import '../model.dart';

abstract class View<M extends Model> extends StatefulWidget {

  View({ Key key, @required this.model }) : super(key: key);

  final M model;

  @override
  ViewState<M, View<M>> createState();
}

abstract class ViewState<M extends Model, W extends View<M>> extends State<W> {

  @protected
  M get model => _model;
  M _model;

  @protected
  bool get rebuildOnChanges => false;

  @protected
  void rebuild() => setState(() { });

  @override
  void initState() {
    super.initState();
    initModel();
  }

  @protected
  @mustCallSuper
  void initModel() {
    _model = widget.model;
    if (rebuildOnChanges)
      _model.addListener(rebuild);
  }

  @override
  void didUpdateWidget(View<M> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.model == _model)
      return;
    
    final M oldModel = _model;
    _model = oldWidget.model;
    didUpdateModel(oldModel);
  }

  @protected
  @mustCallSuper
  void didUpdateModel(M oldModel) {
    oldModel.removeListener(rebuild);
  }

  @override
  void dispose() {
    disposeModel();
    super.dispose();
  }

  @protected
  @mustCallSuper
  void disposeModel() {
    _model.removeListener(rebuild);
    _model = null;
  }
}