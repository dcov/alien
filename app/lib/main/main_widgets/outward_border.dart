part of '../main.dart';

const double _radiansPerDegree = math.pi / 180;

const double _ninetyDegreesInRadians = 90 * _radiansPerDegree;

const double _oneHundredEightyDegreesInRadians = 180 * _radiansPerDegree;

const double _twoHundredSeventyDegreesInRadians = 270 * _radiansPerDegree;

abstract class _OutwardBorder extends ShapeBorder {

  const factory _OutwardBorder.top(double radius) = _TopOutwardBorder;

  const factory _OutwardBorder.bottom(double radius) = _BottomOutwardBorder;

  const _OutwardBorder._(this.radius);

  final double radius;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  ShapeBorder scale(double t) {
    return this;
  }

  @protected
  Path _getPath(Rect rect);

  @override
  Path getInnerPath(Rect rect, {TextDirection textDirection}) {
    return _getPath(rect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    return _getPath(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection textDirection}) { }
}

class _TopOutwardBorder extends _OutwardBorder {

  const _TopOutwardBorder(double radius) : super._(radius);

  @override
  Path _getPath(Rect rect) {
    final double diameter = radius * 2;
    return Path()
      ..arcTo(
          Rect.fromLTWH(0, -diameter, diameter, diameter),
          _oneHundredEightyDegreesInRadians,
          -_ninetyDegreesInRadians,
          false)
      ..lineTo(rect.width - radius, 0)
      ..arcTo(
          Rect.fromLTWH(rect.width - diameter, -diameter, diameter, diameter),
          _ninetyDegreesInRadians,
          -_ninetyDegreesInRadians,
          false)
      ..lineTo(rect.width, rect.height)
      ..lineTo(0, rect.height)
      ..lineTo(0, -radius);
  }
}

class _BottomOutwardBorder extends _OutwardBorder {

  const _BottomOutwardBorder(double radius) : super._(radius);

  @override
  Path _getPath(Rect rect) {
    final double diameter = radius * 2;
    return Path()
      ..lineTo(rect.width, 0)
      ..lineTo(rect.width, rect.height)
      ..arcTo(
          Rect.fromLTWH(rect.width - diameter, rect.height, diameter, diameter),
          0,
          -_ninetyDegreesInRadians,
          false)
      ..lineTo(radius, rect.height)
      ..arcTo(
          Rect.fromLTWH(0, rect.height, diameter, diameter),
          _twoHundredSeventyDegreesInRadians,
          -_ninetyDegreesInRadians,
          false)
      ..lineTo(0, 0);
  }
}
