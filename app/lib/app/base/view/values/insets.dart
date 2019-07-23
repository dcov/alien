import 'package:flutter/widgets.dart';

class Insets {
  static const double quarterAmount = 4.0;
  static const double halfAmount = 8.0;
  static const double threeQuartersAmount = 12.0;
  static const double fullAmount = 16.0;

  static const EdgeInsets quarterAll = const EdgeInsets.all(quarterAmount);
  static const EdgeInsets quarterLeft = const EdgeInsets.only(left: quarterAmount);
  static const EdgeInsets quarterTop = const EdgeInsets.only(top: quarterAmount);
  static const EdgeInsets quarterRight = const EdgeInsets.only(right: quarterAmount);
  static const EdgeInsets quarterBottom = const EdgeInsets.only(bottom: quarterAmount);
  static const EdgeInsets quarterVertical = const EdgeInsets.symmetric(vertical: quarterAmount);

  static const EdgeInsets halfAll = const EdgeInsets.all(halfAmount);
  static const EdgeInsets halfLeft = const EdgeInsets.only(left: halfAmount);
  static const EdgeInsets halfTop = const EdgeInsets.only(top: halfAmount);
  static const EdgeInsets halfRight = const EdgeInsets.only(right: halfAmount);
  static const EdgeInsets halfBottom = const EdgeInsets.only(bottom: halfAmount);
  static const EdgeInsets halfHorizontal = const EdgeInsets.symmetric(horizontal: halfAmount);
  static const EdgeInsets halfVertical = const EdgeInsets.symmetric(vertical: halfAmount);

  static const EdgeInsets threeQuartersAll = const EdgeInsets.all(threeQuartersAmount);
  static const EdgeInsets threeQuartersLeft = const EdgeInsets.only(left: threeQuartersAmount);
  static const EdgeInsets threeQuartersTop = const EdgeInsets.only(top: threeQuartersAmount);
  static const EdgeInsets threeQuartersRight = const EdgeInsets.only(right: threeQuartersAmount);
  static const EdgeInsets threeQuartersBottom = const EdgeInsets.only(bottom: threeQuartersAmount);
  static const EdgeInsets threeQuartersHorizontal = const EdgeInsets.symmetric(horizontal: threeQuartersAmount);
  static const EdgeInsets threeQuartersVertical = const EdgeInsets.symmetric(vertical: threeQuartersAmount);

  static const EdgeInsets fullAll = const EdgeInsets.all(fullAmount);
  static const EdgeInsets fullLeft = const EdgeInsets.only(left: fullAmount);
  static const EdgeInsets fullTop = const EdgeInsets.only(top: fullAmount);
  static const EdgeInsets fullRight = const EdgeInsets.only(right: fullAmount);
  static const EdgeInsets fullBottom = const EdgeInsets.only(bottom: fullAmount);
  static const EdgeInsets fullHorizontal = const EdgeInsets.symmetric(horizontal: fullAmount);
  static const EdgeInsets fullVertical = const EdgeInsets.symmetric(vertical: fullAmount);
  static const EdgeInsets fullAllExceptTop = const EdgeInsets.fromLTRB(fullAmount, 0.0, fullAmount, fullAmount);
  static const EdgeInsets fullAllExceptBottom = const EdgeInsets.fromLTRB(fullAmount, fullAmount, fullAmount, 0.0);

  static const EdgeInsets fullHorizontalHalfVertical = const EdgeInsets.symmetric(horizontal: fullAmount, vertical: halfAmount);
  static const EdgeInsets fullHorizontalThreeQuartersVertical = const EdgeInsets.symmetric(horizontal: fullAmount, vertical: threeQuartersAmount);

  Insets._();
}