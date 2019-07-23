import 'package:flutter/material.dart';

enum TextStyleTheme {
  normal,
  primary,
  accent
}

abstract class StyledText extends StatelessWidget {

  StyledText(
    this.data, {
    Key key,
    this.theme = TextStyleTheme.normal,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    Color color,
    double fontSize,
    FontWeight fontWeight,
    FontStyle fontStyle,
    double letterSpacing,
    double wordSpacing,
    TextBaseline textBaseline,
    double height,
    Paint foreground,
    Paint background,
    List<Shadow> shadows,
    TextDecoration decoration,
    Color decorationColor,
    TextDecorationStyle decorationStyle,
    String debugLabel,
    String fontFamily,
    List<String> fontFamilyFallback,
    String package
  }) : assert(theme != null),
       this._style = TextStyle(
         color: color,
         fontSize: fontSize,
         fontWeight: fontWeight,
         fontStyle: fontStyle,
         letterSpacing: letterSpacing,
         wordSpacing: wordSpacing,
         textBaseline: textBaseline,
         height: height,
         locale: locale,
         foreground: foreground,
         background: background,
         shadows: shadows,
         decoration: decoration,
         decorationColor: decorationColor,
         decorationStyle: decorationStyle,
         debugLabel: debugLabel,
         fontFamily: fontFamily,
         fontFamilyFallback: fontFamilyFallback,
         package: package
       ),
       super(key: key);

  final String data;
  final TextStyleTheme theme;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final Locale locale;
  final bool softWrap;
  final TextOverflow overflow;
  final double textScaleFactor;
  final int maxLines;
  final String semanticsLabel;

  final TextStyle _style;

  @protected
  TextStyle styleFromTheme(TextTheme theme);

  TextTheme _inheritTheme(BuildContext context) {
    final ThemeData data = Theme.of(context);
    switch (theme) {
      case TextStyleTheme.normal:
        return data.textTheme;
      case TextStyleTheme.primary:
        return data.primaryTextTheme;
      case TextStyleTheme.accent:
        return data.accentTextTheme;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle style = styleFromTheme(_inheritTheme(context)).merge(_style);
    return Text(
      data,
      style: style,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaleFactor: textScaleFactor,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
    );
  }
}

class TitleText extends StyledText {

  TitleText(
    String data, {
    Key key,
    TextStyleTheme theme = TextStyleTheme.normal,
    TextAlign textAlign,
    TextDirection textDirection,
    Locale locale,
    bool softWrap,
    TextOverflow overflow,
    double textScaleFactor,
    int maxLines,
    String semanticsLabel,
    Color color,
    double fontSize,
    FontWeight fontWeight,
    FontStyle fontStyle,
    double letterSpacing,
    double wordSpacing,
    TextBaseline textBaseline,
    double height,
    Paint foreground,
    Paint background,
    List<Shadow> shadows,
    TextDecoration decoration,
    Color decorationColor,
    TextDecorationStyle decorationStyle,
    String debugLabel,
    String fontFamily,
    List<String> fontFamilyFallback,
    String package
  }) : super(
    data,
    key: key,
    theme: theme,
    textAlign: textAlign,
    textDirection: textDirection,
    locale: locale,
    softWrap: softWrap,
    overflow: overflow,
    textScaleFactor: textScaleFactor,
    maxLines: maxLines,
    semanticsLabel: semanticsLabel,
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    fontStyle: fontStyle,
    letterSpacing: letterSpacing,
    wordSpacing: wordSpacing,
    textBaseline: textBaseline,
    height: height,
    foreground: foreground,
    background: background,
    shadows: shadows,
    decoration: decoration,
    decorationColor: decorationColor,
    decorationStyle: decorationStyle,
    debugLabel: debugLabel,
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    package: package
  );

  @override
  TextStyle styleFromTheme(TextTheme theme) {
    return theme.title;
  }
}

class SubheadText extends StyledText {

  SubheadText(
    String data, {
    Key key,
    TextStyleTheme theme = TextStyleTheme.normal,
    TextAlign textAlign,
    TextDirection textDirection,
    Locale locale,
    bool softWrap,
    TextOverflow overflow,
    double textScaleFactor,
    int maxLines,
    String semanticsLabel,
    Color color,
    double fontSize,
    FontWeight fontWeight,
    FontStyle fontStyle,
    double letterSpacing,
    double wordSpacing,
    TextBaseline textBaseline,
    double height,
    Paint foreground,
    Paint background,
    List<Shadow> shadows,
    TextDecoration decoration,
    Color decorationColor,
    TextDecorationStyle decorationStyle,
    String debugLabel,
    String fontFamily,
    List<String> fontFamilyFallback,
    String package
  }) : super(
    data,
    key: key,
    theme: theme,
    textAlign: textAlign,
    textDirection: textDirection,
    locale: locale,
    softWrap: softWrap,
    overflow: overflow,
    textScaleFactor: textScaleFactor,
    maxLines: maxLines,
    semanticsLabel: semanticsLabel,
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    fontStyle: fontStyle,
    letterSpacing: letterSpacing,
    wordSpacing: wordSpacing,
    textBaseline: textBaseline,
    height: height,
    foreground: foreground,
    background: background,
    shadows: shadows,
    decoration: decoration,
    decorationColor: decorationColor,
    decorationStyle: decorationStyle,
    debugLabel: debugLabel,
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    package: package
  );

  @override
  TextStyle styleFromTheme(TextTheme theme) {
    return theme.subhead;
  }
}

class Body2Text extends StyledText {

  Body2Text(
    String data, {
    Key key,
    TextStyleTheme theme = TextStyleTheme.normal,
    TextAlign textAlign,
    TextDirection textDirection,
    Locale locale,
    bool softWrap,
    TextOverflow overflow,
    double textScaleFactor,
    int maxLines,
    String semanticsLabel,
    Color color,
    double fontSize,
    FontWeight fontWeight,
    FontStyle fontStyle,
    double letterSpacing,
    double wordSpacing,
    TextBaseline textBaseline,
    double height,
    Paint foreground,
    Paint background,
    List<Shadow> shadows,
    TextDecoration decoration,
    Color decorationColor,
    TextDecorationStyle decorationStyle,
    String debugLabel,
    String fontFamily,
    List<String> fontFamilyFallback,
    String package
  }) : super(
    data,
    key: key,
    theme: theme,
    textAlign: textAlign,
    textDirection: textDirection,
    locale: locale,
    softWrap: softWrap,
    overflow: overflow,
    textScaleFactor: textScaleFactor,
    maxLines: maxLines,
    semanticsLabel: semanticsLabel,
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    fontStyle: fontStyle,
    letterSpacing: letterSpacing,
    wordSpacing: wordSpacing,
    textBaseline: textBaseline,
    height: height,
    foreground: foreground,
    background: background,
    shadows: shadows,
    decoration: decoration,
    decorationColor: decorationColor,
    decorationStyle: decorationStyle,
    debugLabel: debugLabel,
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    package: package
  );

  @override
  TextStyle styleFromTheme(TextTheme theme) {
    return theme.body2;
  }
}

class Body1Text extends StyledText {

  Body1Text(
    String data, {
    Key key,
    TextStyleTheme theme = TextStyleTheme.normal,
    TextAlign textAlign,
    TextDirection textDirection,
    Locale locale,
    bool softWrap,
    TextOverflow overflow,
    double textScaleFactor,
    int maxLines,
    String semanticsLabel,
    Color color,
    double fontSize,
    FontWeight fontWeight,
    FontStyle fontStyle,
    double letterSpacing,
    double wordSpacing,
    TextBaseline textBaseline,
    double height,
    Paint foreground,
    Paint background,
    List<Shadow> shadows,
    TextDecoration decoration,
    Color decorationColor,
    TextDecorationStyle decorationStyle,
    String debugLabel,
    String fontFamily,
    List<String> fontFamilyFallback,
    String package
  }) : super(
    data,
    key: key,
    theme: theme,
    textAlign: textAlign,
    textDirection: textDirection,
    locale: locale,
    softWrap: softWrap,
    overflow: overflow,
    textScaleFactor: textScaleFactor,
    maxLines: maxLines,
    semanticsLabel: semanticsLabel,
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    fontStyle: fontStyle,
    letterSpacing: letterSpacing,
    wordSpacing: wordSpacing,
    textBaseline: textBaseline,
    height: height,
    foreground: foreground,
    background: background,
    shadows: shadows,
    decoration: decoration,
    decorationColor: decorationColor,
    decorationStyle: decorationStyle,
    debugLabel: debugLabel,
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    package: package
  );

  @override
  TextStyle styleFromTheme(TextTheme theme) {
    return theme.body1;
  }
}

class CaptionText extends StyledText {

  CaptionText(
    String data, {
    Key key,
    TextStyleTheme theme = TextStyleTheme.normal,
    TextAlign textAlign,
    TextDirection textDirection,
    Locale locale,
    bool softWrap,
    TextOverflow overflow,
    double textScaleFactor,
    int maxLines,
    String semanticsLabel,
    Color color,
    double fontSize,
    FontWeight fontWeight,
    FontStyle fontStyle,
    double letterSpacing,
    double wordSpacing,
    TextBaseline textBaseline,
    double height,
    Paint foreground,
    Paint background,
    List<Shadow> shadows,
    TextDecoration decoration,
    Color decorationColor,
    TextDecorationStyle decorationStyle,
    String debugLabel,
    String fontFamily,
    List<String> fontFamilyFallback,
    String package
  }) : super(
    data,
    key: key,
    theme: theme,
    textAlign: textAlign,
    textDirection: textDirection,
    locale: locale,
    softWrap: softWrap,
    overflow: overflow,
    textScaleFactor: textScaleFactor,
    maxLines: maxLines,
    semanticsLabel: semanticsLabel,
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    fontStyle: fontStyle,
    letterSpacing: letterSpacing,
    wordSpacing: wordSpacing,
    textBaseline: textBaseline,
    height: height,
    foreground: foreground,
    background: background,
    shadows: shadows,
    decoration: decoration,
    decorationColor: decorationColor,
    decorationStyle: decorationStyle,
    debugLabel: debugLabel,
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    package: package
  );

  @override
  TextStyle styleFromTheme(TextTheme theme) {
    return theme.caption;
  }
}

class ButtonText extends StyledText {

  ButtonText(
    String data, {
    Key key,
    TextStyleTheme theme = TextStyleTheme.normal,
    TextAlign textAlign,
    TextDirection textDirection,
    Locale locale,
    bool softWrap,
    TextOverflow overflow,
    double textScaleFactor,
    int maxLines,
    String semanticsLabel,
    Color color,
    double fontSize,
    FontWeight fontWeight,
    FontStyle fontStyle,
    double letterSpacing,
    double wordSpacing,
    TextBaseline textBaseline,
    double height,
    Paint foreground,
    Paint background,
    List<Shadow> shadows,
    TextDecoration decoration,
    Color decorationColor,
    TextDecorationStyle decorationStyle,
    String debugLabel,
    String fontFamily,
    List<String> fontFamilyFallback,
    String package
  }) : super(
    data,
    key: key,
    theme: theme,
    textAlign: textAlign,
    textDirection: textDirection,
    locale: locale,
    softWrap: softWrap,
    overflow: overflow,
    textScaleFactor: textScaleFactor,
    maxLines: maxLines,
    semanticsLabel: semanticsLabel,
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    fontStyle: fontStyle,
    letterSpacing: letterSpacing,
    wordSpacing: wordSpacing,
    textBaseline: textBaseline,
    height: height,
    foreground: foreground,
    background: background,
    shadows: shadows,
    decoration: decoration,
    decorationColor: decorationColor,
    decorationStyle: decorationStyle,
    debugLabel: debugLabel,
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    package: package
  );

  @override
  TextStyle styleFromTheme(TextTheme theme) {
    return theme.button;
  }
}

class SubtitleText extends StyledText {

  SubtitleText(
    String data, {
    Key key,
    TextStyleTheme theme = TextStyleTheme.normal,
    TextAlign textAlign,
    TextDirection textDirection,
    Locale locale,
    bool softWrap,
    TextOverflow overflow,
    double textScaleFactor,
    int maxLines,
    String semanticsLabel,
    Color color,
    double fontSize,
    FontWeight fontWeight,
    FontStyle fontStyle,
    double letterSpacing,
    double wordSpacing,
    TextBaseline textBaseline,
    double height,
    Paint foreground,
    Paint background,
    List<Shadow> shadows,
    TextDecoration decoration,
    Color decorationColor,
    TextDecorationStyle decorationStyle,
    String debugLabel,
    String fontFamily,
    List<String> fontFamilyFallback,
    String package
  }) : super(
    data,
    key: key,
    theme: theme,
    textAlign: textAlign,
    textDirection: textDirection,
    locale: locale,
    softWrap: softWrap,
    overflow: overflow,
    textScaleFactor: textScaleFactor,
    maxLines: maxLines,
    semanticsLabel: semanticsLabel,
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    fontStyle: fontStyle,
    letterSpacing: letterSpacing,
    wordSpacing: wordSpacing,
    textBaseline: textBaseline,
    height: height,
    foreground: foreground,
    background: background,
    shadows: shadows,
    decoration: decoration,
    decorationColor: decorationColor,
    decorationStyle: decorationStyle,
    debugLabel: debugLabel,
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    package: package
  );

  @override
  TextStyle styleFromTheme(TextTheme theme) {
    return theme.subtitle;
  }
}

class OverlineText extends StyledText {

  OverlineText(
    String data, {
    Key key,
    TextStyleTheme theme = TextStyleTheme.normal,
    TextAlign textAlign,
    TextDirection textDirection,
    Locale locale,
    bool softWrap,
    TextOverflow overflow,
    double textScaleFactor,
    int maxLines,
    String semanticsLabel,
    Color color,
    double fontSize,
    FontWeight fontWeight,
    FontStyle fontStyle,
    double letterSpacing,
    double wordSpacing,
    TextBaseline textBaseline,
    double height,
    Paint foreground,
    Paint background,
    List<Shadow> shadows,
    TextDecoration decoration,
    Color decorationColor,
    TextDecorationStyle decorationStyle,
    String debugLabel,
    String fontFamily,
    List<String> fontFamilyFallback,
    String package
  }) : super(
    data,
    key: key,
    theme: theme,
    textAlign: textAlign,
    textDirection: textDirection,
    locale: locale,
    softWrap: softWrap,
    overflow: overflow,
    textScaleFactor: textScaleFactor,
    maxLines: maxLines,
    semanticsLabel: semanticsLabel,
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    fontStyle: fontStyle,
    letterSpacing: letterSpacing,
    wordSpacing: wordSpacing,
    textBaseline: textBaseline,
    height: height,
    foreground: foreground,
    background: background,
    shadows: shadows,
    decoration: decoration,
    decorationColor: decorationColor,
    decorationStyle: decorationStyle,
    debugLabel: debugLabel,
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    package: package
  );

  @override
  TextStyle styleFromTheme(TextTheme theme) {
    return theme.overline;
  }
}