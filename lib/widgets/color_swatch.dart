import 'package:flutter/material.dart';

class AlienColorSwatchData {

  factory AlienColorSwatchData.dark() {
    return const AlienColorSwatchData.raw(
      surface: Color(0xFF212121),
      divider: Color(0xFF424242),
      text: Color(0xFFFFFFFF),
      textVariant: Color(0xB3FFFFFF),
    );
  }

  const AlienColorSwatchData.raw({
    required this.surface,
    required this.divider,
    required this.text,
    required this.textVariant,
  });

  final Color surface;

  final Color divider;

  final Color text;

  final Color textVariant;
}

class AlienColorSwatch extends InheritedWidget {

  AlienColorSwatch({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  final AlienColorSwatchData data;

  static AlienColorSwatchData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AlienColorSwatch>()!.data;
  }

  @override
  bool updateShouldNotify(AlienColorSwatch oldWidget) {
    return this.data != oldWidget.data;
  }
}
