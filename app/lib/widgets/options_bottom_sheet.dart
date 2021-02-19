import 'package:flutter/material.dart';

import 'tile.dart';

class Option {

  Option({
    required this.onSelected,
    required this.title,
    this.icon
  });

  final VoidCallback onSelected;

  final String title;

  final IconData? icon;
}

void showOptionsBottomSheet({
    required BuildContext context,
    List<Option> options = const <Option>[]
  }) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        expand: false,
        maxChildSize: 0.5,
        builder: (BuildContext context, ScrollController controller) {
          return ListView(
            shrinkWrap: true,
            controller: controller,
            children: options.map((Option option) {
              return CustomTile(
                onTap: () {
                  Navigator.pop(context);
                  option.onSelected();
                },
                title: Text(
                  option.title,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500)),
                icon: option.icon != null ? Icon(option.icon) : null);
            }).toList());
        });
    });
}
