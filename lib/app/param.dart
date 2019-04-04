import 'dart:async';

import 'package:reddit/endpoints.dart';
import 'package:flutter/material.dart';

import 'base.dart';

class ParamModel<T extends Param> extends Model {

  ParamModel(this._param, this.paramValues, this._onParamUpdated);

  T get param => _param;
  T _param;

  final Iterable<T> paramValues;
  final VoidCallback _onParamUpdated;

  void update(T value) {
    if (_param == value)
      return; 
    _param = value;
    _onParamUpdated();
    notifyListeners();
  }
}

class TimedParamModel<T extends TimedParam> extends ParamModel<T> {

  TimedParamModel(
    T param,
    Iterable<T> paramValues,
    VoidCallback onParamUpdated, [
    this._time
  ]) : super(param, paramValues, onParamUpdated);

  TimeSort get time => _time;
  TimeSort _time;
  
  final Iterable<TimeSort> timeValues = TimeSort.values;

  @override
  void update(T value, [ TimeSort timeValue ]) {
    if (_param == value && _time == timeValue)
      return;
    _param = value;
    _time = timeValue;
    _onParamUpdated();
    notifyListeners();
  }
}

Future<Param> _showParamMenu({
  @required BuildContext context,
  Param initialValue,
  @required Iterable<Param> possibleValues,
}) {
  return showMenuAt<Param>(
    context: context,
    initialValue: initialValue,
    items: possibleValues.map((Param param) {
      return PopupMenuItem<Param>(
        value: param,
        child: ListItem(title: Body1Text('${param.name}')),
      );
    }).toList()
  );
}

void _showTimedParamMenu({
  @required BuildContext context,
  @required Param paramResult,
  @required TimedParamModel<TimedParam> model,
}) {
  _showParamMenu(
    context: context,
    initialValue: paramResult == model.param ? model.time : null,
    possibleValues: model.timeValues
  ).then((Param timeResult) {
    if (timeResult == null)
      return;
    
    model.update(paramResult, timeResult);
  });
}

void showParamMenu({
  @required BuildContext context,
  @required ParamModel<Param> model,
}) {
  _showParamMenu(
    context: context,
    initialValue: model.param,
    possibleValues: model.paramValues
  ).then((Param result) {
    if (result == null)
      return;
    
    if (result is TimedParam) {
      assert(model is TimedParamModel);
      if (result.isTimed) {
        _showTimedParamMenu(
          context: context,
          paramResult: result,
          model: model
        );
        return;
      }
    }

    model.update(result);
  });
}