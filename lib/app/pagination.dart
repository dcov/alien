import 'package:flutter/widgets.dart';

import 'base.dart';
import 'endless_pagination_behavior.dart';
import 'pager_pagination_behavior.dart';
import 'pagination_behavior.dart';
import 'thing.dart';

class PaginationModelSideEffects {

  const PaginationModelSideEffects();

  EndlessPaginationBehaviorModel createEndlessPaginationBehaviorModel(
      PaginationBehaviorModelSideEffects sideEffects) {
    return EndlessPaginationBehaviorModel(sideEffects);
  }

  PagerPaginationBehaviorModel createPagerPaginationBehaviorModel(
      PaginationBehaviorModelSideEffects sideEffects) {
    return PagerPaginationBehaviorModel(sideEffects);
  }
}

enum PaginationMode {
  endless,
  pager
}

abstract class PaginationModel extends Model implements PaginationBehaviorModelSideEffects {

  PaginationModel([
    this._mode = PaginationMode.endless,
    this._sideEffects = const PaginationModelSideEffects()
  ]);

  PaginationBehaviorModel get behavior {
    if (_behavior == null) {
      _updateBehavior();
    }
    return _behavior;
  }
  PaginationBehaviorModel _behavior;
  
  set mode(PaginationMode newMode) {
    assert(newMode != null, 'PaginationModel.mode cannot be null');
    if (newMode != null && newMode != _mode) {
      _mode = newMode;
      _updateBehavior();
    }
  }
  PaginationMode _mode;

  final PaginationModelSideEffects _sideEffects;

  void refresh() => behavior.refresh();

  void _updateBehavior() {
    switch (_mode) {
      case PaginationMode.endless:
        _setBehavior<EndlessPaginationBehaviorModel>(
          orElse: () => _sideEffects.createEndlessPaginationBehaviorModel(this)
        );
        break;
      case PaginationMode.pager:
       _setBehavior<PagerPaginationBehaviorModel>(
          orElse: () => _sideEffects.createPagerPaginationBehaviorModel(this)
        );
    }
  }

  void _setBehavior<B extends PaginationBehaviorModel>({ PaginationBehaviorModel orElse() }) {
    PaginationBehaviorModel newBehavior;
    final oldBehavior = _behavior;
    if (oldBehavior == null) {
      newBehavior = orElse();
    } else {
      if (oldBehavior is B) {
        newBehavior = oldBehavior;
      } else {
        newBehavior = orElse();
        oldBehavior.dispose();
        newBehavior.absorbUndisposed(oldBehavior);
      }
    }
    _behavior = newBehavior;
    notifyListeners();
  }

  @override
  void visitChildren(visitor) {
    super.visitChildren(visitor);
    if (_behavior != null)
      visitor(_behavior);
  }
}

abstract class PaginationScrollView extends StatelessWidget {

  PaginationScrollView({ Key key, @required this.model }) : super(key: key);

  final PaginationModel model;

  @protected
  Widget buildChild(BuildContext context, covariant ThingModelMixin childModel);

  @override
  Widget build(BuildContext context) {
    return ValueBuilder(
      listenable: model,
      valueGetter: () => model.behavior,
      builder: (BuildContext context, PaginationBehaviorModel behavior, _) {
        if (behavior is EndlessPaginationBehaviorModel)
          return EndlessPaginationBehaviorScrollView(
            builder: buildChild,
            model: behavior
          );
      },
    );
  }
}