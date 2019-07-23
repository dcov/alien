import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'values.dart';

typedef ThemeWidgetBuilder = Widget Function(BuildContext, ThemeData);

class MaterialToolbar extends StatelessWidget implements PreferredSizeWidget {

  static const defaultHeight = 48.0;

  MaterialToolbar({
    Key key,
    this.elevation = 4.0,
    this.color,
    this.decoration,
    this.centerMiddle = true,
    this.middleSpacing = Insets.halfAmount,
    this.leading,
    this.middle,
    this.trailing,

  }) : super(key: key);

  @override
  final Size preferredSize = const Size.fromHeight(defaultHeight);

  final double elevation;
  final Color color;
  final Decoration decoration;
  final bool centerMiddle;
  final double middleSpacing;
  final Widget leading;
  final Widget middle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {

    Widget child = NavigationToolbar(
      leading: leading,
      middle: middle,
      trailing: trailing,
      centerMiddle: centerMiddle,
      middleSpacing: middleSpacing,
    );

    if (decoration != null) {
      child = DecoratedBox(
        decoration: decoration,
        child: Material(
          type: MaterialType.transparency,
          child: child,
        )
      );
    }

    return SizedBox.fromSize(
      size: preferredSize,
      child: Material(
        elevation: elevation,
        color: color,
        child: child
      ),
    );
  }
}

class MaterialBar extends StatelessWidget implements PreferredSizeWidget {

  MaterialBar({
    Key key,
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    @required this.children
  }) : super(key: key);

  @override
  final Size preferredSize = const Size.fromHeight(48.0);

  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: Size.fromHeight(48.0),
      child: Material(
        elevation: 4.0,
        child: Row(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: children,
        )
      )
    );
  }
}

class MaterialContainer extends StatelessWidget {

  MaterialContainer({
    Key key,
    this.alignment,
    this.padding,
    Color color,
    Decoration decoration,
    this.useCanvasColor = false,
    this.foregroundDecoration,
    double width,
    double height,
    BoxConstraints constraints,
    this.margin,
    this.transform,
    this.child,
  }) : assert(margin == null || margin.isNonNegative),
       assert(padding == null || padding.isNonNegative),
       assert(decoration == null || decoration.debugAssertIsValid()),
       assert(constraints == null || constraints.debugAssertIsValid()),
       assert(color == null || decoration == null,
         'Cannot provide both a color and a decoration\n'
         'The color argument is just a shorthand for "decoration: new BoxDecoration(color: color)".'
       ),
       decoration = decoration ?? (color != null ? BoxDecoration(color: color) : null),
       constraints =
        (width != null || height != null)
          ? constraints?.tighten(width: width, height: height)
            ?? BoxConstraints.tightFor(width: width, height: height)
          : constraints,
       super(key: key);

  /// The [child] contained by the container.
  ///
  /// If null, and if the [constraints] are unbounded or also null, the
  /// container will expand to fill all available space in its parent, unless
  /// the parent provides unbounded constraints, in which case the container
  /// will attempt to be as small as possible.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  /// Align the [child] within the container.
  ///
  /// If non-null, the container will expand to fill its parent and position its
  /// child within itself according to the given value. If the incoming
  /// constraints are unbounded, then the child will be shrink-wrapped instead.
  ///
  /// Ignored if [child] is null.
  ///
  /// See also:
  ///
  ///  * [Alignment], a class with convenient constants typically used to
  ///    specify an [AlignmentGeometry].
  ///  * [AlignmentDirectional], like [Alignment] for specifying alignments
  ///    relative to text direction.
  final AlignmentGeometry alignment;

  /// Empty space to inscribe inside the [decoration]. The [child], if any, is
  /// placed inside this padding.
  ///
  /// This padding is in addition to any padding inherent in the [decoration];
  /// see [Decoration.padding].
  final EdgeInsetsGeometry padding;

  /// The decoration to paint behind the [child].
  ///
  /// A shorthand for specifying just a solid color is available in the
  /// constructor: set the `color` argument instead of the `decoration`
  /// argument.
  final Decoration decoration;

  final bool useCanvasColor;

  /// The decoration to paint in front of the [child].
  final Decoration foregroundDecoration;

  /// Additional constraints to apply to the child.
  ///
  /// The constructor `width` and `height` arguments are combined with the
  /// `constraints` argument to set this property.
  ///
  /// The [padding] goes inside the constraints.
  final BoxConstraints constraints;

  /// Empty space to surround the [decoration] and [child].
  final EdgeInsetsGeometry margin;

  /// The transformation matrix to apply before painting the container.
  final Matrix4 transform;

  EdgeInsetsGeometry get _paddingIncludingDecoration {
    if (decoration == null || decoration.padding == null)
      return padding;
    final EdgeInsetsGeometry decorationPadding = decoration.padding;
    if (padding == null)
      return decorationPadding;
    return padding.add(decorationPadding);
  }

  @override
  Widget build(BuildContext context) {
    Widget current = child;

    if (current != null) {
      current = Material(
        type: MaterialType.transparency,
        child: current,
      );
    }

    if (child == null && (constraints == null || !constraints.isTight)) {
      current = LimitedBox(
        maxWidth: 0.0,
        maxHeight: 0.0,
        child: ConstrainedBox(constraints: const BoxConstraints.expand())
      );
    }

    if (alignment != null)
      current = Align(alignment: alignment, child: current);

    final EdgeInsetsGeometry effectivePadding = _paddingIncludingDecoration;
    if (effectivePadding != null)
      current = Padding(padding: effectivePadding, child: current);

      
    Decoration decoration = this.decoration;
    if (decoration == null && useCanvasColor) {
      decoration = BoxDecoration(color: Theme.of(context).canvasColor);
    }

    if (decoration != null) {
      current = DecoratedBox(decoration: decoration, child: current);
    } 

    if (foregroundDecoration != null) {
      current = DecoratedBox(
        decoration: foregroundDecoration,
        position: DecorationPosition.foreground,
        child: current
      );
    }

    if (constraints != null)
      current = ConstrainedBox(constraints: constraints, child: current);

    if (margin != null)
      current = Padding(padding: margin, child: current);

    if (transform != null)
      current = Transform(transform: transform, child: current);

    return current;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<AlignmentGeometry>('alignment', alignment, showName: false, defaultValue: null));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>('padding', padding, defaultValue: null));
    properties.add(DiagnosticsProperty<Decoration>('bg', decoration, defaultValue: null));
    properties.add(DiagnosticsProperty<Decoration>('fg', foregroundDecoration, defaultValue: null));
    properties.add(DiagnosticsProperty<BoxConstraints>('constraints', constraints, defaultValue: null));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>('margin', margin, defaultValue: null));
    properties.add(ObjectFlagProperty<Matrix4>.has('transform', transform));
  }
}