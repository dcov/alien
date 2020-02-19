import 'package:flutter/widgets.dart';

import '../widgets/tile.dart';

import 'defaults_model.dart';

class DefaultsTile extends StatelessWidget {

  DefaultsTile({
    Key key,
    @required this.defaults
  }) : super(key: key);

  final Defaults defaults;

  @override
  Widget build(BuildContext context) {
    return CustomTile(
      onTap: () { },
      title: Text('Defaults')
    );
  }
}

