import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:muex_flutter/muex_flutter.dart';

import 'core/media.dart';
import 'core/snudown.dart';

class SnudownView extends StatelessWidget {

  SnudownView({
    Key? key,
    required this.snudown,
  }) : super(key: key);

  final Snudown snudown;

  @override
  Widget build(_) => Connector(builder: (BuildContext context) {
    return MarkdownBody(
      data: snudown.data,
      onTapLink: (String text, String? ref, String title) {
        final link = snudown.links[ref!];
        if (link is Media) {
          // TODO: handle opening media links
        }
      }
    );
  });
}
