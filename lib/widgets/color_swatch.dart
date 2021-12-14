import 'package:flutter/material.dart';

class AlienColorSwatchData {

  factory AlienColorSwatchData.dark() {
    return const AlienColorSwatchData.raw(
      mainSurface: Color(0xFF212121),
      altSurface: Color(0xFF424242),
      mainText: Color(0xFFFFFFFF),
      detailText: Color(0xB3FFFFFF),
    );
  }

  const AlienColorSwatchData.raw({
    required this.mainSurface,
    required this.altSurface,
    required this.mainText,
    required this.detailText,
  });

  final Color mainSurface;

  final Color altSurface;

  final Color mainText;

  final Color detailText;
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
